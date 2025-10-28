import { Request, Response, NextFunction } from "express";
import jwt from "jsonwebtoken";

// Extend Express Request type
declare global {
  namespace Express {
    interface Request {
      userId?: string;
      userRole?: string; // Single role: 'USER' or 'ADMIN'
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
    req.userRole = payload.role || 'USER';
    
    next();
  } catch (error) {
    return res.status(401).json({ message: "Token không hợp lệ hoặc hết hạn" });
  }
};

// Middleware yêu cầu quyền ADMIN
export const requireAdmin = (req: Request, res: Response, next: NextFunction) => {
  if (req.userRole !== 'ADMIN') {
    return res.status(403).json({ 
      message: "Chỉ admin mới có quyền truy cập",
      currentRole: req.userRole,
      required: 'ADMIN'
    });
  }
  
  next();
};

// Middleware kiểm tra role (legacy support)
export const requireRoles = (...allowed: string[]) => {
  return (req: Request, res: Response, next: NextFunction) => {
    const role = req.userRole || 'USER';
    
    if (!allowed.includes(role)) {
      return res.status(403).json({ 
        message: "Không có quyền truy cập",
        required: allowed,
        current: role
      });
    }
    
    next();
  };
};

