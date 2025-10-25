import { IsEnum, IsNumber, IsString, validateSync } from 'class-validator';
import { plainToInstance } from 'class-transformer';

enum Environment {
  Development = 'development',
  Production = 'production',
  Test = 'test',
}

/**
 * Environment variables validation schema
 * This ensures all required env vars are present and have correct types
 */
class EnvironmentVariables {
  @IsEnum(Environment)
  NODE_ENV: Environment;

  @IsNumber()
  PORT: number;

  @IsString()
  DATABASE_URL: string;

  @IsString()
  JWT_SECRET: string;

  @IsString()
  JWT_EXPIRES_IN: string;

  @IsNumber()
  RATE_LIMIT_TTL: number;

  @IsNumber()
  RATE_LIMIT_MAX: number;

  @IsString()
  CORS_ORIGIN: string;

  @IsString()
  LOG_LEVEL: string;
}

/**
 * Validates environment variables at application startup
 * Throws an error if validation fails, preventing the app from starting with invalid config
 */
export function validate(config: Record<string, unknown>) {
  const validatedConfig = plainToInstance(EnvironmentVariables, config, {
    enableImplicitConversion: true,
  });

  const errors = validateSync(validatedConfig, {
    skipMissingProperties: false,
  });

  if (errors.length > 0) {
    throw new Error(errors.toString());
  }

  return validatedConfig;
}

