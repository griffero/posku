import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { tripsApi, reservationsApi, paymentApi } from '../api/client'

export const useReservationStore = defineStore('reservation', () => {
  // State
  const currentTrip = ref(null)
  const seatData = ref(null)
  const selectedSeats = ref([])
  const currentReservation = ref(null)
  const paymentIntent = ref(null)
  const loading = ref(false)
  const error = ref(null)

  // Getters
  const selectedSeatsInfo = computed(() => {
    if (!seatData.value) return []
    return selectedSeats.value.map(seatNumber => 
      seatData.value.seats.find(s => s.seat_number === seatNumber)
    ).filter(Boolean)
  })

  const totalPrice = computed(() => 
    selectedSeatsInfo.value.reduce((sum, seat) => sum + (seat?.price_cents || 0), 0)
  )

  const formattedTotal = computed(() => {
    const cents = totalPrice.value
    return '$' + cents.toString().replace(/\B(?=(\d{3})+(?!\d))/g, '.')
  })

  const holdTimeRemaining = computed(() => {
    if (!currentReservation.value?.hold_expires_at) return 0
    const expires = new Date(currentReservation.value.hold_expires_at)
    const now = new Date()
    return Math.max(0, Math.floor((expires - now) / 1000))
  })

  // Actions
  async function loadTripSeats(tripId) {
    loading.value = true
    error.value = null

    try {
      const [tripResponse, seatsResponse] = await Promise.all([
        tripsApi.getOne(tripId),
        tripsApi.getSeats(tripId)
      ])
      currentTrip.value = tripResponse.data.trip
      seatData.value = seatsResponse.data
    } catch (err) {
      error.value = err.response?.data?.message || 'Error al cargar información del viaje'
    } finally {
      loading.value = false
    }
  }

  function toggleSeat(seatNumber) {
    const seat = seatData.value?.seats.find(s => s.seat_number === seatNumber)
    if (!seat || !seat.available) return

    const index = selectedSeats.value.indexOf(seatNumber)
    if (index > -1) {
      selectedSeats.value.splice(index, 1)
    } else {
      selectedSeats.value.push(seatNumber)
    }
  }

  function clearSelectedSeats() {
    selectedSeats.value = []
  }

  async function createReservation() {
    if (selectedSeats.value.length === 0) return

    loading.value = true
    error.value = null

    try {
      const response = await reservationsApi.create({
        trip_id: currentTrip.value.id,
        seat_numbers: selectedSeats.value
      })
      currentReservation.value = response.data.reservation
      return response.data.reservation
    } catch (err) {
      error.value = err.response?.data?.message || 'Error al crear reserva'
      throw err
    } finally {
      loading.value = false
    }
  }

  async function loadReservation(locator) {
    loading.value = true
    error.value = null

    try {
      const response = await reservationsApi.getByLocator(locator)
      currentReservation.value = response.data.reservation
      return response.data.reservation
    } catch (err) {
      error.value = err.response?.data?.message || 'Reserva no encontrada'
      throw err
    } finally {
      loading.value = false
    }
  }

  async function updateReservation(locator, data) {
    loading.value = true
    error.value = null

    try {
      const response = await reservationsApi.update(locator, data)
      currentReservation.value = response.data.reservation
      return response.data.reservation
    } catch (err) {
      error.value = err.response?.data?.message || 'Error al actualizar reserva'
      throw err
    } finally {
      loading.value = false
    }
  }

  async function checkout(locator) {
    loading.value = true
    error.value = null

    try {
      const response = await reservationsApi.checkout(locator)
      paymentIntent.value = response.data.payment_intent
      currentReservation.value = response.data.reservation
      return response.data
    } catch (err) {
      error.value = err.response?.data?.message || 'Error al procesar pago'
      throw err
    } finally {
      loading.value = false
    }
  }

  async function checkPaymentStatus(externalId) {
    try {
      const response = await paymentApi.getStatus(externalId)
      paymentIntent.value = response.data.payment_intent
      return response.data.payment_intent
    } catch (err) {
      console.error('Error checking payment status:', err)
    }
  }

  async function simulatePayment(externalId, eventType = 'succeeded') {
    loading.value = true
    try {
      const response = await paymentApi.simulateWebhook(externalId, eventType)
      paymentIntent.value = response.data.payment_intent
      return response.data.payment_intent
    } catch (err) {
      error.value = err.response?.data?.message || 'Error al procesar pago'
      throw err
    } finally {
      loading.value = false
    }
  }

  function clearReservation() {
    currentReservation.value = null
    paymentIntent.value = null
    selectedSeats.value = []
  }

  return {
    currentTrip,
    seatData,
    selectedSeats,
    currentReservation,
    paymentIntent,
    loading,
    error,
    selectedSeatsInfo,
    totalPrice,
    formattedTotal,
    holdTimeRemaining,
    loadTripSeats,
    toggleSeat,
    clearSelectedSeats,
    createReservation,
    loadReservation,
    updateReservation,
    checkout,
    checkPaymentStatus,
    simulatePayment,
    clearReservation
  }
})
