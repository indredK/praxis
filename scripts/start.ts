// /praxis/scripts/start.mjs (增强版)

import { readFile, access } from "fs/promises";
import path from "path";
import { glob } from "glob";
import inquirer from "inquirer";
import chalk from "chalk";
import { execa } from "execa";
import YAML from "yaml"; // 1. 导入 YAML 解析器
import { a } from "vitest/dist/chunks/suite.d.FvehnV49.js";

// --- 工具函数 ---

async function getScripts(pkgPath) {
  try {
    const content = await readFile(path.join(pkgPath, "package.json"), "utf-8");
    const pkgJson = JSON.parse(content);
    return pkgJson.scripts || {};
  } catch {
    return {};
  }
}

// 2. 重写 getPackages 函数，使其优先读取 pnpm-workspace.yaml
async function getPackages(rootPath) {
  const pnpmWorkspacePath = path.join(rootPath, "pnpm-workspace.yaml");
  let patterns = [];

  try {
    // 优先尝试 pnpm-workspace.yaml
    await access(pnpmWorkspacePath); // 检查文件是否存在
    const content = await readFile(pnpmWorkspacePath, "utf-8");
    const workspaceConfig = YAML.parse(content);
    patterns = workspaceConfig.packages || [];
  } catch {
    // 如果失败，则回退到 package.json 的 workspaces 字段
    const rootPkgJsonPath = path.join(rootPath, "package.json");
    const content = await readFile(rootPkgJsonPath, "utf-8");
    const pkgJson = JSON.parse(content);
    patterns = pkgJson.workspaces || [];
  }

  const packages: any[] = [];
  for (const pattern of patterns) {
    const found = await glob(pattern, { cwd: rootPath, absolute: true });
    for (const pkgAbsPath of found) {
      const pkgJsonPath = path.join(pkgAbsPath, "package.json");
      try {
        const pkgContent = await readFile(pkgJsonPath, "utf-8");
        const { name } = JSON.parse(pkgContent);
        if (name) {
          // path.relative 计算相对路径，更稳健
          packages.push({ name, path: path.relative(rootPath, pkgAbsPath) });
        }
      } catch {}
    }
  }
  return packages;
}

async function runCommand(command) {
  console.log(chalk.cyan(`\n> ${command}\n`));
  try {
    await execa(command, { shell: true, stdio: "inherit" });
  } catch (error) {
    console.error(chalk.red("\nScript failed."));
  }
}

// --- 主函数 ---
async function main() {
  const rootPath = process.cwd();

  const { location } = await inquirer.prompt([
    {
      type: "list",
      name: "location",
      message: chalk.green("你想在哪里运行脚本?"),
      choices: [
        { name: "根目录 (Root)", value: "root" },
        { name: "某个包 (Package)", value: "package" },
      ],
    },
  ]);

  if (location === "root") {
    const rootScripts = await getScripts(rootPath);
    const scriptChoices = Object.keys(rootScripts);
    if (scriptChoices.length === 0) {
      console.log(chalk.yellow("根目录没有可用的脚本。"));
      return;
    }
    const { script } = await inquirer.prompt([
      { type: "list", name: "script", message: chalk.green("选择一个根目录脚本:"), choices: scriptChoices },
    ]);

    // 根目录脚本通常已经是 "turbo run ..." 或者其他命令，直接用 pnpm 运行即可
    await runCommand(`pnpm ${script}`);
  } else {
    const packages = await getPackages(rootPath);
    if (packages.length === 0) {
      console.log(chalk.yellow("找不到任何包。请检查 pnpm-workspace.yaml 或 package.json 中的 workspaces 配置。"));
      return;
    }

    const { selectedPackage } = await inquirer.prompt([
      {
        type: "list",
        name: "selectedPackage",
        message: chalk.green("选择一个包:"),
        choices: packages.map((p) => ({ name: p.name, value: p })),
      },
    ]);

    const packageScripts = await getScripts(path.join(rootPath, selectedPackage.path));
    const scriptChoices = Object.keys(packageScripts);
    if (scriptChoices.length === 0) {
      console.log(chalk.yellow(`包 ${selectedPackage.name} 没有可用的脚本。`));
      return;
    }

    const { script } = await inquirer.prompt([
      {
        type: "list",
        name: "script",
        message: chalk.green(`选择包 "${selectedPackage.name}" 中的一个脚本:`),
        choices: scriptChoices,
      },
    ]);

    // 3. 使用 turbo run 来执行命令，以利用其缓存优势
    await runCommand(`turbo run ${script} --filter=${selectedPackage.name}`);
  }
}

main().catch(console.error);
