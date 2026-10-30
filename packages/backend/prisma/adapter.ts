import { PrismaPg } from '@prisma/adapter-pg';

const CONNECTION_POOL_MAX = 10;
const CONNECTION_TIMEOUT_MS = 5_000;
const IDLE_TIMEOUT_MS = 300_000;

export function createPrismaAdapter() {
  const connectionString = process.env.DATABASE_URL?.trim();

  if (!connectionString) {
    throw new Error('DATABASE_URL must be set before connecting to PostgreSQL.');
  }

  return new PrismaPg({
    connectionString,
    max: CONNECTION_POOL_MAX,
    connectionTimeoutMillis: CONNECTION_TIMEOUT_MS,
    idleTimeoutMillis: IDLE_TIMEOUT_MS,
  });
}
