import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateProductDto } from './dto/create-product.dto';
import { UpdateProductDto } from './dto/update-product.dto';
import { Product } from '@prisma/client';
import { PaginationDto, PaginatedResponse } from '../common/dto/pagination.dto';

/**
 * Products Service
 * Best Practice: Uses Prisma with pagination support
 * Repository Pattern: Encapsulates all product data access
 */
@Injectable()
export class ProductsService {
  constructor(private prisma: PrismaService) {}

  /**
   * Create a new product
   */
  async create(createProductDto: CreateProductDto): Promise<Product> {
    const { id, ...data } = createProductDto;
    return this.prisma.product.create({
      data: {
        id: id || `product_${Date.now()}_${Math.random().toString(36).substring(7)}`,
        ...data,
      },
    });
  }

  /**
   * Get all products with pagination
   * Best Practice: Efficient pagination using skip/take
   */
  async findAll(
    paginationDto: PaginationDto,
  ): Promise<PaginatedResponse<Product>> {
    const { page = 1, limit = 10 } = paginationDto;
    const skip = (page - 1) * limit;

    // Execute count and findMany in parallel for better performance
    const [total, products] = await Promise.all([
      this.prisma.product.count(),
      this.prisma.product.findMany({
        skip,
        take: limit,
        orderBy: {
          createdAt: 'desc',
        },
      }),
    ]);

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

  /**
   * Get product by ID
   */
  async findOne(id: string): Promise<Product> {
    const product = await this.prisma.product.findUnique({
      where: { id },
    });

    if (!product) {
      throw new NotFoundException(`Product with ID ${id} not found`);
    }

    return product;
  }

  /**
   * Update product
   */
  async update(
    id: string,
    updateProductDto: UpdateProductDto,
  ): Promise<Product> {
    // Check if product exists
    await this.findOne(id);

    return this.prisma.product.update({
      where: { id },
      data: updateProductDto,
    });
  }

  /**
   * Delete product
   */
  async remove(id: string): Promise<void> {
    // Check if product exists
    await this.findOne(id);

    await this.prisma.product.delete({
      where: { id },
    });
  }
}

