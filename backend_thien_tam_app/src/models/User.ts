import mongoose, { Document, Schema } from 'mongoose';
import bcrypt from 'bcrypt';

// User roles for regular users
export enum UserRole {
  USER = 'USER',
  PREMIUM_USER = 'PREMIUM_USER',
  VIP_USER = 'VIP_USER',
}

// User preferences
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

// User reading statistics
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
  role: UserRole;
  preferences: IUserPreferences;
  stats: IUserStats;
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
}

const UserSchema = new Schema<IUser>({
  email: {
    type: String,
    required: true,
    unique: true,
    lowercase: true,
    trim: true,
    match: [/^\w+([.-]?\w+)*@\w+([.-]?\w+)*(\.\w{2,3})+$/, 'Email không hợp lệ'],
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
  role: {
    type: String,
    enum: Object.values(UserRole),
    default: UserRole.USER,
  },
  preferences: {
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
      dailyReading: {
        type: Boolean,
        default: true,
      },
      weeklyDigest: {
        type: Boolean,
        default: true,
      },
      newContent: {
        type: Boolean,
        default: false,
      },
    },
    readingGoals: {
      dailyTarget: {
        type: Number,
        default: 15, // 15 minutes per day
        min: 5,
        max: 120,
      },
      weeklyTarget: {
        type: Number,
        default: 5, // 5 days per week
        min: 1,
        max: 7,
      },
    },
  },
  stats: {
    totalReadings: {
      type: Number,
      default: 0,
    },
    totalReadingTime: {
      type: Number,
      default: 0,
    },
    streakDays: {
      type: Number,
      default: 0,
    },
    longestStreak: {
      type: Number,
      default: 0,
    },
    favoriteTopics: [{
      type: String,
    }],
    readingHistory: [{
      readingId: {
        type: String,
        required: true,
      },
      date: {
        type: Date,
        required: true,
      },
      timeSpent: {
        type: Number,
        required: true,
        min: 0,
      },
    }],
  },
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
  // Add to reading history
  this.stats.readingHistory.push({
    readingId,
    date: new Date(),
    timeSpent,
  });
  
  // Update totals
  this.stats.totalReadings += 1;
  this.stats.totalReadingTime += timeSpent;
  
  // Update streak (simplified logic)
  const today = new Date();
  const yesterday = new Date(today);
  yesterday.setDate(yesterday.getDate() - 1);
  
  const hasReadToday = this.stats.readingHistory.some((entry: any) => 
    entry.date.toDateString() === today.toDateString()
  );
  
  const hasReadYesterday = this.stats.readingHistory.some((entry: any) => 
    entry.date.toDateString() === yesterday.toDateString()
  );
  
  if (hasReadToday && hasReadYesterday) {
    this.stats.streakDays += 1;
  } else if (hasReadToday && !hasReadYesterday) {
    this.stats.streakDays = 1;
  }
  
  // Update longest streak
  if (this.stats.streakDays > this.stats.longestStreak) {
    this.stats.longestStreak = this.stats.streakDays;
  }
  
  await this.save();
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

// Transform JSON output
UserSchema.methods.toJSON = function() {
  const userObject = this.toObject();
  delete userObject.passwordHash;
  delete userObject.emailVerificationToken;
  delete userObject.passwordResetToken;
  delete userObject.passwordResetExpires;
  return userObject;
};

export default mongoose.model<IUser>('User', UserSchema);