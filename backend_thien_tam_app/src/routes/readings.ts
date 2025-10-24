import { Router } from "express";
import Reading from "../models/Reading";
import { startOfLocalDay, rangeOfMonthLocal } from "../utils/date";

const r = Router();

/**
 * @swagger
 * /readings/today:
 *   get:
 *     summary: Get today's readings
 *     description: Returns all readings for today's date
 *     tags: [Readings]
 *     responses:
 *       200:
 *         description: Successfully retrieved today's readings
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 items:
 *                   type: array
 *                   items:
 *                     $ref: '#/components/schemas/Reading'
 *                 total:
 *                   type: number
 *                   description: Total number of readings
 *       404:
 *         description: No readings found for today
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 *       500:
 *         description: Server error
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
r.get("/today", async (req, res) => {
  try {
    const s = startOfLocalDay();
    const docs = await Reading.find({ date: s }).sort({ createdAt: 1 });
    if (!docs || docs.length === 0) {
      return res.status(404).json({ message: "not_found" });
    }
    res.json({ items: docs, total: docs.length });
  } catch (error) {
    res.status(500).json({ message: "server_error", error });
  }
});

/**
 * @swagger
 * /readings/{date}:
 *   get:
 *     summary: Get readings by date
 *     description: Returns all readings for a specific date (YYYY-MM-DD format)
 *     tags: [Readings]
 *     parameters:
 *       - in: path
 *         name: date
 *         required: true
 *         schema:
 *           type: string
 *           format: date
 *           example: "2025-10-24"
 *         description: Date in YYYY-MM-DD format
 *     responses:
 *       200:
 *         description: Successfully retrieved readings for the date
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 items:
 *                   type: array
 *                   items:
 *                     $ref: '#/components/schemas/Reading'
 *                 total:
 *                   type: number
 *                   description: Total number of readings
 *       404:
 *         description: No readings found for the specified date
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 *       500:
 *         description: Server error
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
r.get("/:ymd(\\d{4}-\\d{2}-\\d{2})", async (req, res) => {
  try {
    const [y, m, d] = req.params.ymd.split("-").map(Number);
    // Create local date (let startOfLocalDay handle timezone conversion)
    const inputDate = new Date(y, m - 1, d);
    const s = startOfLocalDay(inputDate);
    
    const docs = await Reading.find({ date: s }).sort({ createdAt: 1 });
    if (!docs || docs.length === 0) {
      return res.status(404).json({ message: "not_found" });
    }
    res.json({ items: docs, total: docs.length });
  } catch (error) {
    res.status(500).json({ message: "server_error", error });
  }
});

/**
 * @swagger
 * /readings:
 *   get:
 *     summary: Search and list readings
 *     description: Search readings by query and topic with pagination
 *     tags: [Readings]
 *     parameters:
 *       - in: query
 *         name: query
 *         schema:
 *           type: string
 *         description: Search query for title and body
 *         example: "thiền"
 *       - in: query
 *         name: topic
 *         schema:
 *           type: string
 *         description: Filter by topic slug
 *         example: "phat-giao"
 *       - in: query
 *         name: page
 *         schema:
 *           type: integer
 *           minimum: 1
 *           default: 1
 *         description: Page number
 *       - in: query
 *         name: limit
 *         schema:
 *           type: integer
 *           minimum: 1
 *           maximum: 50
 *           default: 10
 *         description: Number of items per page
 *     responses:
 *       200:
 *         description: Successfully retrieved readings
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 items:
 *                   type: array
 *                   items:
 *                     $ref: '#/components/schemas/Reading'
 *                 total:
 *                   type: number
 *                   description: Total number of readings
 *                 page:
 *                   type: number
 *                   description: Current page number
 *                 pages:
 *                   type: number
 *                   description: Total number of pages
 *       500:
 *         description: Server error
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
r.get("/", async (req, res) => {
  try {
    const { query = "", topic, page = "1", limit = "10" } = req.query as any;
    const p = Math.max(parseInt(page), 1);
    const l = Math.min(Math.max(parseInt(limit), 1), 50);

    const mongoQ: any = {};
    if (query) mongoQ.$text = { $search: String(query) };
    if (topic) mongoQ.topicSlugs = String(topic);

    const items = await Reading.find(mongoQ).sort({ date: -1 }).skip((p - 1) * l).limit(l);
    const total = await Reading.countDocuments(mongoQ);
    
    res.json({ items, total, page: p, pages: Math.ceil(total / l) });
  } catch (error) {
    res.status(500).json({ message: "server_error", error });
  }
});

/**
 * @swagger
 * /readings/month/{yearMonth}:
 *   get:
 *     summary: Get readings by month
 *     description: Returns all readings for a specific month (YYYY-MM format)
 *     tags: [Readings]
 *     parameters:
 *       - in: path
 *         name: yearMonth
 *         required: true
 *         schema:
 *           type: string
 *           pattern: '^\d{4}-\d{2}$'
 *           example: "2025-10"
 *         description: Year and month in YYYY-MM format
 *     responses:
 *       200:
 *         description: Successfully retrieved readings for the month
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 items:
 *                   type: array
 *                   items:
 *                     type: object
 *                     properties:
 *                       _id:
 *                         type: string
 *                         description: Reading ID
 *                       date:
 *                         type: string
 *                         format: date
 *                         description: Reading date
 *                       title:
 *                         type: string
 *                         description: Reading title
 *                       topicSlugs:
 *                         type: array
 *                         items:
 *                           type: string
 *                         description: Topic slugs
 *       500:
 *         description: Server error
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
r.get("/month/:ym(\\d{4}-\\d{2})", async (req, res) => {
  try {
    const [y, m] = req.params.ym.split("-").map(Number);
    const { from, to } = rangeOfMonthLocal(y, m);
    const items = await Reading.find({ date: { $gte: from, $lt: to } })
      .sort({ date: 1 })
      .select("_id date title topicSlugs");
    res.json({ items });
  } catch (error) {
    res.status(500).json({ message: "server_error", error });
  }
});

/**
 * @swagger
 * /readings/random:
 *   get:
 *     summary: Get random reading
 *     description: Returns a random reading from the database
 *     tags: [Readings]
 *     responses:
 *       200:
 *         description: Successfully retrieved random reading
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Reading'
 *       404:
 *         description: No readings found
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 *       500:
 *         description: Server error
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
r.get("/random", async (_req, res) => {
  try {
    const [doc] = await Reading.aggregate([{ $sample: { size: 1 } }]);
    if (!doc) return res.status(404).json({ message: "not_found" });
    res.json(doc);
  } catch (error) {
    res.status(500).json({ message: "server_error", error });
  }
});

export default r;

