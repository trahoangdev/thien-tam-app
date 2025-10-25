import mongoose, { Schema, Document } from 'mongoose';

// Book categories
export enum BookCategory {
  SUTRA = 'sutra',              // Kinh điển
  COMMENTARY = 'commentary',     // Luận giải
  BIOGRAPHY = 'biography',       // Tiểu sử, truyện
  PRACTICE = 'practice',         // Hướng dẫn tu tập
  DHARMA_TALK = 'dharma-talk',   // Pháp thoại
  HISTORY = 'history',           // Lịch sử Phật giáo
  PHILOSOPHY = 'philosophy',     // Triết học
  OTHER = 'other',               // Khác
}

// Book interface
export interface IBook extends Document {
  title: string;
  author?: string;
  translator?: string;
  description?: string;
  category: BookCategory;
  tags: string[];
  bookLanguage: string;
  
  // PDF file info (stored in Cloudinary)
  cloudinaryPublicId: string;
  cloudinaryUrl: string;
  cloudinarySecureUrl: string;
  fileSize: number;
  pageCount?: number;
  
  // Cover image (optional)
  coverImageUrl?: string;
  coverImagePublicId?: string;
  
  // Metadata
  publisher?: string;
  publishYear?: number;
  isbn?: string;
  
  // Stats
  downloadCount: number;
  viewCount: number;
  
  // Access control
  isPublic: boolean;
  uploadedBy: mongoose.Types.ObjectId;
  
  // Timestamps
  createdAt: Date;
  updatedAt: Date;
  
  // Methods
  incrementDownloadCount(): Promise<void>;
  incrementViewCount(): Promise<void>;
}

// Book schema
const BookSchema = new Schema<IBook>(
  {
    title: {
      type: String,
      required: true,
      trim: true,
      maxlength: 300,
      index: true,
    },
    author: {
      type: String,
      trim: true,
      maxlength: 200,
    },
    translator: {
      type: String,
      trim: true,
      maxlength: 200,
    },
    description: {
      type: String,
      trim: true,
      maxlength: 2000,
    },
    category: {
      type: String,
      enum: Object.values(BookCategory),
      required: true,
      index: true,
    },
    tags: {
      type: [String],
      default: [],
      index: true,
    },
    bookLanguage: {
      type: String,
      default: 'vi',
      enum: ['vi', 'en', 'zh', 'pi', 'sa'], // Vietnamese, English, Chinese, Pali, Sanskrit
    },
    
    // PDF file info
    cloudinaryPublicId: {
      type: String,
      required: true,
    },
    cloudinaryUrl: {
      type: String,
      required: true,
    },
    cloudinarySecureUrl: {
      type: String,
      required: true,
    },
    fileSize: {
      type: Number,
      required: true,
    },
    pageCount: {
      type: Number,
    },
    
    // Cover image
    coverImageUrl: {
      type: String,
    },
    coverImagePublicId: {
      type: String,
    },
    
    // Metadata
    publisher: {
      type: String,
      trim: true,
      maxlength: 200,
    },
    publishYear: {
      type: Number,
      min: 1000,
      max: new Date().getFullYear() + 1,
    },
    isbn: {
      type: String,
      trim: true,
      maxlength: 20,
    },
    
    // Stats
    downloadCount: {
      type: Number,
      default: 0,
      min: 0,
    },
    viewCount: {
      type: Number,
      default: 0,
      min: 0,
    },
    
    // Access control
    isPublic: {
      type: Boolean,
      default: true,
    },
    uploadedBy: {
      type: Schema.Types.ObjectId,
      ref: 'AdminUser',
      required: true,
    },
  },
  {
    timestamps: true,
  }
);

// Indexes for search and filtering
BookSchema.index({ 
  title: 'text', 
  author: 'text', 
  description: 'text', 
  tags: 'text' 
}, {
  default_language: 'none', // Disable language-specific stemming
  language_override: 'language_field' // Use a different field name to avoid conflict
});
BookSchema.index({ category: 1, createdAt: -1 });
BookSchema.index({ isPublic: 1, createdAt: -1 });
BookSchema.index({ downloadCount: -1 });
BookSchema.index({ viewCount: -1 });

// Methods
BookSchema.methods.incrementDownloadCount = async function (): Promise<void> {
  this.downloadCount += 1;
  await this.save();
};

BookSchema.methods.incrementViewCount = async function (): Promise<void> {
  this.viewCount += 1;
  await this.save();
};

// Export model
const Book = mongoose.model<IBook>('Book', BookSchema);
export default Book;

