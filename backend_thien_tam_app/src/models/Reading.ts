import { Schema, model } from "mongoose";

const ReadingSchema = new Schema(
  {
    date: { type: Date, required: true, index: true }, // 00:00 local - REMOVED unique constraint
    title: { type: String, required: true },
    body: { type: String, required: true }, // nội dung thuần text/HTML
    topicSlugs: { type: [String], index: true }, // ví dụ: ["chinh-niem","tu-bi"]
    keywords: { type: [String] }, // array field, không thể dùng trong text index
    source: { type: String },
  },
  { timestamps: true }
);

// Text index chỉ cho title và body (không dùng array field)
ReadingSchema.index({ title: "text", body: "text" });

export default model("Reading", ReadingSchema);
