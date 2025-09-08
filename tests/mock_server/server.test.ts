import { describe, it, expect, beforeAll, afterAll, beforeEach } from 'vitest';
import request from 'supertest'; // 导入 supertest
import nock from 'nock';       // 导入 nock
import { REAL_DEVICE_IP } from '../../src/mock_server/config.js';
import { app } from '../../src/mock_server/server.js';

// 告诉 Vitest 我们正在测试 Node.js 环境
// @vitest-environment node

describe('Mock Server E2E Tests', () => {

  // 在所有测试开始前，确保 nock 被激活
  beforeAll(() => {
    nock.disableNetConnect(); // 禁止所有未被 mock 的真实网络请求，确保测试独立
    nock.enableNetConnect('127.0.0.1'); // 允许连接到 localhost
  });

  // 在每个测试后清理 nock 的设置
  afterAll(() => {
    nock.cleanAll();
    nock.enableNetConnect();
  });

  // --- 测试 Mock 功能 ---
  describe('CGI Mocking Logic', () => {
    it('对于匹配的请求，应该返回预设的 Mock 数据', async () => {
      // 准备一个匹配 cgi.mockRegistry.json 规则的请求体
      const mockablePayload = {
        core: 'yruo_status',
        function: 'get',
        values: [{ base: 'summary' }]
      };

      const response = await request(app)
        .post('/cgi')
        .set('Content-Type', 'application/x-www-form-urlencoded')
        .send(JSON.stringify(mockablePayload)); // supertest 会处理好 body

      // 断言：状态码应该是 200
      expect(response.status).toBe(200);
      // 断言：返回的 body 应该包含我们 mock 的数据
      expect(response.body.data.summary).toHaveProperty('uptime');
    });
  });

  // --- 测试代理转发功能 ---
  describe('Proxy Forwarding Logic', () => {
    it('对于未命中的 API GET 请求，应该成功转发', async () => {
      // 1. 使用 nock "假装" 自己是真实设备
      // 当 nock 发现有发往 REAL_DEVICE_IP 的 GET /api/health 的请求时...
      nock(REAL_DEVICE_IP)
        .get('/api/health')
        .reply(200, { status: 'ok', from: 'real device' }); // ...就返回这个 200 OK 的响应

      // 2. 使用 supertest 向我们的 Mock 服务器发请求
      const response = await request(app).get('/api/health');

      // 3. 断言
      // 我们期望 Mock 服务器能返回 200，因为 nock 模拟的真实设备返回了 200
      expect(response.status).toBe(200);
      // 并且 body 也是 nock 返回的那个
      expect(response.body).toEqual({ status: 'ok', from: 'real device' });
    });

    it('对于未命中的 CGI POST 请求，也应该成功转发', async () => {
      const unmockedPayload = { core: 'unknown', function: 'action' };
      const payloadString = JSON.stringify(unmockedPayload);

      // 1. 设置 nock 拦截转发
      nock(REAL_DEVICE_IP)
        .post('/cgi', payloadString) // nock 可以匹配请求体
        .reply(201, { success: true, forwarded: true });

      // 2. 发送请求
      const response = await request(app)
        .post('/cgi')
        .set('Content-Type', 'application/x-www-form-urlencoded')
        .send(payloadString);

      // 3. 断言
      expect(response.status).toBe(201);
      expect(response.body).toEqual({ success: true, forwarded: true });
    });
  });
});