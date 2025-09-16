// 引入 Node.js 的文件系统模块和 xlsx 库
const fs = require('fs');
const xlsx = require('xlsx');
const path = require('path');

// --- 配置 ---
const files = ['../lang/zh-cn.js', '../lang/en.js'];

const outputDir = path.join(__dirname, 'output');
const outputFile = 'language_aligned.xlsx';
const exportVarName = 'language_class'; // 导出变量名

// 确保输出目录存在
if (!fs.existsSync(outputDir)) {
  fs.mkdirSync(outputDir);
}

/**
 * 递归获取对象的路径和值
 * @param {object} obj
 * @param {string[]} pathArr
 * @param {object} resultMap
 */
function collectPaths(obj, pathArr = [], resultMap = {}) {
  for (const key in obj) {
    if (Object.prototype.hasOwnProperty.call(obj, key)) {
      const value = obj[key];
      const newPath = [...pathArr, key];

      if (typeof value === 'object' && value !== null && !Array.isArray(value)) {
        // 纯对象，递归继续
        collectPaths(value, newPath, resultMap);
      } else {
        const pathKey = newPath.join('.');
        // 如果是对象或数组，转成 JSON 字符串
        if (typeof value === 'object' && value !== null) {
          resultMap[pathKey] = JSON.stringify(value, null, 2); // 缩进 2 格便于阅读
        } else {
          resultMap[pathKey] = value;
        }
      }
    }
  }
  return resultMap;
}

/**
 * 从 JS 文件中读取对象
 * @param {string} filePath
 */
function readLanguageFile(filePath) {
  const fileContent = fs.readFileSync(filePath, 'utf8');
  // 找到 exportVarName 的定义
  const startIndex = fileContent.indexOf('{');
  const endIndex = fileContent.lastIndexOf('}');
  const objectString = fileContent.substring(startIndex, endIndex + 1);
  if (!objectString) throw new Error(`在文件 ${filePath} 中找不到有效的对象`);
  return new Function(`return ${objectString}`)();
}

try {
  // 存储所有路径的合集
  const allPaths = new Set();
  // 存储每个文件的路径 -> 值映射
  const fileDataMap = {};

  // 1. 读取每个文件并收集数据
  files.forEach(file => {
    const filePath = path.join(__dirname, file);
    console.log(`读取文件: ${file}...`);
    const langObj = readLanguageFile(filePath);
    const pathsMap = collectPaths(langObj);
    fileDataMap[file] = pathsMap;
    Object.keys(pathsMap).forEach(p => allPaths.add(p));
  });

  // 2. 构建 Excel 数据
  const headers = ['Path', ...files.map(f => path.basename(f, '.js'))];
  const rows = [headers];

  Array.from(allPaths)
    .sort()
    .forEach(p => {
      const row = [p];
      files.forEach(file => {
        let cellValue = fileDataMap[file][p] ?? '';
        if (typeof cellValue === 'object' && cellValue !== null) {
          cellValue = JSON.stringify(cellValue, null, 2);
        }
        row.push(cellValue);
      });
      rows.push(row);
    });

  // 3. 写入 Excel
  const workbook = xlsx.utils.book_new();
  const worksheet = xlsx.utils.aoa_to_sheet(rows);

  // 自动调整列宽
  worksheet['!cols'] = headers.map((_, i) => {
    let maxWidth = 0;
    rows.forEach(row => {
      const cellContent = row[i] ? String(row[i]) : '';
      if (cellContent.length > maxWidth) {
        maxWidth = cellContent.length;
      }
    });
    return { wch: maxWidth < 15 ? 15 : maxWidth + 2 };
  });

  // 自动换行（Excel 里多行 JSON 更易读）
  Object.keys(worksheet).forEach(cellAddr => {
    if (!cellAddr.startsWith('!') && worksheet[cellAddr].v && worksheet[cellAddr].v.includes('\n')) {
      if (!worksheet[cellAddr].s) worksheet[cellAddr].s = {};
      worksheet[cellAddr].s.alignment = { wrapText: true };
    }
  });

  xlsx.utils.book_append_sheet(workbook, worksheet, 'Languages');
  const outputPath = path.join(outputDir, outputFile);
  xlsx.writeFile(workbook, outputPath);

  console.log(`✅ 成功！文件已保存到: ${outputPath}`);
} catch (error) {
  console.error(`❌ 错误: ${error.message}`);
}
