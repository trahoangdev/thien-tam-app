import express from 'express';
import * as bookController from '../controllers/bookController';
import { requireAuth } from '../middlewares/auth';
import { uploadBook } from '../middlewares/upload';

const router = express.Router();

/**
 * @swagger
 * components:
 *   schemas:
 *     Book:
 *       type: object
 *       required:
 *         - title
 *         - category
 *         - cloudinaryPublicId
 *         - cloudinaryUrl
 *         - uploadedBy
 *       properties:
 *         _id:
 *           type: string
 *         title:
 *           type: string
 *           maxLength: 300
 *         author:
 *           type: string
 *           maxLength: 200
 *         translator:
 *           type: string
 *           maxLength: 200
 *         description:
 *           type: string
 *           maxLength: 2000
 *         category:
 *           type: string
 *           enum: [sutra, commentary, biography, practice, dharma-talk, history, philosophy, other]
 *         tags:
 *           type: array
 *           items:
 *             type: string
 *         bookLanguage:
 *           type: string
 *           enum: [vi, en, zh, pi, sa]
 *           default: vi
 *         cloudinaryPublicId:
 *           type: string
 *         cloudinaryUrl:
 *           type: string
 *         cloudinarySecureUrl:
 *           type: string
 *         fileSize:
 *           type: number
 *         pageCount:
 *           type: number
 *         coverImageUrl:
 *           type: string
 *         coverImagePublicId:
 *           type: string
 *         publisher:
 *           type: string
 *         publishYear:
 *           type: number
 *         isbn:
 *           type: string
 *         downloadCount:
 *           type: number
 *           default: 0
 *         viewCount:
 *           type: number
 *           default: 0
 *         isPublic:
 *           type: boolean
 *           default: true
 *         uploadedBy:
 *           type: string
 *         createdAt:
 *           type: string
 *           format: date-time
 *         updatedAt:
 *           type: string
 *           format: date-time
 */

/**
 * @swagger
 * /books/upload:
 *   post:
 *     summary: Upload book with PDF file and optional cover image
 *     tags: [Books Library]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         multipart/form-data:
 *           schema:
 *             type: object
 *             required:
 *               - pdf
 *               - title
 *               - category
 *             properties:
 *               pdf:
 *                 type: string
 *                 format: binary
 *                 description: PDF file (max 100MB)
 *               cover:
 *                 type: string
 *                 format: binary
 *                 description: Cover image (optional, max 5MB)
 *               title:
 *                 type: string
 *               author:
 *                 type: string
 *               translator:
 *                 type: string
 *               description:
 *                 type: string
 *               category:
 *                 type: string
 *                 enum: [sutra, commentary, biography, practice, dharma-talk, history, philosophy, other]
 *               tags:
 *                 type: array
 *                 items:
 *                   type: string
 *               language:
 *                 type: string
 *                 enum: [vi, en, zh, pi, sa]
 *               publisher:
 *                 type: string
 *               publishYear:
 *                 type: number
 *               isbn:
 *                 type: string
 *               pageCount:
 *                 type: number
 *               isPublic:
 *                 type: boolean
 *     responses:
 *       201:
 *         description: Book uploaded successfully
 *       400:
 *         description: Validation error or no file uploaded
 *       401:
 *         description: Unauthorized
 *       500:
 *         description: Server error
 */
router.post('/upload', requireAuth, uploadBook, bookController.uploadBook);

/**
 * @swagger
 * /books/from-url:
 *   post:
 *     summary: Create book from Cloudinary URLs (PDF + optional cover)
 *     tags: [Books Library]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - pdfUrl
 *               - title
 *               - category
 *             properties:
 *               pdfUrl:
 *                 type: string
 *                 format: uri
 *               coverImageUrl:
 *                 type: string
 *                 format: uri
 *               title:
 *                 type: string
 *               author:
 *                 type: string
 *               translator:
 *                 type: string
 *               description:
 *                 type: string
 *               category:
 *                 type: string
 *                 enum: [sutra, commentary, biography, practice, dharma-talk, history, philosophy, other]
 *               tags:
 *                 type: array
 *                 items:
 *                   type: string
 *               language:
 *                 type: string
 *               publisher:
 *                 type: string
 *               publishYear:
 *                 type: number
 *               isbn:
 *                 type: string
 *               pageCount:
 *                 type: number
 *               fileSize:
 *                 type: number
 *               isPublic:
 *                 type: boolean
 *     responses:
 *       201:
 *         description: Book created successfully
 *       400:
 *         description: Validation error
 *       401:
 *         description: Unauthorized
 *       500:
 *         description: Server error
 */
router.post('/from-url', requireAuth, bookController.createBookFromUrl);

/**
 * @swagger
 * /books:
 *   get:
 *     summary: Get all books with filters
 *     tags: [Books Library]
 *     parameters:
 *       - in: query
 *         name: category
 *         schema:
 *           type: string
 *       - in: query
 *         name: tags
 *         schema:
 *           type: string
 *         description: Comma-separated tags
 *       - in: query
 *         name: search
 *         schema:
 *           type: string
 *       - in: query
 *         name: bookLanguage
 *         schema:
 *           type: string
 *       - in: query
 *         name: isPublic
 *         schema:
 *           type: boolean
 *       - in: query
 *         name: page
 *         schema:
 *           type: integer
 *           default: 1
 *       - in: query
 *         name: limit
 *         schema:
 *           type: integer
 *           default: 20
 *       - in: query
 *         name: sortBy
 *         schema:
 *           type: string
 *           default: createdAt
 *       - in: query
 *         name: sortOrder
 *         schema:
 *           type: string
 *           enum: [asc, desc]
 *           default: desc
 *     responses:
 *       200:
 *         description: List of books
 *       500:
 *         description: Server error
 */
router.get('/', bookController.getAllBooks);

/**
 * @swagger
 * /books/categories:
 *   get:
 *     summary: Get all book categories
 *     tags: [Books Library]
 *     responses:
 *       200:
 *         description: List of categories
 *       500:
 *         description: Server error
 */
router.get('/categories', bookController.getCategories);

/**
 * @swagger
 * /books/popular:
 *   get:
 *     summary: Get popular books by download count
 *     tags: [Books Library]
 *     parameters:
 *       - in: query
 *         name: limit
 *         schema:
 *           type: integer
 *           default: 10
 *     responses:
 *       200:
 *         description: List of popular books
 *       500:
 *         description: Server error
 */
router.get('/popular', bookController.getPopularBooks);

/**
 * @swagger
 * /books/{id}:
 *   get:
 *     summary: Get book by ID
 *     tags: [Books Library]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Book details
 *       404:
 *         description: Book not found
 *       500:
 *         description: Server error
 */
router.get('/:id', bookController.getBookById);

/**
 * @swagger
 * /books/{id}:
 *   put:
 *     summary: Update book metadata
 *     tags: [Books Library]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               title:
 *                 type: string
 *               author:
 *                 type: string
 *               translator:
 *                 type: string
 *               description:
 *                 type: string
 *               category:
 *                 type: string
 *               tags:
 *                 type: array
 *                 items:
 *                   type: string
 *               language:
 *                 type: string
 *               publisher:
 *                 type: string
 *               publishYear:
 *                 type: number
 *               isbn:
 *                 type: string
 *               pageCount:
 *                 type: number
 *               isPublic:
 *                 type: boolean
 *     responses:
 *       200:
 *         description: Book updated successfully
 *       400:
 *         description: Validation error
 *       401:
 *         description: Unauthorized
 *       404:
 *         description: Book not found
 *       500:
 *         description: Server error
 */
router.put('/:id', requireAuth, bookController.updateBook);

/**
 * @swagger
 * /books/{id}:
 *   delete:
 *     summary: Delete book
 *     tags: [Books Library]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Book deleted successfully
 *       401:
 *         description: Unauthorized
 *       404:
 *         description: Book not found
 *       500:
 *         description: Server error
 */
router.delete('/:id', requireAuth, bookController.deleteBook);

/**
 * @swagger
 * /books/{id}/download:
 *   post:
 *     summary: Increment download count
 *     tags: [Books Library]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Download count incremented
 *       404:
 *         description: Book not found
 *       500:
 *         description: Server error
 */
router.post('/:id/download', bookController.incrementDownloadCount);

/**
 * @swagger
 * /books/{id}/view:
 *   post:
 *     summary: Increment view count
 *     tags: [Books Library]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: View count incremented
 *       404:
 *         description: Book not found
 *       500:
 *         description: Server error
 */
router.post('/:id/view', bookController.incrementViewCount);

export default router;

