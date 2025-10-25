import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { FilterConfigDto } from './dto/filter-config.dto';

@Injectable()
export class FiltersService {
  constructor(private prisma: PrismaService) {}

  async getFilterConfig() {
    const configs = await this.prisma.filterConfig.findMany({
      orderBy: { createdAt: 'desc' },
      take: 1,
    });
    return configs[0] || null;
  }

  async createOrUpdateFilterConfig(dto: FilterConfigDto) {
    const existing = await this.prisma.filterConfig.findFirst();
    
    if (existing) {
      return this.prisma.filterConfig.update({
        where: { id: existing.id },
        data: {
          filterTree: dto.filterTree,
          comparisonModes: dto.comparisonModes,
        },
      });
    }

    return this.prisma.filterConfig.create({
      data: {
        filterTree: dto.filterTree,
        comparisonModes: dto.comparisonModes,
      },
    });
  }
}

