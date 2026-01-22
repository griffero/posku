<template>
  <div class="min-h-screen bg-gray-50">
    <!-- Header with Search Summary -->
    <div class="bg-white border-b border-gray-200 sticky top-0 z-10">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
        <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
          <div>
            <div class="flex items-center gap-3">
              <h1 class="text-xl sm:text-2xl font-bold text-gray-900">
                {{ searchStore.originTerminal?.city }}
              </h1>
              <svg class="w-5 h-5 text-indigo-500 flex-shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 8l4 4m0 0l-4 4m4-4H3" />
              </svg>
              <h1 class="text-xl sm:text-2xl font-bold text-gray-900">
                {{ searchStore.destinationTerminal?.city }}
              </h1>
            </div>
            <p class="text-gray-500 mt-1">
              {{ formatDate(searchStore.searchParams.date) }} · {{ searchStore.searchParams.passengers }} 
              {{ searchStore.searchParams.passengers === 1 ? 'pasajero' : 'pasajeros' }}
            </p>
          </div>
          <button
            @click="$router.push('/')"
            class="inline-flex items-center gap-2 px-4 py-2 text-sm font-medium text-indigo-600 bg-indigo-50 rounded-lg hover:bg-indigo-100 transition-colors"
          >
            <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
            </svg>
            Nueva búsqueda
          </button>
        </div>
      </div>
    </div>

    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
      <!-- Loading State -->
      <div v-if="searchStore.loading" class="flex flex-col items-center justify-center py-20">
        <div class="relative">
          <div class="w-16 h-16 border-4 border-indigo-200 rounded-full"></div>
          <div class="absolute top-0 left-0 w-16 h-16 border-4 border-indigo-600 rounded-full animate-spin border-t-transparent"></div>
        </div>
        <p class="mt-6 text-lg text-gray-600">Buscando los mejores viajes...</p>
      </div>

      <!-- Error State -->
      <div v-else-if="searchStore.error" class="max-w-lg mx-auto py-20 text-center">
        <div class="w-16 h-16 bg-red-100 rounded-full flex items-center justify-center mx-auto mb-6">
          <svg class="w-8 h-8 text-red-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
          </svg>
        </div>
        <h3 class="text-xl font-semibold text-gray-900 mb-2">Error en la búsqueda</h3>
        <p class="text-gray-600 mb-6">{{ searchStore.error }}</p>
        <button @click="$router.push('/')" class="px-6 py-2 bg-indigo-600 text-white font-medium rounded-lg hover:bg-indigo-700 transition-colors">
          Volver a buscar
        </button>
      </div>

      <!-- Results -->
      <div v-else-if="trips.length > 0">
        <!-- Filters -->
        <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-4 mb-6">
          <div class="flex flex-wrap items-center gap-3">
            <span class="text-sm font-medium text-gray-500">Ordenar:</span>
            <div class="flex flex-wrap gap-2">
              <button 
                v-for="option in sortOptions"
                :key="option.value"
                @click="sortBy = option.value"
                :class="[
                  sortBy === option.value 
                    ? 'bg-indigo-600 text-white shadow-sm' 
                    : 'bg-gray-100 text-gray-700 hover:bg-gray-200',
                  'px-4 py-2 rounded-lg text-sm font-medium transition-colors'
                ]"
              >
                {{ option.label }}
              </button>
            </div>
            <div class="ml-auto text-sm text-gray-500">
              {{ trips.length }} {{ trips.length === 1 ? 'viaje encontrado' : 'viajes encontrados' }}
            </div>
          </div>
        </div>

        <!-- Trip Cards -->
        <div class="space-y-4">
          <div 
            v-for="trip in sortedTrips" 
            :key="trip.id"
            class="bg-white rounded-xl shadow-sm border border-gray-200 hover:shadow-md hover:border-indigo-200 transition-all overflow-hidden"
          >
            <div class="p-5 sm:p-6">
              <div class="flex flex-col lg:flex-row lg:items-center gap-6">
                <!-- Time & Route Info -->
                <div class="flex-1">
                  <div class="flex items-center gap-4 sm:gap-6">
                    <!-- Departure -->
                    <div class="text-center">
                      <p class="text-2xl sm:text-3xl font-bold text-gray-900">{{ formatTime(trip.departure_at) }}</p>
                      <p class="text-sm text-gray-500 mt-1">{{ trip.origin.city }}</p>
                    </div>
                    
                    <!-- Duration Line -->
                    <div class="flex-1 max-w-[200px]">
                      <div class="relative">
                        <div class="flex items-center">
                          <div class="w-2 h-2 bg-indigo-600 rounded-full"></div>
                          <div class="flex-1 h-0.5 bg-gradient-to-r from-indigo-600 to-indigo-400"></div>
                          <div class="w-2 h-2 bg-indigo-400 rounded-full"></div>
                        </div>
                        <p class="absolute -bottom-5 left-1/2 -translate-x-1/2 text-xs text-gray-500 whitespace-nowrap">
                          {{ trip.duration_formatted }}
                        </p>
                      </div>
                    </div>
                    
                    <!-- Arrival -->
                    <div class="text-center">
                      <p class="text-2xl sm:text-3xl font-bold text-gray-900">{{ formatTime(trip.arrival_at) }}</p>
                      <p class="text-sm text-gray-500 mt-1">{{ trip.destination.city }}</p>
                    </div>
                  </div>
                </div>

                <!-- Bus Type & Availability -->
                <div class="flex items-center gap-4 lg:gap-6">
                  <div class="flex flex-col items-center">
                    <span :class="getBusTypeClass(trip.bus_type)" class="px-3 py-1 rounded-full text-xs font-semibold">
                      {{ trip.bus_type_label }}
                    </span>
                    <p class="text-sm text-gray-500 mt-2">
                      <span :class="trip.available_seats <= 5 ? 'text-orange-600 font-medium' : ''">
                        {{ trip.available_seats }} asientos
                      </span>
                    </p>
                  </div>

                  <!-- Price & Action -->
                  <div class="flex items-center gap-4 pl-4 lg:pl-6 border-l border-gray-200">
                    <div class="text-right">
                      <p class="text-xs text-gray-500">Desde</p>
                      <p class="text-2xl font-bold text-gray-900">{{ trip.price_from_formatted }}</p>
                    </div>
                    <button
                      @click="selectTrip(trip)"
                      :disabled="!trip.has_availability"
                      :class="[
                        trip.has_availability 
                          ? 'bg-indigo-600 hover:bg-indigo-700 text-white shadow-sm hover:shadow' 
                          : 'bg-gray-200 text-gray-500 cursor-not-allowed',
                        'px-6 py-3 rounded-xl font-semibold transition-all whitespace-nowrap'
                      ]"
                    >
                      {{ trip.has_availability ? 'Seleccionar' : 'Agotado' }}
                    </button>
                  </div>
                </div>
              </div>
            </div>

            <!-- Low availability warning -->
            <div v-if="trip.available_seats <= 5 && trip.has_availability" class="px-6 py-2 bg-orange-50 border-t border-orange-100">
              <p class="text-sm text-orange-700 flex items-center gap-2">
                <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
                ¡Últimos asientos disponibles!
              </p>
            </div>
          </div>
        </div>
      </div>

      <!-- Empty State -->
      <div v-else class="max-w-lg mx-auto py-20 text-center">
        <div class="w-20 h-20 bg-gray-100 rounded-full flex items-center justify-center mx-auto mb-6">
          <svg class="w-10 h-10 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M8 7h12m0 0l-4-4m4 4l-4 4m0 6H4m0 0l4 4m-4-4l4-4" />
          </svg>
        </div>
        <h3 class="text-xl font-semibold text-gray-900 mb-2">No hay viajes disponibles</h3>
        <p class="text-gray-600 mb-6">
          {{ searchResults?.message || 'No encontramos viajes para la fecha seleccionada. Intenta con otra fecha o ruta.' }}
        </p>
        <button 
          @click="$router.push('/')" 
          class="inline-flex items-center gap-2 px-6 py-3 bg-indigo-600 text-white font-medium rounded-xl hover:bg-indigo-700 transition-colors"
        >
          <svg class="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18" />
          </svg>
          Buscar otra ruta
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useSearchStore } from '../stores/search'

const route = useRoute()
const router = useRouter()
const searchStore = useSearchStore()

const sortBy = ref('time')
const sortOptions = [
  { value: 'time', label: 'Hora' },
  { value: 'price', label: 'Precio' },
  { value: 'duration', label: 'Duración' }
]

const trips = computed(() => searchStore.searchResults?.trips || [])
const searchResults = computed(() => searchStore.searchResults)

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

function getBusTypeClass(busType) {
  const classes = {
    classic: 'bg-gray-100 text-gray-700',
    semi_cama: 'bg-blue-100 text-blue-700',
    salon_cama: 'bg-purple-100 text-purple-700',
    premium: 'bg-amber-100 text-amber-700'
  }
  return classes[busType] || 'bg-gray-100 text-gray-700'
}

function selectTrip(trip) {
  router.push({ name: 'seats', params: { id: trip.id } })
}
</script>
