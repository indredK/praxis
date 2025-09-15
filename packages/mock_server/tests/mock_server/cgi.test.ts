// /packages/mock-server/tests/cgi.test.ts

import { describe, it, expect, beforeEach, afterEach } from "vitest";
import request from "supertest";
import nock from "nock";
import express, { Express } from "express";

import { createRequestHandlers } from "../../src/handlers/index.js";
import { testCgiRegistry } from "../fixtures/cgi.test.mockRegistry.js";
import { REAL_DEVICE_IP } from "../../config.js";
import { normalizeUrl } from "../../src/utils/url.js";

describe("CGI Handler Tests", () => {
  let testApp: Express;

  beforeEach(() => {
    testApp = express();
    testApp.use(express.text({ type: "application/x-www-form-urlencoded" }));

    // 注意：apiRegistry 传入空数组，因为此文件不关心 API 逻辑
    const testHandlers = createRequestHandlers({
      cgiRegistry: testCgiRegistry,
      apiRegistry: [],
      // 关键修正：确保 proxyTarget 是一个完整的 URL
      proxyTarget: normalizeUrl(REAL_DEVICE_IP),
    });

    testApp.use(...testHandlers);
  });

  afterEach(() => {
    nock.cleanAll();
  });

  it("【CGI 静态 Mock】当请求命中 responseData 规则时，应直接返回预设数据", async () => {
    const staticMockRequest = { core: "yruo_status", function: "get", values: [{ base: "details" }] };

    const response = await request(testApp)
      .post("/cgi")
      .set("Content-Type", "application/x-www-form-urlencoded")
      .send(JSON.stringify(staticMockRequest));

    expect(response.status).toBe(200);
    expect(response.body.data.details.firmware).toBe("v2.1.0-mock");
  });

  it("【CGI Modifier】当请求命中 modifier 规则时，应返回修改后的数据", async () => {
    const fakeRealDeviceResponse = {
      success: true,
      data: { summary: { uptime: "REAL_UPTIME", cpu_load: "10%" } },
    };

    nock(normalizeUrl(REAL_DEVICE_IP))
      .post("/cgi")
      .reply(200, fakeRealDeviceResponse, { "Content-Type": "application/json" });

    const modifierMockRequest = { core: "yruo_status", function: "get", values: [{ base: "summary" }] };

    const response = await request(testApp)
      .post("/cgi")
      .set("Content-Type", "application/x-www-form-urlencoded")
      .send(JSON.stringify(modifierMockRequest));

    expect(response.status).toBe(200);
    expect(response.body.data.summary.cpu_load).toBe("10%");
    expect(response.body.data.summary.uptime).toBe("MODIFIED_BY_TEST");
  });

  it("【CGI 代理】当 POST /cgi 但未命中任何规则时，应被代理转发", async () => {
    const unmatchedCgiRequest = { core: "unmatched_service", function: "get" };
    const upstreamResponse = { forwarded: true, from: "cgi-proxy" };

    const scope = nock(normalizeUrl(REAL_DEVICE_IP)).post("/cgi").reply(200, upstreamResponse);

    const response = await request(testApp)
      .post("/cgi")
      .set("Content-Type", "application/x-www-form-urlencoded")
      .send(JSON.stringify(unmatchedCgiRequest));

    expect(scope.isDone()).toBe(true);
    expect(response.status).toBe(200);
    expect(response.body.from).toBe("cgi-proxy");
  });
});
