import express from 'express';
import * as audioController from '../controllers/audioController';
import { requireAuth } from '../middlewares/auth';
import { uploadAudio } from '../middlewares/upload';

const router = express.Router();

/**
 * @swagger
 * components:
 *   schemas:
 *     Audio:
 *       type: object
 *       required:
 *         - title
 *         - category
 *         - cloudinaryPublicId
 *         - cloudinaryUrl
 *         - cloudinarySecureUrl
 *         - uploadedBy
 *       properties:
 *         _id:
 *           type: string
 *           description: Audio ID
 *         title:
 *           type: string
 *           description: Audio title
 *           maxLength: 200
 *         description:
 *           type: string
 *           description: Audio description
 *           maxLength: 1000
 *         artist:
 *           type: string
 *           description: Artist name
 *           maxLength: 100
 *         duration:
 *           type: number
 *           description: Duration in seconds
 *         category:
 *           type: string
 *           enum: [sutra, mantra, dharma-talk, meditation, chanting, music, other]
 *           description: Audio category
 *         tags:
 *           type: array
 *           items:
 *             type: string
 *           description: Audio tags
 *         cloudinaryPublicId:
 *           type: string
 *           description: Cloudinary public ID
 *         cloudinaryUrl:
 *           type: string
 *           description: Cloudinary URL
 *         cloudinarySecureUrl:
 *           type: string
 *           description: Cloudinary secure URL
 *         fileSize:
 *           type: number
 *           description: File size in bytes
 *         format:
 *           type: string
 *           description: Audio format (mp3, wav, etc.)
 *         uploadedBy:
 *           type: string
 *           description: Admin ID who uploaded
 *         playCount:
 *           type: number
 *           description: Number of plays
 *         isPublic:
 *           type: boolean
 *           description: Whether audio is public
 *         createdAt:
 *           type: string
 *           format: date-time
 *         updatedAt:
 *           type: string
 *           format: date-time
 */

/**
 * @swagger
 * /audio/upload:
 *   post:
 *     summary: Upload audio file
 *     tags: [Audio Library]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         multipart/form-data:
 *           schema:
 *             type: object
 *             required:
 *               - file
 *               - title
 *               - category
 *             properties:
 *               file:
 *                 type: string
 *                 format: binary
 *                 description: Audio file (mp3, wav, ogg, etc.)
 *               title:
 *                 type: string
 *                 description: Audio title
 *               description:
 *                 type: string
 *                 description: Audio description
 *               artist:
 *                 type: string
 *                 description: Artist name
 *               category:
 *                 type: string
 *                 enum: [sutra, mantra, dharma-talk, meditation, chanting, music, other]
 *               tags:
 *                 type: array
 *                 items:
 *                   type: string
 *               isPublic:
 *                 type: boolean
 *     responses:
 *       201:
 *         description: Audio uploaded successfully
 *       400:
 *         description: Validation error or no file uploaded
 *       401:
 *         description: Unauthorized
 *       500:
 *         description: Server error
 */
router.post('/upload', requireAuth, uploadAudio.single('file'), audioController.uploadAudio);

/**
 * @swagger
 * /audio/from-url:
 *   post:
 *     summary: Create audio from Cloudinary URL (no file upload)
 *     tags: [Audio Library]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - cloudinaryUrl
 *               - title
 *               - category
 *             properties:
 *               cloudinaryUrl:
 *                 type: string
 *                 format: uri
 *                 description: Cloudinary URL of the audio file
 *                 example: https://res.cloudinary.com/demo/video/upload/v1234567890/samples/audio.mp3
 *               title:
 *                 type: string
 *                 description: Audio title
 *               description:
 *                 type: string
 *                 description: Audio description
 *               artist:
 *                 type: string
 *                 description: Artist name
 *               category:
 *                 type: string
 *                 enum: [sutra, mantra, dharma-talk, meditation, chanting, music, other]
 *               tags:
 *                 type: array
 *                 items:
 *                   type: string
 *               duration:
 *                 type: number
 *                 description: Duration in seconds (optional)
 *               fileSize:
 *                 type: number
 *                 description: File size in bytes (optional)
 *               format:
 *                 type: string
 *                 description: Audio format (mp3, wav, etc.) (optional)
 *               isPublic:
 *                 type: boolean
 *     responses:
 *       201:
 *         description: Audio created successfully from URL
 *       400:
 *         description: Validation error
 *       401:
 *         description: Unauthorized
 *       500:
 *         description: Server error
 */
router.post('/from-url', requireAuth, audioController.createAudioFromUrl);

/**
 * @swagger
 * /audio:
 *   get:
 *     summary: Get all audios with filters
 *     tags: [Audio Library]
 *     parameters:
 *       - in: query
 *         name: category
 *         schema:
 *           type: string
 *           enum: [sutra, mantra, dharma-talk, meditation, chanting, music, other]
 *         description: Filter by category
 *       - in: query
 *         name: tags
 *         schema:
 *           type: string
 *         description: Filter by tags (comma-separated)
 *       - in: query
 *         name: search
 *         schema:
 *           type: string
 *         description: Search in title, description, artist
 *       - in: query
 *         name: isPublic
 *         schema:
 *           type: boolean
 *         description: Filter by public status
 *       - in: query
 *         name: page
 *         schema:
 *           type: integer
 *           default: 1
 *         description: Page number
 *       - in: query
 *         name: limit
 *         schema:
 *           type: integer
 *           default: 20
 *         description: Items per page
 *       - in: query
 *         name: sortBy
 *         schema:
 *           type: string
 *           default: createdAt
 *         description: Sort field
 *       - in: query
 *         name: sortOrder
 *         schema:
 *           type: string
 *           enum: [asc, desc]
 *           default: desc
 *         description: Sort order
 *     responses:
 *       200:
 *         description: List of audios
 *       500:
 *         description: Server error
 */
router.get('/', audioController.getAllAudios);

/**
 * @swagger
 * /audio/categories:
 *   get:
 *     summary: Get all audio categories
 *     tags: [Audio Library]
 *     responses:
 *       200:
 *         description: List of categories
 *       500:
 *         description: Server error
 */
router.get('/categories', audioController.getCategories);

/**
 * @swagger
 * /audio/popular:
 *   get:
 *     summary: Get popular audios by play count
 *     tags: [Audio Library]
 *     parameters:
 *       - in: query
 *         name: limit
 *         schema:
 *           type: integer
 *           default: 10
 *         description: Number of audios to return
 *     responses:
 *       200:
 *         description: List of popular audios
 *       500:
 *         description: Server error
 */
router.get('/popular', audioController.getPopularAudios);

/**
 * @swagger
 * /audio/{id}:
 *   get:
 *     summary: Get audio by ID
 *     tags: [Audio Library]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: Audio ID
 *     responses:
 *       200:
 *         description: Audio details
 *       404:
 *         description: Audio not found
 *       500:
 *         description: Server error
 */
router.get('/:id', audioController.getAudioById);

/**
 * @swagger
 * /audio/{id}:
 *   put:
 *     summary: Update audio metadata
 *     tags: [Audio Library]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: Audio ID
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               title:
 *                 type: string
 *               description:
 *                 type: string
 *               artist:
 *                 type: string
 *               category:
 *                 type: string
 *                 enum: [sutra, mantra, dharma-talk, meditation, chanting, music, other]
 *               tags:
 *                 type: array
 *                 items:
 *                   type: string
 *               isPublic:
 *                 type: boolean
 *     responses:
 *       200:
 *         description: Audio updated successfully
 *       400:
 *         description: Validation error
 *       401:
 *         description: Unauthorized
 *       404:
 *         description: Audio not found
 *       500:
 *         description: Server error
 */
router.put('/:id', requireAuth, audioController.updateAudio);

/**
 * @swagger
 * /audio/{id}:
 *   delete:
 *     summary: Delete audio
 *     tags: [Audio Library]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: Audio ID
 *     responses:
 *       200:
 *         description: Audio deleted successfully
 *       401:
 *         description: Unauthorized
 *       404:
 *         description: Audio not found
 *       500:
 *         description: Server error
 */
router.delete('/:id', requireAuth, audioController.deleteAudio);

/**
 * @swagger
 * /audio/{id}/play:
 *   post:
 *     summary: Increment play count
 *     tags: [Audio Library]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: Audio ID
 *     responses:
 *       200:
 *         description: Play count incremented
 *       404:
 *         description: Audio not found
 *       500:
 *         description: Server error
 */
router.post('/:id/play', audioController.incrementPlayCount);

export default router;

