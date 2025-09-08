import express from 'express';
import cors from 'cors';
import { MOCK_SERVER_PORT } from './config';
// 关键：直接导入我们组装好的责任链
import { requestHandlers } from './handlers';

const app = express();

app.use(cors());

// --- 应用责任链 ---
// Express 的 app.use 可以接受一个处理器数组，它会自动按顺序执行
app.use(...requestHandlers);

// --- 启动服务器 ---
app.listen(MOCK_SERVER_PORT, () => {
  console.log(`--- TS Mock/Proxy Server 正在运行 (责任链版) ---`);
  console.log(`监听端口: http://localhost:${MOCK_SERVER_PORT}`);
});