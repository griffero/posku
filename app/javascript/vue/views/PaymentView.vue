<template>
  <div class="min-h-screen bg-gray-50 flex items-center justify-center p-4">
    <div class="w-full max-w-lg">
      <!-- Loading -->
      <div v-if="loading && !paymentIntent" class="text-center py-12">
        <div class="relative inline-block">
          <div class="w-16 h-16 border-4 border-indigo-200 rounded-full"></div>
          <div class="absolute top-0 left-0 w-16 h-16 border-4 border-indigo-600 rounded-full animate-spin border-t-transparent"></div>
        </div>
        <p class="mt-6 text-gray-600">Preparando pago...</p>
      </div>

      <!-- Payment Card -->
      <div v-else-if="paymentIntent" class="bg-white rounded-2xl shadow-xl overflow-hidden">
        <!-- Header -->
        <div class="bg-gradient-to-r from-indigo-600 to-purple-600 px-6 py-8 text-center text-white">
          <p class="text-indigo-200 text-sm uppercase tracking-wide">Código de reserva</p>
          <p class="text-2xl font-mono font-bold mt-1">{{ locator }}</p>
        </div>

        <!-- Pending Payment -->
        <div v-if="['created', 'pending'].includes(paymentIntent.status)" class="p-6 sm:p-8">
          <div class="text-center mb-8">
            <div class="w-20 h-20 bg-indigo-100 rounded-full flex items-center justify-center mx-auto mb-4">
              <svg class="w-10 h-10 text-indigo-600" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 10h18M7 15h1m4 0h1m-7 4h12a3 3 0 003-3V8a3 3 0 00-3-3H6a3 3 0 00-3 3v8a3 3 0 003 3z" />
              </svg>
            </div>
            <p class="text-gray-600 mb-2">Monto a pagar</p>
            <p class="text-5xl font-bold text-gray-900">{{ paymentIntent.amount }}</p>
          </div>

          <!-- Mock Payment Buttons -->
          <div class="bg-gray-50 rounded-xl p-6 mb-6">
            <p class="text-sm text-gray-500 text-center mb-4">
              Simulador de pago (Demo)
            </p>
            
            <div class="space-y-3">
              <button
                @click="simulatePayment('succeeded')"
                :disabled="processing"
                class="w-full py-4 px-6 bg-gradient-to-r from-emerald-500 to-green-600 text-white font-semibold rounded-xl shadow-lg shadow-emerald-500/30 hover:shadow-xl hover:from-emerald-600 hover:to-green-700 disabled:opacity-50 transition-all flex items-center justify-center gap-2"
              >
                <svg v-if="processing" class="animate-spin h-5 w-5" fill="none" viewBox="0 0 24 24">
                  <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                  <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z"></path>
                </svg>
                <svg v-else class="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
                </svg>
                {{ processing ? 'Procesando...' : 'Simular pago exitoso' }}
              </button>
              
              <button
                @click="simulatePayment('failed')"
                :disabled="processing"
                class="w-full py-3 px-6 bg-red-100 text-red-700 font-medium rounded-xl hover:bg-red-200 disabled:opacity-50 transition-colors"
              >
                Simular pago fallido
              </button>
            </div>
          </div>

          <!-- Expiration Timer -->
          <div class="text-center text-sm text-gray-500">
            <svg class="w-4 h-4 inline mr-1" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
            Expira en {{ formatExpiration(paymentIntent.expires_at) }}
          </div>
        </div>

        <!-- Payment Succeeded -->
        <div v-else-if="paymentIntent.status === 'succeeded'" class="p-6 sm:p-8 text-center">
          <div class="w-20 h-20 bg-emerald-100 rounded-full flex items-center justify-center mx-auto mb-6">
            <svg class="w-10 h-10 text-emerald-600" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
          </div>
          <h2 class="text-2xl font-bold text-gray-900 mb-2">¡Pago confirmado!</h2>
          <p class="text-gray-600 mb-8">Tu compra ha sido procesada exitosamente</p>
          
          <button
            @click="goToConfirmation"
            class="w-full py-4 px-6 bg-gradient-to-r from-indigo-600 to-purple-600 text-white font-semibold rounded-xl shadow-lg shadow-indigo-500/30 hover:shadow-xl hover:from-indigo-700 hover:to-purple-700 transition-all"
          >
            Ver mi pasaje
          </button>
        </div>

        <!-- Payment Failed -->
        <div v-else-if="paymentIntent.status === 'failed'" class="p-6 sm:p-8 text-center">
          <div class="w-20 h-20 bg-red-100 rounded-full flex items-center justify-center mx-auto mb-6">
            <svg class="w-10 h-10 text-red-600" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
          </div>
          <h2 class="text-2xl font-bold text-gray-900 mb-2">Pago rechazado</h2>
          <p class="text-gray-600 mb-8">No pudimos procesar tu pago. Intenta nuevamente.</p>
          
          <button
            @click="$router.push({ name: 'checkout', params: { locator } })"
            class="w-full py-4 px-6 bg-indigo-600 text-white font-semibold rounded-xl hover:bg-indigo-700 transition-colors"
          >
            Intentar de nuevo
          </button>
        </div>

        <!-- Payment Expired -->
        <div v-else-if="paymentIntent.status === 'expired'" class="p-6 sm:p-8 text-center">
          <div class="w-20 h-20 bg-amber-100 rounded-full flex items-center justify-center mx-auto mb-6">
            <svg class="w-10 h-10 text-amber-600" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
          </div>
          <h2 class="text-2xl font-bold text-gray-900 mb-2">Tiempo agotado</h2>
          <p class="text-gray-600 mb-8">El tiempo para completar el pago ha expirado</p>
          
          <button
            @click="$router.push('/')"
            class="w-full py-4 px-6 bg-indigo-600 text-white font-semibold rounded-xl hover:bg-indigo-700 transition-colors"
          >
            Volver al inicio
          </button>
        </div>
      </div>

      <!-- Error -->
      <div v-else-if="error" class="bg-white rounded-2xl shadow-xl p-8 text-center">
        <div class="w-16 h-16 bg-red-100 rounded-full flex items-center justify-center mx-auto mb-6">
          <svg class="w-8 h-8 text-red-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
          </svg>
        </div>
        <p class="text-red-600 mb-6">{{ error }}</p>
        <button @click="$router.push('/')" class="text-indigo-600 font-medium hover:underline">
          Volver al inicio
        </button>
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
  const reservation = await reservationStore.loadReservation(locator.value)
  
  if (reservation?.payment_intent) {
    reservationStore.paymentIntent = reservation.payment_intent
  }
  
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
