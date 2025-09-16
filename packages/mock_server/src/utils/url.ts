// /packages/mock-server/src/utils/url.ts

/**
 * 规范化一个 URL 或 IP 地址字符串，确保它以 http:// 或 https:// 开头。
 * 如果输入已经是完整的 URL，则直接返回。
 * 如果输入只包含 IP 或域名，则默认添加 http:// 前缀。
 * 对 null, undefined 或空字符串等无效输入，返回空字符串。
 * @param {string | null | undefined} urlOrIp - 可能包含协议的 URL 或纯 IP/域名字符串。
 * @returns {string} - 一个保证带有协议前缀的 URL 字符串，或空字符串。
 */
export function normalizeUrl(urlOrIp: string | null | undefined): string {
  // 1. 处理无效输入
  if (!urlOrIp) {
    return "";
  }

  const trimmedUrl = urlOrIp.trim();

  // 2. 检查是否已经包含 http:// 或 https://
  if (/^https?:\/\//.test(trimmedUrl)) {
    return trimmedUrl; // 如果有，直接返回
  }

  // 3. 如果没有，默认添加 http:// 前缀
  return `http://${trimmedUrl}`;
}
