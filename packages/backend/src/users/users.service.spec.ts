import { Test, TestingModule } from '@nestjs/testing';
import { ConflictException, NotFoundException } from '@nestjs/common';
import { UsersService } from './users.service';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';

describe('UsersService', () => {
  let service: UsersService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [UsersService],
    }).compile();

    service = module.get<UsersService>(UsersService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('create', () => {
    it('should create a new user', () => {
      const createUserDto: CreateUserDto = {
        name: 'John Doe',
        email: 'john@example.com',
        password: 'password123',
      };

      const user = service.create(createUserDto);

      expect(user).toBeDefined();
      expect(user.name).toBe(createUserDto.name);
      expect(user.email).toBe(createUserDto.email);
      expect(user.password).toBeUndefined(); // Password should be sanitized
    });

    it('should throw ConflictException if email already exists', () => {
      const createUserDto: CreateUserDto = {
        name: 'John Doe',
        email: 'john@example.com',
        password: 'password123',
      };

      service.create(createUserDto);

      expect(() => service.create(createUserDto)).toThrow(ConflictException);
    });
  });

  describe('findAll', () => {
    it('should return an array of users', () => {
      const createUserDto: CreateUserDto = {
        name: 'John Doe',
        email: 'john@example.com',
        password: 'password123',
      };

      service.create(createUserDto);
      const users = service.findAll();

      expect(users).toBeInstanceOf(Array);
      expect(users.length).toBeGreaterThan(0);
    });
  });

  describe('findOne', () => {
    it('should return a user by id', () => {
      const createUserDto: CreateUserDto = {
        name: 'John Doe',
        email: 'john@example.com',
        password: 'password123',
      };

      const createdUser = service.create(createUserDto);
      const foundUser = service.findOne(createdUser.id);

      expect(foundUser).toBeDefined();
      expect(foundUser.id).toBe(createdUser.id);
    });

    it('should throw NotFoundException if user not found', () => {
      expect(() => service.findOne('999')).toThrow(NotFoundException);
    });
  });

  describe('update', () => {
    it('should update a user', () => {
      const createUserDto: CreateUserDto = {
        name: 'John Doe',
        email: 'john@example.com',
        password: 'password123',
      };

      const createdUser = service.create(createUserDto);
      const updateUserDto: UpdateUserDto = {
        name: 'Jane Doe',
      };

      const updatedUser = service.update(createdUser.id, updateUserDto);

      expect(updatedUser.name).toBe(updateUserDto.name);
      expect(updatedUser.email).toBe(createdUser.email);
    });

    it('should throw NotFoundException if user not found', () => {
      const updateUserDto: UpdateUserDto = {
        name: 'Jane Doe',
      };

      expect(() => service.update('999', updateUserDto)).toThrow(
        NotFoundException,
      );
    });
  });

  describe('remove', () => {
    it('should remove a user', () => {
      const createUserDto: CreateUserDto = {
        name: 'John Doe',
        email: 'john@example.com',
        password: 'password123',
      };

      const createdUser = service.create(createUserDto);
      service.remove(createdUser.id);

      expect(() => service.findOne(createdUser.id)).toThrow(NotFoundException);
    });

    it('should throw NotFoundException if user not found', () => {
      expect(() => service.remove('999')).toThrow(NotFoundException);
    });
  });
});

