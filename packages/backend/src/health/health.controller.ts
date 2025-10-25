import { Controller, Get } from '@nestjs/common';
import { HealthService } from './health.service';

/**
 * Health check controller
 * Provides endpoints for monitoring application health
 */
@Controller('health')
export class HealthController {
  constructor(private readonly healthService: HealthService) {}

  @Get()
  check() {
    return this.healthService.check();
  }

  @Get('ping')
  ping() {
    return { message: 'pong', timestamp: new Date().toISOString() };
  }
}

