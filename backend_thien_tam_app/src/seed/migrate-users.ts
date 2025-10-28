/**
 * Migration Script: Merge AdminUser into User
 * 
 * This script:
 * 1. Backs up existing AdminUser collection
 * 2. Migrates AdminUser documents to User collection with role=ADMIN
 * 3. Updates existing User documents to have role=USER
 * 4. Verifies migration success
 */

import mongoose from 'mongoose';
import dotenv from 'dotenv';
import User, { UserRole } from '../models/User';

// Load environment variables
dotenv.config();

const MONGO_URI = process.env.MONGO_URI || 'mongodb://localhost:27017/thientam';

async function migrateUsers() {
  try {
    console.log('🔄 Starting User Migration...\n');
    
    // Connect to MongoDB
    await mongoose.connect(MONGO_URI);
    console.log('✅ Connected to MongoDB\n');
    
    const db = mongoose.connection.db!;
    
    // Step 1: Backup AdminUser collection
    console.log('📦 Step 1: Backing up AdminUser collection...');
    const adminUserExists = await db.listCollections({ name: 'adminusers' }).hasNext();
    
    if (adminUserExists) {
      const adminUsers = await db.collection('adminusers').find({}).toArray();
      console.log(`   Found ${adminUsers.length} admin users`);
      
      if (adminUsers.length > 0) {
        // Create backup collection
        const backupCollectionName = `adminusers_backup_${Date.now()}`;
        await db.createCollection(backupCollectionName);
        await db.collection(backupCollectionName).insertMany(adminUsers);
        console.log(`   ✅ Backup created: ${backupCollectionName}\n`);
        
        // Step 2: Migrate AdminUsers to User collection
        console.log('🔄 Step 2: Migrating AdminUsers to User collection...');
        
        for (const adminUser of adminUsers) {
          // Check if user already exists in User collection
          const existingUser = await User.findOne({ email: adminUser.email });
          
          if (existingUser) {
            console.log(`   ⚠️  User already exists: ${adminUser.email} - Updating role to ADMIN`);
            existingUser.role = UserRole.ADMIN;
            // Remove preferences and stats for admin users
            existingUser.preferences = undefined;
            existingUser.stats = undefined;
            await existingUser.save({ validateBeforeSave: false });
          } else {
            // Create new user with ADMIN role
            const newUser = new User({
              email: adminUser.email,
              passwordHash: adminUser.passwordHash, // Already hashed
              name: adminUser.name,
              role: UserRole.ADMIN,
              isActive: adminUser.isActive ?? true,
              isEmailVerified: true, // Admins are pre-verified
              lastLoginAt: adminUser.lastLoginAt,
              createdAt: adminUser.createdAt,
              updatedAt: adminUser.updatedAt,
              // No preferences or stats for admin users
            });
            
            await newUser.save({ validateBeforeSave: false });
            console.log(`   ✅ Migrated admin: ${adminUser.email}`);
          }
        }
        
        console.log(`   ✅ Migrated ${adminUsers.length} admin users\n`);
      }
    } else {
      console.log('   ℹ️  No AdminUser collection found - skipping migration\n');
    }
    
    // Step 3: Update existing regular users to have role=USER
    console.log('🔄 Step 3: Ensuring all regular users have role=USER...');
    const usersUpdated = await User.updateMany(
      { role: { $exists: false } },
      { $set: { role: UserRole.USER } }
    );
    console.log(`   ✅ Updated ${usersUpdated.modifiedCount} users\n`);
    
    // Step 4: Initialize preferences and stats for USER role
    console.log('🔄 Step 4: Initializing preferences/stats for USER role...');
    const regularUsers = await User.find({ role: UserRole.USER });
    
    for (const user of regularUsers) {
      let updated = false;
      
      if (!user.preferences) {
        user.preferences = {
          theme: 'auto',
          fontSize: 'medium',
          lineHeight: 1.6,
          notifications: {
            dailyReading: true,
            weeklyDigest: false,
            newContent: true,
          },
          readingGoals: {
            dailyTarget: 15,
            weeklyTarget: 5,
          },
        };
        updated = true;
      }
      
      if (!user.stats) {
        user.stats = {
          totalReadings: 0,
          totalReadingTime: 0,
          streakDays: 0,
          longestStreak: 0,
          favoriteTopics: [],
          readingHistory: [],
        };
        updated = true;
      }
      
      if (updated) {
        await user.save({ validateBeforeSave: false });
      }
    }
    console.log(`   ✅ Initialized data for ${regularUsers.length} users\n`);
    
    // Step 5: Verify migration
    console.log('✅ Step 5: Verification...');
    const totalUsers = await User.countDocuments();
    const adminCount = await User.countDocuments({ role: UserRole.ADMIN });
    const userCount = await User.countDocuments({ role: UserRole.USER });
    
    console.log(`\n📊 Migration Results:`);
    console.log(`   Total Users: ${totalUsers}`);
    console.log(`   Admins (ADMIN role): ${adminCount}`);
    console.log(`   Regular Users (USER role): ${userCount}`);
    
    // List all admin users
    console.log(`\n👨‍💼 Admin Users:`);
    const admins = await User.find({ role: UserRole.ADMIN }).select('email name isActive');
    admins.forEach(admin => {
      console.log(`   - ${admin.email} (${admin.name}) ${admin.isActive ? '✅' : '❌'}`);
    });
    
    console.log(`\n✅ Migration completed successfully!`);
    console.log(`\n⚠️  IMPORTANT: You can now delete the AdminUser model and routes`);
    
  } catch (error) {
    console.error('❌ Migration failed:', error);
    throw error;
  } finally {
    await mongoose.disconnect();
    console.log('\n🔌 Disconnected from MongoDB');
  }
}

// Run migration
migrateUsers()
  .then(() => {
    console.log('\n✅ Migration script completed');
    process.exit(0);
  })
  .catch((error) => {
    console.error('\n❌ Migration script failed:', error);
    process.exit(1);
  });

