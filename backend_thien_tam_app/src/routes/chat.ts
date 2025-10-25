import { Router } from 'express';
import { z } from 'zod';
import geminiService from '../services/geminiService';

const r = Router();

const chatSchema = z.object({
  prompt: z.string().min(1, 'prompt_required'),
  history: z
    .array(
      z.object({
        role: z.enum(['user', 'assistant', 'system']).default('user'),
        content: z.string().min(1),
      })
    )
    .optional(),
  systemInstruction: z.string().optional(),
  temperature: z.number().min(0).max(1).optional(),
  maxOutputTokens: z.number().min(1).max(2048).optional(),
});

/**
 * @openapi
 * /chat/ask:
 *   post:
 *     summary: Chat với Thiền Sư (Gemini)
 *     description: Trả lời bằng tiếng Việt, phong cách từ bi và chánh niệm.
 *     tags:
 *       - Chat
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               prompt:
 *                 type: string
 *                 example: Con đang bị căng thẳng, con nên làm gì để an tĩnh?
 *               history:
 *                 type: array
 *                 items:
 *                   type: object
 *                   properties:
 *                     role:
 *                       type: string
 *                       enum: [user, assistant, system]
 *                     content:
 *                       type: string
 *               temperature:
 *                 type: number
 *                 example: 0.5
 *               maxOutputTokens:
 *                 type: number
 *                 example: 512
 *     responses:
 *       200:
 *         description: Kết quả chat
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 text:
 *                   type: string
 *       400:
 *         description: Yêu cầu không hợp lệ
 *       500:
 *         description: Lỗi server
 */
r.post('/ask', async (req, res) => {
  try {
    const parse = chatSchema.safeParse(req.body);
    if (!parse.success) {
      console.warn('[CHAT] Invalid request', {
        issues: parse.error.flatten(),
      });
      return res.status(400).json({ message: 'invalid_request', issues: parse.error.flatten() });
    }
    const payload = parse.data;
    console.log('[CHAT] Incoming request', {
      promptPreview: payload.prompt.slice(0, 80),
      historyCount: payload.history?.length || 0,
      temperature: payload.temperature,
      maxOutputTokens: payload.maxOutputTokens,
    });
    const result = await geminiService.chat(payload);
    if (result.error) {
      console.error('[CHAT] Chat failed', { error: result.error });
      return res.status(500).json({ message: 'chat_failed', error: result.error });
    }
    res.json({ text: result.text || '' });
  } catch (error: any) {
    console.error('[CHAT] Route error', error?.message || error);
    res.status(500).json({ message: 'server_error', error: process.env.NODE_ENV === 'development' ? error?.message : undefined });
  }
});

/**
 * @openapi
 * /chat/status:
 *   get:
 *     summary: Kiểm tra cấu hình Gemini
 *     tags:
 *       - Chat
 *     responses:
 *       200:
 *         description: Trạng thái
 */
r.get('/status', (_req, res) => {
  res.json({ configured: geminiService.isConfigured() });
});

export default r;


