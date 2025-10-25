import { Controller, Get } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse } from '@nestjs/swagger';
import { HealthService } from './health.service';

/**
 * Health check controller
 * Provides endpoints for monitoring application health
 */
@ApiTags('health')
@Controller('health')
export class HealthController {
  constructor(private readonly healthService: HealthService) {}

  @Get()
  @ApiOperation({ summary: 'Get application health status' })
  @ApiResponse({ status: 200, description: 'Application is healthy' })
  check() {
    return this.healthService.check();
  }

  @Get('ping')
  @ApiOperation({ summary: 'Simple ping-pong health check' })
  @ApiResponse({ status: 200, description: 'Returns pong with timestamp' })
  ping() {
    return { message: 'pong', timestamp: new Date().toISOString() };
  }
}

