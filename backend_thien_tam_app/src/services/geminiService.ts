import axios from 'axios';

export interface ChatMessage {
  role: 'user' | 'assistant' | 'system';
  content: string;
}

export interface ChatRequest {
  prompt: string;
  history?: ChatMessage[];
  systemInstruction?: string;
  temperature?: number;
  maxOutputTokens?: number;
}

export interface ChatResponse {
  text?: string;
  error?: string;
}

class GeminiService {
  private readonly apiKey: string;
  // Use v1 only (v1beta has model availability issues)
  private readonly baseUrls = [
    'https://generativelanguage.googleapis.com/v1',
  ];
  // Primary model preference list (will fallback automatically)
  // Updated to use Gemini 2.x models (available with this API key)
  private readonly modelCandidates = [
    'models/gemini-2.5-flash',
    'models/gemini-2.5-pro',
    'models/gemini-2.0-flash',
    'models/gemini-2.0-flash-001',
    'models/gemini-2.5-flash-lite',
  ];
  private cachedModel?: string;
  private cachedAt?: number;

  constructor() {
    // Accept multiple common env var names for convenience
    this.apiKey =
      process.env.GOOGLE_GEMINI_API_KEY ||
      process.env.GEMINI_API_KEY ||
      process.env.GOOGLE_API_KEY ||
      '';
    if (!this.apiKey) {
      console.warn('⚠️  GOOGLE_GEMINI_API_KEY not found in environment variables');
    }
  }

  isConfigured(): boolean {
    return !!this.apiKey;
  }

  private async resolveBestModel(): Promise<string | undefined> {
    const now = Date.now();
    if (this.cachedModel && this.cachedAt && now - this.cachedAt < 10 * 60 * 1000) {
      return this.cachedModel;
    }
    for (const base of this.baseUrls) {
      try {
        const url = `${base}/models?key=${this.apiKey}`;
        console.log('[GEMINI] Listing models via', url);
        const { data } = await axios.get(url, { timeout: 10000 });
        const models: any[] = data?.models || [];
        const supports = (m: any) => Array.isArray(m?.supportedGenerationMethods) && m.supportedGenerationMethods.includes('generateContent');
        const score = (name: string) => {
          const n = name.toLowerCase();
          if (n.includes('1.5') && n.includes('flash') && n.includes('latest')) return 100;
          if (n.includes('1.5') && n.includes('flash')) return 90;
          if (n.includes('1.5') && n.includes('pro') && n.includes('latest')) return 80;
          if (n.includes('1.5') && n.includes('pro')) return 70;
          if (n.includes('flash-8b')) return 60;
          if (n.includes('1.0') && n.includes('pro')) return 50;
          if (n.includes('pro')) return 40;
          return 10;
        };
        const eligible = models.filter(supports).sort((a, b) => score(b.name) - score(a.name));
        if (eligible.length > 0) {
          this.cachedModel = eligible[0].name;
          this.cachedAt = now;
          console.log('[GEMINI] Selected model', this.cachedModel);
          return this.cachedModel;
        }
      } catch (e: any) {
        console.warn('[GEMINI] List models failed', e?.response?.data?.error?.message || e.message);
        continue;
      }
    }
    this.cachedModel = this.modelCandidates[0];
    this.cachedAt = now;
    return this.cachedModel;
  }

  async chat(req: ChatRequest): Promise<ChatResponse> {
    if (!this.apiKey) {
      return { error: 'Gemini API key not configured' };
    }

    try {
      const safetySystem = req.systemInstruction ||
        'Bạn là Thiền Sư hiền hòa, giải thích giáo lý Phật pháp bằng tiếng Việt, ngắn gọn, từ bi và thực tế. Tránh các chủ đề nhạy cảm chính trị/tôn giáo cực đoan. Luôn khuyên người dùng thực hành chánh niệm, từ bi và trí tuệ.';

      // Convert simple history to Gemini content parts
      const historyParts = (req.history || []).map((m) => ({
        role: m.role === 'assistant' ? 'model' : 'user',
        parts: [{ text: m.content }],
      }));

      // Build request body
      // Note: v1 doesn't support systemInstruction, so we prepend it to contents
      const systemMessage = {
        role: 'user',
        parts: [{ text: safetySystem }],
      };
      const systemResponse = {
        role: 'model',
        parts: [{ text: 'Tôi hiểu. Tôi sẽ trả lời như một Thiền Sư hiền hòa, giải thích giáo lý Phật pháp bằng tiếng Việt, ngắn gọn, từ bi và thực tế.' }],
      };

      const body = {
        contents: [
          systemMessage,
          systemResponse,
          ...historyParts,
          { role: 'user', parts: [{ text: req.prompt }] },
        ],
        generationConfig: {
          temperature: req.temperature ?? 0.7,
          maxOutputTokens: req.maxOutputTokens ?? 512,
        },
      };

      let lastError: string | undefined;

      // Skip autodiscovery for now, use static fallback list directly
      // const discovered = await this.resolveBestModel();
      for (const base of this.baseUrls) {
        for (const model of this.modelCandidates) {
          try {
            const url = `${base}/${model}:generateContent?key=${this.apiKey}`;
            console.log('[GEMINI] Fallback trying', { base, model });
            const { data } = await axios.post(url, body, {
              headers: { 'Content-Type': 'application/json' },
              timeout: 20000,
            });

            const text = data?.candidates?.[0]?.content?.parts?.[0]?.text
              || data?.candidates?.[0]?.output_text
              || data?.candidates?.[0]?.content
              || data?.text
              || '';

            if (text && typeof text === 'string') {
              return { text };
            }
            lastError = 'Empty response';
          } catch (e: any) {
            lastError = e?.response?.data?.error?.message || e.message;
            console.warn('[GEMINI] Fallback failed', { base, model, error: lastError });
            // Try next option
            continue;
          }
        }
      }

      return { error: lastError || 'Gemini request failed' };
    } catch (err: any) {
      const msg = err?.response?.data?.error?.message || err.message || 'Gemini request failed';
      console.error('Gemini chat error:', msg);
      return { error: msg };
    }
  }
}

export default new GeminiService();


