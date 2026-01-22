<template>
  <div class="min-h-screen bg-gray-50">
    <!-- Loading -->
    <div v-if="loading && !reservation" class="flex flex-col items-center justify-center py-20">
      <div class="relative">
        <div class="w-16 h-16 border-4 border-indigo-200 rounded-full"></div>
        <div class="absolute top-0 left-0 w-16 h-16 border-4 border-indigo-600 rounded-full animate-spin border-t-transparent"></div>
      </div>
    </div>

    <div v-else-if="reservation" class="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
      <!-- Timer Warning -->
      <div v-if="reservation.status === 'held'" class="mb-6">
        <div class="bg-gradient-to-r from-amber-50 to-orange-50 border border-amber-200 rounded-xl p-4 flex items-center gap-4">
          <div class="w-12 h-12 bg-amber-100 rounded-full flex items-center justify-center flex-shrink-0">
            <svg class="w-6 h-6 text-amber-600" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
          </div>
          <div class="flex-1">
            <p class="font-semibold text-amber-800">Tu reserva expira en {{ formatTimeRemaining(timeRemaining) }}</p>
            <p class="text-sm text-amber-700">Completa tu compra antes de que se liberen los asientos</p>
          </div>
          <div class="text-3xl font-mono font-bold text-amber-600">
            {{ formatTimeRemaining(timeRemaining) }}
          </div>
        </div>
      </div>

      <!-- Progress Steps -->
      <div class="mb-8">
        <div class="flex items-center justify-center">
          <div class="flex items-center">
            <div :class="[step >= 1 ? 'bg-indigo-600' : 'bg-gray-300', 'w-10 h-10 rounded-full flex items-center justify-center text-white font-semibold']">
              <svg v-if="step > 1" class="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
              </svg>
              <span v-else>1</span>
            </div>
            <span class="ml-3 text-sm font-medium" :class="step >= 1 ? 'text-indigo-600' : 'text-gray-500'">Pasajeros</span>
          </div>
          <div class="w-16 sm:w-24 h-1 mx-4" :class="step >= 2 ? 'bg-indigo-600' : 'bg-gray-200'"></div>
          <div class="flex items-center">
            <div :class="[step >= 2 ? 'bg-indigo-600' : 'bg-gray-300', 'w-10 h-10 rounded-full flex items-center justify-center text-white font-semibold']">
              <svg v-if="step > 2" class="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
              </svg>
              <span v-else>2</span>
            </div>
            <span class="ml-3 text-sm font-medium" :class="step >= 2 ? 'text-indigo-600' : 'text-gray-500'">Contacto</span>
          </div>
          <div class="w-16 sm:w-24 h-1 mx-4" :class="step >= 3 ? 'bg-indigo-600' : 'bg-gray-200'"></div>
          <div class="flex items-center">
            <div :class="[step >= 3 ? 'bg-indigo-600' : 'bg-gray-300', 'w-10 h-10 rounded-full flex items-center justify-center text-white font-semibold']">3</div>
            <span class="ml-3 text-sm font-medium" :class="step >= 3 ? 'text-indigo-600' : 'text-gray-500'">Pago</span>
          </div>
        </div>
      </div>

      <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <!-- Form -->
        <div class="lg:col-span-2">
          <!-- Step 1: Passengers -->
          <div v-if="step === 1" class="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
            <div class="p-4 sm:p-6 border-b border-gray-200">
              <h2 class="text-xl font-bold text-gray-900">Datos de los pasajeros</h2>
              <p class="text-gray-500 mt-1">Ingresa la información de cada pasajero</p>
            </div>
            
            <div class="p-4 sm:p-6 space-y-6">
              <div v-for="(passenger, index) in passengers" :key="index" class="bg-gray-50 rounded-xl p-4 sm:p-6">
                <div class="flex items-center gap-3 mb-4">
                  <div class="w-10 h-10 bg-indigo-600 rounded-lg flex items-center justify-center">
                    <span class="text-white font-bold">{{ reservation.seats[index]?.seat_number }}</span>
                  </div>
                  <div>
                    <h3 class="font-semibold text-gray-900">Pasajero {{ index + 1 }}</h3>
                    <p class="text-sm text-gray-500">Asiento {{ reservation.seats[index]?.seat_number }}</p>
                  </div>
                </div>
                
                <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                  <div>
                    <label class="block text-sm font-medium text-gray-700 mb-2">Nombre</label>
                    <input
                      v-model="passenger.first_name"
                      type="text"
                      class="w-full h-12 px-4 rounded-xl border-2 border-gray-200 focus:border-indigo-500 focus:ring-4 focus:ring-indigo-500/10 transition-all"
                      placeholder="Ej: Juan"
                      required
                    />
                  </div>
                  <div>
                    <label class="block text-sm font-medium text-gray-700 mb-2">Apellido</label>
                    <input
                      v-model="passenger.last_name"
                      type="text"
                      class="w-full h-12 px-4 rounded-xl border-2 border-gray-200 focus:border-indigo-500 focus:ring-4 focus:ring-indigo-500/10 transition-all"
                      placeholder="Ej: Pérez"
                      required
                    />
                  </div>
                  <div>
                    <label class="block text-sm font-medium text-gray-700 mb-2">Tipo de documento</label>
                    <select
                      v-model="passenger.document_type"
                      class="w-full h-12 px-4 rounded-xl border-2 border-gray-200 focus:border-indigo-500 focus:ring-4 focus:ring-indigo-500/10 transition-all"
                    >
                      <option value="rut">RUT</option>
                      <option value="passport">Pasaporte</option>
                      <option value="dni">DNI</option>
                    </select>
                  </div>
                  <div>
                    <label class="block text-sm font-medium text-gray-700 mb-2">Número de documento</label>
                    <input
                      v-model="passenger.document_number"
                      type="text"
                      class="w-full h-12 px-4 rounded-xl border-2 border-gray-200 focus:border-indigo-500 focus:ring-4 focus:ring-indigo-500/10 transition-all"
                      :placeholder="passenger.document_type === 'rut' ? '12.345.678-9' : 'AB123456'"
                      required
                    />
                  </div>
                </div>
              </div>
            </div>

            <div class="p-4 sm:p-6 bg-gray-50 border-t border-gray-200 flex justify-end">
              <button
                @click="nextStep"
                :disabled="!isStep1Valid"
                class="px-8 py-3 bg-indigo-600 text-white font-semibold rounded-xl hover:bg-indigo-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
              >
                Continuar
              </button>
            </div>
          </div>

          <!-- Step 2: Contact -->
          <div v-if="step === 2" class="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
            <div class="p-4 sm:p-6 border-b border-gray-200">
              <h2 class="text-xl font-bold text-gray-900">Datos de contacto</h2>
              <p class="text-gray-500 mt-1">Te enviaremos la confirmación a este correo</p>
            </div>
            
            <div class="p-4 sm:p-6 space-y-4">
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">Correo electrónico</label>
                <input
                  v-model="contact.email"
                  type="email"
                  class="w-full h-12 px-4 rounded-xl border-2 border-gray-200 focus:border-indigo-500 focus:ring-4 focus:ring-indigo-500/10 transition-all"
                  placeholder="tu@email.com"
                  required
                />
              </div>
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">Teléfono</label>
                <input
                  v-model="contact.phone"
                  type="tel"
                  class="w-full h-12 px-4 rounded-xl border-2 border-gray-200 focus:border-indigo-500 focus:ring-4 focus:ring-indigo-500/10 transition-all"
                  placeholder="+56 9 1234 5678"
                  required
                />
              </div>

              <div class="mt-6 p-4 bg-gray-50 rounded-xl">
                <label class="flex items-start gap-3 cursor-pointer">
                  <input
                    v-model="acceptTerms"
                    type="checkbox"
                    class="mt-1 w-5 h-5 rounded border-gray-300 text-indigo-600 focus:ring-indigo-500"
                  />
                  <span class="text-sm text-gray-600">
                    Acepto los <a href="#" class="text-indigo-600 hover:underline font-medium">términos y condiciones</a>
                    y la <a href="#" class="text-indigo-600 hover:underline font-medium">política de privacidad</a>
                  </span>
                </label>
              </div>
            </div>

            <div class="p-4 sm:p-6 bg-gray-50 border-t border-gray-200 flex justify-between">
              <button
                @click="prevStep"
                class="px-6 py-3 text-gray-700 font-medium hover:text-gray-900 transition-colors"
              >
                ← Volver
              </button>
              <button
                @click="proceedToPayment"
                :disabled="!isStep2Valid || processingPayment"
                class="px-8 py-3 bg-gradient-to-r from-indigo-600 to-purple-600 text-white font-semibold rounded-xl shadow-lg shadow-indigo-500/30 hover:shadow-xl hover:from-indigo-700 hover:to-purple-700 disabled:opacity-50 disabled:cursor-not-allowed disabled:shadow-none transition-all flex items-center gap-2"
              >
                <svg v-if="processingPayment" class="animate-spin h-5 w-5" fill="none" viewBox="0 0 24 24">
                  <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                  <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z"></path>
                </svg>
                {{ processingPayment ? 'Procesando...' : 'Ir a pagar' }}
              </button>
            </div>
          </div>
        </div>

        <!-- Summary Sidebar -->
        <div class="lg:col-span-1">
          <div class="bg-white rounded-xl shadow-sm border border-gray-200 sticky top-4">
            <div class="p-4 sm:p-6 border-b border-gray-200">
              <h3 class="text-lg font-bold text-gray-900">Resumen del viaje</h3>
            </div>
            
            <div class="p-4 sm:p-6">
              <!-- Trip Details -->
              <div class="flex items-center gap-3 mb-4">
                <div class="w-10 h-10 bg-indigo-100 rounded-lg flex items-center justify-center">
                  <svg class="w-5 h-5 text-indigo-600" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7h12m0 0l-4-4m4 4l-4 4m0 6H4m0 0l4 4m-4-4l4-4" />
                  </svg>
                </div>
                <div>
                  <p class="font-semibold text-gray-900">{{ reservation.trip?.origin }} → {{ reservation.trip?.destination }}</p>
                  <p class="text-sm text-gray-500">{{ formatDateTime(reservation.trip?.departure_at) }}</p>
                </div>
              </div>

              <div class="flex items-center gap-2 text-sm text-gray-500 mb-6">
                <span class="px-2 py-1 bg-gray-100 rounded">{{ reservation.trip?.bus_type }}</span>
                <span>•</span>
                <span>{{ reservation.trip?.duration }}</span>
              </div>

              <!-- Seats -->
              <div class="border-t border-gray-200 pt-4 mb-4">
                <p class="text-sm font-medium text-gray-700 mb-3">Asientos seleccionados</p>
                <div class="space-y-2">
                  <div v-for="seat in reservation.seats" :key="seat.seat_number" class="flex justify-between text-sm">
                    <span class="text-gray-600">Asiento {{ seat.seat_number }}</span>
                    <span class="font-medium text-gray-900">{{ seat.formatted_price }}</span>
                  </div>
                </div>
              </div>

              <!-- Total -->
              <div class="border-t border-gray-200 pt-4">
                <div class="flex justify-between items-center">
                  <span class="text-lg font-medium text-gray-900">Total</span>
                  <span class="text-2xl font-bold text-indigo-600">{{ reservation.total?.formatted }}</span>
                </div>
              </div>

              <!-- Locator -->
              <div class="mt-6 p-4 bg-indigo-50 rounded-xl text-center">
                <p class="text-xs text-indigo-600 uppercase tracking-wide font-medium">Código de reserva</p>
                <p class="text-2xl font-mono font-bold text-indigo-900 mt-1">{{ reservation.locator_code }}</p>
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
      <h3 class="text-xl font-semibold text-gray-900 mb-2">Error</h3>
      <p class="text-gray-600 mb-6">{{ error }}</p>
      <button @click="$router.push('/')" class="px-6 py-3 bg-indigo-600 text-white font-medium rounded-xl hover:bg-indigo-700 transition-colors">
        Volver al inicio
      </button>
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

  if (reservation.value.passengers?.length > 0) {
    reservation.value.passengers.forEach((p, i) => {
      if (passengers.value[i]) {
        passengers.value[i] = { ...passengers.value[i], ...p }
      }
    })
  }

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
    await reservationStore.updateReservation(reservation.value.locator_code, {
      passengers: passengers.value,
      contact_email: contact.value.email,
      contact_phone: contact.value.phone
    })

    await reservationStore.checkout(reservation.value.locator_code)

    router.push({ name: 'payment', params: { locator: reservation.value.locator_code } })
  } catch (err) {
    console.error('Error proceeding to payment:', err)
  } finally {
    processingPayment.value = false
  }
}
</script>
