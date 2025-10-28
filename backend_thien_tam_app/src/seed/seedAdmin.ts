import dotenv from "dotenv";
dotenv.config();
import { connectDB } from "../db";
import User, { UserRole } from "../models/User";
import bcrypt from "bcrypt";

(async () => {
  try {
    await connectDB(process.env.MONGO_URI!);
    console.log("✅ Connected to MongoDB");

    // Admin account credentials from environment or defaults
    const email = process.env.ADMIN_EMAIL || "admin@thientam.local";
    const password = process.env.ADMIN_PASSWORD || "ThienTam@2025";
    const name = process.env.ADMIN_NAME || "Admin User";
    
    // Hash password
    const passwordHash = await bcrypt.hash(password, 10);

    // Create or update admin user
    const result = await User.updateOne(
      { email },
      {
        $set: {
          email,
          passwordHash,
          name,
          role: UserRole.ADMIN,
          isActive: true,
          isEmailVerified: true,
        },
      },
      { upsert: true }
    );

    if (result.upsertedCount > 0) {
      console.log("✅ Created new admin user");
    } else {
      console.log("✅ Updated existing admin user");
    }

    console.log("\n📧 Admin credentials:");
    console.log(`   Email: ${email}`);
    console.log(`   Password: ${password}`);
    console.log(`   Name: ${name}`);
    console.log("\n⚠️  IMPORTANT: Change this password in production!");
    console.log("   Set ADMIN_EMAIL, ADMIN_PASSWORD, and ADMIN_NAME environment variables\n");

    process.exit(0);
  } catch (error) {
    console.error("❌ Seed admin error:", error);
    process.exit(1);
  }
})();

