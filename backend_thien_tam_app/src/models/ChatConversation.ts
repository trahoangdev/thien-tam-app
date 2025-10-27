import mongoose, { Schema, Document } from 'mongoose';

export interface IChatMessage {
  role: 'user' | 'assistant' | 'system';
  content: string;
  timestamp: Date;
}

export interface IChatConversation extends Document {
  userId?: mongoose.Types.ObjectId; // Optional - for guest users
  sessionId: string; // For tracking guest sessions
  title?: string; // Auto-generated from first message
  messages: IChatMessage[];
  isActive: boolean;
  lastMessageAt: Date;
  createdAt: Date;
  updatedAt: Date;
}

const ChatMessageSchema = new Schema({
  role: {
    type: String,
    enum: ['user', 'assistant', 'system'],
    required: true,
  },
  content: {
    type: String,
    required: true,
  },
  timestamp: {
    type: Date,
    default: Date.now,
  },
}, { _id: false });

const ChatConversationSchema = new Schema<IChatConversation>(
  {
    userId: {
      type: Schema.Types.ObjectId,
      ref: 'User',
      default: null,
    },
    sessionId: {
      type: String,
      required: true,
      index: true,
    },
    title: {
      type: String,
      trim: true,
      maxlength: 200,
    },
    messages: {
      type: [ChatMessageSchema],
      default: [],
    },
    isActive: {
      type: Boolean,
      default: true,
    },
    lastMessageAt: {
      type: Date,
      default: Date.now,
    },
  },
  {
    timestamps: true,
  }
);

// Indexes
ChatConversationSchema.index({ userId: 1, createdAt: -1 });
ChatConversationSchema.index({ sessionId: 1, createdAt: -1 });
ChatConversationSchema.index({ lastMessageAt: -1 });
ChatConversationSchema.index({ isActive: 1 });

// Auto-generate title from first user message
ChatConversationSchema.pre('save', function (next) {
  if (!this.title && this.messages.length > 0) {
    const firstUserMessage = this.messages.find(m => m.role === 'user');
    if (firstUserMessage) {
      this.title = firstUserMessage.content.slice(0, 50) + (firstUserMessage.content.length > 50 ? '...' : '');
    }
  }
  next();
});

const ChatConversation = mongoose.model<IChatConversation>('ChatConversation', ChatConversationSchema);

export default ChatConversation;

