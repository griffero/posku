<template>
  <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
    <!-- Loading -->
    <div v-if="loading && !reservation" class="text-center py-12">
      <svg class="animate-spin h-10 w-10 text-indigo-600 mx-auto" fill="none" viewBox="0 0 24 24">
        <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
        <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z"></path>
      </svg>
    </div>

    <div v-else-if="reservation">
      <!-- Timer Warning -->
      <div v-if="reservation.status === 'held'" class="bg-yellow-50 border-l-4 border-yellow-400 p-4 mb-6">
        <div class="flex items-center">
          <svg class="h-5 w-5 text-yellow-400 mr-2" viewBox="0 0 20 20" fill="currentColor">
            <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm1-12a1 1 0 10-2 0v4a1 1 0 00.293.707l2.828 2.829a1 1 0 101.415-1.415L11 9.586V6z" clip-rule="evenodd" />
          </svg>
          <p class="text-yellow-700">
            <span class="font-medium">Tu reserva expira en {{ formatTimeRemaining(timeRemaining) }}</span>
            <span class="text-sm ml-2">Completa tu compra antes de que se liberen los asientos.</span>
          </p>
        </div>
      </div>

      <!-- Steps -->
      <div class="mb-8">
        <div class="flex items-center justify-center space-x-4">
          <div class="flex items-center">
            <span class="flex items-center justify-center w-8 h-8 bg-indigo-600 text-white rounded-full text-sm font-medium">1</span>
            <span class="ml-2 text-sm font-medium text-gray-900">Pasajeros</span>
          </div>
          <div class="w-12 h-0.5 bg-gray-300"></div>
          <div class="flex items-center">
            <span :class="[step >= 2 ? 'bg-indigo-600 text-white' : 'bg-gray-300 text-gray-600', 'flex items-center justify-center w-8 h-8 rounded-full text-sm font-medium']">2</span>
            <span class="ml-2 text-sm font-medium text-gray-600">Contacto</span>
          </div>
          <div class="w-12 h-0.5 bg-gray-300"></div>
          <div class="flex items-center">
            <span :class="[step >= 3 ? 'bg-indigo-600 text-white' : 'bg-gray-300 text-gray-600', 'flex items-center justify-center w-8 h-8 rounded-full text-sm font-medium']">3</span>
            <span class="ml-2 text-sm font-medium text-gray-600">Pago</span>
          </div>
        </div>
      </div>

      <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
        <!-- Form -->
        <div class="lg:col-span-2">
          <!-- Step 1: Passengers -->
          <div v-if="step === 1" class="bg-white rounded-lg shadow-md p-6">
            <h2 class="text-xl font-bold text-gray-900 mb-6">Datos de los pasajeros</h2>
            
            <div v-for="(passenger, index) in passengers" :key="index" class="mb-6 p-4 bg-gray-50 rounded-lg">
              <h3 class="font-medium text-gray-900 mb-4">
                Pasajero {{ index + 1 }} - Asiento {{ reservation.seats[index]?.seat_number }}
              </h3>
              
              <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-1">Nombre</label>
                  <input
                    v-model="passenger.first_name"
                    type="text"
                    class="w-full rounded-lg border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
                    placeholder="Juan"
                    required
                  />
                </div>
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-1">Apellido</label>
                  <input
                    v-model="passenger.last_name"
                    type="text"
                    class="w-full rounded-lg border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
                    placeholder="Pérez"
                    required
                  />
                </div>
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-1">Tipo de documento</label>
                  <select
                    v-model="passenger.document_type"
                    class="w-full rounded-lg border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
                  >
                    <option value="rut">RUT</option>
                    <option value="passport">Pasaporte</option>
                    <option value="dni">DNI</option>
                  </select>
                </div>
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-1">Número de documento</label>
                  <input
                    v-model="passenger.document_number"
                    type="text"
                    class="w-full rounded-lg border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
                    :placeholder="passenger.document_type === 'rut' ? '12345678-9' : 'AB123456'"
                    required
                  />
                </div>
              </div>
            </div>

            <div class="flex justify-end">
              <button
                @click="nextStep"
                :disabled="!isStep1Valid"
                class="px-6 py-2 bg-indigo-600 text-white font-medium rounded-lg hover:bg-indigo-700 disabled:bg-gray-300 disabled:cursor-not-allowed"
              >
                Continuar
              </button>
            </div>
          </div>

          <!-- Step 2: Contact -->
          <div v-if="step === 2" class="bg-white rounded-lg shadow-md p-6">
            <h2 class="text-xl font-bold text-gray-900 mb-6">Datos de contacto</h2>
            
            <div class="space-y-4">
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">Email</label>
                <input
                  v-model="contact.email"
                  type="email"
                  class="w-full rounded-lg border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
                  placeholder="tu@email.com"
                  required
                />
                <p class="mt-1 text-sm text-gray-500">Recibirás la confirmación en este correo</p>
              </div>
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">Teléfono</label>
                <input
                  v-model="contact.phone"
                  type="tel"
                  class="w-full rounded-lg border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
                  placeholder="+56 9 1234 5678"
                  required
                />
              </div>
            </div>

            <div class="mt-6 p-4 bg-gray-50 rounded-lg">
              <label class="flex items-start">
                <input
                  v-model="acceptTerms"
                  type="checkbox"
                  class="mt-1 h-4 w-4 rounded border-gray-300 text-indigo-600 focus:ring-indigo-500"
                />
                <span class="ml-2 text-sm text-gray-600">
                  Acepto los <a href="#" class="text-indigo-600 hover:underline">términos y condiciones</a>
                  y la <a href="#" class="text-indigo-600 hover:underline">política de privacidad</a>
                </span>
              </label>
            </div>

            <div class="flex justify-between mt-6">
              <button
                @click="prevStep"
                class="px-6 py-2 text-gray-700 font-medium hover:text-gray-900"
              >
                ← Volver
              </button>
              <button
                @click="proceedToPayment"
                :disabled="!isStep2Valid || processingPayment"
                class="px-6 py-2 bg-indigo-600 text-white font-medium rounded-lg hover:bg-indigo-700 disabled:bg-gray-300 disabled:cursor-not-allowed"
              >
                {{ processingPayment ? 'Procesando...' : 'Ir a pagar' }}
              </button>
            </div>
          </div>
        </div>

        <!-- Summary Sidebar -->
        <div class="lg:col-span-1">
          <div class="bg-white rounded-lg shadow-md p-6 sticky top-4">
            <h3 class="text-lg font-bold text-gray-900 mb-4">Tu viaje</h3>
            
            <!-- Trip Details -->
            <div class="border-b border-gray-200 pb-4 mb-4">
              <p class="font-medium text-gray-900">{{ reservation.trip?.origin }} → {{ reservation.trip?.destination }}</p>
              <p class="text-sm text-gray-500">{{ formatDateTime(reservation.trip?.departure_at) }}</p>
              <p class="text-sm text-gray-500">{{ reservation.trip?.bus_type }}</p>
            </div>

            <!-- Seats -->
            <div class="border-b border-gray-200 pb-4 mb-4">
              <p class="text-sm font-medium text-gray-700 mb-2">Asientos</p>
              <div v-for="seat in reservation.seats" :key="seat.seat_number" class="flex justify-between text-sm">
                <span>{{ seat.seat_number }}</span>
                <span>{{ seat.formatted_price }}</span>
              </div>
            </div>

            <!-- Total -->
            <div class="flex justify-between items-center">
              <span class="text-lg font-medium text-gray-900">Total</span>
              <span class="text-2xl font-bold text-indigo-600">{{ reservation.total?.formatted }}</span>
            </div>

            <!-- Locator -->
            <div class="mt-4 p-3 bg-gray-50 rounded-lg text-center">
              <p class="text-xs text-gray-500">Código de reserva</p>
              <p class="text-lg font-bold text-gray-900">{{ reservation.locator_code }}</p>
            </div>
          </div>
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
import { ref, computed, onMounted, onUnmounted, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useReservationStore } from '../stores/reservation'

const route = useRoute()
const router = useRouter()
const reservationStore = useReservationStore()

const step = ref(1)
const passengers = ref([])
const contact = ref({ email: '', phone: '' })
const acceptTerms = ref(false)
const processingPayment = ref(false)
const timeRemaining = ref(0)
let timerInterval = null

const loading = computed(() => reservationStore.loading)
const error = computed(() => reservationStore.error)
const reservation = computed(() => reservationStore.currentReservation)

const isStep1Valid = computed(() => {
  return passengers.value.every(p => 
    p.first_name && p.last_name && p.document_type && p.document_number
  )
})

const isStep2Valid = computed(() => {
  return contact.value.email && contact.value.phone && acceptTerms.value
})

onMounted(async () => {
  const locator = route.params.locator
  try {
    await reservationStore.loadReservation(locator)
    initializePassengers()
    startTimer()
  } catch (err) {
    console.error(err)
  }
})

onUnmounted(() => {
  if (timerInterval) {
    clearInterval(timerInterval)
  }
})

watch(reservation, () => {
  if (reservation.value && passengers.value.length === 0) {
    initializePassengers()
  }
})

function initializePassengers() {
  if (!reservation.value?.seats) return
  
  passengers.value = reservation.value.seats.map(seat => ({
    first_name: '',
    last_name: '',
    document_type: 'rut',
    document_number: '',
    seat_number: seat.seat_number
  }))

  // Pre-fill if passengers exist
  if (reservation.value.passengers?.length > 0) {
    reservation.value.passengers.forEach((p, i) => {
      if (passengers.value[i]) {
        passengers.value[i] = { ...passengers.value[i], ...p }
      }
    })
  }

  // Pre-fill contact
  if (reservation.value.contact) {
    contact.value.email = reservation.value.contact.email || ''
    contact.value.phone = reservation.value.contact.phone || ''
  }
}

function startTimer() {
  updateTimeRemaining()
  timerInterval = setInterval(updateTimeRemaining, 1000)
}

function updateTimeRemaining() {
  if (!reservation.value?.hold_expires_at) {
    timeRemaining.value = 0
    return
  }
  const expires = new Date(reservation.value.hold_expires_at)
  const now = new Date()
  timeRemaining.value = Math.max(0, Math.floor((expires - now) / 1000))
  
  if (timeRemaining.value <= 0 && reservation.value.status === 'held') {
    router.push('/')
  }
}

function formatTimeRemaining(seconds) {
  const mins = Math.floor(seconds / 60)
  const secs = seconds % 60
  return `${mins}:${secs.toString().padStart(2, '0')}`
}

function formatDateTime(dateStr) {
  if (!dateStr) return ''
  const date = new Date(dateStr)
  return date.toLocaleDateString('es-CL', { 
    weekday: 'long', 
    day: 'numeric', 
    month: 'long',
    hour: '2-digit',
    minute: '2-digit'
  })
}

function nextStep() {
  step.value++
}

function prevStep() {
  step.value--
}

async function proceedToPayment() {
  if (!isStep2Valid.value) return

  processingPayment.value = true
  try {
    // Update reservation with passengers and contact
    await reservationStore.updateReservation(reservation.value.locator_code, {
      passengers: passengers.value,
      contact_email: contact.value.email,
      contact_phone: contact.value.phone
    })

    // Create payment intent
    await reservationStore.checkout(reservation.value.locator_code)

    // Go to payment page
    router.push({ name: 'payment', params: { locator: reservation.value.locator_code } })
  } catch (err) {
    console.error('Error proceeding to payment:', err)
  } finally {
    processingPayment.value = false
  }
}
</script>
