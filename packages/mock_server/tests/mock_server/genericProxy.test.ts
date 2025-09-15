// /packages/mock-server/tests/genericProxy.test.ts

import { describe, it, expect, beforeEach, afterEach } from "vitest";
import request from "supertest";
import nock from "nock";
import express, { Express } from "express";

import { createRequestHandlers } from "../../src/handlers/index.js";
import { REAL_DEVICE_IP } from "../../config.js";
import { normalizeUrl } from "../../src/utils/url.js";

describe("Generic Proxy Handler Tests", () => {
  let testApp: Express;

  beforeEach(() => {
    testApp = express();
    testApp.use(express.json());

    // 关键：传入空的 mock registries，确保请求一定会落到最后的通用代理
    const testHandlers = createRequestHandlers({
      cgiRegistry: [],
      apiRegistry: [],
      proxyTarget: normalizeUrl(REAL_DEVICE_IP),
    });

    testApp.use(...testHandlers);
  });

  afterEach(() => {
    nock.cleanAll();
  });

  it("【通用代理】应能忠实转发上游服务的响应 (包括状态码和响应体)", async () => {
    const unmatchedPath = "/a-truly-random-path-that-does-not-exist";
    const upstreamErrorBody = { error: "Upstream Service Not Found" };

    const scope = nock(normalizeUrl(REAL_DEVICE_IP)).get(unmatchedPath).reply(404, upstreamErrorBody);

    const response = await request(testApp).get(unmatchedPath);

    expect(scope.isDone()).toBe(true);
    expect(response.status).toBe(404);
    expect(response.body).toEqual(upstreamErrorBody);
  });
});
