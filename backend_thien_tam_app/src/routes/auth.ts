import { Router } from "express";
import jwt, { SignOptions } from "jsonwebtoken";
import bcrypt from "bcrypt";
import AdminUser from "../models/AdminUser";

const r = Router();

// Login endpoint
r.post("/login", async (req, res) => {
  try {
    const { email, password } = req.body;
    
    if (!email || !password) {
      return res.status(400).json({ message: "Email và mật khẩu là bắt buộc" });
    }
    
    const u = await AdminUser.findOne({ email, isActive: true });
    if (!u) {
      return res.status(401).json({ message: "Email hoặc mật khẩu không đúng" });
    }
    
    const ok = await bcrypt.compare(password, u.passwordHash);
    if (!ok) {
      return res.status(401).json({ message: "Email hoặc mật khẩu không đúng" });
    }
    
    const access = jwt.sign(
      { sub: (u._id as any).toString(), roles: u.roles },
      process.env.JWT_SECRET as string,
      { expiresIn: "1h" } as SignOptions
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
        roles: u.roles,
      }
    });
  } catch (error) {
    console.error("Login error:", error);
    res.status(500).json({ message: "Lỗi server" });
  }
});

// Refresh token endpoint
r.post("/refresh", async (req, res) => {
  try {
    const { refresh } = req.body;
    
    if (!refresh) {
      return res.status(400).json({ message: "Refresh token là bắt buộc" });
    }
    
    const p = jwt.verify(refresh, process.env.REFRESH_SECRET as string) as any;
    const u = await AdminUser.findById(p.sub);
    
    if (!u || !u.isActive) {
      return res.status(401).json({ message: "Token không hợp lệ" });
    }
    
    const access = jwt.sign(
      { sub: (u._id as any).toString(), roles: u.roles },
      process.env.JWT_SECRET as string,
      { expiresIn: "7 days" } as SignOptions
    );
    
    res.json({ access });
  } catch (error) {
    res.status(401).json({ message: "Token không hợp lệ hoặc hết hạn" });
  }
});

// Get current user info
r.get("/me", async (req, res) => {
  try {
    const h = req.headers.authorization || "";
    if (!h.startsWith("Bearer ")) {
      return res.status(401).json({ message: "Unauthorized" });
    }
    
    const token = h.slice(7);
    const payload = jwt.verify(token, process.env.JWT_SECRET as string) as any;
    const u = await AdminUser.findById(payload.sub).select("-passwordHash");
    
    if (!u || !u.isActive) {
      return res.status(401).json({ message: "User không tồn tại" });
    }
    
    res.json({ user: u });
  } catch (error) {
    res.status(401).json({ message: "Token không hợp lệ" });
  }
});

export default r;

