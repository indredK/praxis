/**
 * User entity
 * In a real application, this would be a database model (Prisma, TypeORM, etc.)
 */
export class User {
  id: string;
  name: string;
  email: string;
  password: string; // In production, this should be hashed
  createdAt: Date;
  updatedAt: Date;

  constructor(partial: Partial<User>) {
    Object.assign(this, partial);
  }
}

