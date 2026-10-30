import { jest } from '@jest/globals';
import { Test, TestingModule } from '@nestjs/testing';
import { NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { UsersService } from './users.service';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';

const makeUser = (overrides: Record<string, unknown> = {}) => ({
  id: 'user-1',
  name: 'John Doe',
  email: 'john@example.com',
  createdAt: new Date('2026-01-01T00:00:00.000Z'),
  updatedAt: new Date('2026-01-01T00:00:00.000Z'),
  ...overrides,
});

const asyncMock = () =>
  jest.fn<(...args: unknown[]) => Promise<unknown>>();

const makePrismaMock = () => ({
  user: {
    create: asyncMock(),
    findMany: asyncMock(),
    findUnique: asyncMock(),
    update: asyncMock(),
    delete: asyncMock(),
  },
});

describe('UsersService', () => {
  let service: UsersService;
  let prisma: ReturnType<typeof makePrismaMock>;

  beforeEach(async () => {
    prisma = makePrismaMock();
    const module: TestingModule = await Test.createTestingModule({
      providers: [UsersService, { provide: PrismaService, useValue: prisma }],
    }).compile();

    service = module.get<UsersService>(UsersService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('create', () => {
    it('returns the selected public fields', async () => {
      const input: CreateUserDto = {
        name: 'John Doe',
        email: 'john@example.com',
        password: 'password123',
      };
      const user = makeUser();
      prisma.user.create.mockResolvedValue(user);

      const result = await service.create(input);

      expect(result).toEqual(user);
      expect(result).not.toHaveProperty('password');
      expect(prisma.user.create).toHaveBeenCalledWith(
        expect.objectContaining({ data: input }),
      );
    });

    it('propagates Prisma create errors for the exception filter', async () => {
      const error = new Error('database error');
      prisma.user.create.mockRejectedValue(error);

      await expect(
        service.create({
          name: 'John Doe',
          email: 'john@example.com',
          password: 'password123',
        }),
      ).rejects.toBe(error);
    });
  });

  describe('findAll', () => {
    it('returns users from Prisma', async () => {
      const users = [makeUser()];
      prisma.user.findMany.mockResolvedValue(users);

      await expect(service.findAll()).resolves.toEqual(users);
    });
  });

  describe('findOne', () => {
    it('returns a user by id', async () => {
      const user = makeUser();
      prisma.user.findUnique.mockResolvedValue(user);

      await expect(service.findOne(user.id)).resolves.toEqual(user);
    });

    it('throws when the user is missing', async () => {
      prisma.user.findUnique.mockResolvedValue(null);

      await expect(service.findOne('missing')).rejects.toBeInstanceOf(
        NotFoundException,
      );
    });
  });

  describe('update', () => {
    it('updates an existing user', async () => {
      const existing = makeUser();
      const updated = makeUser({ name: 'Jane Doe' });
      const input: UpdateUserDto = { name: 'Jane Doe' };
      prisma.user.findUnique.mockResolvedValue(existing);
      prisma.user.update.mockResolvedValue(updated);

      await expect(service.update(existing.id, input)).resolves.toEqual(updated);
      expect(prisma.user.update).toHaveBeenCalledWith(
        expect.objectContaining({ where: { id: existing.id }, data: input }),
      );
    });

    it('throws before updating when the user is missing', async () => {
      prisma.user.findUnique.mockResolvedValue(null);

      await expect(
        service.update('missing', { name: 'Jane Doe' }),
      ).rejects.toBeInstanceOf(NotFoundException);
      expect(prisma.user.update).not.toHaveBeenCalled();
    });
  });

  describe('remove', () => {
    it('deletes an existing user', async () => {
      const user = makeUser();
      prisma.user.findUnique.mockResolvedValue(user);
      prisma.user.delete.mockResolvedValue(undefined);

      await service.remove(user.id);

      expect(prisma.user.delete).toHaveBeenCalledWith({
        where: { id: user.id },
      });
    });

    it('throws before deleting when the user is missing', async () => {
      prisma.user.findUnique.mockResolvedValue(null);

      await expect(service.remove('missing')).rejects.toBeInstanceOf(
        NotFoundException,
      );
      expect(prisma.user.delete).not.toHaveBeenCalled();
    });
  });
});
