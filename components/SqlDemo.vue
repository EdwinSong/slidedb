<template>
    <div>
      <textarea v-model="sqlQuery" placeholder="Enter your SQL query here"></textarea>
      <button @click="runQuery">Run Query</button>
      <div v-if="result">
        <h3>Result:</h3>
        <pre>{{ result }}</pre>
      </div>
    </div>
  </template>
  
  <script>
  export default {
    data() {
      return {
        sqlQuery: '',
        result: null,
      };
    },
    methods: {
      async runQuery() {
        try {
          // 这里可以替换为实际的 SQL 执行逻辑
          // 例如，使用 fetch 或 axios 发送请求到后端 API
          const response = await this.executeSql(this.sqlQuery);
          this.result = JSON.stringify(response, null, 2);
        } catch (error) {
          this.result = `Error: ${error.message}`;
        }
      },
      async executeSql(query) {
        // 模拟 SQL 执行
        // 你可以在这里替换为实际的 SQL 执行逻辑
        return new Promise((resolve) => {
          setTimeout(() => {
            resolve([
              { id: 1, name: 'John Doe' },
              { id: 2, name: 'Jane Doe' },
            ]);
          }, 1000);
        });
      },
    },
  };
  </script>
  
  <style scoped>
  textarea {
    width: 100%;
    height: 100px;
    margin-bottom: 10px;
  }
  
  button {
    padding: 5px 10px;
    background-color: #42b983;
    color: white;
    border: none;
    cursor: pointer;
  }
  
  button:hover {
    background-color: #3aa876;
  }
  
  pre {
    background-color: #f4f4f4;
    padding: 10px;
    border-radius: 5px;
  }
  </style>