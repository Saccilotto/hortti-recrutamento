import {
  IsNotEmpty,
  IsString,
  IsEnum,
  IsNumber,
  IsOptional,
  Min,
  MaxLength,
  IsInt,
} from 'class-validator';
import { ProductCategory } from '../../entities/product.entity';
import { Type } from 'class-transformer';

export class CreateProductDto {
  @IsString({ message: 'Nome deve ser uma string' })
  @IsNotEmpty({ message: 'Nome é obrigatório' })
  @MaxLength(255, { message: 'Nome deve ter no máximo 255 caracteres' })
  name: string;

  @IsEnum(ProductCategory, {
    message: 'Categoria deve ser: fruta, verdura ou legume',
  })
  @IsNotEmpty({ message: 'Categoria é obrigatória' })
  category: ProductCategory;

  @IsNumber(
    { maxDecimalPlaces: 2 },
    { message: 'Preço deve ser um número com no máximo 2 casas decimais' },
  )
  @IsNotEmpty({ message: 'Preço é obrigatório' })
  @Min(0, { message: 'Preço não pode ser negativo' })
  @Type(() => Number)
  price: number;

  @IsOptional()
  @IsString({ message: 'URL da imagem deve ser uma string' })
  imageUrl?: string;

  @IsOptional()
  @IsString({ message: 'Descrição deve ser uma string' })
  @MaxLength(1000, { message: 'Descrição deve ter no máximo 1000 caracteres' })
  description?: string;

  @IsOptional()
  @IsInt({ message: 'Estoque deve ser um número inteiro' })
  @Min(0, { message: 'Estoque não pode ser negativo' })
  @Type(() => Number)
  stock?: number;
}
