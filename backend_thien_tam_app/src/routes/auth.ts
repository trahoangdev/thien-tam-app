import { Router } from "express";
import jwt, { SignOptions } from "jsonwebtoken";
import bcrypt from "bcrypt";
import User, { UserRole } from "../models/User";

const r = Router();

/**
 * @swagger
 * /auth/login:
 *   post:
 *     summary: Admin login
 *     description: Authenticate admin user and return JWT tokens
 *     tags: [Authentication]
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
 *                 description: Admin email address
 *                 example: "admin@thientam.local"
 *               password:
 *                 type: string
 *                 format: password
 *                 description: Admin password
 *                 example: "ThienTam@2025"
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
 *                 accessToken:
 *                   type: string
 *                   description: JWT access token
 *                 refreshToken:
 *                   type: string
 *                   description: JWT refresh token
 *                 user:
 *                   type: object
 *                   properties:
 *                     id:
 *                       type: string
 *                       description: User ID
 *                     email:
 *                       type: string
 *                       description: User email
 *                     roles:
 *                       type: array
 *                       items:
 *                         type: string
 *                       description: User roles
 *       400:
 *         description: Bad request - missing credentials
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
r.post("/login", async (req, res) => {
  try {
    const { email, password } = req.body;
    
    if (!email || !password) {
      return res.status(400).json({ message: "Email và mật khẩu là bắt buộc" });
    }
    
    // Find user with ADMIN role only
    const u = await User.findOne({ 
      email, 
      role: UserRole.ADMIN,
      isActive: true 
    });
    
    if (!u) {
      return res.status(401).json({ message: "Email hoặc mật khẩu không đúng" });
    }
    
    const ok = await bcrypt.compare(password, u.passwordHash);
    if (!ok) {
      return res.status(401).json({ message: "Email hoặc mật khẩu không đúng" });
    }
    
    // Update last login
    await u.updateLastLogin();
    
    const access = jwt.sign(
      { sub: (u._id as any).toString(), role: u.role },
      process.env.JWT_SECRET as string,
      { expiresIn: "7d" } as SignOptions
    );
    
    const refresh = jwt.sign(
      { sub: (u._id as any).toString() },
      process.env.REFRESH_SECRET as string,
      { expiresIn: "30d" } as SignOptions
    );
    
    res.json({
      access,
      refresh,
      user: {
        id: u._id,
        email: u.email,
        name: u.name,
        role: u.role,
      }
    });
  } catch (error) {
    console.error("Login error:", error);
    res.status(500).json({ message: "Lỗi server" });
  }
});

/**
 * @swagger
 * /auth/refresh:
 *   post:
 *     summary: Refresh admin token
 *     description: Refresh admin access token using refresh token
 *     tags: [Authentication]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - refresh
 *             properties:
 *               refresh:
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
 *                 access:
 *                   type: string
 *                   description: New JWT access token
 *                 user:
 *                   type: object
 *                   properties:
 *                     id:
 *                       type: string
 *                       description: User ID
 *                     email:
 *                       type: string
 *                       description: User email
 *                     roles:
 *                       type: array
 *                       items:
 *                         type: string
 *                       description: User roles
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
r.post("/refresh", async (req, res) => {
  try {
    const { refresh } = req.body;
    
    if (!refresh) {
      return res.status(400).json({ message: "Refresh token là bắt buộc" });
    }
    
    const p = jwt.verify(refresh, process.env.REFRESH_SECRET as string) as any;
    const u = await User.findById(p.sub);
    
    if (!u || !u.isActive || u.role !== UserRole.ADMIN) {
      return res.status(401).json({ message: "Token không hợp lệ" });
    }
    
    const access = jwt.sign(
      { sub: (u._id as any).toString(), role: u.role },
      process.env.JWT_SECRET as string,
      { expiresIn: "7d" } as SignOptions
    );
    
    res.json({ access });
  } catch (error) {
    res.status(401).json({ message: "Token không hợp lệ hoặc hết hạn" });
  }
});

/**
 * @swagger
 * /auth/me:
 *   get:
 *     summary: Get current admin user info
 *     description: Returns information about the currently authenticated admin user
 *     tags: [Authentication]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Successfully retrieved user info
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 user:
 *                   type: object
 *                   properties:
 *                     _id:
 *                       type: string
 *                       description: User ID
 *                     email:
 *                       type: string
 *                       description: User email
 *                     roles:
 *                       type: array
 *                       items:
 *                         type: string
 *                       description: User roles
 *                     isActive:
 *                       type: boolean
 *                       description: Whether user is active
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
 *       500:
 *         description: Server error
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
r.get("/me", async (req, res) => {
  try {
    const h = req.headers.authorization || "";
    if (!h.startsWith("Bearer ")) {
      return res.status(401).json({ message: "Unauthorized" });
    }
    
    const token = h.slice(7);
    const payload = jwt.verify(token, process.env.JWT_SECRET as string) as any;
    const u = await User.findById(payload.sub).select("-passwordHash");
    
    if (!u || !u.isActive || u.role !== UserRole.ADMIN) {
      return res.status(401).json({ message: "User không tồn tại hoặc không có quyền admin" });
    }
    
    res.json({ user: u });
  } catch (error) {
    res.status(401).json({ message: "Token không hợp lệ" });
  }
});

export default r;

