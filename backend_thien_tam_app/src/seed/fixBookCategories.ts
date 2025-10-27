// Script to fix books with invalid category references
// Run: npx ts-node src/seed/fixBookCategories.ts

import mongoose from "mongoose";
import Book from "../models/Book";
import { BookCategory } from "../models/BookCategory";
import dotenv from "dotenv";

dotenv.config();

async function fixBookCategories() {
  try {
    // Connect to MongoDB
    await mongoose.connect(
      process.env.MONGO_URI || "mongodb://localhost:27017/thien_tam_app"
    );
    console.log("✅ Connected to MongoDB");

    // Get all books
    const books = await Book.find({}).select("_id title category");
    console.log(`📚 Found ${books.length} books`);

    let fixedCount = 0;
    let deletedCount = 0;

    for (const book of books) {
      const categoryValue = book.category;

      // Check if category is a valid ObjectId
      if (!mongoose.Types.ObjectId.isValid(categoryValue)) {
        console.log(
          `\n❌ Book "${book.title}" has invalid category: "${categoryValue}"`
        );

        // Try to find category by name
        const categoryDoc = await BookCategory.findOne({
          $or: [{ name: categoryValue }, { nameEn: categoryValue }],
        });

        if (categoryDoc) {
          // Update to correct ObjectId
          book.category = categoryDoc._id as any;
          await book.save();
          console.log(
            `✅ Fixed: Updated to category ID ${categoryDoc._id} (${categoryDoc.name})`
          );
          fixedCount++;
        } else {
          // Category not found - delete the book or set to null
          console.log(
            `⚠️  Category "${categoryValue}" not found in BookCategory collection`
          );
          console.log(`   Options: 1) Delete book, 2) Set category to null`);

          // Option 1: Delete book with invalid category
          await Book.deleteOne({ _id: book._id });
          console.log(`🗑️  Deleted book "${book.title}"`);
          deletedCount++;
        }
      }
    }

    console.log(`\n✅ Finished fixing book categories`);
    console.log(`   Fixed: ${fixedCount} books`);
    console.log(`   Deleted: ${deletedCount} books with invalid categories`);
  } catch (error) {
    console.error("❌ Error:", error);
  } finally {
    await mongoose.disconnect();
    console.log("👋 Disconnected from MongoDB");
  }
}

fixBookCategories();
