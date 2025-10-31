import { Router } from "express";
import Topic from "../models/Topic";
import Reading from "../models/Reading";
import { z } from "zod";

const r = Router();

// Validation schemas
const createTopicSchema = z.object({
  slug: z.string().min(1, "Slug không được để trống").regex(/^[a-z0-9-]+$/, "Slug chỉ được chứa chữ thường, số và dấu gạch ngang"),
  name: z.string().min(1, "Tên chủ đề không được để trống"),
  description: z.string().optional(),
  color: z.string().regex(/^#[0-9A-F]{6}$/i, "Màu sắc phải là mã hex hợp lệ").optional(),
  icon: z.string().optional(),
  sortOrder: z.number().optional()
});

const updateTopicSchema = z.object({
  name: z.string().min(1, "Tên chủ đề không được để trống").optional(),
  description: z.string().optional(),
  color: z.string().regex(/^#[0-9A-F]{6}$/i, "Màu sắc phải là mã hex hợp lệ").optional(),
  icon: z.string().optional(),
  isActive: z.boolean().optional(),
  sortOrder: z.number().optional()
});

/**
 * @swagger
 * /admin/topics:
 *   get:
 *     summary: Get all topics (Admin)
 *     description: Retrieve all topics with pagination and search
 *     tags: [Admin - Topics]
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
 *         name: search
 *         schema:
 *           type: string
 *         description: Search in name and description
 *       - in: query
 *         name: isActive
 *         schema:
 *           type: boolean
 *         description: Filter by active status
 *     responses:
 *       200:
 *         description: Successfully retrieved topics
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 items:
 *                   type: array
 *                   items:
 *                     $ref: '#/components/schemas/Topic'
 *                 total:
 *                   type: number
 *                   description: Total number of topics
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
r.get("/topics", async (req, res) => {
  try {
    const page = parseInt(req.query.page as string) || 1;
    const limit = parseInt(req.query.limit as string) || 20;
    const skip = (page - 1) * limit;
    const search = req.query.search as string;

    const query: any = {};
    if (search) {
      query.$text = { $search: search };
    }

    const total = await Topic.countDocuments(query);
    const topics = await Topic.find(query)
      .sort({ sortOrder: 1, name: 1 })
      .skip(skip)
      .limit(limit);

    // Get reading counts for each topic
    const topicsWithCounts: any[] = [];
    for (const topic of topics) {
      const readingCount = await Reading.countDocuments({ 
        topicSlugs: topic.slug 
      });
      const topicData = topic.toJSON();
      topicsWithCounts.push({
        ...topicData,
        readingCount
      });
    }

    res.json({
      items: topicsWithCounts,
      total,
      page,
      pages: Math.ceil(total / limit),
    });
  } catch (error: any) {
    console.error("Error fetching topics:", error);
    res.status(500).json({ message: "Lỗi server" });
  }
});

/**
 * @swagger
 * /admin/topics/stats:
 *   get:
 *     summary: Get topic statistics (Admin)
 *     description: Returns aggregated statistics about topics including counts and top topics
 *     tags: [Admin - Topics]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Successfully retrieved topic statistics
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 totalTopics:
 *                   type: number
 *                   description: Total number of topics
 *                 activeTopics:
 *                   type: number
 *                   description: Number of active topics
 *                 inactiveTopics:
 *                   type: number
 *                   description: Number of inactive topics
 *                 topTopics:
 *                   type: array
 *                   items:
 *                     type: object
 *                     properties:
 *                       slug:
 *                         type: string
 *                         description: Topic slug
 *                       name:
 *                         type: string
 *                         description: Topic name
 *                       count:
 *                         type: number
 *                         description: Number of readings for this topic
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
// GET /admin/topics/stats - Get topic statistics
r.get("/topics/stats", async (req, res) => {
  try {
    console.log("📊 Fetching topic statistics...");
    
    // Basic topic counts
    const totalTopics = await Topic.countDocuments();
    const activeTopics = await Topic.countDocuments({ isActive: true });
    const inactiveTopics = await Topic.countDocuments({ isActive: false });
    
    console.log(`📈 Topic counts: total=${totalTopics}, active=${activeTopics}, inactive=${inactiveTopics}`);
    
    // Get topics with most readings (simplified approach)
    let topTopics = [];
    try {
      // Simple approach: get all topics and count readings for each
      const allTopics = await Topic.find({}).limit(10);
      topTopics = [];
      for (const topic of allTopics) {
        const count = await Reading.countDocuments({ topicSlugs: topic.slug });
        topTopics.push({
          slug: topic.slug,
          name: topic.name,
          count: count
        });
      }
      
      // Sort by count descending
      topTopics.sort((a, b) => b.count - a.count);
      
      console.log(`📊 Top topics:`, topTopics);
    } catch (error: any) {
      console.warn("⚠️ Error getting top topics:", error.message);
      topTopics = [];
    }

    const stats = {
      totalTopics,
      activeTopics,
      inactiveTopics,
      topTopics: topTopics.filter(t => t.count > 0).slice(0, 10)
    };
    
    console.log("✅ Topic stats generated successfully");
    res.json(stats);
  } catch (error: any) {
    console.error("❌ Error fetching topic stats:", error);
    res.status(500).json({ 
      message: "Lỗi server", 
      error: process.env.NODE_ENV === 'development' ? error.message : undefined 
    });
  }
});

/**
 * @swagger
 * /admin/topics/{id}:
 *   get:
 *     summary: Get topic by ID (Admin)
 *     description: Retrieve a specific topic by its ID with reading count
 *     tags: [Admin - Topics]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: Topic ID
 *         example: "507f1f77bcf86cd799439011"
 *     responses:
 *       200:
 *         description: Successfully retrieved topic
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 _id:
 *                   type: string
 *                 slug:
 *                   type: string
 *                 name:
 *                   type: string
 *                 description:
 *                   type: string
 *                 color:
 *                   type: string
 *                 icon:
 *                   type: string
 *                 sortOrder:
 *                   type: number
 *                 isActive:
 *                   type: boolean
 *                 readingCount:
 *                   type: number
 *                   description: Number of readings using this topic
 *                 createdAt:
 *                   type: string
 *                   format: date-time
 *                 updatedAt:
 *                   type: string
 *                   format: date-time
 *       401:
 *         description: Unauthorized
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 *       404:
 *         description: Topic not found
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
// GET /admin/topics/:id - Get a single topic by ID
r.get("/topics/:id", async (req, res) => {
  try {
    const topic = await Topic.findById(req.params.id);
    if (!topic) {
      return res.status(404).json({ message: "Chủ đề không tìm thấy" });
    }

    // Get reading count
    const readingCount = await Reading.countDocuments({ 
      topicSlugs: topic.slug 
    });

    res.json({
      ...(topic.toJSON() as Record<string, any>),
      readingCount
    });
  } catch (error: any) {
    console.error("Error fetching topic:", error);
    res.status(500).json({ message: "Lỗi server" });
  }
});

/**
 * @swagger
 * /admin/topics:
 *   post:
 *     summary: Create new topic (Admin)
 *     description: Create a new topic with validation
 *     tags: [Admin - Topics]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - slug
 *               - name
 *             properties:
 *               slug:
 *                 type: string
 *                 pattern: '^[a-z0-9-]+$'
 *                 description: Topic slug (lowercase letters, numbers, and hyphens only)
 *                 example: "phat-giao"
 *               name:
 *                 type: string
 *                 minLength: 1
 *                 description: Topic name
 *                 example: "Phật Giáo"
 *               description:
 *                 type: string
 *                 description: Topic description
 *                 example: "Các bài viết về Phật giáo"
 *               color:
 *                 type: string
 *                 pattern: '^#[0-9A-F]{6}$'
 *                 description: Hex color code
 *                 example: "#4CAF50"
 *               icon:
 *                 type: string
 *                 description: Icon name or emoji
 *                 example: "label"
 *               sortOrder:
 *                 type: number
 *                 description: Display order
 *                 example: 1
 *     responses:
 *       201:
 *         description: Topic created successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: "Tạo chủ đề thành công"
 *                 topic:
 *                   $ref: '#/components/schemas/Topic'
 *       400:
 *         description: Validation error
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                 errors:
 *                   type: array
 *                   items:
 *                     type: object
 *       401:
 *         description: Unauthorized
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 *       409:
 *         description: Topic with slug already exists
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
// POST /admin/topics - Create a new topic
r.post("/topics", async (req, res) => {
  try {
    const validatedData = createTopicSchema.parse(req.body);
    
    // Check if slug already exists
    const existingTopic = await Topic.findOne({ slug: validatedData.slug });
    if (existingTopic) {
      return res.status(409).json({ 
        message: `Chủ đề với slug "${validatedData.slug}" đã tồn tại` 
      });
    }

    const newTopic = await Topic.create({
      ...validatedData,
      color: validatedData.color || "#4CAF50",
      icon: validatedData.icon || "label"
    });

    console.log("✅ Created topic:", newTopic.slug, newTopic.name);

    res.status(201).json({
      message: "Tạo chủ đề thành công",
      topic: newTopic,
    });
  } catch (error: any) {
    console.error("Create topic error:", error);
    if (error instanceof z.ZodError) {
      return res.status(400).json({ 
        message: "Dữ liệu không hợp lệ", 
        errors: error.errors 
      });
    }
    if (error.code === 11000) {
      return res.status(409).json({ 
        message: "Chủ đề đã tồn tại" 
      });
    }
    res.status(500).json({ message: "Lỗi server", error: error.message });
  }
});

/**
 * @swagger
 * /admin/topics/{id}:
 *   put:
 *     summary: Update topic (Admin)
 *     description: Update an existing topic by its ID
 *     tags: [Admin - Topics]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: Topic ID
 *         example: "507f1f77bcf86cd799439011"
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               name:
 *                 type: string
 *                 minLength: 1
 *                 description: Updated topic name
 *                 example: "Phật Giáo Cơ Bản"
 *               description:
 *                 type: string
 *                 description: Updated description
 *                 example: "Các bài viết cơ bản về Phật giáo"
 *               color:
 *                 type: string
 *                 pattern: '^#[0-9A-F]{6}$'
 *                 description: Updated hex color code
 *                 example: "#4CAF50"
 *               icon:
 *                 type: string
 *                 description: Updated icon
 *                 example: "book"
 *               isActive:
 *                 type: boolean
 *                 description: Active status
 *                 example: true
 *               sortOrder:
 *                 type: number
 *                 description: Display order
 *                 example: 1
 *     responses:
 *       200:
 *         description: Topic updated successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: "Chủ đề đã được cập nhật"
 *                 topic:
 *                   $ref: '#/components/schemas/Topic'
 *       400:
 *         description: Validation error
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                 errors:
 *                   type: array
 *                   items:
 *                     type: object
 *       401:
 *         description: Unauthorized
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 *       404:
 *         description: Topic not found
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
// PUT /admin/topics/:id - Update an existing topic
r.put("/topics/:id", async (req, res) => {
  try {
    const validatedData = updateTopicSchema.parse(req.body);
    
    const updatedTopic = await Topic.findByIdAndUpdate(
      req.params.id,
      { $set: validatedData },
      { new: true, runValidators: true }
    );
    
    if (!updatedTopic) {
      return res.status(404).json({ message: "Chủ đề không tìm thấy" });
    }

    console.log("✅ Updated topic:", updatedTopic.slug, updatedTopic.name);

    res.json({ 
      message: "Chủ đề đã được cập nhật", 
      topic: updatedTopic 
    });
  } catch (error: any) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ 
        message: "Dữ liệu không hợp lệ", 
        errors: error.errors 
      });
    }
    console.error("Error updating topic:", error);
    res.status(500).json({ message: "Lỗi server" });
  }
});

/**
 * @swagger
 * /admin/topics/{id}:
 *   delete:
 *     summary: Delete topic (Admin)
 *     description: Delete a topic by its ID. Cannot delete if topic is used in any readings.
 *     tags: [Admin - Topics]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: Topic ID
 *         example: "507f1f77bcf86cd799439011"
 *     responses:
 *       200:
 *         description: Topic deleted successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: "Chủ đề đã được xóa"
 *       400:
 *         description: Cannot delete topic that is used in readings
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: "Không thể xóa chủ đề \"Phật Giáo\" vì đang được sử dụng trong 25 bài đọc"
 *       401:
 *         description: Unauthorized
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 *       404:
 *         description: Topic not found
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
// DELETE /admin/topics/:id - Delete a topic
r.delete("/topics/:id", async (req, res) => {
  try {
    const topic = await Topic.findById(req.params.id);
    if (!topic) {
      return res.status(404).json({ message: "Chủ đề không tìm thấy" });
    }

    // Check if topic is used in any readings
    const readingCount = await Reading.countDocuments({ 
      topicSlugs: topic.slug 
    });
    
    if (readingCount > 0) {
      return res.status(400).json({ 
        message: `Không thể xóa chủ đề "${topic.name}" vì đang được sử dụng trong ${readingCount} bài đọc` 
      });
    }

    await Topic.findByIdAndDelete(req.params.id);
    
    console.log("✅ Deleted topic:", topic.slug, topic.name);

    res.json({ message: "Chủ đề đã được xóa" });
  } catch (error: any) {
    console.error("Error deleting topic:", error);
    res.status(500).json({ message: "Lỗi server" });
  }
});

export default r;
