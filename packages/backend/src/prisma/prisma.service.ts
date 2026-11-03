import {
  Injectable,
  OnModuleInit,
  OnModuleDestroy,
  Logger,
} from '@nestjs/common';
import { PrismaClient } from '../../generated/prisma/client';
import { createPrismaAdapter } from '../../prisma/adapter';

/**
 * Prisma Service
 * Manages database connections and provides Prisma Client instance
 * Best Practice: Singleton pattern, handles connection lifecycle
 */
@Injectable()
export class PrismaService
  extends PrismaClient
  implements OnModuleInit, OnModuleDestroy
{
  private readonly logger = new Logger(PrismaService.name);

  constructor() {
    super({
      adapter: createPrismaAdapter(),
      log: [
        { emit: 'event', level: 'query' },
        { emit: 'stdout', level: 'info' },
        { emit: 'stdout', level: 'warn' },
        { emit: 'stdout', level: 'error' },
      ],
      errorFormat: 'pretty',
    });
  }

  async onModuleInit() {
    await this.$connect();
    this.logger.log('✅ Database connected successfully');
  }

  async onModuleDestroy() {
    await this.$disconnect();
    this.logger.log('🔌 Database disconnected');
  }

  /**
   * Clean database for testing
   * ⚠️ Use with caution - only in test environment
   */
  async cleanDatabase() {
    if (process.env.NODE_ENV === 'production') {
      throw new Error('Cannot clean database in production!');
    }

    const models = Reflect.ownKeys(this).filter(
      (key) => key[0] !== '_' && key !== 'constructor',
    );

    const deletions = models.flatMap((modelKey) => {
      const model: unknown = this[modelKey as keyof typeof this];
      return isDeletable(model) ? [model.deleteMany()] : [];
    });
    return Promise.all(deletions);
  }
}

/** Prisma model delegates expose deleteMany(); anything else is skipped. */
interface Deletable {
  deleteMany: () => Promise<unknown>;
}

function isDeletable(value: unknown): value is Deletable {
  return (
    typeof value === 'object' &&
    value !== null &&
    'deleteMany' in value &&
    typeof value.deleteMany === 'function'
  );
}
