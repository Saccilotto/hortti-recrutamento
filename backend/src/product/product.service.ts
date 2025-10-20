import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Product } from './product.entity';

@Injectable()
export class ProductService {
  constructor(@InjectRepository(Product) private repo: Repository<Product>) {}

  create(data: Partial<Product>) {
    const p = this.repo.create(data);
    return this.repo.save(p);
  }

  findAll(page = 1, limit = 10, search?: string, category?: string) {
    const qb = this.repo.createQueryBuilder('p');
    if (search) qb.andWhere('p.name ILIKE :search', { search: `%${search}%` });
    if (category) qb.andWhere('p.category = :category', { category });
    return qb.skip((page - 1) * limit).take(limit).getMany();
  }

  findOne(id: number) {
    return this.repo.findOneBy({ id });
  }

  update(id: number, data: Partial<Product>) {
    return this.repo.update(id, data);
  }

  remove(id: number) {
    return this.repo.delete(id);
  }
}
