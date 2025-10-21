import { Router } from "express";
import Reading from "../models/Reading";
import { startOfLocalDay, rangeOfMonthLocal } from "../utils/date";

const r = Router();

// today - Returns ARRAY of readings
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

// by date /readings/2025-10-21
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

// search + list
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

// month list /readings/month/2025-10
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

// random
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

