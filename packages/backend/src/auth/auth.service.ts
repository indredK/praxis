import {
  Injectable,
  UnauthorizedException,
  ConflictException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import * as bcrypt from 'bcrypt';
import { UsersService } from '../users/users.service';
import { LoginDto } from './dto/login.dto';
import { RegisterDto } from './dto/register.dto';

/**
 * Authentication Service
 * Handles user registration, login, and JWT token generation
 */
@Injectable()
export class AuthService {
  constructor(
    private usersService: UsersService,
    private jwtService: JwtService,
    private configService: ConfigService,
  ) {}

  /**
   * Register a new user
   * Best Practice: Hash password before storing
   */
  async register(registerDto: RegisterDto) {
    // Hash the password
    const hashedPassword = await bcrypt.hash(registerDto.password, 10);

    // Create user (Prisma will handle unique constraint for email)
    const user = await this.usersService.create({
      ...registerDto,
      password: hashedPassword,
    });

    // Generate JWT token
    const token = await this.generateToken(user.id, user.email);

    return {
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
      },
      access_token: token,
    };
  }

  /**
   * Login user
   * Best Practice: Use findByEmail method to get user with password
   */
  async login(loginDto: LoginDto) {
    // Find user by email (includes password for verification)
    const user = await this.usersService.findByEmail(loginDto.email);

    if (!user) {
      throw new UnauthorizedException('Invalid credentials');
    }

    // Verify password
    const isPasswordValid = await bcrypt.compare(
      loginDto.password,
      user.password,
    );

    if (!isPasswordValid) {
      throw new UnauthorizedException('Invalid credentials');
    }

    // Generate JWT token
    const token = await this.generateToken(user.id, user.email);

    return {
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
      },
      access_token: token,
    };
  }

  /**
   * Validate user from JWT payload
   * Used by JwtStrategy
   */
  async validateUser(userId: string) {
    try {
      return this.usersService.findOne(userId);
    } catch {
      return null;
    }
  }

  /**
   * Generate JWT access token
   * Best Practice: Use consistent payload structure
   */
  private async generateToken(userId: string, email: string): Promise<string> {
    const payload = { sub: userId, email };
    return this.jwtService.signAsync(payload);
  }
}

