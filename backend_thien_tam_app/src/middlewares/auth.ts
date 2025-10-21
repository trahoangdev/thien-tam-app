import { Request, Response, NextFunction } from "express";
import jwt from "jsonwebtoken";

// Extend Express Request type
declare global {
  namespace Express {
    interface Request {
      userId?: string;
      roles?: string[];
    }
  }
}

// Middleware xác thực token
export const requireAuth = (req: Request, res: Response, next: NextFunction) => {
  const h = req.headers.authorization || "";
  
  if (!h.startsWith("Bearer ")) {
    return res.status(401).json({ message: "Thiếu token xác thực" });
  }
  
  try {
    const token = h.slice(7);
    const payload = jwt.verify(token, process.env.JWT_SECRET as string) as any;
    
    req.userId = payload.sub;
    req.roles = payload.roles || [];
    
    next();
  } catch (error) {
    return res.status(401).json({ message: "Token không hợp lệ hoặc hết hạn" });
  }
};

// Middleware phân quyền theo roles
export const requireRoles = (...allowed: string[]) => {
  return (req: Request, res: Response, next: NextFunction) => {
    const roles: string[] = req.roles || [];
    const ok = roles.some(r => allowed.includes(r));
    
    if (!ok) {
      return res.status(403).json({ 
        message: "Không có quyền truy cập",
        required: allowed,
        current: roles
      });
    }
    
    next();
  };
};

