import mongoose, { Document, Schema } from 'mongoose';
import bcrypt from 'bcrypt';

// Unified User roles
export enum UserRole {
  USER = 'USER',     // Regular user - can access all user features
  ADMIN = 'ADMIN',   // Administrator - full system access
}

// User preferences (only for USER role)
export interface IUserPreferences {
  theme: 'light' | 'dark' | 'auto';
  fontSize: 'small' | 'medium' | 'large';
  lineHeight: number;
  notifications: {
    dailyReading: boolean;
    weeklyDigest: boolean;
    newContent: boolean;
  };
  readingGoals: {
    dailyTarget: number; // minutes per day
    weeklyTarget: number; // days per week
  };
}

// User reading statistics (only for USER role)
export interface IUserStats {
  totalReadings: number;
  totalReadingTime: number; // in minutes
  streakDays: number;
  longestStreak: number;
  favoriteTopics: string[];
  readingHistory: Array<{
    readingId: string;
    date: Date;
    timeSpent: number; // in minutes
  }>;
}

export interface IUser extends Document {
  email: string;
  passwordHash: string;
  name: string;
  avatar?: string;
  dateOfBirth?: Date;
  role: UserRole;
  
  // Optional fields (only for USER role)
  preferences?: IUserPreferences;
  stats?: IUserStats;
  
  // Common fields
  isActive: boolean;
  isEmailVerified: boolean;
  emailVerificationToken?: string;
  passwordResetToken?: string;
  passwordResetExpires?: Date;
  lastLoginAt?: Date;
  createdAt: Date;
  updatedAt: Date;
  
  // Methods
  comparePassword(password: string): Promise<boolean>;
  updateLastLogin(): Promise<void>;
  updateReadingStats(readingId: string, timeSpent: number): Promise<void>;
  isAdmin(): boolean;
  isUser(): boolean;
}

const UserSchema = new Schema<IUser>({
  email: {
    type: String,
    required: true,
    unique: true,
    lowercase: true,
    trim: true,
    match: [/^[^\s@]+@[^\s@]+\.[^\s@]+$/, 'Email không hợp lệ'],
  },
  passwordHash: {
    type: String,
    required: true,
    minlength: 6,
  },
  name: {
    type: String,
    required: true,
    trim: true,
    minlength: 2,
    maxlength: 50,
  },
  avatar: {
    type: String,
    default: null,
  },
  dateOfBirth: {
    type: Date,
    default: null,
  },
  role: {
    type: String,
    enum: Object.values(UserRole),
    default: UserRole.USER,
    required: true,
  },
  
  // Preferences (optional - only for USER role)
  preferences: {
    type: {
      theme: {
        type: String,
        enum: ['light', 'dark', 'auto'],
        default: 'auto',
      },
      fontSize: {
        type: String,
        enum: ['small', 'medium', 'large'],
        default: 'medium',
      },
      lineHeight: {
        type: Number,
        default: 1.6,
        min: 1.2,
        max: 2.0,
      },
      notifications: {
        dailyReading: { type: Boolean, default: true },
        weeklyDigest: { type: Boolean, default: false },
        newContent: { type: Boolean, default: true },
      },
      readingGoals: {
        dailyTarget: { type: Number, default: 15 },
        weeklyTarget: { type: Number, default: 5 },
      },
    },
    default: undefined,
  },
  
  // Stats (optional - only for USER role)
  stats: {
    type: {
      totalReadings: { type: Number, default: 0 },
      totalReadingTime: { type: Number, default: 0 },
      streakDays: { type: Number, default: 0 },
      longestStreak: { type: Number, default: 0 },
      favoriteTopics: [{ type: String }],
      readingHistory: [{
        readingId: { type: String, required: true },
        date: { type: Date, required: true },
        timeSpent: { type: Number, required: true },
      }],
    },
    default: undefined,
  },
  
  // Common fields
  isActive: {
    type: Boolean,
    default: true,
  },
  isEmailVerified: {
    type: Boolean,
    default: false,
  },
  emailVerificationToken: {
    type: String,
    default: null,
  },
  passwordResetToken: {
    type: String,
    default: null,
  },
  passwordResetExpires: {
    type: Date,
    default: null,
  },
  lastLoginAt: {
    type: Date,
    default: null,
  },
}, {
  timestamps: true,
});

// Indexes
UserSchema.index({ email: 1 });
UserSchema.index({ role: 1 });
UserSchema.index({ isActive: 1 });
UserSchema.index({ createdAt: -1 });

// Methods
UserSchema.methods.comparePassword = async function(password: string): Promise<boolean> {
  return bcrypt.compare(password, this.passwordHash);
};

UserSchema.methods.updateLastLogin = async function(): Promise<void> {
  this.lastLoginAt = new Date();
  await this.save();
};

UserSchema.methods.updateReadingStats = async function(readingId: string, timeSpent: number): Promise<void> {
  if (this.role !== UserRole.USER || !this.stats) return;
  
  this.stats.totalReadings += 1;
  this.stats.totalReadingTime += timeSpent;
  this.stats.readingHistory.push({
    readingId,
    date: new Date(),
    timeSpent,
  });
  
  // Keep only last 100 reading history entries
  if (this.stats.readingHistory.length > 100) {
    this.stats.readingHistory = this.stats.readingHistory.slice(-100);
  }
  
  await this.save();
};

UserSchema.methods.isAdmin = function(): boolean {
  return this.role === UserRole.ADMIN;
};

UserSchema.methods.isUser = function(): boolean {
  return this.role === UserRole.USER;
};

// Pre-save middleware to hash password
UserSchema.pre('save', async function(next) {
  if (!this.isModified('passwordHash')) return next();
  
  try {
    const salt = await bcrypt.genSalt(12);
    this.passwordHash = await bcrypt.hash(this.passwordHash, salt);
    next();
  } catch (error) {
    next(error as Error);
  }
});

// Pre-save middleware to initialize preferences and stats for USER role
UserSchema.pre('save', async function(next) {
  if (this.isNew && this.role === UserRole.USER) {
    if (!this.preferences) {
      this.preferences = {
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
    }
    
    if (!this.stats) {
      this.stats = {
        totalReadings: 0,
        totalReadingTime: 0,
        streakDays: 0,
        longestStreak: 0,
        favoriteTopics: [],
        readingHistory: [],
      };
    }
  }
  
  next();
});

// Transform JSON output (remove sensitive fields)
UserSchema.methods.toJSON = function() {
  const userObject = this.toObject();
  delete userObject.passwordHash;
  delete userObject.emailVerificationToken;
  delete userObject.passwordResetToken;
  delete userObject.passwordResetExpires;
  return userObject;
};

export default mongoose.model<IUser>('User', UserSchema);
