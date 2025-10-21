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

// GET /admin/topics - Get all topics with pagination and search
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
    const topicsWithCounts = await Promise.all(
      topics.map(async (topic) => {
        const readingCount = await Reading.countDocuments({ 
          topicSlugs: topic.slug 
        });
        return {
          ...topic.toObject(),
          readingCount
        };
      })
    );

    res.json({
      items: topicsWithCounts,
      total,
      page,
      pages: Math.ceil(total / limit),
    });
  } catch (error) {
    console.error("Error fetching topics:", error);
    res.status(500).json({ message: "Lỗi server" });
  }
});

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
      ...topic.toObject(),
      readingCount
    });
  } catch (error) {
    console.error("Error fetching topic:", error);
    res.status(500).json({ message: "Lỗi server" });
  }
});

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
  } catch (error) {
    console.error("Error deleting topic:", error);
    res.status(500).json({ message: "Lỗi server" });
  }
});

// GET /admin/topics/stats - Get topic statistics
r.get("/topics/stats", async (req, res) => {
  try {
    const totalTopics = await Topic.countDocuments();
    const activeTopics = await Topic.countDocuments({ isActive: true });
    const inactiveTopics = await Topic.countDocuments({ isActive: false });
    
    // Get topics with most readings
    const topTopics = await Reading.aggregate([
      { $unwind: "$topicSlugs" },
      { $group: { _id: "$topicSlugs", count: { $sum: 1 } } },
      { $sort: { count: -1 } },
      { $limit: 10 },
      {
        $lookup: {
          from: "topics",
          localField: "_id",
          foreignField: "slug",
          as: "topic"
        }
      },
      { $unwind: "$topic" },
      {
        $project: {
          slug: "$_id",
          name: "$topic.name",
          count: 1
        }
      }
    ]);

    res.json({
      totalTopics,
      activeTopics,
      inactiveTopics,
      topTopics
    });
  } catch (error) {
    console.error("Error fetching topic stats:", error);
    res.status(500).json({ message: "Lỗi server" });
  }
});

export default r;
