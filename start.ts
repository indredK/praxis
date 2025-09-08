import inquirer from 'inquirer';
import { spawn } from 'child_process';
import { readFileSync } from 'fs';
import path from 'path';
import chalk from 'chalk'; // 我们继续使用 chalk 来美化输出

// 1. 读取并解析 package.json
const packageJsonPath = path.resolve(process.cwd(), 'package.json');
const packageJson = JSON.parse(readFileSync(packageJsonPath, 'utf-8'));
const scripts = packageJson.scripts || {};

// 2. 过滤掉我们不希望用户直接选择的脚本
const excludedScripts = new Set(['start', 'prepare', 'release']);
const scriptChoices = Object.keys(scripts)
  .filter(key => !excludedScripts.has(key))
  .map(key => ({
    name: `${chalk.green(key.padEnd(15))} ${chalk.dim(scripts[key])}`, // 美化输出，让命令更清晰
    value: key,
    short: key,
  }));

// 如果没有可选择的脚本，则退出
if (scriptChoices.length === 0) {
  console.log(chalk.red('在 package.json 中没有找到可执行的脚本。'));
  process.exit(0);
}

// 3. 使用 inquirer 创建交互式菜单
inquirer
  .prompt([
    {
      type: 'list',
      name: 'script',
      message: '请选择要运行的 NPM 脚本:',
      choices: scriptChoices,
      pageSize: 15, // 如果脚本很多，可以增加显示行数
    },
  ])
  .then(answers => {
    // 4. 获取用户选择的脚本名称
    const scriptToRun = answers.script;
    console.log(chalk.cyan(`\n> 正在执行: npm run ${scriptToRun}\n`));

    // 5. 使用 spawn 执行选择的脚本
    const child = spawn('npm', ['run', scriptToRun], {
      // stdio: 'inherit' 是关键，它让子进程的输出/输入直接连接到当前终端
      // 这样你就能看到实时日志，并能用 Ctrl+C 终止它
      stdio: 'inherit',
      // 在 Windows 上，需要 shell: true 才能正确找到 npm 命令
      shell: true,
    });

    // 监听子进程退出事件
    child.on('exit', (code) => {
      console.log(chalk.dim(`\n脚本 "${scriptToRun}" 已退出，退出码: ${code}\n`));
    });
  })
  .catch(error => {
    console.error(chalk.red('启动器发生错误:'), error);
  });