// /packages/mock-server/tests/api.test.ts

import { describe, it, expect, beforeEach, afterEach } from "vitest";
import request from "supertest";
import nock from "nock";
import express, { Express } from "express";

import { createRequestHandlers } from "../../src/handlers/index.js";
import { testApiRegistry } from "../fixtures/api.test.mockRegistry.js";
import { REAL_DEVICE_IP } from "../../config.js";
import { normalizeUrl } from "../../src/utils/url.js";

describe("API Handler Tests", () => {
  let testApp: Express;

  beforeEach(() => {
    testApp = express();
    testApp.use(express.json());

    // 注意：cgiRegistry 传入空数组
    const testHandlers = createRequestHandlers({
      cgiRegistry: [],
      apiRegistry: testApiRegistry,
      proxyTarget: normalizeUrl(REAL_DEVICE_IP),
    });

    testApp.use(...testHandlers);
  });

  afterEach(() => {
    nock.cleanAll();
  });

  it("【API 静态 Mock】当请求命中 apiRegistry 规则时，应直接返回预设数据", async () => {
    const response = await request(testApp).get("/api/user/profile");

    expect(response.status).toBe(200);
    expect(response.body.user.id).toBe("test-user");
    expect(response.body.user.name).toBe("Test User");
  });

  it("【API 代理】当请求 /api/* 但未命中任何规则时，应被代理转发", async () => {
    const unmatchedApiPath = "/some/other/endpoint";
    const upstreamResponse = { forwarded: true, from: "api-proxy" };

    const scope = nock(normalizeUrl(REAL_DEVICE_IP)).get(unmatchedApiPath).reply(200, upstreamResponse);

    const response = await request(testApp).get(unmatchedApiPath);

    expect(scope.isDone()).toBe(true);
    expect(response.status).toBe(200);
    expect(response.body.from).toBe("api-proxy");
  });
});
