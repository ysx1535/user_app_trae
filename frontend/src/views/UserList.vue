<template>
  <div class="user-list-container">
    <el-card class="user-list-card">
      <template #header>
        <div class="card-header">
          <h2>用户列表</h2>
          <el-button @click="handleLogout" type="danger" size="small">退出登录</el-button>
        </div>
      </template>
      <el-table :data="users" style="width: 100%">
        <el-table-column prop="id" label="ID" width="80" />
        <el-table-column prop="username" label="用户名" />
        <el-table-column prop="email" label="邮箱" />
        <el-table-column prop="createTime" label="创建时间" />
        <el-table-column label="操作" width="200">
          <template #default="scope">
            <el-button size="small" @click="handleEditEmail(scope.row)">修改邮箱</el-button>
            <el-button size="small" type="danger" @click="handleDelete(scope.row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
      <div class="pagination">
        <el-pagination
          v-model:current-page="currentPage"
          v-model:page-size="pageSize"
          :total="total"
          :page-sizes="[10, 20, 30, 50]"
          layout="total, sizes, prev, pager, next"
          @size-change="handleSizeChange"
          @current-change="handleCurrentChange"
        />
      </div>
    </el-card>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import axios from 'axios'

const router = useRouter()
const users = ref([])
const currentPage = ref(1)
const pageSize = ref(10)
const total = ref(0)

const loadUsers = async () => {
  try {
    const token = localStorage.getItem('token')
    if (!token) {
      router.push('/login')
      return
    }

    const response = await axios.get(`http://localhost:8080/api/users?page=${currentPage.value - 1}&size=${pageSize.value}`, {
      headers: {
        Authorization: `Bearer ${token}`
      }
    })
    users.value = response.data.content
    total.value = response.data.totalElements
  } catch (error) {
    if (error.response?.status === 401) {
      localStorage.removeItem('token')
      router.push('/login')
    }
    ElMessage.error('获取用户列表失败')
  }
}

const handleSizeChange = (val) => {
  pageSize.value = val
  loadUsers()
}

const handleCurrentChange = (val) => {
  currentPage.value = val
  loadUsers()
}

const handleLogout = () => {
  localStorage.removeItem('token')
  router.push('/login')
  ElMessage.success('已退出登录')
}

const handleEditEmail = async (user) => {
  try {
    const { value: email } = await ElMessageBox.prompt('请输入新的邮箱地址', '修改邮箱', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      inputValue: user.email || '',
      inputValidator: (value) => {
        if (!value) return '邮箱不能为空'
        const emailRegex = /^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,6}$/
        if (!emailRegex.test(value)) return '请输入正确的邮箱格式'
        return true
      }
    })

    const token = localStorage.getItem('token')
    await axios.put(`http://localhost:8080/api/users/${user.id}/email`, email, {
      headers: {
        Authorization: `Bearer ${token}`,
        'Content-Type': 'text/plain'
      }
    })

    ElMessage.success('邮箱修改成功')
    loadUsers()
  } catch (error) {
    if (error.response?.status === 401) {
      localStorage.removeItem('token')
      router.push('/login')
    } else if (error !== 'cancel') {
      ElMessage.error('修改邮箱失败')
    }
  }
}

const handleDelete = async (user) => {
  try {
    await ElMessageBox.confirm('确定要删除该用户吗？', '警告', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })

    const token = localStorage.getItem('token')
    await axios.delete(`http://localhost:8080/api/users/${user.id}`, {
      headers: {
        Authorization: `Bearer ${token}`
      }
    })

    ElMessage.success('用户删除成功')
    loadUsers()
  } catch (error) {
    if (error.response?.status === 401) {
      localStorage.removeItem('token')
      router.push('/login')
    } else if (error !== 'cancel') {
      ElMessage.error('删除用户失败')
    }
  }
}

onMounted(() => {
  loadUsers()
})
</script>

<style scoped>
.user-list-container {
  padding: 20px;
  background-color: #f5f5f5;
  min-height: 100vh;
}

.user-list-card {
  max-width: 1200px;
  margin: 0 auto;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.card-header h2 {
  margin: 0;
  color: #409EFF;
}

.pagination {
  margin-top: 20px;
  display: flex;
  justify-content: center;
}
</style>