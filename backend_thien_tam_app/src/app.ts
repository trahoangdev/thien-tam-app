import express from "express";
import cors from "cors";
import helmet from "helmet";
import morgan from "morgan";
import compression from "compression";
import rateLimit from "express-rate-limit";
import readingsRouter from "./routes/readings";
import authRouter from "./routes/auth";
import userAuthRouter from "./routes/userAuth";
import adminRouter from "./routes/admin";
import topicsRouter from "./routes/topics";
import ttsRouter from "./routes/tts";
import { requireAuth, requireRoles } from "./middlewares/auth";
import { errorHandler } from "./middlewares/error";
import { setupSwagger } from "./config/swagger";

const app = express();

// Security & middleware
app.use(helmet());
app.use(cors({ origin: "*" }));
app.use(express.json({ limit: "1mb" }));
app.use(morgan("dev"));
app.use(compression());

// Rate limiting global
app.use(rateLimit({ 
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 300 // limit each IP to 300 requests per windowMs
}));

// Stricter rate limiting for auth endpoints
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 10, // limit each IP to 10 auth requests per window
  message: "Quá nhiều yêu cầu đăng nhập, vui lòng thử lại sau"
});

// Swagger documentation
setupSwagger(app);

// Public routes
app.use("/readings", readingsRouter);
app.use("/tts", ttsRouter); // Text-to-speech routes
app.get("/healthz", (_req, res) => res.json({ ok: true }));

// Auth routes (with stricter rate limit)
app.use("/auth", authLimiter, authRouter); // Admin auth
app.use("/user-auth", authLimiter, userAuthRouter); // User auth

// Protected admin routes (require authentication and ADMIN or EDITOR role)
app.use("/admin", requireAuth, requireRoles("ADMIN", "EDITOR"), adminRouter);
app.use("/admin", requireAuth, requireRoles("ADMIN", "EDITOR"), topicsRouter);

// Error handler
app.use(errorHandler);

export default app;

