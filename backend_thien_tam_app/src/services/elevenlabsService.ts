import axios from 'axios';
import FormData from 'form-data';

export interface TTSRequest {
  text: string;
  voiceId?: string;
  modelId?: string;
  voiceSettings?: {
    stability?: number;
    similarityBoost?: number;
    style?: number;
    useSpeakerBoost?: boolean;
  };
}

export interface TTSResponse {
  audioUrl?: string;
  audioData?: Buffer;
  error?: string;
}

class ElevenLabsService {
  private apiKey: string;
  private baseUrl = 'https://api.elevenlabs.io/v1';

  constructor() {
    this.apiKey = process.env.ELEVENLABS_API_KEY || '';
    if (!this.apiKey) {
      console.warn('⚠️  ELEVENLABS_API_KEY not found in environment variables');
    }
  }

  async textToSpeech(request: TTSRequest): Promise<TTSResponse> {
    if (!this.apiKey) {
      return { error: 'ElevenLabs API key not configured' };
    }

    try {
      const voiceId = request.voiceId || 'DXiwi9uoxet6zAiZXynP'; // Default Vietnamese voice
      const modelId = request.modelId || 'eleven_flash_v2_5'; // Fastest model with Vietnamese support
      
      const voiceSettings = {
        stability: request.voiceSettings?.stability || 0.5,
        similarityBoost: request.voiceSettings?.similarityBoost || 0.5,
        style: request.voiceSettings?.style || 0.0,
        useSpeakerBoost: request.voiceSettings?.useSpeakerBoost || true,
      };

      const response = await axios.post(
        `${this.baseUrl}/text-to-speech/${voiceId}`,
        {
          text: request.text,
          model_id: modelId,
          voice_settings: voiceSettings,
        },
        {
          headers: {
            'Accept': 'audio/mpeg',
            'Content-Type': 'application/json',
            'xi-api-key': this.apiKey,
          },
          responseType: 'arraybuffer',
        }
      );

      // Convert arraybuffer to buffer
      const audioBuffer = Buffer.from(response.data);
      
      return {
        audioData: audioBuffer,
      };
    } catch (error: any) {
      console.error('ElevenLabs TTS Error:', error.response?.data || error.message);
      return {
        error: error.response?.data?.detail?.message || 'Failed to generate speech',
      };
    }
  }

  async getVoices(): Promise<any[]> {
    if (!this.apiKey) {
      return [];
    }

    try {
      const response = await axios.get(`${this.baseUrl}/voices`, {
        headers: {
          'xi-api-key': this.apiKey,
        },
      });

      return response.data.voices || [];
    } catch (error: any) {
      console.error('ElevenLabs Get Voices Error:', error.response?.data || error.message);
      return [];
    }
  }

  async getModels(): Promise<any[]> {
    if (!this.apiKey) {
      return [];
    }

    try {
      const response = await axios.get(`${this.baseUrl}/models`, {
        headers: {
          'xi-api-key': this.apiKey,
        },
      });

      return response.data || [];
    } catch (error: any) {
      console.error('ElevenLabs Get Models Error:', error.response?.data || error.message);
      return [];
    }
  }

  // Check if service is properly configured
  isConfigured(): boolean {
    return !!this.apiKey;
  }
}

export default new ElevenLabsService();
