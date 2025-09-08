import express from 'express';
import cors from 'cors';
import { MOCK_SERVER_PORT } from './config.js';
// 关键：直接导入我们组装好的责任链
import { requestHandlers } from './handlers/index.js';

// 1. 创建 app 实例
const app = express();

app.use(cors());

// 2. 应用所有处理器/中间件
app.use(...requestHandlers);

// 3. 只有在直接通过 node 运行此文件时，才启动监听
// 当被其他文件（如测试文件）导入时，则不启动监听
if (process.env.NODE_ENV !== 'test') { // 增加一个环境变量判断
  app.listen(MOCK_SERVER_PORT, () => {
    console.log(`--- TS Mock/Proxy Server 正在运行 (责任链版) ---`);
    console.log(`监听端口: http://localhost:${MOCK_SERVER_PORT}`);
  });
}

// 4. 导出 app 实例，以便测试文件可以导入它
export { app };