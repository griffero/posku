<template>
  <div class="max-w-2xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
    <div class="bg-white rounded-lg shadow-md p-8">
      <!-- Header -->
      <div class="text-center mb-8">
        <h1 class="text-2xl font-bold text-gray-900">Confirma tu pago</h1>
        <p class="text-gray-600 mt-2">Código de reserva: <span class="font-mono font-bold">{{ locator }}</span></p>
      </div>

      <!-- Loading Payment Intent -->
      <div v-if="loading && !paymentIntent" class="text-center py-8">
        <svg class="animate-spin h-10 w-10 text-indigo-600 mx-auto" fill="none" viewBox="0 0 24 24">
          <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
          <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z"></path>
        </svg>
        <p class="mt-4 text-gray-600">Preparando pago...</p>
      </div>

      <!-- Payment Status -->
      <div v-else-if="paymentIntent">
        <!-- Pending Payment -->
        <div v-if="paymentIntent.status === 'created' || paymentIntent.status === 'pending'" class="text-center">
          <div class="w-20 h-20 bg-indigo-100 rounded-full flex items-center justify-center mx-auto mb-6">
            <svg class="w-10 h-10 text-indigo-600" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
          </div>

          <p class="text-xl font-medium text-gray-900 mb-2">Monto a pagar</p>
          <p class="text-4xl font-bold text-indigo-600 mb-6">{{ paymentIntent.amount }}</p>

          <!-- Mock Fintoc Payment -->
          <div class="bg-gray-50 rounded-lg p-6 mb-6">
            <p class="text-sm text-gray-600 mb-4">
              Este es un pago de prueba. En producción, aquí se mostraría el widget de Fintoc.
            </p>
            
            <div class="space-y-3">
              <button
                @click="simulatePayment('succeeded')"
                :disabled="processing"
                class="w-full py-3 px-4 bg-green-600 text-white font-medium rounded-lg hover:bg-green-700 disabled:bg-gray-300"
              >
                {{ processing ? 'Procesando...' : 'Simular Pago Exitoso' }}
              </button>
              <button
                @click="simulatePayment('failed')"
                :disabled="processing"
                class="w-full py-3 px-4 bg-red-600 text-white font-medium rounded-lg hover:bg-red-700 disabled:bg-gray-300"
              >
                Simular Pago Fallido
              </button>
            </div>
          </div>

          <!-- Expiration -->
          <p class="text-sm text-gray-500">
            Este pago expira en {{ formatExpiration(paymentIntent.expires_at) }}
          </p>
        </div>

        <!-- Payment Succeeded -->
        <div v-else-if="paymentIntent.status === 'succeeded'" class="text-center">
          <div class="w-20 h-20 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-6">
            <svg class="w-10 h-10 text-green-600" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
            </svg>
          </div>
          <h2 class="text-2xl font-bold text-green-600 mb-2">¡Pago confirmado!</h2>
          <p class="text-gray-600 mb-6">Tu compra ha sido procesada exitosamente.</p>
          
          <button
            @click="goToConfirmation"
            class="px-8 py-3 bg-indigo-600 text-white font-medium rounded-lg hover:bg-indigo-700"
          >
            Ver mi pasaje
          </button>
        </div>

        <!-- Payment Failed -->
        <div v-else-if="paymentIntent.status === 'failed'" class="text-center">
          <div class="w-20 h-20 bg-red-100 rounded-full flex items-center justify-center mx-auto mb-6">
            <svg class="w-10 h-10 text-red-600" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
            </svg>
          </div>
          <h2 class="text-2xl font-bold text-red-600 mb-2">Pago fallido</h2>
          <p class="text-gray-600 mb-6">No pudimos procesar tu pago. Por favor, intenta de nuevo.</p>
          
          <button
            @click="$router.push({ name: 'checkout', params: { locator } })"
            class="px-8 py-3 bg-indigo-600 text-white font-medium rounded-lg hover:bg-indigo-700"
          >
            Intentar de nuevo
          </button>
        </div>

        <!-- Payment Expired -->
        <div v-else-if="paymentIntent.status === 'expired'" class="text-center">
          <div class="w-20 h-20 bg-yellow-100 rounded-full flex items-center justify-center mx-auto mb-6">
            <svg class="w-10 h-10 text-yellow-600" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
          </div>
          <h2 class="text-2xl font-bold text-yellow-600 mb-2">Pago expirado</h2>
          <p class="text-gray-600 mb-6">El tiempo para completar el pago ha expirado.</p>
          
          <button
            @click="$router.push('/')"
            class="px-8 py-3 bg-indigo-600 text-white font-medium rounded-lg hover:bg-indigo-700"
          >
            Volver al inicio
          </button>
        </div>
      </div>

      <!-- Error -->
      <div v-else-if="error" class="text-center py-8">
        <p class="text-red-600">{{ error }}</p>
        <button @click="$router.push('/')" class="mt-4 text-indigo-600">Volver al inicio</button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useReservationStore } from '../stores/reservation'

const route = useRoute()
const router = useRouter()
const reservationStore = useReservationStore()

const processing = ref(false)
let pollInterval = null

const locator = computed(() => route.params.locator)
const loading = computed(() => reservationStore.loading)
const error = computed(() => reservationStore.error)
const paymentIntent = computed(() => reservationStore.paymentIntent)

onMounted(async () => {
  // Load reservation to get payment intent
  const reservation = await reservationStore.loadReservation(locator.value)
  
  // If reservation has payment_intent, set it in the store
  if (reservation?.payment_intent) {
    reservationStore.paymentIntent = reservation.payment_intent
  }
  
  // Poll for payment status changes
  if (paymentIntent.value && ['created', 'pending'].includes(paymentIntent.value.status)) {
    pollInterval = setInterval(async () => {
      await reservationStore.checkPaymentStatus(paymentIntent.value.id)
      if (paymentIntent.value.status === 'succeeded') {
        clearInterval(pollInterval)
      }
    }, 3000)
  }
})

onUnmounted(() => {
  if (pollInterval) {
    clearInterval(pollInterval)
  }
})

function formatExpiration(dateStr) {
  if (!dateStr) return ''
  const expires = new Date(dateStr)
  const now = new Date()
  const diff = Math.max(0, Math.floor((expires - now) / 1000))
  const mins = Math.floor(diff / 60)
  const secs = diff % 60
  return `${mins}:${secs.toString().padStart(2, '0')}`
}

async function simulatePayment(eventType) {
  processing.value = true
  try {
    await reservationStore.simulatePayment(paymentIntent.value.id, eventType)
    
    if (eventType === 'succeeded') {
      // Redirect to confirmation after short delay
      setTimeout(() => {
        router.push({ name: 'confirmation', params: { locator: locator.value } })
      }, 1500)
    }
  } catch (err) {
    console.error('Error simulating payment:', err)
  } finally {
    processing.value = false
  }
}

function goToConfirmation() {
  router.push({ name: 'confirmation', params: { locator: locator.value } })
}
</script>
