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
  avatar: z.string().url('avatar phải là URL hợp lệ').optional(),
  dateOfBirth: z.string().optional().refine((val) => {
    if (!val) return true;
    const date = new Date(val);
    return !isNaN(date.getTime());
  }, 'Ngày sinh không hợp lệ'),
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

/**
 * @swagger
 * /user-auth/register:
 *   post:
 *     summary: Register new user
 *     description: Register a new user account
 *     tags: [User Authentication]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - email
 *               - password
 *               - name
 *             properties:
 *               email:
 *                 type: string
 *                 format: email
 *                 description: User email address
 *                 example: "user@example.com"
 *               password:
 *                 type: string
 *                 minLength: 6
 *                 description: User password (min 6 characters)
 *                 example: "password123"
 *               name:
 *                 type: string
 *                 minLength: 2
 *                 maxLength: 50
 *                 description: User full name
 *                 example: "Nguyễn Văn A"
 *     responses:
 *       201:
 *         description: User registered successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: "Đăng ký thành công"
 *                 user:
 *                   type: object
 *                   properties:
 *                     id:
 *                       type: string
 *                       description: User ID
 *                     email:
 *                       type: string
 *                       description: User email
 *                     name:
 *                       type: string
 *                       description: User name
 *                     role:
 *                       type: string
 *                       description: User role
 *                 accessToken:
 *                   type: string
 *                   description: JWT access token
 *                 refreshToken:
 *                   type: string
 *                   description: JWT refresh token
 *       400:
 *         description: Bad request - validation error or email exists
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 *       500:
 *         description: Server error
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
router.post('/register', async (req, res) => {
  try {
    const { email, password, name } = registerSchema.parse(req.body);
    
    // Check if user already exists
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).json({ 
        message: 'Tài khoản này đã được đăng ký. Vui lòng thử lại!',
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
      user: {
        id: user._id,
        email: user.email,
        name: user.name,
        role: user.role,
      },
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

/**
 * @swagger
 * /user-auth/login:
 *   post:
 *     summary: User login
 *     description: Authenticate user and return JWT tokens
 *     tags: [User Authentication]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - email
 *               - password
 *             properties:
 *               email:
 *                 type: string
 *                 format: email
 *                 description: User email address
 *                 example: "user@example.com"
 *               password:
 *                 type: string
 *                 description: User password
 *                 example: "password123"
 *     responses:
 *       200:
 *         description: Login successful
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: "Đăng nhập thành công"
 *                 user:
 *                   type: object
 *                   properties:
 *                     id:
 *                       type: string
 *                       description: User ID
 *                     email:
 *                       type: string
 *                       description: User email
 *                     name:
 *                       type: string
 *                       description: User name
 *                     role:
 *                       type: string
 *                       description: User role
 *                 tokens:
 *                   type: object
 *                   properties:
 *                     accessToken:
 *                       type: string
 *                       description: JWT access token
 *                     refreshToken:
 *                       type: string
 *                       description: JWT refresh token
 *       400:
 *         description: Bad request - validation error
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 *       401:
 *         description: Invalid credentials
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 *       500:
 *         description: Server error
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
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
      user: {
        id: user._id,
        email: user.email,
        name: user.name,
        role: user.role,
      },
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

/**
 * @swagger
 * /user-auth/refresh:
 *   post:
 *     summary: Refresh user token
 *     description: Refresh user access token using refresh token
 *     tags: [User Authentication]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - refreshToken
 *             properties:
 *               refreshToken:
 *                 type: string
 *                 description: Refresh token
 *                 example: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
 *     responses:
 *       200:
 *         description: Token refreshed successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 accessToken:
 *                   type: string
 *                   description: New JWT access token
 *       400:
 *         description: Bad request - missing refresh token
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 *       401:
 *         description: Invalid refresh token
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 *       500:
 *         description: Server error
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
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

/**
 * @swagger
 * /user-auth/me:
 *   get:
 *     summary: Get current user profile
 *     description: Returns information about the currently authenticated user
 *     tags: [User Authentication]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Successfully retrieved user profile
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 user:
 *                   type: object
 *                   properties:
 *                     id:
 *                       type: string
 *                       description: User ID
 *                     email:
 *                       type: string
 *                       description: User email
 *                     name:
 *                       type: string
 *                       description: User name
 *                     role:
 *                       type: string
 *                       description: User role
 *                     preferences:
 *                       type: object
 *                       description: User preferences
 *                     stats:
 *                       type: object
 *                       description: User reading statistics
 *                     createdAt:
 *                       type: string
 *                       format: date-time
 *                       description: Creation timestamp
 *                     updatedAt:
 *                       type: string
 *                       format: date-time
 *                       description: Last update timestamp
 *       401:
 *         description: Unauthorized - invalid or missing token
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 *       404:
 *         description: User not found
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 *       500:
 *         description: Server error
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
router.get('/me', requireAuth, async (req, res) => {
  try {
    const user = await User.findById(req.userId).select('-passwordHash');
    
    if (!user) {
      return res.status(404).json({ message: 'Người dùng không tồn tại' });
    }
    
    res.json({
      user: {
        id: user._id,
        email: user.email,
        name: user.name,
        avatar: user.avatar,
        dateOfBirth: user.dateOfBirth,
        role: user.role,
        preferences: user.preferences,
        stats: user.stats,
        createdAt: user.createdAt,
        updatedAt: user.updatedAt,
      },
    });
  } catch (error) {
    console.error('Get profile error:', error);
    res.status(500).json({ message: 'Lỗi server' });
  }
});

/**
 * @swagger
 * /user-auth/profile:
 *   put:
 *     summary: Update user profile
 *     description: Update user profile information and preferences
 *     tags: [User Authentication]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               name:
 *                 type: string
 *                 minLength: 2
 *                 maxLength: 50
 *                 description: Updated user name
 *                 example: "Nguyễn Văn B"
 *               preferences:
 *                 type: object
 *                 properties:
 *                   theme:
 *                     type: string
 *                     enum: [light, dark, auto]
 *                     description: UI theme preference
 *                   fontSize:
 *                     type: string
 *                     enum: [small, medium, large]
 *                     description: Font size preference
 *                   lineHeight:
 *                     type: number
 *                     minimum: 1.2
 *                     maximum: 2.0
 *                     description: Line height preference
 *                   notifications:
 *                     type: object
 *                     properties:
 *                       dailyReading:
 *                         type: boolean
 *                         description: Daily reading notifications
 *                       weeklyDigest:
 *                         type: boolean
 *                         description: Weekly digest notifications
 *                       newContent:
 *                         type: boolean
 *                         description: New content notifications
 *                   readingGoals:
 *                     type: object
 *                     properties:
 *                       dailyTarget:
 *                         type: number
 *                         minimum: 5
 *                         maximum: 120
 *                         description: Daily reading target (minutes)
 *                       weeklyTarget:
 *                         type: number
 *                         minimum: 1
 *                         maximum: 7
 *                         description: Weekly reading target (days)
 *     responses:
 *       200:
 *         description: Profile updated successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: "Cập nhật thông tin thành công"
 *                 user:
 *                   type: object
 *                   properties:
 *                     id:
 *                       type: string
 *                       description: User ID
 *                     email:
 *                       type: string
 *                       description: User email
 *                     name:
 *                       type: string
 *                       description: User name
 *                     preferences:
 *                       type: object
 *                       description: User preferences
 *       400:
 *         description: Bad request - validation error
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 *       401:
 *         description: Unauthorized
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 *       404:
 *         description: User not found
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 *       500:
 *         description: Server error
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
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
    if (updateData.avatar) {
      user.avatar = updateData.avatar;
    }
    if (updateData.dateOfBirth) {
      user.dateOfBirth = new Date(updateData.dateOfBirth);
    }
    
    if (updateData.preferences && user.preferences) {
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
      user: {
        id: user._id,
        email: user.email,
        name: user.name,
        avatar: user.avatar,
        dateOfBirth: user.dateOfBirth,
        role: user.role,
        preferences: user.preferences,
      },
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

/**
 * @swagger
 * /user-auth/logout:
 *   post:
 *     summary: User logout
 *     description: Logout user (client-side token removal)
 *     tags: [User Authentication]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Logout successful
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: "Đăng xuất thành công"
 *       401:
 *         description: Unauthorized
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 *       500:
 *         description: Server error
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
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

/**
 * @swagger
 * /user-auth/reading-stats:
 *   post:
 *     summary: Update reading statistics
 *     description: Update user reading statistics for a specific reading
 *     tags: [User Authentication]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - readingId
 *               - timeSpent
 *             properties:
 *               readingId:
 *                 type: string
 *                 description: ID of the reading
 *                 example: "507f1f77bcf86cd799439011"
 *               timeSpent:
 *                 type: number
 *                 minimum: 0
 *                 description: Time spent reading in minutes
 *                 example: 15
 *     responses:
 *       200:
 *         description: Reading statistics updated successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: "Cập nhật thống kê thành công"
 *                 stats:
 *                   type: object
 *                   description: Updated user reading statistics
 *       400:
 *         description: Bad request - missing required fields
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 *       401:
 *         description: Unauthorized
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 *       404:
 *         description: User not found
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 *       500:
 *         description: Server error
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
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
