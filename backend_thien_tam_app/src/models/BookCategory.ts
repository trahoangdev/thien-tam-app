import mongoose, { Document, Schema } from 'mongoose';

export interface IBookCategory extends Document {
  _id: string;
  name: string;
  nameEn?: string;
  description?: string;
  icon?: string;
  color?: string;
  displayOrder: number;
  isActive: boolean;
  bookCount: number;
  createdAt: Date;
  updatedAt: Date;
}

const bookCategorySchema = new Schema<IBookCategory>(
  {
    name: {
      type: String,
      required: [true, 'Tên danh mục là bắt buộc'],
      unique: true,
      trim: true,
    },
    nameEn: {
      type: String,
      trim: true,
    },
    description: {
      type: String,
      trim: true,
    },
    icon: {
      type: String,
      default: '📚',
    },
    color: {
      type: String,
      default: '#8B7355',
    },
    displayOrder: {
      type: Number,
      default: 0,
    },
    isActive: {
      type: Boolean,
      default: true,
    },
    bookCount: {
      type: Number,
      default: 0,
    },
  },
  {
    timestamps: true,
  }
);

// Index for sorting
bookCategorySchema.index({ displayOrder: 1, name: 1 });
bookCategorySchema.index({ isActive: 1 });

export const BookCategory = mongoose.model<IBookCategory>(
  'BookCategory',
  bookCategorySchema
);

