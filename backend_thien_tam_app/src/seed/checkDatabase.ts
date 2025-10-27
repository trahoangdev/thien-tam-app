// Script to check database contents
import mongoose from "mongoose";
import Book from "../models/Book";
import { BookCategory } from "../models/BookCategory";
import dotenv from "dotenv";

dotenv.config();

async function checkDatabase() {
  try {
    await mongoose.connect(
      process.env.MONGO_URI || "mongodb://localhost:27017/thien_tam_app"
    );
    console.log("✅ Connected to MongoDB");

    // Check books
    const books = await Book.find({});
    console.log(`\n📚 BOOKS: Found ${books.length} books`);
    books.forEach((book, index) => {
      console.log(`  ${index + 1}. ${book.title || "Untitled"}`);
      console.log(`     Category: ${book.category}`);
    });

    // Check categories
    const categories = await BookCategory.find({});
    console.log(`\n📂 CATEGORIES: Found ${categories.length} categories`);
    categories.forEach((cat, index) => {
      console.log(`  ${index + 1}. ${cat.name || cat.nameEn} (ID: ${cat._id})`);
    });
  } catch (error) {
    console.error("❌ Error:", error);
  } finally {
    await mongoose.disconnect();
    console.log("\n👋 Disconnected from MongoDB");
  }
}

checkDatabase();
