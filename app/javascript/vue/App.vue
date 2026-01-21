<template>
  <div class="min-h-screen bg-gray-50">
    <!-- Header -->
    <header class="bg-indigo-600 shadow-lg">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex justify-between items-center py-4">
          <router-link to="/" class="flex items-center space-x-2">
            <svg class="h-8 w-8 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8.25 18.75a1.5 1.5 0 01-3 0m3 0a1.5 1.5 0 00-3 0m3 0h6m-9 0H3.375a1.125 1.125 0 01-1.125-1.125V14.25m17.25 4.5a1.5 1.5 0 01-3 0m3 0a1.5 1.5 0 00-3 0m3 0h1.125c.621 0 1.129-.504 1.09-1.124a17.902 17.902 0 00-3.213-9.193 2.056 2.056 0 00-1.58-.86H14.25M16.5 18.75h-2.25m0-11.177v-.958c0-.568-.422-1.048-.987-1.106a48.554 48.554 0 00-10.026 0 1.106 1.106 0 00-.987 1.106v7.635m12-6.677v6.677m0 4.5v-4.5m0 0h-12" />
            </svg>
            <span class="text-xl font-bold text-white">Posku</span>
          </router-link>
          
          <nav class="flex items-center space-x-4">
            <router-link 
              v-if="reservationStore.currentReservation" 
              :to="{ name: 'checkout', params: { locator: reservationStore.currentReservation.locator_code }}"
              class="text-white hover:text-indigo-200 text-sm font-medium"
            >
              Mi Reserva
            </router-link>
            <a href="/admin" class="text-indigo-200 hover:text-white text-sm">Admin</a>
          </nav>
        </div>
      </div>
    </header>

    <!-- Main content -->
    <main>
      <router-view v-slot="{ Component }">
        <transition name="fade" mode="out-in">
          <component :is="Component" />
        </transition>
      </router-view>
    </main>

    <!-- Footer -->
    <footer class="bg-gray-800 mt-auto">
      <div class="max-w-7xl mx-auto px-4 py-8 sm:px-6 lg:px-8">
        <div class="text-center text-gray-400 text-sm">
          <p>&copy; 2026 Posku. Plataforma de venta de pasajes de bus.</p>
          <p class="mt-2">Demo creada con Rails 8 + Vue 3 + Tailwind</p>
        </div>
      </div>
    </footer>
  </div>
</template>

<script setup>
import { useReservationStore } from './stores/reservation'

const reservationStore = useReservationStore()
</script>

<style>
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.2s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}
</style>
