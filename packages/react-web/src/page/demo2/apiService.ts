// 模拟后端API服务
export interface GroupData {
  id: string;
  name: string;
  description?: string;
}

// 模拟电话群组数据
export const mockPhoneGroups: GroupData[] = [
  { id: '1', name: '技术组', description: '技术团队' },
  { id: '2', name: '管理组', description: '管理层' },
  { id: '3', name: '值班组', description: '24小时值班' },
  { id: '4', name: '运维组', description: '运维团队' },
  { id: '5', name: '监控组', description: '监控团队' },
  { id: '6', name: '应急组', description: '应急响应' },
];

// 模拟邮箱群组数据
export const mockEmailGroups: GroupData[] = [
  { id: '1', name: '技术组', description: '技术团队邮箱' },
  { id: '2', name: '管理组', description: '管理层邮箱' },
  { id: '3', name: '值班组', description: '24小时值班邮箱' },
  { id: '4', name: '运维组', description: '运维团队邮箱' },
  { id: '5', name: '监控组', description: '监控团队邮箱' },
  { id: '6', name: '应急组', description: '应急响应邮箱' },
  { id: '7', name: '财务组', description: '财务部门邮箱' },
  { id: '8', name: '人事组', description: '人事部门邮箱' },
];

// 模拟API调用延迟
const delay = (ms: number) => new Promise(resolve => setTimeout(resolve, ms));

// 获取电话群组列表
export const fetchPhoneGroups = async (): Promise<GroupData[]> => {
  await delay(500); // 模拟网络延迟
  return mockPhoneGroups;
};

// 获取邮箱群组列表
export const fetchEmailGroups = async (): Promise<GroupData[]> => {
  await delay(500); // 模拟网络延迟
  return mockEmailGroups;
};

// 搜索电话群组
export const searchPhoneGroups = async (keyword: string): Promise<GroupData[]> => {
  await delay(300);
  if (!keyword) return mockPhoneGroups;
  return mockPhoneGroups.filter(group =>
    group.name.toLowerCase().includes(keyword.toLowerCase()) ||
    (group.description && group.description.toLowerCase().includes(keyword.toLowerCase()))
  );
};

// 搜索邮箱群组
export const searchEmailGroups = async (keyword: string): Promise<GroupData[]> => {
  await delay(300);
  if (!keyword) return mockEmailGroups;
  return mockEmailGroups.filter(group =>
    group.name.toLowerCase().includes(keyword.toLowerCase()) ||
    (group.description && group.description.toLowerCase().includes(keyword.toLowerCase()))
  );
};
