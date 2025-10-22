import { Module, OnModuleInit } from '@nestjs/common';
import { MulterModule } from '@nestjs/platform-express';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { diskStorage } from 'multer';
import { extname, join } from 'path';
import * as fs from 'fs/promises';
import { UploadController } from './upload.controller';
import { UploadService } from './upload.service';

@Module({
  imports: [
    MulterModule.registerAsync({
      imports: [ConfigModule],
      useFactory: async (configService: ConfigService) => {
        const uploadPath = configService.get<string>('UPLOAD_DEST', './uploads');
        const absolutePath = uploadPath.startsWith('/') ? uploadPath : join(process.cwd(), uploadPath);

        // Ensure upload directory exists
        try {
          await fs.access(absolutePath);
        } catch {
          await fs.mkdir(absolutePath, { recursive: true });
        }

        return {
          storage: diskStorage({
            destination: (req, file, cb) => {
              cb(null, absolutePath);
            },
            filename: (req, file, cb) => {
              const randomName = Array(32)
                .fill(null)
                .map(() => Math.round(Math.random() * 16).toString(16))
                .join('');
              cb(null, `${randomName}${extname(file.originalname)}`);
            },
          }),
          fileFilter: (req, file, cb) => {
            const allowedTypes = /jpeg|jpg|png|webp/;
            const mimeType = allowedTypes.test(file.mimetype);
            const extName = allowedTypes.test(extname(file.originalname).toLowerCase());

            if (mimeType && extName) {
              return cb(null, true);
            }
            cb(new Error('Apenas imagens são permitidas (jpeg, jpg, png, webp)'), false);
          },
          limits: {
            fileSize: configService.get<number>('UPLOAD_MAX_FILE_SIZE', 5242880),
          },
        };
      },
      inject: [ConfigService],
    }),
  ],
  controllers: [UploadController],
  providers: [UploadService],
  exports: [UploadService, MulterModule],
})
export class UploadModule implements OnModuleInit {
  constructor(private uploadService: UploadService) {}

  async onModuleInit() {
    // Ensure upload directory exists on module initialization
    await this.uploadService.ensureUploadDir();
  }
}
