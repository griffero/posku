<template>
  <div class="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
    <!-- Loading -->
    <div v-if="loading && !reservation" class="text-center py-12">
      <svg class="animate-spin h-10 w-10 text-indigo-600 mx-auto" fill="none" viewBox="0 0 24 24">
        <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
        <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z"></path>
      </svg>
    </div>

    <div v-else-if="reservation" class="bg-white rounded-lg shadow-md overflow-hidden">
      <!-- Success Header -->
      <div class="bg-green-600 px-6 py-8 text-center">
        <div class="w-16 h-16 bg-white rounded-full flex items-center justify-center mx-auto mb-4">
          <svg class="w-8 h-8 text-green-600" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
          </svg>
        </div>
        <h1 class="text-2xl font-bold text-white">¡Compra confirmada!</h1>
        <p class="text-green-100 mt-2">Tu pasaje ha sido emitido exitosamente</p>
      </div>

      <!-- Locator Code -->
      <div class="bg-gray-50 px-6 py-4 text-center border-b">
        <p class="text-sm text-gray-600">Código de reserva</p>
        <p class="text-3xl font-mono font-bold text-gray-900">{{ reservation.locator_code }}</p>
        <p class="text-sm text-gray-500 mt-1">Guarda este código para presentar al abordar</p>
      </div>

      <!-- Trip Details -->
      <div class="p-6">
        <h2 class="text-lg font-bold text-gray-900 mb-4">Detalles del viaje</h2>
        
        <div class="bg-gray-50 rounded-lg p-4 mb-6">
          <div class="flex items-center justify-between">
            <div class="text-center">
              <p class="text-2xl font-bold text-gray-900">{{ formatTime(reservation.trip?.departure_at) }}</p>
              <p class="text-sm text-gray-600">{{ reservation.trip?.origin }}</p>
            </div>
            <div class="flex-1 px-4">
              <div class="border-t-2 border-gray-300 border-dashed relative">
                <div class="absolute left-1/2 -top-3 transform -translate-x-1/2 bg-gray-50 px-2">
                  <svg class="w-6 h-6 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M14 5l7 7m0 0l-7 7m7-7H3" />
                  </svg>
                </div>
              </div>
              <p class="text-center text-xs text-gray-500 mt-2">{{ reservation.trip?.duration }}</p>
            </div>
            <div class="text-center">
              <p class="text-2xl font-bold text-gray-900">{{ formatTime(reservation.trip?.arrival_at) }}</p>
              <p class="text-sm text-gray-600">{{ reservation.trip?.destination }}</p>
            </div>
          </div>
          <div class="mt-4 pt-4 border-t border-gray-200 flex justify-between text-sm">
            <span class="text-gray-600">{{ formatDate(reservation.trip?.departure_at) }}</span>
            <span class="text-gray-600">{{ reservation.trip?.bus_type }}</span>
          </div>
        </div>

        <!-- Passengers -->
        <h3 class="font-medium text-gray-900 mb-3">Pasajeros</h3>
        <div class="space-y-3 mb-6">
          <div 
            v-for="passenger in reservation.passengers" 
            :key="passenger.seat_number"
            class="flex justify-between items-center p-3 bg-gray-50 rounded-lg"
          >
            <div>
              <p class="font-medium text-gray-900">{{ passenger.full_name }}</p>
              <p class="text-sm text-gray-500">{{ passenger.document }}</p>
            </div>
            <div class="text-right">
              <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-indigo-100 text-indigo-800">
                Asiento {{ passenger.seat_number }}
              </span>
            </div>
          </div>
        </div>

        <!-- Payment Summary -->
        <div class="border-t border-gray-200 pt-4">
          <div class="flex justify-between items-center">
            <span class="text-gray-600">Total pagado</span>
            <span class="text-2xl font-bold text-gray-900">{{ reservation.total?.formatted }}</span>
          </div>
          <div class="flex justify-between items-center mt-2">
            <span class="text-gray-600">Estado</span>
            <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800">
              {{ reservation.status_label }}
            </span>
          </div>
        </div>

        <!-- Contact Info -->
        <div class="mt-6 p-4 bg-blue-50 rounded-lg">
          <p class="text-sm text-blue-800">
            Se ha enviado una copia de tu pasaje a <strong>{{ reservation.contact?.email }}</strong>
          </p>
        </div>

        <!-- Actions -->
        <div class="mt-6 flex flex-col sm:flex-row gap-3">
          <button
            @click="downloadTicket"
            class="flex-1 flex items-center justify-center px-4 py-3 bg-indigo-600 text-white font-medium rounded-lg hover:bg-indigo-700"
          >
            <svg class="w-5 h-5 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 10v6m0 0l-3-3m3 3l3-3m2 8H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
            </svg>
            Descargar comprobante
          </button>
          <button
            @click="$router.push('/')"
            class="flex-1 px-4 py-3 border border-gray-300 text-gray-700 font-medium rounded-lg hover:bg-gray-50"
          >
            Comprar otro pasaje
          </button>
        </div>
      </div>
    </div>

    <!-- Error -->
    <div v-else-if="error" class="text-center py-12">
      <p class="text-red-600">{{ error }}</p>
      <button @click="$router.push('/')" class="mt-4 text-indigo-600">Volver al inicio</button>
    </div>
  </div>
</template>

<script setup>
import { computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
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
  // In a real app, this would generate and download a PDF
  alert('En una implementación real, aquí se descargaría el PDF del pasaje.\n\nCódigo: ' + reservation.value.locator_code)
}
</script>
