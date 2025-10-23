import { Router } from 'express';
import { z } from 'zod';
import elevenLabsService from '../services/elevenlabsService';

const r = Router();

// Validation schema for TTS request
const ttsRequestSchema = z.object({
  text: z.string().min(1).max(5000, 'Text too long (max 5000 characters)'),
  voiceId: z.string().optional(),
  modelId: z.string().optional(),
  voiceSettings: z.object({
    stability: z.number().min(0).max(1).optional(),
    similarityBoost: z.number().min(0).max(1).optional(),
    style: z.number().min(0).max(1).optional(),
    useSpeakerBoost: z.boolean().optional(),
  }).optional(),
});

// POST /tts/text-to-speech - Convert text to speech
r.post('/text-to-speech', async (req, res) => {
  try {
    // Validate request
    const validationResult = ttsRequestSchema.safeParse(req.body);
    if (!validationResult.success) {
      return res.status(400).json({
        message: 'Invalid request data',
        errors: validationResult.error.errors,
      });
    }

    const { text, voiceId, modelId, voiceSettings } = validationResult.data;

    // Check if ElevenLabs is configured
    if (!elevenLabsService.isConfigured()) {
      return res.status(503).json({
        message: 'Text-to-speech service is not configured',
      });
    }

    // Generate speech
    const result = await elevenLabsService.textToSpeech({
      text,
      voiceId,
      modelId,
      voiceSettings,
    });

    if (result.error) {
      return res.status(500).json({
        message: 'Failed to generate speech',
        error: result.error,
      });
    }

    // Set appropriate headers for audio response
    res.set({
      'Content-Type': 'audio/mpeg',
      'Content-Length': result.audioData!.length.toString(),
      'Cache-Control': 'public, max-age=3600', // Cache for 1 hour
    });

    // Send audio data
    res.send(result.audioData);
  } catch (error: any) {
    console.error('TTS endpoint error:', error);
    res.status(500).json({
      message: 'Internal server error',
      error: error.message,
    });
  }
});

// GET /tts/voices - Get available voices
r.get('/voices', async (req, res) => {
  try {
    if (!elevenLabsService.isConfigured()) {
      return res.status(503).json({
        message: 'Text-to-speech service is not configured',
        voices: [],
      });
    }

    const voices = await elevenLabsService.getVoices();
    res.json({ voices });
  } catch (error: any) {
    console.error('Get voices error:', error);
    res.status(500).json({
      message: 'Failed to fetch voices',
      error: error.message,
    });
  }
});

// GET /tts/models - Get available models
r.get('/models', async (req, res) => {
  try {
    if (!elevenLabsService.isConfigured()) {
      return res.status(503).json({
        message: 'Text-to-speech service is not configured',
        models: [],
      });
    }

    const models = await elevenLabsService.getModels();
    res.json({ models });
  } catch (error: any) {
    console.error('Get models error:', error);
    res.status(500).json({
      message: 'Failed to fetch models',
      error: error.message,
    });
  }
});

// GET /tts/status - Check TTS service status
r.get('/status', async (req, res) => {
  try {
    const isConfigured = elevenLabsService.isConfigured();
    res.json({
      configured: isConfigured,
      message: isConfigured 
        ? 'Text-to-speech service is available' 
        : 'Text-to-speech service is not configured',
    });
  } catch (error: any) {
    console.error('TTS status error:', error);
    res.status(500).json({
      message: 'Failed to check TTS status',
      error: error.message,
    });
  }
});

export default r;
