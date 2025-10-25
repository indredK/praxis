import {
  IsString,
  IsNumber,
  IsObject,
  IsDateString,
  IsOptional,
  Min,
  IsNotEmpty,
} from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateProductDto {
  @ApiPropertyOptional({ example: 'iphone_15_pro_max' })
  @IsString()
  @IsOptional()
  id?: string;

  @ApiProperty({ example: 'iPhone 15 Pro Max' })
  @IsString()
  @IsNotEmpty()
  name: string;

  @ApiProperty({ example: 'Apple' })
  @IsString()
  @IsNotEmpty()
  company: string;

  @ApiProperty({ example: '手机' })
  @IsString()
  @IsNotEmpty()
  category: string;

  @ApiProperty({ example: 'https://via.placeholder.com/300x300' })
  @IsString()
  @IsNotEmpty()
  imageUrl: string;

  @ApiProperty({ example: 9999 })
  @IsNumber()
  @Min(0)
  price: number;

  @ApiProperty({ example: '2023-09-22T00:00:00.000Z' })
  @IsDateString()
  releaseDate: string;

  @ApiPropertyOptional({ example: 'iPhone 15 Pro Max，搭载3纳米A17 Pro芯片' })
  @IsString()
  @IsOptional()
  description?: string;

  // 核心筛选字段
  @ApiPropertyOptional({ example: '旗舰' })
  @IsString()
  @IsOptional()
  productLine?: string;

  @ApiPropertyOptional({ example: 'A17 Pro' })
  @IsString()
  @IsOptional()
  processor?: string;

  @ApiPropertyOptional({ example: '8GB' })
  @IsString()
  @IsOptional()
  ram?: string;

  @ApiPropertyOptional({ example: '256GB' })
  @IsString()
  @IsOptional()
  storage?: string;

  @ApiPropertyOptional({ example: '6.7英寸' })
  @IsString()
  @IsOptional()
  screenSize?: string;

  @ApiProperty({
    example: {
      colors: ['原色钛金属', '白色钛金属'],
      camera: '48MP主摄',
      battery: '4422mAh',
      features: ['防水', '无线', '快充'],
    },
  })
  @IsObject()
  specs: Record<string, any>;

  @ApiProperty({
    example: {
      屏幕尺寸: '6.7英寸',
      处理器: 'A17 Pro (3nm)',
      内存: '8GB',
    },
  })
  @IsObject()
  specifications: Record<string, string>;
}
