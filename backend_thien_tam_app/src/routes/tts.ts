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

/**
 * @swagger
 * /tts/text-to-speech:
 *   post:
 *     summary: Convert text to speech
 *     description: Converts Vietnamese text to speech using ElevenLabs API
 *     tags: [Text-to-Speech]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - text
 *             properties:
 *               text:
 *                 type: string
 *                 minLength: 1
 *                 maxLength: 5000
 *                 description: Text to convert to speech
 *                 example: "Chào mừng bạn đến với ứng dụng Thiền Tâm"
 *               voiceId:
 *                 type: string
 *                 description: Voice ID for TTS (optional, uses default Vietnamese voice)
 *                 example: "DXiwi9uoxet6zAiZXynP"
 *               modelId:
 *                 type: string
 *                 description: Model ID for TTS (optional, uses default model)
 *                 example: "eleven_multilingual_v2"
 *               voiceSettings:
 *                 type: object
 *                 properties:
 *                   stability:
 *                     type: number
 *                     minimum: 0
 *                     maximum: 1
 *                     description: Voice stability (0-1)
 *                   similarityBoost:
 *                     type: number
 *                     minimum: 0
 *                     maximum: 1
 *                     description: Voice similarity boost (0-1)
 *                   style:
 *                     type: number
 *                     minimum: 0
 *                     maximum: 1
 *                     description: Voice style (0-1)
 *                   useSpeakerBoost:
 *                     type: boolean
 *                     description: Whether to use speaker boost
 *     responses:
 *       200:
 *         description: Successfully generated audio
 *         content:
 *           audio/mpeg:
 *             schema:
 *               type: string
 *               format: binary
 *               description: MP3 audio file
 *       400:
 *         description: Invalid request data
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 *       500:
 *         description: Server error
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
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

/**
 * @swagger
 * /tts/voices:
 *   get:
 *     summary: Get available voices
 *     description: Returns list of available TTS voices from ElevenLabs
 *     tags: [Text-to-Speech]
 *     responses:
 *       200:
 *         description: Successfully retrieved voices
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 voices:
 *                   type: array
 *                   items:
 *                     type: object
 *                     properties:
 *                       voice_id:
 *                         type: string
 *                         description: Voice ID
 *                       name:
 *                         type: string
 *                         description: Voice name
 *                       category:
 *                         type: string
 *                         description: Voice category
 *                       description:
 *                         type: string
 *                         description: Voice description
 *                       labels:
 *                         type: object
 *                         description: Voice labels (gender, age, etc.)
 *       503:
 *         description: Service not configured
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 *       500:
 *         description: Server error
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
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

/**
 * @swagger
 * /tts/models:
 *   get:
 *     summary: Get available models
 *     description: Returns list of available TTS models from ElevenLabs
 *     tags: [Text-to-Speech]
 *     responses:
 *       200:
 *         description: Successfully retrieved models
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 models:
 *                   type: array
 *                   items:
 *                     type: object
 *                     properties:
 *                       model_id:
 *                         type: string
 *                         description: Model ID
 *                       name:
 *                         type: string
 *                         description: Model name
 *                       description:
 *                         type: string
 *                         description: Model description
 *                       can_be_finetuned:
 *                         type: boolean
 *                         description: Whether model can be fine-tuned
 *                       can_do_text_to_speech:
 *                         type: boolean
 *                         description: Whether model supports TTS
 *                       can_do_voice_conversion:
 *                         type: boolean
 *                         description: Whether model supports voice conversion
 *       503:
 *         description: Service not configured
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 *       500:
 *         description: Server error
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
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

/**
 * @swagger
 * /tts/status:
 *   get:
 *     summary: Check TTS service status
 *     description: Returns the current status of the TTS service
 *     tags: [Text-to-Speech]
 *     responses:
 *       200:
 *         description: Successfully retrieved TTS status
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 configured:
 *                   type: boolean
 *                   description: Whether TTS service is configured
 *                 message:
 *                   type: string
 *                   description: Status message
 *                   example: "Text-to-speech service is available"
 *       500:
 *         description: Server error
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
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
