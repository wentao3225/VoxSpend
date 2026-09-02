import { createRouter, createWebHistory } from 'vue-router'

const routes = [
  { path: '/', name: 'home', component: () => import('../views/HomePage.vue') },
  { path: '/add', name: 'add', component: () => import('../views/AddPage.vue') },
  { path: '/confirm', name: 'confirm', component: () => import('../views/ConfirmPage.vue') },
  { path: '/search', name: 'search', component: () => import('../views/SearchPage.vue') },
  { path: '/settings', name: 'settings', component: () => import('../views/SettingsPage.vue') },
  { path: '/transaction/:id', name: 'transaction-detail', component: () => import('../views/TransactionDetailPage.vue') },
  { path: '/weekly-report', name: 'weekly-report', component: () => import('../views/WeeklyReportPage.vue') },
  { path: '/weekly-report-list', name: 'weekly-report-list', component: () => import('../views/WeeklyReportListPage.vue') },
]

const router = createRouter({
  history: createWebHistory(),
  routes,
})

export default router
