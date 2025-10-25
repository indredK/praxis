import { applyDecorators } from '@nestjs/common';

/**
 * Custom decorator for API documentation
 * This can be extended with Swagger decorators when needed
 */
export function ApiResponse(options: {
  description?: string;
  type?: any;
  status?: number;
}) {
  return applyDecorators(
    // Add Swagger decorators here when @nestjs/swagger is installed
    // @ApiOperation({ summary: options.description })
    // @ApiResponse({ status: options.status, type: options.type })
  );
}

