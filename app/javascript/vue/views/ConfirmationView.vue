<template>
  <div class="min-h-screen bg-gray-50">
    <!-- Loading -->
    <div v-if="loading && !reservation" class="flex flex-col items-center justify-center py-20">
      <div class="relative">
        <div class="w-16 h-16 border-4 border-indigo-200 rounded-full"></div>
        <div class="absolute top-0 left-0 w-16 h-16 border-4 border-indigo-600 rounded-full animate-spin border-t-transparent"></div>
      </div>
    </div>

    <div v-else-if="reservation" class="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <!-- Success Card -->
      <div class="bg-white rounded-2xl shadow-xl overflow-hidden">
        <!-- Success Header -->
        <div class="bg-gradient-to-r from-emerald-500 to-green-600 px-6 py-12 text-center relative overflow-hidden">
          <!-- Decorative Elements -->
          <div class="absolute inset-0">
            <div class="absolute -top-20 -right-20 w-40 h-40 bg-white/10 rounded-full"></div>
            <div class="absolute -bottom-20 -left-20 w-40 h-40 bg-white/10 rounded-full"></div>
          </div>
          
          <div class="relative">
            <div class="w-20 h-20 bg-white rounded-full flex items-center justify-center mx-auto mb-6 shadow-lg">
              <svg class="w-10 h-10 text-emerald-600" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
              </svg>
            </div>
            <h1 class="text-3xl font-bold text-white mb-2">¡Compra confirmada!</h1>
            <p class="text-emerald-100">Tu pasaje ha sido emitido exitosamente</p>
          </div>
        </div>

        <!-- Locator Code -->
        <div class="bg-gradient-to-b from-gray-50 to-white px-6 py-6 text-center border-b border-gray-100">
          <p class="text-sm text-gray-500 uppercase tracking-wide font-medium mb-2">Código de reserva</p>
          <p class="text-4xl font-mono font-bold text-gray-900 tracking-wider">{{ reservation.locator_code }}</p>
          <p class="text-sm text-gray-500 mt-2">Presenta este código al abordar</p>
        </div>

        <!-- Trip Details -->
        <div class="p-6 sm:p-8">
          <h2 class="text-lg font-bold text-gray-900 mb-6 flex items-center gap-2">
            <svg class="w-5 h-5 text-indigo-600" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7h12m0 0l-4-4m4 4l-4 4m0 6H4m0 0l4 4m-4-4l4-4" />
            </svg>
            Detalles del viaje
          </h2>
          
          <!-- Journey Visual -->
          <div class="bg-gray-50 rounded-xl p-6 mb-6">
            <div class="flex items-center justify-between">
              <div class="text-center">
                <p class="text-3xl font-bold text-gray-900">{{ formatTime(reservation.trip?.departure_at) }}</p>
                <p class="text-sm text-gray-500 mt-1">{{ reservation.trip?.origin }}</p>
              </div>
              
              <div class="flex-1 px-4 sm:px-8">
                <div class="relative">
                  <div class="flex items-center">
                    <div class="w-3 h-3 bg-indigo-600 rounded-full"></div>
                    <div class="flex-1 h-0.5 bg-gradient-to-r from-indigo-600 via-indigo-400 to-indigo-300"></div>
                    <svg class="w-6 h-6 text-indigo-400 -ml-1" fill="currentColor" viewBox="0 0 24 24">
                      <path d="M8.25 18.75a1.5 1.5 0 01-3 0m3 0a1.5 1.5 0 00-3 0m3 0h6m-9 0H3.375a1.125 1.125 0 01-1.125-1.125V14.25m17.25 4.5a1.5 1.5 0 01-3 0m3 0a1.5 1.5 0 00-3 0m3 0h1.125c.621 0 1.129-.504 1.09-1.124a17.902 17.902 0 00-3.213-9.193 2.056 2.056 0 00-1.58-.86H14.25M16.5 18.75h-2.25m0-11.177v-.958c0-.568-.422-1.048-.987-1.106a48.554 48.554 0 00-10.026 0 1.106 1.106 0 00-.987 1.106v7.635m12-6.677v6.677m0 4.5v-4.5m0 0h-12"/>
                    </svg>
                    <div class="flex-1 h-0.5 bg-gradient-to-r from-indigo-300 via-indigo-400 to-indigo-600"></div>
                    <div class="w-3 h-3 bg-indigo-600 rounded-full"></div>
                  </div>
                  <p class="text-center text-xs text-gray-500 mt-2">{{ reservation.trip?.duration }}</p>
                </div>
              </div>
              
              <div class="text-center">
                <p class="text-3xl font-bold text-gray-900">{{ formatTime(reservation.trip?.arrival_at) }}</p>
                <p class="text-sm text-gray-500 mt-1">{{ reservation.trip?.destination }}</p>
              </div>
            </div>
            
            <div class="mt-6 pt-4 border-t border-gray-200 flex flex-wrap justify-center gap-4 text-sm">
              <span class="flex items-center gap-1.5 text-gray-600">
                <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
                </svg>
                {{ formatDate(reservation.trip?.departure_at) }}
              </span>
              <span class="px-3 py-1 bg-indigo-100 text-indigo-700 rounded-full font-medium">
                {{ reservation.trip?.bus_type }}
              </span>
            </div>
          </div>

          <!-- Passengers -->
          <h3 class="font-semibold text-gray-900 mb-4 flex items-center gap-2">
            <svg class="w-5 h-5 text-gray-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0z" />
            </svg>
            Pasajeros
          </h3>
          <div class="space-y-3 mb-6">
            <div 
              v-for="passenger in reservation.passengers" 
              :key="passenger.seat_number"
              class="flex items-center justify-between p-4 bg-gray-50 rounded-xl"
            >
              <div class="flex items-center gap-4">
                <div class="w-12 h-12 bg-indigo-600 rounded-xl flex items-center justify-center">
                  <span class="text-white font-bold">{{ passenger.seat_number }}</span>
                </div>
                <div>
                  <p class="font-semibold text-gray-900">{{ passenger.full_name }}</p>
                  <p class="text-sm text-gray-500">{{ passenger.document }}</p>
                </div>
              </div>
              <span class="text-sm font-medium text-indigo-600 bg-indigo-50 px-3 py-1 rounded-lg">
                Asiento {{ passenger.seat_number }}
              </span>
            </div>
          </div>

          <!-- Payment Info -->
          <div class="border-t border-gray-200 pt-6">
            <div class="flex justify-between items-center mb-4">
              <span class="text-gray-600">Total pagado</span>
              <span class="text-2xl font-bold text-gray-900">{{ reservation.total?.formatted }}</span>
            </div>
            <div class="flex justify-between items-center">
              <span class="text-gray-600">Estado</span>
              <span class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-sm font-medium bg-emerald-100 text-emerald-700">
                <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
                </svg>
                {{ reservation.status_label }}
              </span>
            </div>
          </div>

          <!-- Email Notice -->
          <div class="mt-6 p-4 bg-blue-50 rounded-xl flex items-start gap-3">
            <svg class="w-5 h-5 text-blue-600 flex-shrink-0 mt-0.5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />
            </svg>
            <p class="text-sm text-blue-800">
              Hemos enviado una copia de tu pasaje a <strong>{{ reservation.contact?.email }}</strong>
            </p>
          </div>

          <!-- Actions -->
          <div class="mt-8 flex flex-col sm:flex-row gap-4">
            <button
              @click="downloadTicket"
              class="flex-1 py-4 px-6 bg-gradient-to-r from-indigo-600 to-purple-600 text-white font-semibold rounded-xl shadow-lg shadow-indigo-500/30 hover:shadow-xl hover:from-indigo-700 hover:to-purple-700 transition-all flex items-center justify-center gap-2"
            >
              <svg class="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4" />
              </svg>
              Descargar comprobante
            </button>
            <button
              @click="$router.push('/')"
              class="flex-1 py-4 px-6 bg-gray-100 text-gray-700 font-semibold rounded-xl hover:bg-gray-200 transition-colors flex items-center justify-center gap-2"
            >
              <svg class="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6" />
              </svg>
              Comprar otro pasaje
            </button>
          </div>
        </div>
      </div>

      <!-- Help Section -->
      <div class="mt-8 text-center text-sm text-gray-500">
        <p>¿Necesitas ayuda? Contáctanos en <a href="mailto:soporte@posku.cl" class="text-indigo-600 hover:underline">soporte@posku.cl</a></p>
      </div>
    </div>

    <!-- Error -->
    <div v-else-if="error" class="max-w-lg mx-auto py-20 text-center px-4">
      <div class="w-16 h-16 bg-red-100 rounded-full flex items-center justify-center mx-auto mb-6">
        <svg class="w-8 h-8 text-red-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
        </svg>
      </div>
      <h3 class="text-xl font-semibold text-gray-900 mb-2">Error</h3>
      <p class="text-gray-600 mb-6">{{ error }}</p>
      <button @click="$router.push('/')" class="px-6 py-3 bg-indigo-600 text-white font-medium rounded-xl hover:bg-indigo-700 transition-colors">
        Volver al inicio
      </button>
    </div>
  </div>
</template>

<script setup>
import { computed, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { useReservationStore } from '../stores/reservation'

const route = useRoute()
const reservationStore = useReservationStore()

const loading = computed(() => reservationStore.loading)
const error = computed(() => reservationStore.error)
const reservation = computed(() => reservationStore.currentReservation)

onMounted(async () => {
  const locator = route.params.locator
  if (!reservation.value || reservation.value.locator_code !== locator) {
    await reservationStore.loadReservation(locator)
  }
})

function formatTime(dateStr) {
  if (!dateStr) return ''
  const date = new Date(dateStr)
  return date.toLocaleTimeString('es-CL', { hour: '2-digit', minute: '2-digit' })
}

function formatDate(dateStr) {
  if (!dateStr) return ''
  const date = new Date(dateStr)
  return date.toLocaleDateString('es-CL', { weekday: 'long', day: 'numeric', month: 'long', year: 'numeric' })
}

function downloadTicket() {
  if (!reservation.value?.locator_code) return
  
  const link = document.createElement('a')
  link.href = `/api/tickets/${reservation.value.locator_code}`
  link.download = `pasaje_${reservation.value.locator_code}.pdf`
  document.body.appendChild(link)
  link.click()
  document.body.removeChild(link)
}
</script>
