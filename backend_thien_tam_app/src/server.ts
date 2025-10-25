import dotenv from "dotenv";
dotenv.config();
import app from "./app";
import { connectDB } from "./db";

const PORT = parseInt(process.env.PORT || '4000');
const MONGO_URI = process.env.MONGO_URI!;

connectDB(MONGO_URI).then(() => {
  app.listen(PORT, '0.0.0.0', () => {
    console.log(`🚀 API server running on http://0.0.0.0:${PORT}`);
    console.log(`🌐 Accessible from network: http://192.168.1.228:${PORT}`);
    console.log(`\n📚 Public Endpoints:`);
    console.log(`   GET  /readings/today`);
    console.log(`   GET  /readings/:yyyy-:mm-:dd`);
    console.log(`   GET  /readings?query=...&topic=...&page=...`);
    console.log(`   GET  /readings/month/:yyyy-:mm`);
    console.log(`   GET  /readings/random`);
    console.log(`\n🎵 Text-to-Speech Endpoints:`);
    console.log(`   POST /tts/text-to-speech`);
    console.log(`   GET  /tts/voices`);
    console.log(`   GET  /tts/models`);
    console.log(`   GET  /tts/status`);
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
    console.log(`\n⚠️  ElevenLabs API Key: ${process.env.ELEVENLABS_API_KEY ? '✅ Configured' : '❌ Not configured'}`);
    const geminiKey = process.env.GOOGLE_GEMINI_API_KEY || process.env.GEMINI_API_KEY || process.env.GOOGLE_API_KEY;
    console.log(`⚠️  Gemini API Key: ${geminiKey ? '✅ Configured' : '❌ Not configured'}`);
    const cloudinaryConfigured = process.env.CLOUDINARY_CLOUD_NAME && process.env.CLOUDINARY_API_KEY && process.env.CLOUDINARY_API_SECRET;
    console.log(`⚠️  Cloudinary: ${cloudinaryConfigured ? '✅ Configured' : '❌ Not configured'}`);
  });
});

