import {
  Injectable,
  NotFoundException,
  ConflictException,
} from '@nestjs/common';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';
import { User } from './entities/user.entity';

/**
 * Users service
 * This is a simple in-memory implementation for demonstration
 * In production, use a real database (Prisma, TypeORM, etc.)
 */
@Injectable()
export class UsersService {
  private users: User[] = [];
  private currentId = 1;

  create(createUserDto: CreateUserDto): User {
    // Check if email already exists
    const existingUser = this.users.find(
      (user) => user.email === createUserDto.email,
    );
    if (existingUser) {
      throw new ConflictException('Email already exists');
    }

    const user = new User({
      id: String(this.currentId++),
      ...createUserDto,
      createdAt: new Date(),
      updatedAt: new Date(),
    });

    this.users.push(user);
    return this.sanitizeUser(user);
  }

  findAll(): User[] {
    return this.users.map((user) => this.sanitizeUser(user));
  }

  findOne(id: string): User {
    const user = this.users.find((u) => u.id === id);
    if (!user) {
      throw new NotFoundException(`User with ID ${id} not found`);
    }
    return this.sanitizeUser(user);
  }

  update(id: string, updateUserDto: UpdateUserDto): User {
    const userIndex = this.users.findIndex((u) => u.id === id);
    if (userIndex === -1) {
      throw new NotFoundException(`User with ID ${id} not found`);
    }

    // Check if email already exists (if updating email)
    if (updateUserDto.email) {
      const existingUser = this.users.find(
        (user) => user.email === updateUserDto.email && user.id !== id,
      );
      if (existingUser) {
        throw new ConflictException('Email already exists');
      }
    }

    const updatedUser = {
      ...this.users[userIndex],
      ...updateUserDto,
      updatedAt: new Date(),
    };

    this.users[userIndex] = updatedUser;
    return this.sanitizeUser(updatedUser);
  }

  remove(id: string): void {
    const userIndex = this.users.findIndex((u) => u.id === id);
    if (userIndex === -1) {
      throw new NotFoundException(`User with ID ${id} not found`);
    }
    this.users.splice(userIndex, 1);
  }

  /**
   * Remove sensitive data from user object
   */
  private sanitizeUser(user: User): User {
    const { password, ...sanitized } = user;
    return sanitized as User;
  }
}

