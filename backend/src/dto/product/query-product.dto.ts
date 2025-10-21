import { IsOptional, IsString, IsEnum, IsIn } from 'class-validator';
import { ProductCategory } from '../../entities/product.entity';
import { Type } from 'class-transformer';

export class QueryProductDto {
  @IsOptional()
  @IsString({ message: 'Busca deve ser uma string' })
  search?: string;

  @IsOptional()
  @IsEnum(ProductCategory, {
    message: 'Categoria deve ser: fruta, verdura ou legume',
  })
  category?: ProductCategory;

  @IsOptional()
  @IsIn(['name', 'price', 'createdAt'], {
    message: 'sortBy deve ser: name, price ou createdAt',
  })
  sortBy?: 'name' | 'price' | 'createdAt';

  @IsOptional()
  @IsIn(['ASC', 'DESC', 'asc', 'desc'], {
    message: 'order deve ser: ASC ou DESC',
  })
  order?: 'ASC' | 'DESC';

  @IsOptional()
  @Type(() => Number)
  page?: number;

  @IsOptional()
  @Type(() => Number)
  limit?: number;
}
