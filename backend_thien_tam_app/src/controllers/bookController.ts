import { Request, Response } from 'express';
import { z } from 'zod';
import Book, { BookCategory } from '../models/Book';
import cloudinaryService from '../services/cloudinaryService';
import fs from 'fs';
import path from 'path';
import os from 'os';

// Validation schemas
const createBookSchema = z.object({
  title: z.string().min(1).max(300),
  author: z.string().max(200).optional(),
  translator: z.string().max(200).optional(),
  description: z.string().max(2000).optional(),
  category: z.enum([
    'sutra',
    'commentary',
    'biography',
    'practice',
    'dharma-talk',
    'history',
    'philosophy',
    'other',
  ]),
  tags: z.array(z.string()).max(15).optional(),
  bookLanguage: z.enum(['vi', 'en', 'zh', 'pi', 'sa']).optional(),
  publisher: z.string().max(200).optional(),
  publishYear: z.number().int().min(1000).max(new Date().getFullYear() + 1).optional(),
  isbn: z.string().max(20).optional(),
  pageCount: z.number().int().min(1).optional(),
  isPublic: z.boolean().optional(),
});

const createBookFromUrlSchema = z.object({
  pdfUrl: z.string().url(),
  coverImageUrl: z.string().url().optional(),
  title: z.string().min(1).max(300),
  author: z.string().max(200).optional(),
  translator: z.string().max(200).optional(),
  description: z.string().max(2000).optional(),
  category: z.enum([
    'sutra',
    'commentary',
    'biography',
    'practice',
    'dharma-talk',
    'history',
    'philosophy',
    'other',
  ]),
  tags: z.array(z.string()).max(15).optional(),
  bookLanguage: z.enum(['vi', 'en', 'zh', 'pi', 'sa']).optional(),
  publisher: z.string().max(200).optional(),
  publishYear: z.number().int().optional(),
  isbn: z.string().max(20).optional(),
  pageCount: z.number().int().optional(),
  fileSize: z.number().int().optional(),
  isPublic: z.boolean().optional(),
});

const updateBookSchema = z.object({
  title: z.string().min(1).max(300).optional(),
  author: z.string().max(200).optional(),
  translator: z.string().max(200).optional(),
  description: z.string().max(2000).optional(),
  category: z.enum([
    'sutra',
    'commentary',
    'biography',
    'practice',
    'dharma-talk',
    'history',
    'philosophy',
    'other',
  ]).optional(),
  tags: z.array(z.string()).max(15).optional(),
  bookLanguage: z.enum(['vi', 'en', 'zh', 'pi', 'sa']).optional(),
  publisher: z.string().max(200).optional(),
  publishYear: z.number().int().optional(),
  isbn: z.string().max(20).optional(),
  pageCount: z.number().int().optional(),
  isPublic: z.boolean().optional(),
});

/**
 * Upload book with PDF file
 */
export const uploadBook = async (req: Request, res: Response) => {
  const tempPdfPath = path.join(os.tmpdir(), `pdf-${Date.now()}.pdf`);
  const tempCoverPath = req.files && (req.files as any).cover
    ? path.join(os.tmpdir(), `cover-${Date.now()}.jpg`)
    : null;

  try {
    // Check if PDF file is uploaded
    if (!req.files || !(req.files as any).pdf) {
      return res.status(400).json({ message: 'No PDF file uploaded' });
    }

    const pdfFile = (req.files as any).pdf[0];
    const coverFile = (req.files as any).cover ? (req.files as any).cover[0] : null;

    // Parse form data
    const bodyData = {
      ...req.body,
      tags: req.body.tags
        ? (Array.isArray(req.body.tags)
            ? req.body.tags
            : req.body.tags.split(',').map((t: string) => t.trim()).filter((t: string) => t))
        : undefined,
      isPublic: req.body.isPublic !== undefined
        ? (req.body.isPublic === 'true' || req.body.isPublic === true)
        : undefined,
      pageCount: req.body.pageCount ? parseInt(req.body.pageCount) : undefined,
      publishYear: req.body.publishYear ? parseInt(req.body.publishYear) : undefined,
    };

    // Validate data
    const validatedData = createBookSchema.parse(bodyData);

    // Save PDF to temp file
    fs.writeFileSync(tempPdfPath, pdfFile.buffer);

    // Upload PDF to Cloudinary
    const pdfUploadResult = await cloudinaryService.uploadPDF(tempPdfPath, {
      folder: 'thientam/books',
      tags: validatedData.tags || [],
    });

    // Upload cover image if provided
    let coverUploadResult = null;
    if (coverFile) {
      fs.writeFileSync(tempCoverPath!, coverFile.buffer);
      coverUploadResult = await cloudinaryService.uploadCoverImage(tempCoverPath!, {
        folder: 'thientam/book-covers',
        tags: [`book-${pdfUploadResult.publicId}`],
      });
    }

    // Create book record
    const book = new Book({
      ...validatedData,
      cloudinaryPublicId: pdfUploadResult.publicId,
      cloudinaryUrl: pdfUploadResult.url,
      cloudinarySecureUrl: pdfUploadResult.secureUrl,
      fileSize: pdfUploadResult.bytes,
      coverImageUrl: coverUploadResult?.secureUrl,
      coverImagePublicId: coverUploadResult?.publicId,
      uploadedBy: req.userId,
      isPublic: validatedData.isPublic ?? true,
      bookLanguage: validatedData.bookLanguage || 'vi',
    });

    await book.save();

    // Clean up temp files
    fs.unlinkSync(tempPdfPath);
    if (tempCoverPath && fs.existsSync(tempCoverPath)) {
      fs.unlinkSync(tempCoverPath);
    }

    res.status(201).json({
      message: 'Book uploaded successfully',
      book,
    });
  } catch (error: any) {
    // Clean up temp files on error
    if (fs.existsSync(tempPdfPath)) {
      fs.unlinkSync(tempPdfPath);
    }
    if (tempCoverPath && fs.existsSync(tempCoverPath)) {
      fs.unlinkSync(tempCoverPath);
    }

    console.error('[BOOK] Upload error:', error);

    if (error instanceof z.ZodError) {
      return res.status(400).json({
        message: 'Validation error',
        errors: error.errors,
      });
    }

    res.status(500).json({
      message: 'Failed to upload book',
      error: error.message,
    });
  }
};

/**
 * Create book from URLs (PDF + optional cover image)
 */
export const createBookFromUrl = async (req: Request, res: Response) => {
  try {
    const validatedData = createBookFromUrlSchema.parse(req.body);

    // Extract public IDs from URLs
    const pdfPublicId = extractPublicIdFromUrl(validatedData.pdfUrl);
    const coverPublicId = validatedData.coverImageUrl
      ? extractPublicIdFromUrl(validatedData.coverImageUrl)
      : undefined;

    // Create book record
    const book = new Book({
      title: validatedData.title,
      author: validatedData.author,
      translator: validatedData.translator,
      description: validatedData.description,
      category: validatedData.category,
      tags: validatedData.tags || [],
      bookLanguage: validatedData.bookLanguage || 'vi',
      cloudinaryPublicId: pdfPublicId,
      cloudinaryUrl: validatedData.pdfUrl,
      cloudinarySecureUrl: validatedData.pdfUrl.replace('http://', 'https://'),
      fileSize: validatedData.fileSize || 0,
      pageCount: validatedData.pageCount,
      coverImageUrl: validatedData.coverImageUrl,
      coverImagePublicId: coverPublicId,
      publisher: validatedData.publisher,
      publishYear: validatedData.publishYear,
      isbn: validatedData.isbn,
      uploadedBy: req.userId,
      isPublic: validatedData.isPublic ?? true,
    });

    await book.save();

    res.status(201).json({
      message: 'Book created successfully from URL',
      book,
    });
  } catch (error: any) {
    console.error('[BOOK] Create from URL error:', error);

    if (error instanceof z.ZodError) {
      return res.status(400).json({
        message: 'Validation error',
        errors: error.errors,
      });
    }

    res.status(500).json({
      message: 'Failed to create book from URL',
      error: error.message,
    });
  }
};

/**
 * Get all books with filters
 */
export const getAllBooks = async (req: Request, res: Response) => {
  try {
    const {
      category,
      tags,
      search,
      bookLanguage,
      isPublic,
      page = 1,
      limit = 20,
      sortBy = 'createdAt',
      sortOrder = 'desc',
    } = req.query as any;

    const p = Math.max(parseInt(page), 1);
    const l = Math.min(Math.max(parseInt(limit), 1), 100);

    // Build filter
    const filter: any = {};

    if (category) filter.category = category;
    if (bookLanguage) filter.bookLanguage = bookLanguage;
    if (isPublic !== undefined) filter.isPublic = isPublic === 'true';
    if (tags) {
      const tagArray = tags.split(',').map((t: string) => t.trim());
      filter.tags = { $in: tagArray };
    }
    if (search) {
      filter.$text = { $search: search };
    }

    // Build sort
    const sort: any = {};
    sort[sortBy] = sortOrder === 'asc' ? 1 : -1;

    // Execute query
    const books = await Book.find(filter)
      .populate('uploadedBy', 'username email')
      .sort(sort)
      .skip((p - 1) * l)
      .limit(l)
      .lean();

    const total = await Book.countDocuments(filter);

    res.json({
      books,
      total,
      page: p,
      totalPages: Math.ceil(total / l),
    });
  } catch (error: any) {
    console.error('[BOOK] Get all error:', error);
    res.status(500).json({
      message: 'Failed to fetch books',
      error: error.message,
    });
  }
};

/**
 * Get book by ID
 */
export const getBookById = async (req: Request, res: Response) => {
  try {
    const book = await Book.findById(req.params.id).populate('uploadedBy', 'username email');

    if (!book) {
      return res.status(404).json({ message: 'Book not found' });
    }

    res.json({ book });
  } catch (error: any) {
    console.error('[BOOK] Get by ID error:', error);
    res.status(500).json({
      message: 'Failed to fetch book',
      error: error.message,
    });
  }
};

/**
 * Update book metadata
 */
export const updateBook = async (req: Request, res: Response) => {
  try {
    const validatedData = updateBookSchema.parse(req.body);

    const book = await Book.findByIdAndUpdate(req.params.id, validatedData, {
      new: true,
      runValidators: true,
    });

    if (!book) {
      return res.status(404).json({ message: 'Book not found' });
    }

    res.json({
      message: 'Book updated successfully',
      book,
    });
  } catch (error: any) {
    console.error('[BOOK] Update error:', error);

    if (error instanceof z.ZodError) {
      return res.status(400).json({
        message: 'Validation error',
        errors: error.errors,
      });
    }

    res.status(500).json({
      message: 'Failed to update book',
      error: error.message,
    });
  }
};

/**
 * Delete book
 */
export const deleteBook = async (req: Request, res: Response) => {
  try {
    const book = await Book.findById(req.params.id);

    if (!book) {
      return res.status(404).json({ message: 'Book not found' });
    }

    // Delete PDF from Cloudinary
    await cloudinaryService.deletePDF(book.cloudinaryPublicId);

    // Delete cover image if exists
    if (book.coverImagePublicId) {
      await cloudinaryService.deleteCoverImage(book.coverImagePublicId);
    }

    // Delete book record
    await Book.findByIdAndDelete(req.params.id);

    res.json({ message: 'Book deleted successfully' });
  } catch (error: any) {
    console.error('[BOOK] Delete error:', error);
    res.status(500).json({
      message: 'Failed to delete book',
      error: error.message,
    });
  }
};

/**
 * Increment download count
 */
export const incrementDownloadCount = async (req: Request, res: Response) => {
  try {
    const book = await Book.findById(req.params.id);

    if (!book) {
      return res.status(404).json({ message: 'Book not found' });
    }

    await book.incrementDownloadCount();

    res.json({ message: 'Download count incremented', downloadCount: book.downloadCount });
  } catch (error: any) {
    console.error('[BOOK] Increment download error:', error);
    res.status(500).json({
      message: 'Failed to increment download count',
      error: error.message,
    });
  }
};

/**
 * Increment view count
 */
export const incrementViewCount = async (req: Request, res: Response) => {
  try {
    const book = await Book.findById(req.params.id);

    if (!book) {
      return res.status(404).json({ message: 'Book not found' });
    }

    await book.incrementViewCount();

    res.json({ message: 'View count incremented', viewCount: book.viewCount });
  } catch (error: any) {
    console.error('[BOOK] Increment view error:', error);
    res.status(500).json({
      message: 'Failed to increment view count',
      error: error.message,
    });
  }
};

/**
 * Get book categories
 */
export const getCategories = async (req: Request, res: Response) => {
  try {
    const categories = Object.values(BookCategory).map((cat) => ({
      value: cat,
      label: getCategoryLabel(cat),
    }));

    res.json({ categories });
  } catch (error: any) {
    console.error('[BOOK] Get categories error:', error);
    res.status(500).json({
      message: 'Failed to fetch categories',
      error: error.message,
    });
  }
};

/**
 * Get popular books by download count
 */
export const getPopularBooks = async (req: Request, res: Response) => {
  try {
    const limit = Math.min(parseInt(req.query.limit as string) || 10, 50);

    const books = await Book.find({ isPublic: true })
      .sort({ downloadCount: -1, viewCount: -1 })
      .limit(limit)
      .populate('uploadedBy', 'username email')
      .lean();

    res.json({ books });
  } catch (error: any) {
    console.error('[BOOK] Get popular error:', error);
    res.status(500).json({
      message: 'Failed to fetch popular books',
      error: error.message,
    });
  }
};

// Helper functions
function extractPublicIdFromUrl(url: string): string {
  const parts = url.split('/');
  const fileNameWithExt = parts[parts.length - 1];
  const fileName = fileNameWithExt.split('.')[0];
  const versionIndex = parts.findIndex((part) => part.startsWith('v'));
  return versionIndex !== -1
    ? parts.slice(versionIndex + 1, -1).join('/') + '/' + fileName
    : fileName;
}

function getCategoryLabel(category: BookCategory): string {
  const labels: Record<BookCategory, string> = {
    [BookCategory.SUTRA]: 'Kinh điển',
    [BookCategory.COMMENTARY]: 'Luận giải',
    [BookCategory.BIOGRAPHY]: 'Tiểu sử, truyện',
    [BookCategory.PRACTICE]: 'Hướng dẫn tu tập',
    [BookCategory.DHARMA_TALK]: 'Pháp thoại',
    [BookCategory.HISTORY]: 'Lịch sử Phật giáo',
    [BookCategory.PHILOSOPHY]: 'Triết học',
    [BookCategory.OTHER]: 'Khác',
  };
  return labels[category] || category;
}

