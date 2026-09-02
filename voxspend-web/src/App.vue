<script setup lang="ts">
import { ref } from 'vue'
import { useRouter, useRoute } from 'vue-router'

const router = useRouter()
const route = useRoute()
const activeTab = ref<'home' | 'settings'>('home')

function switchTab(tab: 'home' | 'settings') {
  activeTab.value = tab
  router.push(tab === 'home' ? '/' : '/settings')
}
</script>

<template>
  <div class="app-container">
    <router-view v-slot="{ Component }">
      <keep-alive>
        <component :is="Component" />
      </keep-alive>
    </router-view>
    <nav class="tab-bar">
      <button
        :class="['tab-item', { active: route.path === '/' }]"
        @click="switchTab('home')"
      >
        <span class="tab-icon">🏠</span>
        <span class="tab-label">首页</span>
      </button>
      <button
        :class="['tab-item', { active: route.path === '/settings' }]"
        @click="switchTab('settings')"
      >
        <span class="tab-icon">👤</span>
        <span class="tab-label">我的</span>
      </button>
    </nav>
  </div>
</template>
