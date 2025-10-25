import express from 'express';
import {
  getAllCategories,
  getCategoryById,
  createCategory,
  updateCategory,
  deleteCategory,
  reorderCategories,
} from '../controllers/bookCategoryController';
import { requireAuth } from '../middlewares/auth';

const router = express.Router();

/**
 * @swagger
 * tags:
 *   name: Book Categories
 *   description: Book category management endpoints
 */

/**
 * @swagger
 * /book-categories:
 *   get:
 *     summary: Get all book categories
 *     tags: [Book Categories]
 *     parameters:
 *       - in: query
 *         name: isActive
 *         schema:
 *           type: boolean
 *         description: Filter by active status
 *     responses:
 *       200:
 *         description: List of book categories
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                 data:
 *                   type: array
 *                   items:
 *                     type: object
 *                     properties:
 *                       _id:
 *                         type: string
 *                       name:
 *                         type: string
 *                       nameEn:
 *                         type: string
 *                       description:
 *                         type: string
 *                       icon:
 *                         type: string
 *                       color:
 *                         type: string
 *                       displayOrder:
 *                         type: number
 *                       isActive:
 *                         type: boolean
 *                       bookCount:
 *                         type: number
 *                       createdAt:
 *                         type: string
 *                         format: date-time
 *                       updatedAt:
 *                         type: string
 *                         format: date-time
 *                 total:
 *                   type: number
 */
router.get('/', getAllCategories);

/**
 * @swagger
 * /book-categories/{id}:
 *   get:
 *     summary: Get book category by ID
 *     tags: [Book Categories]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: Category ID
 *     responses:
 *       200:
 *         description: Book category details
 *       404:
 *         description: Category not found
 */
router.get('/:id', getCategoryById);

/**
 * @swagger
 * /book-categories:
 *   post:
 *     summary: Create new book category (Admin only)
 *     tags: [Book Categories]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - name
 *             properties:
 *               name:
 *                 type: string
 *                 description: Category name in Vietnamese
 *               nameEn:
 *                 type: string
 *                 description: Category name in English
 *               description:
 *                 type: string
 *               icon:
 *                 type: string
 *                 description: Emoji icon
 *               color:
 *                 type: string
 *                 description: Hex color code
 *               displayOrder:
 *                 type: number
 *               isActive:
 *                 type: boolean
 *     responses:
 *       201:
 *         description: Category created successfully
 *       400:
 *         description: Invalid data or category already exists
 *       401:
 *         description: Unauthorized
 */
router.post('/', requireAuth, createCategory);

/**
 * @swagger
 * /book-categories/{id}:
 *   put:
 *     summary: Update book category (Admin only)
 *     tags: [Book Categories]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: Category ID
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               name:
 *                 type: string
 *               nameEn:
 *                 type: string
 *               description:
 *                 type: string
 *               icon:
 *                 type: string
 *               color:
 *                 type: string
 *               displayOrder:
 *                 type: number
 *               isActive:
 *                 type: boolean
 *     responses:
 *       200:
 *         description: Category updated successfully
 *       404:
 *         description: Category not found
 *       401:
 *         description: Unauthorized
 */
router.put('/:id', requireAuth, updateCategory);

/**
 * @swagger
 * /book-categories/{id}:
 *   delete:
 *     summary: Delete book category (Admin only)
 *     tags: [Book Categories]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: Category ID
 *     responses:
 *       200:
 *         description: Category deleted successfully
 *       400:
 *         description: Cannot delete category with books
 *       404:
 *         description: Category not found
 *       401:
 *         description: Unauthorized
 */
router.delete('/:id', requireAuth, deleteCategory);

/**
 * @swagger
 * /book-categories/reorder:
 *   post:
 *     summary: Reorder book categories (Admin only)
 *     tags: [Book Categories]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - categoryIds
 *             properties:
 *               categoryIds:
 *                 type: array
 *                 items:
 *                   type: string
 *                 description: Array of category IDs in desired order
 *     responses:
 *       200:
 *         description: Categories reordered successfully
 *       401:
 *         description: Unauthorized
 */
router.post('/reorder', requireAuth, reorderCategories);

export default router;

