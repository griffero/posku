import { createRouter, createWebHistory } from 'vue-router'

const routes = [
  {
    path: '/',
    name: 'home',
    component: () => import('../views/HomeView.vue')
  },
  {
    path: '/buscar',
    name: 'search',
    component: () => import('../views/SearchResultsView.vue')
  },
  {
    path: '/viaje/:id/asientos',
    name: 'seats',
    component: () => import('../views/SeatSelectionView.vue')
  },
  {
    path: '/reserva/:locator',
    name: 'checkout',
    component: () => import('../views/CheckoutView.vue')
  },
  {
    path: '/reserva/:locator/pago',
    name: 'payment',
    component: () => import('../views/PaymentView.vue')
  },
  {
    path: '/confirmacion/:locator',
    name: 'confirmation',
    component: () => import('../views/ConfirmationView.vue')
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes,
  scrollBehavior() {
    return { top: 0 }
  }
})

export default router
