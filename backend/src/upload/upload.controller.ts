import {
  Controller,
  Post,
  UseInterceptors,
  UploadedFile,
  UseGuards,
  BadRequestException,
  Delete,
  Param,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { UploadService } from './upload.service';

@Controller('upload')
@UseGuards(JwtAuthGuard)
export class UploadController {
  constructor(private readonly uploadService: UploadService) {}

  @Post('image')
  @UseInterceptors(FileInterceptor('file'))
  async uploadImage(@UploadedFile() file: Express.Multer.File) {
    if (!file) {
      throw new BadRequestException('Nenhum arquivo foi enviado');
    }

    const imageUrl = this.uploadService.getFileUrl(file.filename);

    return {
      message: 'Imagem enviada com sucesso',
      filename: file.filename,
      imageUrl,
    };
  }

  @Delete(':filename')
  async deleteImage(@Param('filename') filename: string) {
    await this.uploadService.deleteFile(filename);

    return {
      message: 'Imagem deletada com sucesso',
    };
  }
}
