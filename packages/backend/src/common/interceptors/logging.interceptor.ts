import {
  Injectable,
  NestInterceptor,
  ExecutionContext,
  CallHandler,
  Logger,
} from '@nestjs/common';
import { Observable } from 'rxjs';
import { tap } from 'rxjs/operators';
import type { Request } from 'express';

/**
 * Logging interceptor
 * Logs all incoming requests and their response times
 */
@Injectable()
export class LoggingInterceptor implements NestInterceptor {
  private readonly logger = new Logger(LoggingInterceptor.name);

  intercept(context: ExecutionContext, next: CallHandler): Observable<unknown> {
    const request = context.switchToHttp().getRequest<Request>();
    const { method, url } = request;
    const body: unknown = request.body;
    const userAgent = request.get('user-agent') || '';
    const startTime = Date.now();

    this.logger.log(`📥 ${method} ${url} - ${userAgent}`);

    if (body && typeof body === 'object' && Object.keys(body).length > 0) {
      this.logger.debug(`Request Body: ${JSON.stringify(body)}`);
    }

    return next.handle().pipe(
      tap({
        next: () => {
          const responseTime = Date.now() - startTime;
          this.logger.log(`📤 ${method} ${url} - ${responseTime}ms - Success`);
        },
        error: (error: unknown) => {
          const responseTime = Date.now() - startTime;
          const message =
            error instanceof Error ? error.message : String(error);
          this.logger.error(
            `❌ ${method} ${url} - ${responseTime}ms - Error: ${message}`,
          );
        },
      }),
    );
  }
}
