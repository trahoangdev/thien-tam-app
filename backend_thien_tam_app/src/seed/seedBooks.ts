// Seed sample books for testing
import mongoose from "mongoose";
import dotenv from "dotenv";
import Book from "../models/Book";
import { BookCategory } from "../models/BookCategory";
import User, { UserRole } from "../models/User";

dotenv.config();

async function seedBooks() {
  try {
    await mongoose.connect(
      process.env.MONGO_URI || "mongodb://localhost:27017/thien-tam-app"
    );
    console.log("✅ Connected to MongoDB");

    // Get or create admin user for uploadedBy
    let admin = await User.findOne({ email: "admin@thientam.local", role: UserRole.ADMIN });
    if (!admin) {
      const bcrypt = require('bcrypt');
      const passwordHash = await bcrypt.hash("ThienTam@2025", 10);
      admin = await User.create({
        email: "admin@thientam.local",
        passwordHash,
        name: "System Admin",
        role: UserRole.ADMIN,
        isActive: true,
        isEmailVerified: true,
      });
      console.log("✅ Created admin user");
    }

    // Get categories
    const sutraCategory = await BookCategory.findOne({ nameEn: "Sutras" });
    const practiceCategory = await BookCategory.findOne({
      nameEn: "Practice Guides",
    });
    const dharmaTalkCategory = await BookCategory.findOne({
      nameEn: "Dharma Talks",
    });
    const commentaryCategory = await BookCategory.findOne({
      nameEn: "Commentaries",
    });

    if (
      !sutraCategory ||
      !practiceCategory ||
      !dharmaTalkCategory ||
      !commentaryCategory
    ) {
      console.error(
        "❌ Categories not found. Run seed-book-categories.ts first!"
      );
      return;
    }

    // Clear existing books
    await Book.deleteMany({});
    console.log("🗑️  Cleared existing books");

    // Sample books
    const books = [
      {
        title: "Kinh Kim Cương",
        description:
          "Kinh Kim Cương Bát Nhã Ba La Mật - một trong những bộ kinh quan trọng nhất của Phật giáo Đại Thừa, giảng về trí tuệ siêu việt.",
        author: "Đức Phật Thích Ca",
        category: sutraCategory._id,
        coverImageUrl:
          "https://via.placeholder.com/300x400?text=Kinh+Kim+Cương",
        cloudinaryPublicId: "sample/kinh-kim-cuong",
        cloudinaryUrl: "http://cloudinary.com/sample/kinh-kim-cuong.pdf",
        cloudinarySecureUrl: "https://cloudinary.com/sample/kinh-kim-cuong.pdf",
        fileSize: 1024000,
        pageCount: 120,
        bookLanguage: "vi",
        publishYear: 2020,
        publisher: "Nhà Xuất Bản Phương Đông",
        tags: ["kinh điển", "bát nhã", "đại thừa"],
        uploadedBy: admin._id,
        isPublic: true,
      },
      {
        title: "Kinh Pháp Hoa",
        description:
          "Kinh Diệu Pháp Liên Hoa - kinh điển quan trọng nhất của Phật giáo Đại Thừa, nói về giáo pháp viên mãn của Đức Phật.",
        author: "Đức Phật Thích Ca",
        category: sutraCategory._id,
        cloudinaryPublicId: "sample/kinh-phap-hoa",
        cloudinaryUrl: "http://cloudinary.com/sample/kinh-phap-hoa.pdf",
        cloudinarySecureUrl: "https://cloudinary.com/sample/kinh-phap-hoa.pdf",
        fileSize: 2048000,
        pageCount: 450,
        bookLanguage: "vi",
        publishYear: 2019,
        publisher: "Nhà Xuất Bản Tôn Giáo",
        tags: ["kinh điển", "pháp hoa", "đại thừa"],
        uploadedBy: admin._id,
        isPublic: true,
      },
      {
        title: "Bát Chánh Đạo - Con Đường Đến Hạnh Phúc",
        description:
          "Hướng dẫn thực hành Bát Chánh Đạo - con đường tám nhánh dẫn đến giải thoát khổ đau theo lời Phật dạy.",
        author: "Thích Nhất Hạnh",
        category: practiceCategory._id,
        cloudinaryPublicId: "sample/bat-chanh-dao",
        cloudinaryUrl: "http://cloudinary.com/sample/bat-chanh-dao.pdf",
        cloudinarySecureUrl: "https://cloudinary.com/sample/bat-chanh-dao.pdf",
        fileSize: 1536000,
        pageCount: 250,
        bookLanguage: "vi",
        publishYear: 2021,
        publisher: "Nhà Xuất Bản Hồng Đức",
        tags: ["tu tập", "bát chánh đạo", "thực hành"],
        uploadedBy: admin._id,
        isPublic: true,
      },
      {
        title: "Thiền Tông Nhập Môn",
        description:
          "Giới thiệu cơ bản về Thiền tông, các phương pháp thiền quán và cách áp dụng vào đời sống hiện đại.",
        author: "Thích Thanh Từ",
        category: practiceCategory._id,
        cloudinaryPublicId: "sample/thien-tong-nhap-mon",
        cloudinaryUrl: "http://cloudinary.com/sample/thien-tong.pdf",
        cloudinarySecureUrl: "https://cloudinary.com/sample/thien-tong.pdf",
        fileSize: 1280000,
        pageCount: 180,
        bookLanguage: "vi",
        publishYear: 2022,
        publisher: "Nhà Xuất Bản Phương Đông",
        tags: ["thiền", "tu tập", "nhập môn"],
        uploadedBy: admin._id,
        isPublic: true,
      },
      {
        title: "Pháp Thoại Về Tứ Diệu Đế",
        description:
          "Tuyển tập các bài pháp thoại giảng giải về Tứ Diệu Đế - bốn chân lý cao quý của Phật giáo.",
        author: "Thích Trí Quảng",
        category: dharmaTalkCategory._id,
        cloudinaryPublicId: "sample/phap-thoai-tu-dieu-de",
        cloudinaryUrl: "http://cloudinary.com/sample/tu-dieu-de.pdf",
        cloudinarySecureUrl: "https://cloudinary.com/sample/tu-dieu-de.pdf",
        fileSize: 1400000,
        pageCount: 200,
        bookLanguage: "vi",
        publishYear: 2020,
        publisher: "Nhà Xuất Bản Tôn Giáo",
        tags: ["pháp thoại", "tứ diệu đế", "giáo lý"],
        uploadedBy: admin._id,
        isPublic: true,
      },
      {
        title: "Luận Giải Kinh Hoa Nghiêm",
        description:
          "Bình giảng chi tiết về Kinh Hoa Nghiêm - bộ kinh khổng lồ về thế giới pháp giới của Đức Phật.",
        author: "Thích Minh Châu",
        category: commentaryCategory._id,
        cloudinaryPublicId: "sample/hoa-nghiem",
        cloudinaryUrl: "http://cloudinary.com/sample/hoa-nghiem.pdf",
        cloudinarySecureUrl: "https://cloudinary.com/sample/hoa-nghiem.pdf",
        fileSize: 3072000,
        pageCount: 600,
        bookLanguage: "vi",
        publishYear: 2018,
        publisher: "Nhà Xuất Bản Phương Đông",
        tags: ["luận giải", "hoa nghiêm", "kinh điển"],
        uploadedBy: admin._id,
        isPublic: true,
      },
      {
        title: "Tâm Kinh Bát Nhã",
        description:
          "Kinh Bát Nhã Ba La Mật Đa Tâm Kinh - bản kinh ngắn gọn nhất nhưng chứa đựng tinh túy của trí tuệ Phật giáo.",
        author: "Đức Phật Thích Ca",
        category: sutraCategory._id,
        cloudinaryPublicId: "sample/tam-kinh",
        cloudinaryUrl: "http://cloudinary.com/sample/tam-kinh.pdf",
        cloudinarySecureUrl: "https://cloudinary.com/sample/tam-kinh.pdf",
        fileSize: 512000,
        pageCount: 50,
        bookLanguage: "vi",
        publishYear: 2021,
        publisher: "Nhà Xuất Bản Tôn Giáo",
        tags: ["kinh điển", "bát nhã", "tâm kinh"],
        uploadedBy: admin._id,
        isPublic: true,
      },
      {
        title: "Hạnh Phúc Từ Thiền Định",
        description:
          "Hướng dẫn các phương pháp thiền định để đạt được an lạc và hạnh phúc trong cuộc sống.",
        author: "Thích Nhất Hạnh",
        category: practiceCategory._id,
        cloudinaryPublicId: "sample/hanh-phuc-thien-dinh",
        cloudinaryUrl: "http://cloudinary.com/sample/thien-dinh.pdf",
        cloudinarySecureUrl: "https://cloudinary.com/sample/thien-dinh.pdf",
        fileSize: 1700000,
        pageCount: 220,
        bookLanguage: "vi",
        publishYear: 2023,
        publisher: "Nhà Xuất Bản Hồng Đức",
        tags: ["thiền định", "tu tập", "hạnh phúc"],
        uploadedBy: admin._id,
        isPublic: true,
      },
    ];

    const createdBooks = await Book.insertMany(books);
    console.log(`✅ Created ${createdBooks.length} sample books\n`);

    // Display created books
    createdBooks.forEach((book, index) => {
      console.log(`${index + 1}. 📖 ${book.title}`);
      console.log(`   Tác giả: ${book.author}`);
      console.log(`   Danh mục: ${book.category}`);
      console.log("");
    });

    console.log("🎉 SUCCESS! Sample books seeded!");
  } catch (error) {
    console.error("❌ Error:", error);
  } finally {
    await mongoose.disconnect();
    console.log("👋 Disconnected from MongoDB");
  }
}

seedBooks();
