import { IsObject, IsNotEmpty } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class FilterConfigDto {
  @ApiProperty({
    description: 'Filter tree configuration',
    example: {
      id: 'root',
      title: '产品筛选',
      children: [],
    },
  })
  @IsObject()
  @IsNotEmpty()
  filterTree: Record<string, any>;

  @ApiProperty({
    description: 'Comparison modes configuration',
    example: {
      same_brand: {
        title: '自家对比',
        enabledFilters: ['category_filter', 'product_line_filter'],
      },
    },
  })
  @IsObject()
  @IsNotEmpty()
  comparisonModes: Record<string, any>;
}

