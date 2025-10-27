import mongoose from "mongoose";
import dotenv from "dotenv";
import { BookCategory } from "../models/BookCategory";

dotenv.config();

const categories = [
  {
    name: "Kinh Điển",
    nameEn: "Sutras",
    description: "Các bộ kinh Phật giáo cổ điển",
    icon: "📿",
    color: "#D4AF37",
    displayOrder: 0,
    isActive: true,
  },
  {
    name: "Luận Giải",
    nameEn: "Commentaries",
    description: "Các bài luận giải, bình giảng kinh điển",
    icon: "📖",
    color: "#8B4513",
    displayOrder: 1,
    isActive: true,
  },
  {
    name: "Tiểu Sử & Truyện",
    nameEn: "Biographies & Stories",
    description: "Tiểu sử, truyện kể về các bậc Thánh Tăng",
    icon: "🙏",
    color: "#FF8C00",
    displayOrder: 2,
    isActive: true,
  },
  {
    name: "Hướng Dẫn Tu Tập",
    nameEn: "Practice Guides",
    description: "Sách hướng dẫn thực hành Phật pháp",
    icon: "🧘",
    color: "#4CAF50",
    displayOrder: 3,
    isActive: true,
  },
  {
    name: "Pháp Thoại",
    nameEn: "Dharma Talks",
    description: "Các bài pháp thoại của các Thiền sư",
    icon: "🎙️",
    color: "#2196F3",
    displayOrder: 4,
    isActive: true,
  },
  {
    name: "Lịch Sử Phật Giáo",
    nameEn: "Buddhist History",
    description: "Lịch sử phát triển của Phật giáo",
    icon: "📜",
    color: "#9C27B0",
    displayOrder: 5,
    isActive: true,
  },
  {
    name: "Triết Học",
    nameEn: "Philosophy",
    description: "Triết học Phật giáo và so sánh tôn giáo",
    icon: "🤔",
    color: "#607D8B",
    displayOrder: 6,
    isActive: true,
  },
  {
    name: "Khác",
    nameEn: "Other",
    description: "Các loại sách khác liên quan đến Phật giáo",
    icon: "📚",
    color: "#795548",
    displayOrder: 7,
    isActive: true,
  },
];

async function seedBookCategories() {
  try {
    const MONGODB_URI =
      process.env.MONGO_URI || "mongodb://localhost:27017/thien-tam-app";

    await mongoose.connect(MONGODB_URI);
    console.log("✓ Connected to MongoDB");

    // Clear existing categories
    await BookCategory.deleteMany({});
    console.log("✓ Cleared existing book categories");

    // Insert new categories
    const result = await BookCategory.insertMany(categories);
    console.log(`✓ Seeded ${result.length} book categories`);

    // Display created categories
    console.log("\n📚 Created Categories:");
    result.forEach((cat, index) => {
      console.log(`${index + 1}. ${cat.icon} ${cat.name} (${cat.nameEn})`);
      console.log(`   ID: ${cat._id}`);
      console.log(`   Color: ${cat.color}`);
      console.log("");
    });

    await mongoose.connection.close();
    console.log("✓ Database connection closed");
  } catch (error) {
    console.error("✗ Seeding error:", error);
    process.exit(1);
  }
}

seedBookCategories();
