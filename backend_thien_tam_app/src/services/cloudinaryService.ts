import cloudinary, { isCloudinaryConfigured } from '../config/cloudinary';
import { UploadApiResponse, UploadApiErrorResponse } from 'cloudinary';

interface UploadResult {
  publicId: string;
  url: string;
  secureUrl: string;
  format: string;
  duration?: number;
  bytes: number;
}

class CloudinaryService {
  /**
   * Check if Cloudinary is properly configured
   */
  isConfigured(): boolean {
    return isCloudinaryConfigured();
  }

  /**
   * Upload audio file to Cloudinary
   * @param filePath - Local file path or buffer
   * @param options - Upload options
   */
  async uploadAudio(
    filePath: string,
    options?: {
      folder?: string;
      publicId?: string;
      tags?: string[];
    }
  ): Promise<UploadResult> {
    if (!this.isConfigured()) {
      throw new Error('Cloudinary is not configured. Please set environment variables.');
    }

    try {
      const uploadOptions = {
        resource_type: 'video' as const, // Cloudinary uses 'video' for audio files
        folder: options?.folder || 'thientam/audio',
        public_id: options?.publicId,
        tags: options?.tags || ['buddhist-audio'],
        overwrite: false,
        unique_filename: true,
      };

      const result: UploadApiResponse = await cloudinary.uploader.upload(
        filePath,
        uploadOptions
      );

      return {
        publicId: result.public_id,
        url: result.url,
        secureUrl: result.secure_url,
        format: result.format,
        duration: result.duration,
        bytes: result.bytes,
      };
    } catch (error: any) {
      console.error('[CLOUDINARY] Upload failed:', error);
      throw new Error(`Failed to upload audio: ${error.message}`);
    }
  }

  /**
   * Delete audio file from Cloudinary
   * @param publicId - Cloudinary public ID
   */
  async deleteAudio(publicId: string): Promise<boolean> {
    if (!this.isConfigured()) {
      throw new Error('Cloudinary is not configured. Please set environment variables.');
    }

    try {
      const result = await cloudinary.uploader.destroy(publicId, {
        resource_type: 'video',
      });

      return result.result === 'ok';
    } catch (error: any) {
      console.error('[CLOUDINARY] Delete failed:', error);
      throw new Error(`Failed to delete audio: ${error.message}`);
    }
  }

  /**
   * Get audio file details from Cloudinary
   * @param publicId - Cloudinary public ID
   */
  async getAudioDetails(publicId: string): Promise<any> {
    if (!this.isConfigured()) {
      throw new Error('Cloudinary is not configured. Please set environment variables.');
    }

    try {
      const result = await cloudinary.api.resource(publicId, {
        resource_type: 'video',
      });

      return {
        publicId: result.public_id,
        url: result.url,
        secureUrl: result.secure_url,
        format: result.format,
        duration: result.duration,
        bytes: result.bytes,
        createdAt: result.created_at,
      };
    } catch (error: any) {
      console.error('[CLOUDINARY] Get details failed:', error);
      throw new Error(`Failed to get audio details: ${error.message}`);
    }
  }

  /**
   * List all audio files in a folder
   * @param folder - Folder path
   * @param maxResults - Maximum number of results
   */
  async listAudios(folder: string = 'thientam/audio', maxResults: number = 100): Promise<any[]> {
    if (!this.isConfigured()) {
      throw new Error('Cloudinary is not configured. Please set environment variables.');
    }

    try {
      const result = await cloudinary.api.resources({
        type: 'upload',
        resource_type: 'video',
        prefix: folder,
        max_results: maxResults,
      });

      return result.resources;
    } catch (error: any) {
      console.error('[CLOUDINARY] List audios failed:', error);
      throw new Error(`Failed to list audios: ${error.message}`);
    }
  }

  /**
   * Generate streaming URL for audio
   * @param publicId - Cloudinary public ID
   */
  getStreamingUrl(publicId: string): string {
    return cloudinary.url(publicId, {
      resource_type: 'video',
      secure: true,
      format: 'mp3',
    });
  }

  /**
   * Upload PDF file to Cloudinary
   * @param filePath - Local file path or buffer
   * @param options - Upload options
   */
  async uploadPDF(
    filePath: string,
    options?: {
      folder?: string;
      publicId?: string;
      tags?: string[];
    }
  ): Promise<UploadResult> {
    if (!this.isConfigured()) {
      throw new Error('Cloudinary is not configured. Please set environment variables.');
    }

    try {
      // IMPORTANT: Use 'image' resource_type for PDF to enable proper viewing
      // This allows Cloudinary to generate /image/upload/ URLs which work with PDF viewers
      // Raw resource_type creates /raw/upload/ URLs which cannot be viewed directly
      const uploadOptions = {
        resource_type: 'image' as const, // Use 'image' to allow PDF viewing/transformations
        folder: options?.folder || 'thientam/books',
        public_id: options?.publicId,
        tags: options?.tags || ['buddhist-book'],
        overwrite: false,
        unique_filename: true,
        // Note: Cloudinary will automatically detect and handle PDF files
      };

      const result: UploadApiResponse = await cloudinary.uploader.upload(
        filePath,
        uploadOptions
      );

      console.log('[CLOUDINARY] PDF upload result:');
      console.log('- Resource type: image (for PDF viewing)');
      console.log('- Public ID:', result.public_id);
      console.log('- URL:', result.url);
      console.log('- Secure URL:', result.secure_url);
      console.log('- Format:', result.format);
      console.log('- Bytes:', result.bytes);

      return {
        publicId: result.public_id,
        url: result.url,
        secureUrl: result.secure_url,
        format: result.format,
        bytes: result.bytes,
      };
    } catch (error: any) {
      console.error('[CLOUDINARY] PDF upload failed:', error);
      throw new Error(`Failed to upload PDF: ${error.message}`);
    }
  }

  /**
   * Upload cover image for book
   * @param filePath - Local file path or buffer
   * @param options - Upload options
   */
  async uploadCoverImage(
    filePath: string,
    options?: {
      folder?: string;
      publicId?: string;
      tags?: string[];
    }
  ): Promise<UploadResult> {
    if (!this.isConfigured()) {
      throw new Error('Cloudinary is not configured. Please set environment variables.');
    }

    try {
      const uploadOptions = {
        resource_type: 'image' as const,
        folder: options?.folder || 'thientam/book-covers',
        public_id: options?.publicId,
        tags: options?.tags || ['book-cover'],
        overwrite: false,
        unique_filename: true,
        transformation: [
          { width: 800, height: 1200, crop: 'limit' }, // Limit max size
          { quality: 'auto:good' }, // Auto quality
          { fetch_format: 'auto' }, // Auto format (WebP if supported)
        ],
      };

      const result: UploadApiResponse = await cloudinary.uploader.upload(
        filePath,
        uploadOptions
      );

      return {
        publicId: result.public_id,
        url: result.url,
        secureUrl: result.secure_url,
        format: result.format,
        bytes: result.bytes,
      };
    } catch (error: any) {
      console.error('[CLOUDINARY] Cover image upload failed:', error);
      throw new Error(`Failed to upload cover image: ${error.message}`);
    }
  }

  /**
   * Delete PDF file from Cloudinary
   * @param publicId - Cloudinary public ID
   */
  async deletePDF(publicId: string): Promise<boolean> {
    if (!this.isConfigured()) {
      throw new Error('Cloudinary is not configured. Please set environment variables.');
    }

    try {
      const result = await cloudinary.uploader.destroy(publicId, {
        resource_type: 'raw',
      });

      return result.result === 'ok';
    } catch (error: any) {
      console.error('[CLOUDINARY] PDF delete failed:', error);
      throw new Error(`Failed to delete PDF: ${error.message}`);
    }
  }

  /**
   * Delete cover image from Cloudinary
   * @param publicId - Cloudinary public ID
   */
  async deleteCoverImage(publicId: string): Promise<boolean> {
    if (!this.isConfigured()) {
      throw new Error('Cloudinary is not configured. Please set environment variables.');
    }

    try {
      const result = await cloudinary.uploader.destroy(publicId, {
        resource_type: 'image',
      });

      return result.result === 'ok';
    } catch (error: any) {
      console.error('[CLOUDINARY] Cover image delete failed:', error);
      throw new Error(`Failed to delete cover image: ${error.message}`);
    }
  }
}

export default new CloudinaryService();

