<template>
  <div class="home-container">
    <el-row :gutter="20">
      <el-col :span="8">
        <el-card class="stat-card">
          <template #header>
            <div class="card-header">
              <el-icon class="header-icon"><User /></el-icon>
              <span>用户总数</span>
            </div>
          </template>
          <div class="card-content">
            <span class="number">{{ totalUsers }}</span>
            <span class="label">位用户</span>
          </div>
        </el-card>
      </el-col>
      <el-col :span="8">
        <el-card class="stat-card">
          <template #header>
            <div class="card-header">
              <el-icon class="header-icon"><Calendar /></el-icon>
              <span>本月新增</span>
            </div>
          </template>
          <div class="card-content">
            <span class="number">{{ monthlyNewUsers }}</span>
            <span class="label">位用户</span>
          </div>
        </el-card>
      </el-col>
      <el-col :span="8">
        <el-card class="stat-card">
          <template #header>
            <div class="card-header">
              <el-icon class="header-icon"><Timer /></el-icon>
              <span>今日活跃</span>
            </div>
          </template>
          <div class="card-content">
            <span class="number">{{ dailyActiveUsers }}</span>
            <span class="label">位用户</span>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <el-card class="recent-users-card">
      <template #header>
        <div class="card-header">
          <span>最近注册用户</span>
        </div>
      </template>
      <el-table :data="recentUsers" style="width: 100%">
        <el-table-column prop="id" label="ID" width="80" />
        <el-table-column prop="username" label="用户名" />
        <el-table-column prop="email" label="邮箱" />
        <el-table-column prop="createTime" label="注册时间" />
      </el-table>
    </el-card>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { User, Calendar, Timer } from '@element-plus/icons-vue'
import axios from 'axios'

const router = useRouter()
const totalUsers = ref(0)
const monthlyNewUsers = ref(0)
const dailyActiveUsers = ref(0)
const recentUsers = ref([])

const loadStatistics = async () => {
  try {
    const token = localStorage.getItem('token')
    if (!token) {
      router.push('/login')
      return
    }

    const response = await axios.get('http://localhost:8080/api/users/statistics', {
      headers: {
        Authorization: `Bearer ${token}`
      }
    })

    totalUsers.value = response.data.totalUsers
    monthlyNewUsers.value = response.data.monthlyNewUsers
    dailyActiveUsers.value = response.data.dailyActiveUsers
  } catch (error) {
    if (error.response?.status === 401) {
      localStorage.removeItem('token')
      router.push('/login')
    }
    ElMessage.error('获取统计数据失败')
  }
}

const loadRecentUsers = async () => {
  try {
    const token = localStorage.getItem('token')
    if (!token) {
      router.push('/login')
      return
    }

    const response = await axios.get('http://localhost:8080/api/users/recent', {
      headers: {
        Authorization: `Bearer ${token}`
      }
    })

    recentUsers.value = response.data
  } catch (error) {
    if (error.response?.status === 401) {
      localStorage.removeItem('token')
      router.push('/login')
    }
    ElMessage.error('获取最近用户数据失败')
  }
}

onMounted(() => {
  loadStatistics()
  loadRecentUsers()
})
</script>

<style scoped>
.home-container {
  padding: 20px;
}

.stat-card {
  height: 180px;
  margin-bottom: 20px;
}

.card-header {
  display: flex;
  align-items: center;
}

.header-icon {
  margin-right: 8px;
  font-size: 20px;
}

.card-content {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  height: 100px;
}

.number {
  font-size: 36px;
  font-weight: bold;
  color: #409EFF;
  margin-bottom: 8px;
}

.label {
  font-size: 14px;
  color: #909399;
}

.recent-users-card {
  margin-top: 20px;
}
</style>