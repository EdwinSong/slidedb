<template>
    <div class="container" :style="{ height: containerHeight }">
      <!-- 上部：左侧为编辑器，右侧为结果 -->
      <div class="top-panel">
        <div class="editor-container">
          <div ref="editorContainer" class="editor"></div>
        </div>
        <div class="result-container">
          <div v-if="error" class="error-message">{{ error }}</div>
          <div v-else class="result-wrapper">
            <table v-if="result.length > 0" class="result-table">
              <thead>
                <tr>
                  <th v-for="column in columns" :key="column">{{ column }}</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(row, index) in result" :key="index">
                  <td v-for="column in columns" :key="column">{{ row[column] }}</td>
                </tr>
              </tbody>
            </table>
            <div v-else class="no-result">暂无数据</div>
          </div>
        </div>
      </div>
  
      <!-- 下部：运行按钮 -->
      <div class="bottom-panel">
        <button @click="executeSql" class="run-button">运行 SQL</button>
      </div>
    </div>
  </template>
  
  <script setup>
  import { ref, onMounted, onBeforeUnmount, watch, computed } from 'vue'
  import loader from '@monaco-editor/loader'
  import initSqlJs from 'sql.js'
  
  // 编辑器容器
  const editorContainer = ref(null)
  let editor = null
  
  // SQL 执行结果
  const result = ref([])
  const columns = ref([])
  const error = ref(null)
  
  // 接收初始 SQL 语句和高度
  const props = defineProps({
    initialSql: String,
    height: {
      type: String,
      default: '400px', // 默认高度
    },
  })
  
  // 计算容器高度
  const containerHeight = computed(() => props.height)
  
  // 初始化 Monaco Editor
  onMounted(async () => {
    try {
      // 配置资源路径
      loader.config({ paths: { vs: '/vs' } })
      
      // 初始化 Monaco Editor
      await loader.init()
      editor = monaco.editor.create(editorContainer.value, {
        value: props.initialSql || 'SELECT * FROM users;', // 使用 initialSql 或默认值
        language: 'sql', // 设置语言为 SQL
        theme: 'vs-light', // 设置主题
        automaticLayout: true, // 自适应布局
        minimap: { enabled: false }, // 禁用迷你地图
      })
    } catch (err) {
      console.error('Monaco Editor 初始化失败:', err)
    }
  })
  
  // 监听 initialSql 的变化
  watch(() => props.initialSql, (newSql) => {
    if (editor) {
      editor.setValue(newSql) // 更新编辑器内容
    }
  })
  
  // 执行 SQL
  const executeSql = async () => {
    const sql = editor.getValue()
  
    if (!sql) {
      error.value = 'SQL 语句不能为空'
      return
    }
  
    try {
      // 调用 API 执行 SQL
      const response = await fetch('http://localhost:4000/execute-sql', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ sql }),
      })
  
      const data = await response.json()
  
      if (response.ok) {
        // 解析执行结果
        result.value = data.results
        if (data.results.length > 0) {
          columns.value = Object.keys(data.results[0])
        } else {
          columns.value = []
        }
        error.value = null
      } else {
        error.value = data.error || 'SQL 执行失败'
        result.value = []
        columns.value = []
      }
    } catch (err) {
      error.value = `请求失败: ${err.message}`
      result.value = []
      columns.value = []
    }
  }
  
  // 组件销毁时清理编辑器实例
  onBeforeUnmount(() => {
    if (editor) {
      editor.dispose()
    }
  })
  </script>
  
  <style>
  .container {
    display: flex;
    flex-direction: column;
    gap: 16px; /* 上下部分之间的间距 */
  }
  
  .top-panel {
    display: grid;
    grid-template-columns: 1fr 1fr; /* 左右分栏 */
    gap: 16px; /* 左右部分之间的间距 */
    flex: 1; /* 上部占满剩余空间 */
  }
  
  .editor-container {
    border: 1px solid #ddd;
    border-radius: 4px;
    overflow: hidden;
  }
  
  .editor {
    height: 100%;
  }
  
  .result-container {
    border: 1px solid #ddd;
    border-radius: 4px;
    padding: 16px;
    overflow: auto; /* 支持滚动条 */
    height: 100%; /* 固定高度 */
  }
  
  .result-wrapper {
    width: 100%;
    height: 100%;
    overflow: auto; /* 支持滚动条 */
  }
  
  .result-table {
    width: 100%;
    border-collapse: collapse;
    font-size: 12px; /* 字体更小 */
  }
  
  .result-table th,
  .result-table td {
    padding: 8px;
    border: 1px solid #ddd;
    text-align: left;
    white-space: nowrap; /* 防止文本换行 */
  }
  
  .result-table th {
    background-color: #f8f9fa;
  }
  
  .no-result {
    color: #6c757d;
    font-style: italic;
  }
  
  .bottom-panel {
    display: flex;
    justify-content: center; /* 按钮水平居中 */
  }
  
  .run-button {
    width: 200px; /* 按钮宽度 */
    padding: 8px 16px;
    background-color: #007bff;
    color: white;
    border: none;
    border-radius: 4px;
    cursor: pointer;
  }
  
  .run-button:hover {
    background-color: #0056b3;
  }
  
  .error-message {
    color: red;
    font-weight: bold;
  }
  </style>