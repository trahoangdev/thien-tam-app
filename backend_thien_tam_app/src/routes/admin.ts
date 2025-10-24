import { Router } from "express";
import Reading from "../models/Reading";
import { startOfLocalDay } from "../utils/date";

const r = Router();

/**
 * @swagger
 * /admin/readings:
 *   get:
 *     summary: Get all readings (Admin)
 *     description: Retrieve all readings with pagination and filtering options
 *     tags: [Admin - Readings]
 *     security:
 *       - bearerAuth: []
 *     parameters:
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
 *           maximum: 100
 *           default: 20
 *         description: Number of items per page
 *       - in: query
 *         name: topic
 *         schema:
 *           type: string
 *         description: Filter by topic slug
 *       - in: query
 *         name: search
 *         schema:
 *           type: string
 *         description: Search in title and body
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
 *       401:
 *         description: Unauthorized
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
r.get("/readings", async (req, res) => {
  try {
    const { page = "1", limit = "20", topic, search } = req.query as any;
    const p = Math.max(parseInt(page), 1);
    const l = Math.min(Math.max(parseInt(limit), 1), 100);

    const filter: any = {};
    if (topic) filter.topicSlugs = String(topic);
    if (search) filter.$text = { $search: String(search) };

    const items = await Reading.find(filter)
      .sort({ date: -1 })
      .skip((p - 1) * l)
      .limit(l);
    
    const total = await Reading.countDocuments(filter);

    res.json({
      items,
      total,
      page: p,
      pages: Math.ceil(total / l),
    });
  } catch (error) {
    console.error("Admin get readings error:", error);
    res.status(500).json({ message: "Lỗi server" });
  }
});

/**
 * @swagger
 * /admin/readings/{id}:
 *   get:
 *     summary: Get reading by ID (Admin)
 *     description: Retrieve a specific reading by its ID
 *     tags: [Admin - Readings]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: Reading ID
 *         example: "507f1f77bcf86cd799439011"
 *     responses:
 *       200:
 *         description: Successfully retrieved reading
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Reading'
 *       401:
 *         description: Unauthorized
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 *       404:
 *         description: Reading not found
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
r.get("/readings/:id", async (req, res) => {
  try {
    const doc = await Reading.findById(req.params.id);
    if (!doc) {
      return res.status(404).json({ message: "Không tìm thấy bài đọc" });
    }
    res.json(doc);
  } catch (error) {
    res.status(500).json({ message: "Lỗi server" });
  }
});

/**
 * @swagger
 * /admin/readings:
 *   post:
 *     summary: Create a new reading (Admin)
 *     description: Create a new reading with all required fields
 *     tags: [Admin - Readings]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - title
 *               - body
 *               - date
 *             properties:
 *               title:
 *                 type: string
 *                 description: Title of the reading
 *                 example: "Chính Niệm - Sống Trong Hiện Tại"
 *               body:
 *                 type: string
 *                 description: Content of the reading
 *                 example: "Nội dung bài đọc về chính niệm..."
 *               date:
 *                 type: string
 *                 format: date
 *                 description: Date of the reading (YYYY-MM-DD)
 *                 example: "2025-10-24"
 *               topicSlugs:
 *                 type: array
 *                 items:
 *                   type: string
 *                 description: Array of topic slugs
 *                 example: ["chanh-niem", "phat-giao"]
 *               keywords:
 *                 type: array
 *                 items:
 *                   type: string
 *                 description: Array of keywords
 *                 example: ["chánh niệm", "hiện tại"]
 *               source:
 *                 type: string
 *                 description: Source of the reading
 *                 example: "Admin"
 *               lang:
 *                 type: string
 *                 description: Language code
 *                 example: "vi"
 *     responses:
 *       201:
 *         description: Reading created successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: "Tạo bài đọc thành công"
 *                 reading:
 *                   $ref: '#/components/schemas/Reading'
 *       400:
 *         description: Bad request - missing required fields
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 *       401:
 *         description: Unauthorized
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
r.post("/readings", async (req, res) => {
  try {
    const { date, title, body, topicSlugs, keywords, source, lang } = req.body;

    console.log("📝 CREATE REQUEST:", {
      date,
      title: title?.substring(0, 50),
      bodyLength: body?.length,
      topicSlugs,
      keywords
    });

    // Validation
    if (!date || !title || !body) {
      console.error("❌ Validation failed:", { date, title: !!title, body: !!body });
      return res.status(400).json({
        message: "Thiếu thông tin bắt buộc: date, title, body"
      });
    }

    // Parse date and convert to local start of day
    const readingDate = startOfLocalDay(new Date(date));
    console.log("📅 Parsed date:", readingDate);

    // Check how many readings exist for this date
    const existingCount = await Reading.countDocuments({ date: readingDate });
    console.log(`📊 Existing readings for ${readingDate}:`, existingCount);

    const newReading = await Reading.create({
      date: readingDate,
      title,
      body,
      topicSlugs: topicSlugs || [],
      keywords: keywords || [],
      source: source || "Admin",
      lang: lang || "vi",
    });

    console.log("✅ Created reading:", newReading._id, "for date:", readingDate);

    res.status(201).json({
      message: "Tạo bài đọc thành công",
      reading: newReading,
    });
  } catch (error: any) {
    console.error("Create reading error:", error);
    if (error.code === 11000) {
      return res.status(409).json({ message: "Bài đọc đã tồn tại cho ngày này" });
    }
    res.status(500).json({ message: "Lỗi server", error: error.message });
  }
});

/**
 * @swagger
 * /admin/readings/{id}:
 *   put:
 *     summary: Update reading (Admin)
 *     description: Update an existing reading by its ID
 *     tags: [Admin - Readings]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: Reading ID
 *         example: "507f1f77bcf86cd799439011"
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               title:
 *                 type: string
 *                 description: Updated title
 *                 example: "Updated Title"
 *               body:
 *                 type: string
 *                 description: Updated content
 *                 example: "Updated content..."
 *               topicSlugs:
 *                 type: array
 *                 items:
 *                   type: string
 *                 description: Updated topic slugs
 *                 example: ["phat-giao", "tu-tap"]
 *               keywords:
 *                 type: array
 *                 items:
 *                   type: string
 *                 description: Updated keywords
 *                 example: ["thiền", "tu tập"]
 *               source:
 *                 type: string
 *                 description: Updated source
 *                 example: "Admin"
 *               lang:
 *                 type: string
 *                 description: Updated language
 *                 example: "vi"
 *     responses:
 *       200:
 *         description: Reading updated successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: "Cập nhật thành công"
 *                 reading:
 *                   $ref: '#/components/schemas/Reading'
 *       401:
 *         description: Unauthorized
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 *       404:
 *         description: Reading not found
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
r.put("/readings/:id", async (req, res) => {
  try {
    const { title, body, topicSlugs, keywords, source, lang } = req.body;

    const updateData: any = {};
    if (title !== undefined) updateData.title = title;
    if (body !== undefined) updateData.body = body;
    if (topicSlugs !== undefined) updateData.topicSlugs = topicSlugs;
    if (keywords !== undefined) updateData.keywords = keywords;
    if (source !== undefined) updateData.source = source;
    if (lang !== undefined) updateData.lang = lang;

    const updated = await Reading.findByIdAndUpdate(
      req.params.id,
      { $set: updateData },
      { new: true, runValidators: true }
    );

    if (!updated) {
      return res.status(404).json({ message: "Không tìm thấy bài đọc" });
    }

    res.json({
      message: "Cập nhật thành công",
      reading: updated,
    });
  } catch (error: any) {
    console.error("Update reading error:", error);
    res.status(500).json({ message: "Lỗi server", error: error.message });
  }
});

/**
 * @swagger
 * /admin/readings/{id}:
 *   delete:
 *     summary: Delete reading (Admin)
 *     description: Delete a reading by its ID
 *     tags: [Admin - Readings]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: Reading ID
 *         example: "507f1f77bcf86cd799439011"
 *     responses:
 *       200:
 *         description: Reading deleted successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: "Xóa bài đọc thành công"
 *       401:
 *         description: Unauthorized
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 *       404:
 *         description: Reading not found
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
r.delete("/readings/:id", async (req, res) => {
  try {
    const deleted = await Reading.findByIdAndDelete(req.params.id);

    if (!deleted) {
      return res.status(404).json({ message: "Không tìm thấy bài đọc" });
    }

    res.json({
      message: "Xóa bài đọc thành công",
      reading: deleted,
    });
  } catch (error: any) {
    console.error("Delete reading error:", error);
    res.status(500).json({ message: "Lỗi server", error: error.message });
  }
});

// Get statistics
r.get("/stats", async (_req, res) => {
  try {
    const totalReadings = await Reading.countDocuments();
    
    // Topic counts with proper formatting
    const topicCounts = await Reading.aggregate([
      { $unwind: "$topicSlugs" },
      { $group: { _id: "$topicSlugs", count: { $sum: 1 } } },
      { $sort: { count: -1 } },
      { $project: { topic: "$_id", count: 1 } }
    ]);

    // Recent readings (last 10)
    const recentReadings = await Reading.find()
      .sort({ date: -1 })
      .limit(10)
      .select('title date topicSlugs')
      .lean();

    // Monthly statistics (last 6 months)
    const sixMonthsAgo = new Date();
    sixMonthsAgo.setMonth(sixMonthsAgo.getMonth() - 6);
    
    const monthlyStats = await Reading.aggregate([
      { $match: { date: { $gte: sixMonthsAgo } } },
      {
        $group: {
          _id: {
            year: { $year: "$date" },
            month: { $month: "$date" }
          },
          count: { $sum: 1 }
        }
      },
      { $sort: { "_id.year": -1, "_id.month": -1 } },
      {
        $project: {
          month: {
            $concat: [
              { $toString: "$_id.year" },
              "-",
              { $toString: "$_id.month" }
            ]
          },
          count: 1
        }
      }
    ]);

    res.json({
      totalReadings,
      topicCounts,
      recentReadings,
      monthlyStats,
    });
  } catch (error) {
    console.error("Admin stats error:", error);
    res.status(500).json({ message: "Lỗi server" });
  }
});

export default r;

