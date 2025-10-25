import { Injectable, NotFoundException } from '@nestjs/common';
import { CreateProductDto } from './dto/create-product.dto';
import { UpdateProductDto } from './dto/update-product.dto';
import { Product } from './entities/product.entity';
import { PaginationDto, PaginatedResponse } from '../common/dto/pagination.dto';

/**
 * Products service with pagination support
 */
@Injectable()
export class ProductsService {
  private products: Product[] = [
    new Product({
      id: '1',
      name: 'Sample Product 1',
      description: 'This is a sample product',
      price: 99.99,
      stock: 100,
      createdAt: new Date(),
      updatedAt: new Date(),
    }),
    new Product({
      id: '2',
      name: 'Sample Product 2',
      description: 'Another sample product',
      price: 149.99,
      stock: 50,
      createdAt: new Date(),
      updatedAt: new Date(),
    }),
  ];
  private currentId = 3;

  create(createProductDto: CreateProductDto): Product {
    const product = new Product({
      id: String(this.currentId++),
      ...createProductDto,
      createdAt: new Date(),
      updatedAt: new Date(),
    });

    this.products.push(product);
    return product;
  }

  findAll(paginationDto: PaginationDto): PaginatedResponse<Product> {
    const { page = 1, limit = 10 } = paginationDto;
    const startIndex = (page - 1) * limit;
    const endIndex = startIndex + limit;

    const paginatedProducts = this.products.slice(startIndex, endIndex);
    const total = this.products.length;

    return {
      data: paginatedProducts,
      meta: {
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  findOne(id: string): Product {
    const product = this.products.find((p) => p.id === id);
    if (!product) {
      throw new NotFoundException(`Product with ID ${id} not found`);
    }
    return product;
  }

  update(id: string, updateProductDto: UpdateProductDto): Product {
    const productIndex = this.products.findIndex((p) => p.id === id);
    if (productIndex === -1) {
      throw new NotFoundException(`Product with ID ${id} not found`);
    }

    const updatedProduct = {
      ...this.products[productIndex],
      ...updateProductDto,
      updatedAt: new Date(),
    };

    this.products[productIndex] = updatedProduct;
    return updatedProduct;
  }

  remove(id: string): void {
    const productIndex = this.products.findIndex((p) => p.id === id);
    if (productIndex === -1) {
      throw new NotFoundException(`Product with ID ${id} not found`);
    }
    this.products.splice(productIndex, 1);
  }
}

