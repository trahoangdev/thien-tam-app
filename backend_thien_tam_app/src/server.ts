import dotenv from "dotenv";
dotenv.config();
import app from "./app";
import { connectDB } from "./db";

const PORT = process.env.PORT || 4000;
const MONGO_URI = process.env.MONGO_URI!;

connectDB(MONGO_URI).then(() => {
  app.listen(PORT, () => {
    console.log(`🚀 API server running on http://localhost:${PORT}`);
    console.log(`\n📚 Public Endpoints:`);
    console.log(`   GET  /readings/today`);
    console.log(`   GET  /readings/:yyyy-:mm-:dd`);
    console.log(`   GET  /readings?query=...&topic=...&page=...`);
    console.log(`   GET  /readings/month/:yyyy-:mm`);
    console.log(`   GET  /readings/random`);
    console.log(`\n🔐 Auth Endpoints:`);
    console.log(`   POST /auth/login`);
    console.log(`   POST /auth/refresh`);
    console.log(`   GET  /auth/me`);
    console.log(`\n👑 Admin Endpoints (require token):`);
    console.log(`   GET    /admin/readings`);
    console.log(`   POST   /admin/readings`);
    console.log(`   PUT    /admin/readings/:id`);
    console.log(`   DELETE /admin/readings/:id`);
    console.log(`   GET    /admin/stats`);
    console.log(`\n📝 Admin credentials: admin@thientam.local / ThienTam@2025`);
  });
});

