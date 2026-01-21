<template>
  <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
    <!-- Loading -->
    <div v-if="loading" class="text-center py-12">
      <svg class="animate-spin h-10 w-10 text-indigo-600 mx-auto" fill="none" viewBox="0 0 24 24">
        <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
        <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z"></path>
      </svg>
    </div>

    <div v-else-if="trip && seatData" class="grid grid-cols-1 lg:grid-cols-3 gap-8">
      <!-- Seat Map -->
      <div class="lg:col-span-2">
        <div class="bg-white rounded-lg shadow-md p-6">
          <h2 class="text-xl font-bold text-gray-900 mb-4">Selecciona tus asientos</h2>
          
          <!-- Trip Info -->
          <div class="bg-gray-50 rounded-lg p-4 mb-6">
            <div class="flex justify-between items-center">
              <div>
                <p class="font-medium text-gray-900">
                  {{ trip.route.origin.city }} → {{ trip.route.destination.city }}
                </p>
                <p class="text-sm text-gray-500">
                  {{ formatDateTime(trip.departure_at) }} · {{ seatData.bus_type_label }}
                </p>
              </div>
              <span class="text-sm text-gray-500">{{ seatData.available_seats }} asientos disponibles</span>
            </div>
          </div>

          <!-- Legend -->
          <div class="flex flex-wrap gap-4 mb-6">
            <div class="flex items-center">
              <div class="w-6 h-6 bg-green-500 rounded mr-2"></div>
              <span class="text-sm text-gray-600">Disponible</span>
            </div>
            <div class="flex items-center">
              <div class="w-6 h-6 bg-gray-400 rounded mr-2"></div>
              <span class="text-sm text-gray-600">Ocupado</span>
            </div>
            <div class="flex items-center">
              <div class="w-6 h-6 bg-indigo-600 rounded mr-2"></div>
              <span class="text-sm text-gray-600">Seleccionado</span>
            </div>
          </div>

          <!-- Seat Map by Floor -->
          <div v-for="floor in seatData.layout.floors" :key="floor.floor" class="mb-8">
            <h3 class="text-sm font-medium text-gray-700 mb-3">
              Piso {{ floor.floor }} {{ floor.floor === 2 ? '(Superior)' : '(Inferior)' }}
            </h3>
            
            <!-- Bus visualization -->
            <div class="bg-gray-100 rounded-lg p-4">
              <!-- Driver area -->
              <div class="flex justify-center mb-4">
                <div class="bg-gray-300 rounded px-4 py-1 text-xs text-gray-600">Conductor</div>
              </div>
              
              <!-- Seats Grid -->
              <div class="space-y-2">
                <div v-for="row in floor.rows" :key="row.row" class="flex justify-center gap-1">
                  <template v-for="(seatDef, colIdx) in row.seats" :key="colIdx">
                    <div v-if="seatDef === null" class="w-10 h-10"></div>
                    <button
                      v-else
                      @click="toggleSeat(getSeatNumber(floor.floor, row.row, seatDef.col))"
                      :disabled="!isSeatAvailable(getSeatNumber(floor.floor, row.row, seatDef.col))"
                      :class="getSeatClass(getSeatNumber(floor.floor, row.row, seatDef.col))"
                      class="w-10 h-10 rounded-lg text-xs font-medium transition-all transform hover:scale-105 disabled:cursor-not-allowed disabled:hover:scale-100"
                      :title="getSeatTooltip(getSeatNumber(floor.floor, row.row, seatDef.col))"
                    >
                      {{ row.row }}{{ seatDef.col }}
                    </button>
                  </template>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Summary Sidebar -->
      <div class="lg:col-span-1">
        <div class="bg-white rounded-lg shadow-md p-6 sticky top-4">
          <h3 class="text-lg font-bold text-gray-900 mb-4">Resumen</h3>

          <!-- Selected Seats -->
          <div v-if="selectedSeats.length > 0" class="space-y-3 mb-6">
            <div 
              v-for="seat in selectedSeatsInfo" 
              :key="seat.seat_number"
              class="flex justify-between items-center p-3 bg-gray-50 rounded-lg"
            >
              <div>
                <p class="font-medium text-gray-900">Asiento {{ seat.seat_number }}</p>
                <p class="text-sm text-gray-500">{{ seat.seat_class_label }}</p>
              </div>
              <div class="text-right">
                <p class="font-medium text-gray-900">{{ formatPrice(seat.price_cents) }}</p>
                <button 
                  @click="toggleSeat(seat.seat_number)"
                  class="text-xs text-red-600 hover:text-red-800"
                >
                  Quitar
                </button>
              </div>
            </div>
          </div>

          <div v-else class="text-center py-8 text-gray-500">
            <p>Selecciona al menos un asiento para continuar</p>
          </div>

          <!-- Total -->
          <div class="border-t border-gray-200 pt-4 mb-6">
            <div class="flex justify-between items-center">
              <span class="text-lg font-medium text-gray-900">Total</span>
              <span class="text-2xl font-bold text-indigo-600">{{ formattedTotal }}</span>
            </div>
          </div>

          <!-- Continue Button -->
          <button
            @click="handleContinue"
            :disabled="selectedSeats.length === 0 || processingReservation"
            class="w-full py-3 px-4 bg-indigo-600 text-white font-medium rounded-lg hover:bg-indigo-700 disabled:bg-gray-300 disabled:cursor-not-allowed transition-colors"
          >
            <span v-if="processingReservation">Procesando...</span>
            <span v-else>Continuar ({{ selectedSeats.length }} {{ selectedSeats.length === 1 ? 'asiento' : 'asientos' }})</span>
          </button>

          <button
            @click="$router.back()"
            class="w-full mt-3 py-2 px-4 text-gray-700 font-medium hover:text-gray-900"
          >
            ← Volver a resultados
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
  if (!isSeatAvailable(seatNumber)) {
    return 'bg-gray-400 text-gray-600'
  }
  if (isSelected(seatNumber)) {
    return 'bg-indigo-600 text-white shadow-lg'
  }
  return 'bg-green-500 text-white hover:bg-green-600'
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
