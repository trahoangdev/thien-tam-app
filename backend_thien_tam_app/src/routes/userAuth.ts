import express from 'express';
import jwt, { SignOptions } from 'jsonwebtoken';
import bcrypt from 'bcrypt';
import { z } from 'zod';
import User, { UserRole } from '../models/User';
import { requireAuth } from '../middlewares/auth';

const router = express.Router();

// Validation schemas
const registerSchema = z.object({
  email: z.string().email('Email không hợp lệ'),
  password: z.string().min(6, 'Mật khẩu phải có ít nhất 6 ký tự'),
  name: z.string().min(2, 'Tên phải có ít nhất 2 ký tự').max(50, 'Tên không được quá 50 ký tự'),
});

const loginSchema = z.object({
  email: z.string().email('Email không hợp lệ'),
  password: z.string().min(1, 'Mật khẩu không được để trống'),
});

const updateProfileSchema = z.object({
  name: z.string().min(2, 'Tên phải có ít nhất 2 ký tự').max(50, 'Tên không được quá 50 ký tự').optional(),
  preferences: z.object({
    theme: z.enum(['light', 'dark', 'auto']).optional(),
    fontSize: z.enum(['small', 'medium', 'large']).optional(),
    lineHeight: z.number().min(1.2).max(2.0).optional(),
    notifications: z.object({
      dailyReading: z.boolean().optional(),
      weeklyDigest: z.boolean().optional(),
      newContent: z.boolean().optional(),
    }).optional(),
    readingGoals: z.object({
      dailyTarget: z.number().min(5).max(120).optional(),
      weeklyTarget: z.number().min(1).max(7).optional(),
    }).optional(),
  }).optional(),
});

// Helper function to generate JWT tokens
const generateTokens = (userId: string, role: UserRole) => {
  const accessToken = jwt.sign(
    { sub: userId, role },
    process.env.JWT_SECRET as string,
    { expiresIn: '7d' } as SignOptions
  );
  
  const refreshToken = jwt.sign(
    { sub: userId },
    process.env.REFRESH_SECRET as string,
    { expiresIn: '30d' } as SignOptions
  );
  
  return { accessToken, refreshToken };
};

// POST /auth/register - User registration
router.post('/register', async (req, res) => {
  try {
    const { email, password, name } = registerSchema.parse(req.body);
    
    // Check if user already exists
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).json({ 
        message: 'Email đã được sử dụng',
        code: 'EMAIL_EXISTS'
      });
    }
    
    // Create new user
    const user = new User({
      email,
      passwordHash: password, // Will be hashed by pre-save middleware
      name,
      role: UserRole.USER,
    });
    
    await user.save();
    
    // Generate tokens
    const { accessToken, refreshToken } = generateTokens((user._id as any).toString(), user.role);
    
    // Update last login
    await user.updateLastLogin();
    
    res.status(201).json({
      message: 'Đăng ký thành công',
      user: user.toJSON(),
      tokens: {
        accessToken,
        refreshToken,
      },
    });
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({
        message: 'Dữ liệu không hợp lệ',
        errors: error.errors,
      });
    }
    
    console.error('Register error:', error);
    res.status(500).json({ message: 'Lỗi server' });
  }
});

// POST /auth/login - User login
router.post('/login', async (req, res) => {
  try {
    const { email, password } = loginSchema.parse(req.body);
    
    // Find user
    const user = await User.findOne({ email, isActive: true });
    if (!user) {
      return res.status(401).json({ 
        message: 'Email hoặc mật khẩu không đúng',
        code: 'INVALID_CREDENTIALS'
      });
    }
    
    // Check password
    const isValidPassword = await user.comparePassword(password);
    if (!isValidPassword) {
      return res.status(401).json({ 
        message: 'Email hoặc mật khẩu không đúng',
        code: 'INVALID_CREDENTIALS'
      });
    }
    
    // Generate tokens
    const { accessToken, refreshToken } = generateTokens((user._id as any).toString(), user.role);
    
    // Update last login
    await user.updateLastLogin();
    
    res.json({
      message: 'Đăng nhập thành công',
      user: user.toJSON(),
      tokens: {
        accessToken,
        refreshToken,
      },
    });
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({
        message: 'Dữ liệu không hợp lệ',
        errors: error.errors,
      });
    }
    
    console.error('Login error:', error);
    res.status(500).json({ message: 'Lỗi server' });
  }
});

// POST /auth/refresh - Refresh access token
router.post('/refresh', async (req, res) => {
  try {
    const { refreshToken } = req.body;
    
    if (!refreshToken) {
      return res.status(400).json({ message: 'Refresh token là bắt buộc' });
    }
    
    // Verify refresh token
    const payload = jwt.verify(refreshToken, process.env.REFRESH_SECRET as string) as any;
    const user = await User.findById(payload.sub).select('-passwordHash');
    
    if (!user || !user.isActive) {
      return res.status(401).json({ message: 'Token không hợp lệ' });
    }
    
    // Generate new access token
    const { accessToken } = generateTokens((user._id as any).toString(), user.role);
    
    res.json({
      accessToken,
    });
  } catch (error) {
    res.status(401).json({ message: 'Token không hợp lệ hoặc hết hạn' });
  }
});

// GET /auth/me - Get current user profile
router.get('/me', requireAuth, async (req, res) => {
  try {
    const user = await User.findById(req.userId).select('-passwordHash');
    
    if (!user) {
      return res.status(404).json({ message: 'Người dùng không tồn tại' });
    }
    
    res.json({
      user: user.toJSON(),
    });
  } catch (error) {
    console.error('Get profile error:', error);
    res.status(500).json({ message: 'Lỗi server' });
  }
});

// PUT /auth/profile - Update user profile
router.put('/profile', requireAuth, async (req, res) => {
  try {
    const updateData = updateProfileSchema.parse(req.body);
    
    const user = await User.findById(req.userId);
    if (!user) {
      return res.status(404).json({ message: 'Người dùng không tồn tại' });
    }
    
    // Update user data
    if (updateData.name) {
      user.name = updateData.name;
    }
    
    if (updateData.preferences) {
      if (updateData.preferences.theme) {
        user.preferences.theme = updateData.preferences.theme;
      }
      if (updateData.preferences.fontSize) {
        user.preferences.fontSize = updateData.preferences.fontSize;
      }
      if (updateData.preferences.lineHeight) {
        user.preferences.lineHeight = updateData.preferences.lineHeight;
      }
      if (updateData.preferences.notifications) {
        Object.assign(user.preferences.notifications, updateData.preferences.notifications);
      }
      if (updateData.preferences.readingGoals) {
        Object.assign(user.preferences.readingGoals, updateData.preferences.readingGoals);
      }
    }
    
    await user.save();
    
    res.json({
      message: 'Cập nhật thông tin thành công',
      user: user.toJSON(),
    });
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({
        message: 'Dữ liệu không hợp lệ',
        errors: error.errors,
      });
    }
    
    console.error('Update profile error:', error);
    res.status(500).json({ message: 'Lỗi server' });
  }
});

// POST /auth/logout - Logout (client-side token removal)
router.post('/logout', requireAuth, async (req, res) => {
  try {
    // In a more sophisticated system, you might want to blacklist the token
    // For now, we'll just return success and let the client handle token removal
    
    res.json({
      message: 'Đăng xuất thành công',
    });
  } catch (error) {
    console.error('Logout error:', error);
    res.status(500).json({ message: 'Lỗi server' });
  }
});

// POST /auth/reading-stats - Update reading statistics
router.post('/reading-stats', requireAuth, async (req, res) => {
  try {
    const { readingId, timeSpent } = req.body;
    
    if (!readingId || !timeSpent || timeSpent < 0) {
      return res.status(400).json({ 
        message: 'readingId và timeSpent là bắt buộc' 
      });
    }
    
    const user = await User.findById(req.userId);
    if (!user) {
      return res.status(404).json({ message: 'Người dùng không tồn tại' });
    }
    
    await user.updateReadingStats(readingId, timeSpent);
    
    res.json({
      message: 'Cập nhật thống kê thành công',
      stats: user.stats,
    });
  } catch (error) {
    console.error('Update reading stats error:', error);
    res.status(500).json({ message: 'Lỗi server' });
  }
});

export default router;
