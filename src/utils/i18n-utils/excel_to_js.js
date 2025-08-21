const fs = require('fs');
const xlsx = require('xlsx');
const path = require('path');

// --- 配置 ---
const inputExcel = path.join(__dirname, 'output', 'language_aligned.xlsx'); // 你的Excel
const outputDir = path.join(__dirname, 'output_js');
const exportVarName = 'language_class'; // 导出变量名

// 确保输出目录存在
if (!fs.existsSync(outputDir)) {
  fs.mkdirSync(outputDir);
}

/**
 * 设置对象的嵌套值
 * @param {object} obj 
 * @param {string[]} pathArr 
 * @param {*} value 
 */
function setNestedValue(obj, pathArr, value) {
  let current = obj;
  for (let i = 0; i < pathArr.length; i++) {
    const key = pathArr[i];
    if (i === pathArr.length - 1) {
      current[key] = value;
    } else {
      if (!current[key] || typeof current[key] !== 'object') {
        current[key] = {};
      }
      current = current[key];
    }
  }
}

/**
 * 尝试解析 JSON，如果失败就返回原值
 * @param {*} value 
 */
function tryParseJSON(value) {
  if (typeof value !== 'string') return value;
  try {
    const parsed = JSON.parse(value);
    if (typeof parsed === 'object') return parsed;
  } catch (_) {}
  return value;
}

/**
 * 将 Excel 转成多个 JS 文件
 */
function excelToJsFiles() {
  const workbook = xlsx.readFile(inputExcel);
  const sheetName = workbook.SheetNames[0];
  const sheet = workbook.Sheets[sheetName];
  const rows = xlsx.utils.sheet_to_json(sheet, { defval: '' });

  if (!rows.length) {
    console.error('❌ Excel 没有数据');
    return;
  }

  // 获取所有语言列名（去掉 Path）
  const langKeys = Object.keys(rows[0]).filter(k => k !== 'Path');

  langKeys.forEach(lang => {
    const obj = {};
    rows.forEach(row => {
      const pathKey = row['Path'];
      const value = tryParseJSON(row[lang]);
      setNestedValue(obj, pathKey.split('.'), value);
    });

    const jsContent = `export const ${exportVarName} = ${JSON.stringify(obj, null, 2)};\n`;
    const outputPath = path.join(outputDir, `${lang}.js`);
    fs.writeFileSync(outputPath, jsContent, 'utf8');
    console.log(`✅ 生成 ${lang}.js 成功！`);
  });
}

excelToJsFiles();
