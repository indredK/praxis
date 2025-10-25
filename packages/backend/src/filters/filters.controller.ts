import { Controller, Get, Post, Body } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse } from '@nestjs/swagger';
import { FiltersService } from './filters.service';
import { FilterConfigDto } from './dto/filter-config.dto';

@ApiTags('filters')
@Controller('filters')
export class FiltersController {
  constructor(private readonly filtersService: FiltersService) {}

  @Get('config')
  @ApiOperation({ summary: 'Get filter configuration' })
  @ApiResponse({ status: 200, description: 'Filter configuration retrieved' })
  async getFilterConfig() {
    return this.filtersService.getFilterConfig();
  }

  @Post('config')
  @ApiOperation({ summary: 'Create or update filter configuration' })
  @ApiResponse({ status: 201, description: 'Filter configuration saved' })
  async createOrUpdateFilterConfig(@Body() dto: FilterConfigDto) {
    return this.filtersService.createOrUpdateFilterConfig(dto);
  }
}

