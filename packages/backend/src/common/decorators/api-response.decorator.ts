import { applyDecorators, Type } from '@nestjs/common';
import { ApiResponse as SwaggerApiResponse } from '@nestjs/swagger';

/**
 * Custom decorator for API documentation
 * Thin wrapper over the Swagger @ApiResponse decorator
 */
export function ApiResponse(options: {
  description?: string;
  type?: Type<unknown>;
  status?: number;
}) {
  return applyDecorators(
    SwaggerApiResponse({
      status: options.status,
      description: options.description,
      type: options.type,
    }),
  );
}
