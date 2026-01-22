<template>
  <div class="min-h-screen bg-gray-50">
    <!-- Loading -->
    <div v-if="loading" class="flex flex-col items-center justify-center py-20">
      <div class="relative">
        <div class="w-16 h-16 border-4 border-indigo-200 rounded-full"></div>
        <div class="absolute top-0 left-0 w-16 h-16 border-4 border-indigo-600 rounded-full animate-spin border-t-transparent"></div>
      </div>
      <p class="mt-6 text-lg text-gray-600">Cargando mapa de asientos...</p>
    </div>

    <div v-else-if="trip && seatData" class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
      <!-- Back Button & Trip Info Header -->
      <div class="mb-6">
        <button @click="$router.back()" class="inline-flex items-center gap-2 text-gray-600 hover:text-gray-900 mb-4">
          <svg class="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18" />
          </svg>
          Volver a resultados
        </button>
        
        <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-4 sm:p-6">
          <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
            <div>
              <div class="flex items-center gap-3">
                <span class="text-xl font-bold text-gray-900">{{ trip.route.origin.city }}</span>
                <svg class="w-5 h-5 text-indigo-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 8l4 4m0 0l-4 4m4-4H3" />
                </svg>
                <span class="text-xl font-bold text-gray-900">{{ trip.route.destination.city }}</span>
              </div>
              <p class="text-gray-500 mt-1">{{ formatDateTime(trip.departure_at) }}</p>
            </div>
            <div class="flex items-center gap-4">
              <span :class="getBusTypeClass(seatData.bus_type)" class="px-3 py-1.5 rounded-lg text-sm font-semibold">
                {{ seatData.bus_type_label }}
              </span>
              <span class="text-sm text-gray-500">
                {{ seatData.available_seats }} asientos disponibles
              </span>
            </div>
          </div>
        </div>
      </div>

      <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <!-- Seat Map -->
        <div class="lg:col-span-2">
          <div class="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
            <div class="p-4 sm:p-6 border-b border-gray-200">
              <h2 class="text-lg font-bold text-gray-900">Selecciona tus asientos</h2>
              
              <!-- Legend -->
              <div class="flex flex-wrap gap-4 mt-4">
                <div class="flex items-center gap-2">
                  <div class="w-8 h-8 bg-emerald-500 rounded-lg"></div>
                  <span class="text-sm text-gray-600">Disponible</span>
                </div>
                <div class="flex items-center gap-2">
                  <div class="w-8 h-8 bg-indigo-600 rounded-lg ring-2 ring-indigo-300 ring-offset-2"></div>
                  <span class="text-sm text-gray-600">Seleccionado</span>
                </div>
                <div class="flex items-center gap-2">
                  <div class="w-8 h-8 bg-gray-300 rounded-lg"></div>
                  <span class="text-sm text-gray-600">Ocupado</span>
                </div>
              </div>
            </div>
            
            <!-- Bus Visualization -->
            <div class="p-4 sm:p-6 bg-gray-50">
              <div v-for="floor in seatData.layout.floors" :key="floor.floor" class="mb-8 last:mb-0">
                <div class="flex items-center gap-2 mb-4">
                  <span class="text-sm font-semibold text-gray-700 bg-white px-3 py-1 rounded-full border border-gray-200">
                    {{ floor.floor === 1 ? 'Piso Inferior' : 'Piso Superior' }}
                  </span>
                </div>
                
                <!-- Bus Frame -->
                <div class="bg-white rounded-2xl border-2 border-gray-300 p-4 max-w-md mx-auto">
                  <!-- Driver Area -->
                  <div class="flex justify-center mb-6">
                    <div class="flex items-center gap-2 bg-gray-100 px-4 py-2 rounded-lg">
                      <svg class="w-5 h-5 text-gray-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5.121 17.804A13.937 13.937 0 0112 16c2.5 0 4.847.655 6.879 1.804M15 10a3 3 0 11-6 0 3 3 0 016 0zm6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                      </svg>
                      <span class="text-sm font-medium text-gray-600">Conductor</span>
                    </div>
                  </div>
                  
                  <!-- Seats Grid -->
                  <div class="space-y-2">
                    <div v-for="row in floor.rows" :key="row.row" class="flex justify-center items-center gap-1.5">
                      <template v-for="(seatDef, colIdx) in row.seats" :key="colIdx">
                        <!-- Aisle Space -->
                        <div v-if="seatDef === null" class="w-10 h-10 sm:w-12 sm:h-12"></div>
                        
                        <!-- Seat Button -->
                        <button
                          v-else
                          @click="toggleSeat(getSeatNumber(floor.floor, row.row, seatDef.col))"
                          :disabled="!isSeatAvailable(getSeatNumber(floor.floor, row.row, seatDef.col))"
                          :class="getSeatClass(getSeatNumber(floor.floor, row.row, seatDef.col))"
                          class="w-10 h-10 sm:w-12 sm:h-12 rounded-lg text-xs sm:text-sm font-bold transition-all duration-150 focus:outline-none disabled:cursor-not-allowed"
                          :title="getSeatTooltip(getSeatNumber(floor.floor, row.row, seatDef.col))"
                        >
                          {{ row.row }}{{ seatDef.col }}
                        </button>
                      </template>
                    </div>
                  </div>
                  
                  <!-- Back of Bus -->
                  <div class="mt-6 flex justify-center">
                    <div class="h-2 w-32 bg-gray-200 rounded-full"></div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Summary Sidebar -->
        <div class="lg:col-span-1">
          <div class="bg-white rounded-xl shadow-sm border border-gray-200 sticky top-4">
            <div class="p-4 sm:p-6 border-b border-gray-200">
              <h3 class="text-lg font-bold text-gray-900">Tu selección</h3>
            </div>

            <div class="p-4 sm:p-6">
              <!-- Selected Seats -->
              <div v-if="selectedSeats.length > 0" class="space-y-3 mb-6">
                <div 
                  v-for="seat in selectedSeatsInfo" 
                  :key="seat.seat_number"
                  class="flex items-center justify-between p-3 bg-gray-50 rounded-xl"
                >
                  <div class="flex items-center gap-3">
                    <div class="w-10 h-10 bg-indigo-600 rounded-lg flex items-center justify-center">
                      <span class="text-white font-bold text-sm">{{ seat.seat_number }}</span>
                    </div>
                    <div>
                      <p class="font-medium text-gray-900">Asiento {{ seat.seat_number }}</p>
                      <p class="text-sm text-gray-500">{{ seat.seat_class_label }}</p>
                    </div>
                  </div>
                  <div class="text-right">
                    <p class="font-bold text-gray-900">{{ formatPrice(seat.price_cents) }}</p>
                    <button 
                      @click="toggleSeat(seat.seat_number)"
                      class="text-xs text-red-600 hover:text-red-700 font-medium"
                    >
                      Quitar
                    </button>
                  </div>
                </div>
              </div>

              <!-- Empty State -->
              <div v-else class="text-center py-8">
                <div class="w-16 h-16 bg-gray-100 rounded-full flex items-center justify-center mx-auto mb-4">
                  <svg class="w-8 h-8 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M5 3v4M3 5h4M6 17v4m-2-2h4m5-16l2.286 6.857L21 12l-5.714 2.143L13 21l-2.286-6.857L5 12l5.714-2.143L13 3z" />
                  </svg>
                </div>
                <p class="text-gray-500">Selecciona asientos en el mapa</p>
              </div>

              <!-- Total -->
              <div class="border-t border-gray-200 pt-4 mt-4">
                <div class="flex justify-between items-center mb-6">
                  <span class="text-gray-600">Total</span>
                  <span class="text-3xl font-bold text-gray-900">{{ formattedTotal }}</span>
                </div>

                <!-- Continue Button -->
                <button
                  @click="handleContinue"
                  :disabled="selectedSeats.length === 0 || processingReservation"
                  class="w-full py-4 px-6 bg-gradient-to-r from-indigo-600 to-purple-600 text-white font-semibold rounded-xl shadow-lg shadow-indigo-500/30 hover:shadow-xl hover:from-indigo-700 hover:to-purple-700 disabled:opacity-50 disabled:cursor-not-allowed disabled:shadow-none transition-all flex items-center justify-center gap-2"
                >
                  <svg v-if="processingReservation" class="animate-spin h-5 w-5" fill="none" viewBox="0 0 24 24">
                    <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                    <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z"></path>
                  </svg>
                  <span v-if="processingReservation">Reservando...</span>
                  <span v-else>
                    Continuar con {{ selectedSeats.length }} {{ selectedSeats.length === 1 ? 'asiento' : 'asientos' }}
                  </span>
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Error -->
    <div v-else-if="error" class="max-w-lg mx-auto py-20 text-center px-4">
      <div class="w-16 h-16 bg-red-100 rounded-full flex items-center justify-center mx-auto mb-6">
        <svg class="w-8 h-8 text-red-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
        </svg>
      </div>
      <h3 class="text-xl font-semibold text-gray-900 mb-2">Error al cargar</h3>
      <p class="text-gray-600 mb-6">{{ error }}</p>
      <button @click="$router.push('/')" class="px-6 py-3 bg-indigo-600 text-white font-medium rounded-xl hover:bg-indigo-700 transition-colors">
        Volver al inicio
      </button>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useReservationStore } from '../stores/reservation'

const route = useRoute()
const router = useRouter()
const reservationStore = useReservationStore()

const processingReservation = ref(false)

const loading = computed(() => reservationStore.loading)
const error = computed(() => reservationStore.error)
const trip = computed(() => reservationStore.currentTrip)
const seatData = computed(() => reservationStore.seatData)
const selectedSeats = computed(() => reservationStore.selectedSeats)
const selectedSeatsInfo = computed(() => reservationStore.selectedSeatsInfo)
const formattedTotal = computed(() => reservationStore.formattedTotal)

onMounted(() => {
  const tripId = route.params.id
  reservationStore.clearSelectedSeats()
  reservationStore.loadTripSeats(tripId)
})

function getSeatNumber(floor, row, col) {
  return `${floor}-${row}${col}`
}

function isSeatAvailable(seatNumber) {
  const seat = seatData.value?.seats.find(s => s.seat_number === seatNumber)
  return seat?.available
}

function isSelected(seatNumber) {
  return selectedSeats.value.includes(seatNumber)
}

function getSeatClass(seatNumber) {
  const base = 'focus:ring-2 focus:ring-offset-2 '
  if (!isSeatAvailable(seatNumber)) {
    return base + 'bg-gray-300 text-gray-500'
  }
  if (isSelected(seatNumber)) {
    return base + 'bg-indigo-600 text-white ring-2 ring-indigo-300 ring-offset-2 shadow-lg scale-105'
  }
  return base + 'bg-emerald-500 text-white hover:bg-emerald-600 hover:scale-105 focus:ring-emerald-500'
}

function getSeatTooltip(seatNumber) {
  const seat = seatData.value?.seats.find(s => s.seat_number === seatNumber)
  if (!seat) return ''
  if (!seat.available) return 'Asiento ocupado'
  return `${seat.seat_class_label} - ${formatPrice(seat.price_cents)}`
}

function toggleSeat(seatNumber) {
  reservationStore.toggleSeat(seatNumber)
}

function formatPrice(cents) {
  return '$' + cents.toString().replace(/\B(?=(\d{3})+(?!\d))/g, '.')
}

function formatDateTime(dateStr) {
  const date = new Date(dateStr)
  return date.toLocaleDateString('es-CL', { 
    weekday: 'long', 
    day: 'numeric', 
    month: 'long',
    hour: '2-digit',
    minute: '2-digit'
  })
}

function getBusTypeClass(busType) {
  const classes = {
    classic: 'bg-gray-100 text-gray-700',
    semi_cama: 'bg-blue-100 text-blue-700',
    salon_cama: 'bg-purple-100 text-purple-700',
    premium: 'bg-amber-100 text-amber-700'
  }
  return classes[busType] || 'bg-gray-100 text-gray-700'
}

async function handleContinue() {
  if (selectedSeats.value.length === 0) return

  processingReservation.value = true
  try {
    const reservation = await reservationStore.createReservation()
    router.push({ name: 'checkout', params: { locator: reservation.locator_code } })
  } catch (err) {
    console.error('Error creating reservation:', err)
  } finally {
    processingReservation.value = false
  }
}
</script>
