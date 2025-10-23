import mongoose, { Document, Schema } from 'mongoose';
import bcrypt from 'bcrypt';

// Admin roles
export enum AdminRole {
  ADMIN = 'ADMIN',
  EDITOR = 'EDITOR',
}

export interface IAdminUser extends Document {
  email: string;
  passwordHash: string;
  name: string;
  roles: AdminRole[];
  isActive: boolean;
  lastLoginAt?: Date;
  createdAt: Date;
  updatedAt: Date;
  
  // Methods
  comparePassword(password: string): Promise<boolean>;
  updateLastLogin(): Promise<void>;
}

const AdminUserSchema = new Schema<IAdminUser>({
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
  roles: [{
    type: String,
    enum: Object.values(AdminRole),
    default: AdminRole.EDITOR,
  }],
  isActive: {
    type: Boolean,
    default: true,
  },
  lastLoginAt: {
    type: Date,
    default: null,
  },
}, {
  timestamps: true,
});

// Indexes
AdminUserSchema.index({ email: 1 });
AdminUserSchema.index({ roles: 1 });
AdminUserSchema.index({ isActive: 1 });

// Methods
AdminUserSchema.methods.comparePassword = async function(password: string): Promise<boolean> {
  return bcrypt.compare(password, this.passwordHash);
};

AdminUserSchema.methods.updateLastLogin = async function(): Promise<void> {
  this.lastLoginAt = new Date();
  await this.save();
};

// Pre-save middleware to hash password
AdminUserSchema.pre('save', async function(next) {
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
AdminUserSchema.methods.toJSON = function() {
  const userObject = this.toObject();
  delete userObject.passwordHash;
  return userObject;
};

export default mongoose.model<IAdminUser>('AdminUser', AdminUserSchema);
