<template>
  <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
    <!-- Search Summary -->
    <div class="mb-6">
      <h1 class="text-2xl font-bold text-gray-900">
        {{ searchStore.originTerminal?.city }} → {{ searchStore.destinationTerminal?.city }}
      </h1>
      <p class="text-gray-600">
        {{ formatDate(searchStore.searchParams.date) }} · {{ searchStore.searchParams.passengers }} 
        {{ searchStore.searchParams.passengers === 1 ? 'pasajero' : 'pasajeros' }}
      </p>
    </div>

    <!-- Loading State -->
    <div v-if="searchStore.loading" class="text-center py-12">
      <svg class="animate-spin h-10 w-10 text-indigo-600 mx-auto" fill="none" viewBox="0 0 24 24">
        <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
        <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
      </svg>
      <p class="mt-4 text-gray-600">Buscando viajes disponibles...</p>
    </div>

    <!-- Error State -->
    <div v-else-if="searchStore.error" class="bg-red-50 border-l-4 border-red-400 p-4">
      <p class="text-red-700">{{ searchStore.error }}</p>
      <button @click="$router.push('/')" class="mt-2 text-red-600 underline">Volver a buscar</button>
    </div>

    <!-- Results -->
    <div v-else-if="trips.length > 0" class="space-y-4">
      <!-- Filters -->
      <div class="bg-white rounded-lg shadow p-4 mb-6">
        <div class="flex flex-wrap gap-4 items-center">
          <span class="text-sm font-medium text-gray-700">Ordenar por:</span>
          <button 
            @click="sortBy = 'time'"
            :class="[sortBy === 'time' ? 'bg-indigo-100 text-indigo-700' : 'bg-gray-100 text-gray-700', 'px-3 py-1 rounded-full text-sm font-medium']"
          >
            Hora de salida
          </button>
          <button 
            @click="sortBy = 'price'"
            :class="[sortBy === 'price' ? 'bg-indigo-100 text-indigo-700' : 'bg-gray-100 text-gray-700', 'px-3 py-1 rounded-full text-sm font-medium']"
          >
            Precio
          </button>
          <button 
            @click="sortBy = 'duration'"
            :class="[sortBy === 'duration' ? 'bg-indigo-100 text-indigo-700' : 'bg-gray-100 text-gray-700', 'px-3 py-1 rounded-full text-sm font-medium']"
          >
            Duración
          </button>
        </div>
      </div>

      <!-- Trip Cards -->
      <div 
        v-for="trip in sortedTrips" 
        :key="trip.id"
        class="bg-white rounded-lg shadow-md overflow-hidden hover:shadow-lg transition-shadow"
      >
        <div class="p-6">
          <div class="flex flex-col md:flex-row md:items-center md:justify-between">
            <!-- Times -->
            <div class="flex items-center space-x-4 mb-4 md:mb-0">
              <div class="text-center">
                <p class="text-2xl font-bold text-gray-900">{{ formatTime(trip.departure_at) }}</p>
                <p class="text-sm text-gray-500">{{ trip.origin.city }}</p>
              </div>
              <div class="flex flex-col items-center px-4">
                <p class="text-xs text-gray-500">{{ trip.duration_formatted }}</p>
                <div class="w-24 h-0.5 bg-gray-300 my-1 relative">
                  <div class="absolute right-0 top-1/2 -translate-y-1/2 w-2 h-2 bg-gray-400 rounded-full"></div>
                </div>
                <p class="text-xs text-gray-400">Directo</p>
              </div>
              <div class="text-center">
                <p class="text-2xl font-bold text-gray-900">{{ formatTime(trip.arrival_at) }}</p>
                <p class="text-sm text-gray-500">{{ trip.destination.city }}</p>
              </div>
            </div>

            <!-- Bus Type & Availability -->
            <div class="flex items-center space-x-6 mb-4 md:mb-0">
              <div>
                <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-indigo-100 text-indigo-800">
                  {{ trip.bus_type_label }}
                </span>
                <p class="text-sm text-gray-500 mt-1">{{ trip.available_seats }} asientos</p>
              </div>
            </div>

            <!-- Price & Action -->
            <div class="flex items-center justify-between md:flex-col md:items-end">
              <div class="text-right">
                <p class="text-sm text-gray-500">Desde</p>
                <p class="text-2xl font-bold text-indigo-600">{{ trip.price_from_formatted }}</p>
              </div>
              <button
                @click="selectTrip(trip)"
                :disabled="!trip.has_availability"
                :class="[
                  trip.has_availability 
                    ? 'bg-indigo-600 hover:bg-indigo-700 text-white' 
                    : 'bg-gray-300 text-gray-500 cursor-not-allowed',
                  'mt-2 px-6 py-2 rounded-lg font-medium transition-colors'
                ]"
              >
                {{ trip.has_availability ? 'Seleccionar' : 'Agotado' }}
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Empty State -->
    <div v-else class="text-center py-12 bg-white rounded-lg shadow">
      <svg class="mx-auto h-12 w-12 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9.172 16.172a4 4 0 015.656 0M9 10h.01M15 10h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
      </svg>
      <h3 class="mt-2 text-lg font-medium text-gray-900">No hay viajes disponibles</h3>
      <p class="mt-1 text-gray-500">No encontramos viajes para la fecha seleccionada. Intenta con otra fecha.</p>
      <button @click="$router.push('/')" class="mt-4 text-indigo-600 font-medium hover:text-indigo-500">
        ← Volver a buscar
      </button>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useSearchStore } from '../stores/search'

const route = useRoute()
const router = useRouter()
const searchStore = useSearchStore()

const sortBy = ref('time')

const trips = computed(() => searchStore.searchResults?.trips || [])

const sortedTrips = computed(() => {
  const sorted = [...trips.value]
  switch (sortBy.value) {
    case 'price':
      return sorted.sort((a, b) => a.price_from_cents - b.price_from_cents)
    case 'duration':
      return sorted.sort((a, b) => a.duration_minutes - b.duration_minutes)
    default:
      return sorted.sort((a, b) => new Date(a.departure_at) - new Date(b.departure_at))
  }
})

onMounted(async () => {
  await searchStore.loadTerminals()
  
  // Set search params from URL query
  if (route.query.origin && route.query.destination && route.query.date) {
    searchStore.setSearchParams({
      origin: route.query.origin,
      destination: route.query.destination,
      date: route.query.date,
      passengers: parseInt(route.query.passengers) || 1
    })
    searchStore.search()
  } else {
    router.push('/')
  }
})

function formatDate(dateStr) {
  if (!dateStr) return ''
  const date = new Date(dateStr + 'T12:00:00')
  return date.toLocaleDateString('es-CL', { weekday: 'long', day: 'numeric', month: 'long' })
}

function formatTime(dateStr) {
  const date = new Date(dateStr)
  return date.toLocaleTimeString('es-CL', { hour: '2-digit', minute: '2-digit' })
}

function selectTrip(trip) {
  router.push({ name: 'seats', params: { id: trip.id } })
}
</script>
