import { Request, Response } from "express";
import { z } from "zod";
import Audio from "../models/Audio";
import cloudinaryService from "../services/cloudinaryService";
import fs from "fs";
import path from "path";
import os from "os";

// Validation schemas
const createAudioSchema = z.object({
  title: z.string().min(1).max(200),
  description: z.string().max(1000).optional(),
  artist: z.string().max(100).optional(),
  category: z.enum([
    "sutra",
    "mantra",
    "dharma-talk",
    "meditation",
    "chanting",
    "music",
    "other",
  ]),
  tags: z.array(z.string()).max(10).optional(),
  isPublic: z.boolean().optional(),
});

const createAudioFromUrlSchema = z.object({
  cloudinaryUrl: z.string().url(),
  title: z.string().min(1).max(200),
  description: z.string().max(1000).optional(),
  artist: z.string().max(100).optional(),
  category: z.enum([
    "sutra",
    "mantra",
    "dharma-talk",
    "meditation",
    "chanting",
    "music",
    "other",
  ]),
  tags: z.array(z.string()).max(10).optional(),
  duration: z.number().optional(),
  fileSize: z.number().optional(),
  format: z.string().optional(),
  isPublic: z.boolean().optional(),
});

const updateAudioSchema = z.object({
  title: z.string().min(1).max(200).optional(),
  description: z.string().max(1000).optional(),
  artist: z.string().max(100).optional(),
  category: z
    .enum([
      "sutra",
      "mantra",
      "dharma-talk",
      "meditation",
      "chanting",
      "music",
      "other",
    ])
    .optional(),
  tags: z.array(z.string()).max(10).optional(),
  isPublic: z.boolean().optional(),
});

/**
 * Upload audio file
 */
export const uploadAudio = async (
  req: Request & { file?: Express.Multer.File },
  res: Response
) => {
  try {
    // Check if file is uploaded
    if (!req.file) {
      return res.status(400).json({ message: "No audio file uploaded" });
    }

    // Parse form data (multipart/form-data sends everything as strings)
    const bodyData = {
      ...req.body,
      // Parse tags: can be string, array, or undefined
      tags: req.body.tags
        ? Array.isArray(req.body.tags)
          ? req.body.tags
          : req.body.tags
              .split(",")
              .map((t: string) => t.trim())
              .filter((t: string) => t)
        : undefined,
      // Parse isPublic: convert string to boolean
      isPublic:
        req.body.isPublic !== undefined
          ? req.body.isPublic === "true" || req.body.isPublic === true
          : undefined,
    };

    // Validate request body
    const validatedData = createAudioSchema.parse(bodyData);

    // Get admin ID from auth middleware
    const adminId = req.userId;
    if (!adminId) {
      return res.status(401).json({ message: "Unauthorized" });
    }

    // Save buffer to temporary file (Cloudinary needs file path)
    const tempFilePath = path.join(
      os.tmpdir(),
      `${Date.now()}-${req.file.originalname}`
    );
    fs.writeFileSync(tempFilePath, req.file.buffer);

    try {
      // Upload to Cloudinary
      const uploadResult = await cloudinaryService.uploadAudio(tempFilePath, {
        folder: "thientam/audio",
        tags: validatedData.tags || [],
      });

      // Create audio record in database
      const audio = new Audio({
        title: validatedData.title,
        description: validatedData.description,
        artist: validatedData.artist,
        category: validatedData.category,
        tags: validatedData.tags || [],
        cloudinaryPublicId: uploadResult.publicId,
        cloudinaryUrl: uploadResult.url,
        cloudinarySecureUrl: uploadResult.secureUrl,
        fileSize: uploadResult.bytes,
        format: uploadResult.format,
        duration: uploadResult.duration,
        uploadedBy: adminId,
        isPublic: validatedData.isPublic ?? true,
      });

      await audio.save();

      // Clean up temp file
      fs.unlinkSync(tempFilePath);

      res.status(201).json({
        message: "Audio uploaded successfully",
        audio,
      });
    } catch (error) {
      // Clean up temp file on error
      if (fs.existsSync(tempFilePath)) {
        fs.unlinkSync(tempFilePath);
      }
      throw error;
    }
  } catch (error: any) {
    console.error("[AUDIO] Upload error:", error);

    if (error instanceof z.ZodError) {
      return res.status(400).json({
        message: "Validation error",
        errors: error.errors,
      });
    }

    res.status(500).json({
      message: "Failed to upload audio",
      error: error.message,
    });
  }
};

/**
 * Create audio from Cloudinary URL (no file upload)
 */
export const createAudioFromUrl = async (req: Request, res: Response) => {
  try {
    // Validate request body
    const validatedData = createAudioFromUrlSchema.parse(req.body);

    // Extract public ID from Cloudinary URL
    // URL format: https://res.cloudinary.com/{cloud_name}/video/upload/v{version}/{public_id}.{format}
    const urlParts = validatedData.cloudinaryUrl.split("/");
    const fileNameWithExt = urlParts[urlParts.length - 1];
    const fileName = fileNameWithExt.split(".")[0];
    const versionIndex = urlParts.findIndex((part) => part.startsWith("v"));
    const publicId =
      versionIndex !== -1
        ? urlParts.slice(versionIndex + 1, -1).join("/") + "/" + fileName
        : fileName;

    // Create audio record
    const audio = new Audio({
      title: validatedData.title,
      description: validatedData.description,
      artist: validatedData.artist,
      category: validatedData.category,
      tags: validatedData.tags || [],
      cloudinaryPublicId: publicId,
      cloudinaryUrl: validatedData.cloudinaryUrl,
      cloudinarySecureUrl: validatedData.cloudinaryUrl.replace(
        "http://",
        "https://"
      ),
      fileSize: validatedData.fileSize || 0,
      format: validatedData.format || "mp3",
      duration: validatedData.duration || 0,
      uploadedBy: req.userId,
      isPublic: validatedData.isPublic ?? true,
    });

    await audio.save();

    res.status(201).json({
      message: "Audio created successfully from URL",
      audio,
    });
  } catch (error: any) {
    console.error("[AUDIO] Create from URL error:", error);

    if (error instanceof z.ZodError) {
      return res.status(400).json({
        message: "Validation error",
        errors: error.errors,
      });
    }

    res.status(500).json({
      message: "Failed to create audio from URL",
      error: error.message,
    });
  }
};

/**
 * Get all audios with filters
 */
export const getAllAudios = async (req: Request, res: Response) => {
  try {
    const {
      category,
      tags,
      search,
      isPublic,
      page = 1,
      limit = 20,
      sortBy = "createdAt",
      sortOrder = "desc",
    } = req.query;

    // Build filter
    const filter: any = {};

    if (category) {
      filter.category = category;
    }

    if (tags) {
      const tagArray = typeof tags === "string" ? tags.split(",") : tags;
      filter.tags = { $in: tagArray };
    }

    if (isPublic !== undefined) {
      filter.isPublic = isPublic === "true";
    }

    if (search) {
      filter.$text = { $search: search as string };
    }

    // Calculate pagination
    const skip = (Number(page) - 1) * Number(limit);

    // Build sort
    const sort: any = {};
    sort[sortBy as string] = sortOrder === "asc" ? 1 : -1;

    // Execute query
    const audios = await Audio.find(filter)
      .sort(sort)
      .skip(skip)
      .limit(Number(limit))
      .populate("uploadedBy", "email name")
      .exec();

    const total = await Audio.countDocuments(filter);

    res.json({
      audios,
      pagination: {
        page: Number(page),
        limit: Number(limit),
        total,
        pages: Math.ceil(total / Number(limit)),
      },
    });
  } catch (error: any) {
    console.error("[AUDIO] Get all error:", error);
    res.status(500).json({
      message: "Failed to fetch audios",
      error: error.message,
    });
  }
};

/**
 * Get audio by ID
 */
export const getAudioById = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;

    const audio = await Audio.findById(id).populate("uploadedBy", "email name");

    if (!audio) {
      return res.status(404).json({ message: "Audio not found" });
    }

    res.json({ audio });
  } catch (error: any) {
    console.error("[AUDIO] Get by ID error:", error);
    res.status(500).json({
      message: "Failed to fetch audio",
      error: error.message,
    });
  }
};

/**
 * Update audio metadata
 */
export const updateAudio = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;

    // Validate request body
    const validatedData = updateAudioSchema.parse(req.body);

    const audio = await Audio.findByIdAndUpdate(
      id,
      { $set: validatedData },
      { new: true, runValidators: true }
    );

    if (!audio) {
      return res.status(404).json({ message: "Audio not found" });
    }

    res.json({
      message: "Audio updated successfully",
      audio,
    });
  } catch (error: any) {
    console.error("[AUDIO] Update error:", error);

    if (error instanceof z.ZodError) {
      return res.status(400).json({
        message: "Validation error",
        errors: error.errors,
      });
    }

    res.status(500).json({
      message: "Failed to update audio",
      error: error.message,
    });
  }
};

/**
 * Delete audio
 */
export const deleteAudio = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;

    const audio = await Audio.findById(id);

    if (!audio) {
      return res.status(404).json({ message: "Audio not found" });
    }

    // Delete from Cloudinary
    await cloudinaryService.deleteAudio(audio.cloudinaryPublicId);

    // Delete from database
    await audio.deleteOne();

    res.json({ message: "Audio deleted successfully" });
  } catch (error: any) {
    console.error("[AUDIO] Delete error:", error);
    res.status(500).json({
      message: "Failed to delete audio",
      error: error.message,
    });
  }
};

/**
 * Increment play count
 */
export const incrementPlayCount = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;

    const audio = await Audio.findById(id);

    if (!audio) {
      return res.status(404).json({ message: "Audio not found" });
    }

    await (audio as any).incrementPlayCount();

    res.json({
      message: "Play count incremented",
      playCount: audio.playCount,
    });
  } catch (error: any) {
    console.error("[AUDIO] Increment play count error:", error);
    res.status(500).json({
      message: "Failed to increment play count",
      error: error.message,
    });
  }
};

/**
 * Get audio categories
 */
export const getCategories = async (req: Request, res: Response) => {
  try {
    const categories = [
      {
        value: "sutra",
        label: "Kinh Phật",
        description: "Buddhist sutras and scriptures",
      },
      {
        value: "mantra",
        label: "Chú Phật",
        description: "Buddhist mantras and dharani",
      },
      {
        value: "dharma-talk",
        label: "Pháp Thoại",
        description: "Dharma talks and teachings",
      },
      {
        value: "meditation",
        label: "Thiền Định",
        description: "Meditation guidance",
      },
      {
        value: "chanting",
        label: "Tụng Niệm",
        description: "Buddhist chanting",
      },
      { value: "music", label: "Nhạc Phật", description: "Buddhist music" },
      { value: "other", label: "Khác", description: "Other audio content" },
    ];

    res.json({ categories });
  } catch (error: any) {
    console.error("[AUDIO] Get categories error:", error);
    res.status(500).json({
      message: "Failed to fetch categories",
      error: error.message,
    });
  }
};

/**
 * Get popular audios (by play count)
 */
export const getPopularAudios = async (req: Request, res: Response) => {
  try {
    const { limit = 10 } = req.query;

    const audios = await Audio.find({ isPublic: true })
      .sort({ playCount: -1 })
      .limit(Number(limit))
      .populate("uploadedBy", "email name");

    res.json({ audios });
  } catch (error: any) {
    console.error("[AUDIO] Get popular error:", error);
    res.status(500).json({
      message: "Failed to fetch popular audios",
      error: error.message,
    });
  }
};
