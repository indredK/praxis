import {
  IsOptional,
  IsString,
  IsNumber,
  IsObject,
  IsDateString,
  Min,
} from 'class-validator';
import { ApiPropertyOptional } from '@nestjs/swagger';

export class UpdateProductDto {
  @ApiPropertyOptional({ example: 'iPhone 15 Pro Max' })
  @IsOptional()
  @IsString()
  name?: string;

  @ApiPropertyOptional({ example: 'Apple' })
  @IsOptional()
  @IsString()
  company?: string;

  @ApiPropertyOptional({ example: '手机' })
  @IsOptional()
  @IsString()
  category?: string;

  @ApiPropertyOptional({ example: 'https://via.placeholder.com/300x300' })
  @IsOptional()
  @IsString()
  imageUrl?: string;

  @ApiPropertyOptional({ example: 9999 })
  @IsOptional()
  @IsNumber()
  @Min(0)
  price?: number;

  @ApiPropertyOptional({ example: '2023-09-22T00:00:00.000Z' })
  @IsOptional()
  @IsDateString()
  releaseDate?: string;

  @ApiPropertyOptional({ example: 'iPhone 15 Pro Max，搭载3纳米A17 Pro芯片' })
  @IsOptional()
  @IsString()
  description?: string;

  // 核心筛选字段
  @ApiPropertyOptional({ example: '旗舰' })
  @IsOptional()
  @IsString()
  productLine?: string;

  @ApiPropertyOptional({ example: 'A17 Pro' })
  @IsOptional()
  @IsString()
  processor?: string;

  @ApiPropertyOptional({ example: '8GB' })
  @IsOptional()
  @IsString()
  ram?: string;

  @ApiPropertyOptional({ example: '256GB' })
  @IsOptional()
  @IsString()
  storage?: string;

  @ApiPropertyOptional({ example: '6.7英寸' })
  @IsOptional()
  @IsString()
  screenSize?: string;

  @ApiPropertyOptional({
    example: {
      colors: ['原色钛金属', '白色钛金属'],
      camera: '48MP主摄',
      battery: '4422mAh',
      features: ['防水', '无线', '快充'],
    },
  })
  @IsOptional()
  @IsObject()
  specs?: Record<string, any>;

  @ApiPropertyOptional({
    example: {
      屏幕尺寸: '6.7英寸',
      处理器: 'A17 Pro (3nm)',
      内存: '8GB',
    },
  })
  @IsOptional()
  @IsObject()
  specifications?: Record<string, string>;

  @ApiPropertyOptional({ example: 50, minimum: 0 })
  @IsOptional()
  @IsNumber()
  @Min(0)
  stock?: number;
}

