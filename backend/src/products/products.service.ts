import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Like, ILike } from 'typeorm';
import { Product } from '../entities/product.entity';
import {
  CreateProductDto,
  UpdateProductDto,
  QueryProductDto,
} from '../dto';
import { UploadService } from '../upload/upload.service';

@Injectable()
export class ProductsService {
  constructor(
    @InjectRepository(Product)
    private readonly productRepository: Repository<Product>,
    private readonly uploadService: UploadService,
  ) {}

  async create(createProductDto: CreateProductDto): Promise<Product> {
    const product = this.productRepository.create(createProductDto);
    return this.productRepository.save(product);
  }

  async findAll(query: QueryProductDto) {
    const {
      search,
      category,
      sortBy = 'createdAt',
      order = 'DESC',
      page = 1,
      limit = 10,
    } = query;

    const queryBuilder = this.productRepository.createQueryBuilder('product');

    queryBuilder.where('product.isActive = :isActive', { isActive: true });

    if (search) {
      queryBuilder.andWhere('product.name ILIKE :search', {
        search: `%${search}%`,
      });
    }

    if (category) {
      queryBuilder.andWhere('product.category = :category', { category });
    }

    queryBuilder.orderBy(`product.${sortBy}`, order as 'ASC' | 'DESC');

    const skip = (page - 1) * limit;
    queryBuilder.skip(skip).take(limit);

    const [products, total] = await queryBuilder.getManyAndCount();

    return {
      data: products,
      meta: {
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  async findOne(id: number): Promise<Product> {
    const product = await this.productRepository.findOne({ where: { id } });

    if (!product) {
      throw new NotFoundException(`Produto #${id} não encontrado`);
    }

    return product;
  }

  async update(id: number, updateProductDto: UpdateProductDto): Promise<Product> {
    const product = await this.findOne(id);

    if (updateProductDto.imageUrl && product.imageUrl) {
      const oldFilename = product.imageUrl.split('/').pop();
      if (oldFilename) {
        await this.uploadService.deleteFile(oldFilename);
      }
    }

    Object.assign(product, updateProductDto);
    return this.productRepository.save(product);
  }

  async remove(id: number): Promise<void> {
    const product = await this.findOne(id);

    if (product.imageUrl) {
      const filename = product.imageUrl.split('/').pop();
      if (filename) {
        await this.uploadService.deleteFile(filename);
      }
    }

    await this.productRepository.remove(product);
  }

  async softRemove(id: number): Promise<Product> {
    const product = await this.findOne(id);
    product.isActive = false;
    return this.productRepository.save(product);
  }

  async updateImage(id: number, imageUrl: string): Promise<Product> {
    const product = await this.findOne(id);

    if (product.imageUrl) {
      const oldFilename = product.imageUrl.split('/').pop();
      if (oldFilename) {
        await this.uploadService.deleteFile(oldFilename);
      }
    }

    product.imageUrl = imageUrl;
    return this.productRepository.save(product);
  }
}
