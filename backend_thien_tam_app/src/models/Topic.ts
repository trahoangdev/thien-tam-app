import { Schema, model } from "mongoose";

const TopicSchema = new Schema({
  slug: { 
    type: String, 
    required: true, 
    unique: true, 
    lowercase: true,
    trim: true,
    index: true 
  },
  name: { 
    type: String, 
    required: true,
    trim: true 
  },
  description: { 
    type: String, 
    default: "",
    trim: true 
  },
  color: { 
    type: String, 
    default: "#4CAF50", // Default green color
    match: /^#[0-9A-F]{6}$/i // Hex color validation
  },
  icon: { 
    type: String, 
    default: "label", // Material icon name
    trim: true 
  },
  isActive: { 
    type: Boolean, 
    default: true 
  },
  readingCount: { 
    type: Number, 
    default: 0 
  },
  sortOrder: { 
    type: Number, 
    default: 0 
  }
}, { 
  timestamps: true 
});

// Index for search
TopicSchema.index({ name: "text", description: "text" });

// Virtual for reading count (will be updated via aggregation)
TopicSchema.virtual('readings', {
  ref: 'Reading',
  localField: 'slug',
  foreignField: 'topicSlugs',
  count: true
});

export default model("Topic", TopicSchema);
