import { Router } from "express";
import Reading from "../models/Reading";
import { startOfLocalDay } from "../utils/date";

const r = Router();

// GET all readings (with pagination)
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

// GET single reading
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

// CREATE reading
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

// UPDATE reading
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

// DELETE reading
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
    const topicCounts = await Reading.aggregate([
      { $unwind: "$topicSlugs" },
      { $group: { _id: "$topicSlugs", count: { $sum: 1 } } },
      { $sort: { count: -1 } }
    ]);

    res.json({
      totalReadings,
      topicCounts,
    });
  } catch (error) {
    res.status(500).json({ message: "Lỗi server" });
  }
});

export default r;

