import { Request, Response } from 'express';
import { BookCategory, IBookCategory } from '../models/BookCategory';
import Book from '../models/Book';
import { z } from 'zod';

// Validation schemas
const createCategorySchema = z.object({
  name: z.string().min(1, 'Tên danh mục là bắt buộc'),
  nameEn: z.string().optional(),
  description: z.string().optional(),
  icon: z.string().optional(),
  color: z.string().optional(),
  displayOrder: z.number().int().min(0).optional(),
  isActive: z.boolean().optional(),
});

const updateCategorySchema = createCategorySchema.partial();

/**
 * Get all book categories
 */
export const getAllCategories = async (req: Request, res: Response) => {
  try {
    const { isActive } = req.query;

    const query: any = {};
    if (isActive !== undefined) {
      query.isActive = isActive === 'true';
    }

    const categories = await BookCategory.find(query).sort({
      displayOrder: 1,
      name: 1,
    });

    res.json({
      success: true,
      data: categories,
      total: categories.length,
    });
  } catch (error: any) {
    console.error('Get categories error:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi lấy danh sách danh mục',
      error: error.message,
    });
  }
};

/**
 * Get category by ID
 */
export const getCategoryById = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;

    const category = await BookCategory.findById(id);

    if (!category) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy danh mục',
      });
    }

    res.json({
      success: true,
      data: category,
    });
  } catch (error: any) {
    console.error('Get category error:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi lấy thông tin danh mục',
      error: error.message,
    });
  }
};

/**
 * Create new book category
 */
export const createCategory = async (req: Request, res: Response) => {
  try {
    // Validate request body
    const validatedData = createCategorySchema.parse(req.body);

    // Check if category already exists
    const existingCategory = await BookCategory.findOne({
      name: validatedData.name,
    });

    if (existingCategory) {
      return res.status(400).json({
        success: false,
        message: 'Danh mục này đã tồn tại',
      });
    }

    // Create new category
    const category = new BookCategory(validatedData);
    await category.save();

    res.status(201).json({
      success: true,
      message: 'Tạo danh mục thành công',
      data: category,
    });
  } catch (error: any) {
    console.error('Create category error:', error);

    if (error instanceof z.ZodError) {
      return res.status(400).json({
        success: false,
        message: 'Dữ liệu không hợp lệ',
        errors: error.errors,
      });
    }

    res.status(500).json({
      success: false,
      message: 'Lỗi khi tạo danh mục',
      error: error.message,
    });
  }
};

/**
 * Update book category
 */
export const updateCategory = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;

    // Validate request body
    const validatedData = updateCategorySchema.parse(req.body);

    // Check if category exists
    const category = await BookCategory.findById(id);

    if (!category) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy danh mục',
      });
    }

    // Check if name is being changed and already exists
    if (validatedData.name && validatedData.name !== category.name) {
      const existingCategory = await BookCategory.findOne({
        name: validatedData.name,
        _id: { $ne: id },
      });

      if (existingCategory) {
        return res.status(400).json({
          success: false,
          message: 'Tên danh mục này đã tồn tại',
        });
      }
    }

    // Update category
    Object.assign(category, validatedData);
    await category.save();

    res.json({
      success: true,
      message: 'Cập nhật danh mục thành công',
      data: category,
    });
  } catch (error: any) {
    console.error('Update category error:', error);

    if (error instanceof z.ZodError) {
      return res.status(400).json({
        success: false,
        message: 'Dữ liệu không hợp lệ',
        errors: error.errors,
      });
    }

    res.status(500).json({
      success: false,
      message: 'Lỗi khi cập nhật danh mục',
      error: error.message,
    });
  }
};

/**
 * Delete book category
 */
export const deleteCategory = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;

    // Check if category exists
    const category = await BookCategory.findById(id);

    if (!category) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy danh mục',
      });
    }

    // Check if category has books
    const bookCount = await Book.countDocuments({ category: id });

    if (bookCount > 0) {
      return res.status(400).json({
        success: false,
        message: `Không thể xóa danh mục này vì còn ${bookCount} sách đang sử dụng`,
      });
    }

    // Delete category
    await BookCategory.findByIdAndDelete(id);

    res.json({
      success: true,
      message: 'Xóa danh mục thành công',
    });
  } catch (error: any) {
    console.error('Delete category error:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi xóa danh mục',
      error: error.message,
    });
  }
};

/**
 * Update category book count
 */
export const updateCategoryBookCount = async (categoryId: string) => {
  try {
    const count = await Book.countDocuments({ category: categoryId });
    await BookCategory.findByIdAndUpdate(categoryId, { bookCount: count });
  } catch (error) {
    console.error('Update category book count error:', error);
  }
};

/**
 * Reorder categories
 */
export const reorderCategories = async (req: Request, res: Response) => {
  try {
    const { categoryIds } = req.body;

    if (!Array.isArray(categoryIds)) {
      return res.status(400).json({
        success: false,
        message: 'categoryIds phải là một mảng',
      });
    }

    // Update display order for each category
    const updatePromises = categoryIds.map((id, index) =>
      BookCategory.findByIdAndUpdate(id, { displayOrder: index })
    );

    await Promise.all(updatePromises);

    res.json({
      success: true,
      message: 'Sắp xếp danh mục thành công',
    });
  } catch (error: any) {
    console.error('Reorder categories error:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi sắp xếp danh mục',
      error: error.message,
    });
  }
};

