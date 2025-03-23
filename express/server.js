import express from 'express';
import mysql from 'mysql2/promise';
import cors from 'cors';
import bodyParser from 'body-parser';

const app = express();
const port = 4000;

// 使用中间件
app.use(cors());
app.use(bodyParser.json());

// 创建 MySQL 连接池
const pool = mysql.createPool({
  host: 'localhost', // MySQL 主机地址
  user: 'root',      // MySQL 用户名
  password: 'intel@321', // MySQL 密码
  database: 'db_university', // 数据库名称
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
});

// 执行 SQL 的 API 接口
app.post('/execute-sql', async (req, res) => {
  const { sql } = req.body;

  if (!sql) {
    return res.status(400).json({ error: 'SQL 语句不能为空' });
  }

  try {
    // 从连接池中获取连接
    const connection = await pool.getConnection();

    // 执行 SQL
    const [rows] = await connection.query(sql);
    connection.release(); // 释放连接

    // 返回执行结果
    res.json({ results: rows });
  } catch (err) {
    console.error('SQL 执行失败:', err);
    res.status(500).json({ error: 'SQL 执行失败', details: err.message });
  }
});

// 启动服务器
app.listen(port, () => {
  console.log(`服务器运行在 http://localhost:${port}`);
});