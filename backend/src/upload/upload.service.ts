import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as fs from 'fs/promises';
import * as path from 'path';

@Injectable()
export class UploadService {
  constructor(private configService: ConfigService) {}

  async deleteFile(filename: string): Promise<void> {
    const uploadDir = this.configService.get<string>('UPLOAD_DEST', './uploads');
    const filePath = path.join(uploadDir, filename);

    try {
      await fs.unlink(filePath);
    } catch (error) {
      console.error('Erro ao deletar arquivo:', error);
    }
  }

  getFileUrl(filename: string): string {
    return `/uploads/${filename}`;
  }

  async ensureUploadDir(): Promise<void> {
    const uploadDir = this.configService.get<string>('UPLOAD_DEST', './uploads');

    try {
      await fs.access(uploadDir);
    } catch {
      await fs.mkdir(uploadDir, { recursive: true });
    }
  }
}
