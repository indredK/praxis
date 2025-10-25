import { ArgumentsHost, Catch, HttpStatus, Logger } from '@nestjs/common';
import { BaseExceptionFilter } from '@nestjs/core';
import { Prisma } from '@prisma/client';
import { Response } from 'express';

/**
 * Prisma Exception Filter
 * Handles Prisma-specific errors and converts them to HTTP responses
 * Best Practice: Centralized error handling for database operations
 */
@Catch(Prisma.PrismaClientKnownRequestError)
export class PrismaClientExceptionFilter extends BaseExceptionFilter {
  private readonly logger = new Logger(PrismaClientExceptionFilter.name);

  catch(exception: Prisma.PrismaClientKnownRequestError, host: ArgumentsHost) {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse<Response>();
    const request = ctx.getRequest();

    const errorResponse = this.handlePrismaError(exception);

    this.logger.error(
      `Prisma Error ${exception.code}: ${exception.message}`,
      exception.stack,
    );

    response.status(errorResponse.status).json({
      statusCode: errorResponse.status,
      timestamp: new Date().toISOString(),
      path: request.url,
      method: request.method,
      message: errorResponse.message,
      error: errorResponse.error,
    });
  }

  private handlePrismaError(exception: Prisma.PrismaClientKnownRequestError): {
    status: number;
    message: string;
    error: string;
  } {
    switch (exception.code) {
      case 'P2000':
        return {
          status: HttpStatus.BAD_REQUEST,
          message: 'The provided value is too long for the column',
          error: 'Bad Request',
        };

      case 'P2001':
        return {
          status: HttpStatus.NOT_FOUND,
          message: 'The record does not exist',
          error: 'Not Found',
        };

      case 'P2002':
        // Unique constraint violation
        const target = exception.meta?.target as string[];
        return {
          status: HttpStatus.CONFLICT,
          message: `${target?.[0] || 'Field'} already exists`,
          error: 'Conflict',
        };

      case 'P2003':
        return {
          status: HttpStatus.BAD_REQUEST,
          message: 'Foreign key constraint failed',
          error: 'Bad Request',
        };

      case 'P2025':
        return {
          status: HttpStatus.NOT_FOUND,
          message: 'Record not found',
          error: 'Not Found',
        };

      default:
        return {
          status: HttpStatus.INTERNAL_SERVER_ERROR,
          message: 'An unexpected error occurred',
          error: 'Internal Server Error',
        };
    }
  }
}

