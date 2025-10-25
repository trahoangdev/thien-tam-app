import mongoose, { Schema, Document } from 'mongoose';

export interface IAudio extends Document {
  title: string;
  description?: string;
  artist?: string;
  duration?: number; // in seconds
  category: 'sutra' | 'mantra' | 'dharma-talk' | 'meditation' | 'chanting' | 'music' | 'other';
  tags: string[];
  cloudinaryPublicId: string;
  cloudinaryUrl: string;
  cloudinarySecureUrl: string;
  fileSize?: number; // in bytes
  format?: string; // mp3, wav, etc.
  uploadedBy: mongoose.Types.ObjectId;
  playCount: number;
  isPublic: boolean;
  createdAt: Date;
  updatedAt: Date;
}

const AudioSchema: Schema = new Schema(
  {
    title: {
      type: String,
      required: [true, 'Title is required'],
      trim: true,
      maxlength: [200, 'Title cannot exceed 200 characters'],
    },
    description: {
      type: String,
      trim: true,
      maxlength: [1000, 'Description cannot exceed 1000 characters'],
    },
    artist: {
      type: String,
      trim: true,
      maxlength: [100, 'Artist name cannot exceed 100 characters'],
    },
    duration: {
      type: Number,
      min: [0, 'Duration cannot be negative'],
    },
    category: {
      type: String,
      enum: {
        values: ['sutra', 'mantra', 'dharma-talk', 'meditation', 'chanting', 'music', 'other'],
        message: '{VALUE} is not a valid category',
      },
      required: [true, 'Category is required'],
      default: 'other',
    },
    tags: {
      type: [String],
      default: [],
      validate: {
        validator: function (tags: string[]) {
          return tags.length <= 10;
        },
        message: 'Cannot have more than 10 tags',
      },
    },
    cloudinaryPublicId: {
      type: String,
      required: [true, 'Cloudinary public ID is required'],
      unique: true,
    },
    cloudinaryUrl: {
      type: String,
      required: [true, 'Cloudinary URL is required'],
    },
    cloudinarySecureUrl: {
      type: String,
      required: [true, 'Cloudinary secure URL is required'],
    },
    fileSize: {
      type: Number,
      min: [0, 'File size cannot be negative'],
    },
    format: {
      type: String,
      lowercase: true,
    },
    uploadedBy: {
      type: Schema.Types.ObjectId,
      ref: 'AdminUser',
      required: [true, 'Uploader is required'],
    },
    playCount: {
      type: Number,
      default: 0,
      min: [0, 'Play count cannot be negative'],
    },
    isPublic: {
      type: Boolean,
      default: true,
    },
  },
  {
    timestamps: true,
  }
);

// Indexes for better query performance
AudioSchema.index({ category: 1, isPublic: 1 });
AudioSchema.index({ tags: 1 });
AudioSchema.index({ createdAt: -1 });
AudioSchema.index({ playCount: -1 });
AudioSchema.index({ title: 'text', description: 'text', artist: 'text' });

// Method to increment play count
AudioSchema.methods.incrementPlayCount = async function () {
  this.playCount += 1;
  return this.save();
};

export default mongoose.model<IAudio>('Audio', AudioSchema);

