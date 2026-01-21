<template>
  <div>
    <!-- Hero Section -->
    <div class="relative bg-indigo-600 overflow-hidden">
      <div class="max-w-7xl mx-auto">
        <div class="relative z-10 pb-8 sm:pb-16 md:pb-20 lg:pb-28 xl:pb-32">
          <main class="mt-10 mx-auto max-w-7xl px-4 sm:mt-12 sm:px-6 md:mt-16 lg:mt-20 lg:px-8 xl:mt-28">
            <div class="text-center">
              <h1 class="text-4xl tracking-tight font-extrabold text-white sm:text-5xl md:text-6xl">
                <span class="block">Viaja por Chile</span>
                <span class="block text-indigo-200">con comodidad y seguridad</span>
              </h1>
              <p class="mt-3 text-base text-indigo-100 sm:mt-5 sm:text-lg sm:max-w-xl sm:mx-auto md:mt-5 md:text-xl">
                Compra tus pasajes de bus online. Rutas a todo Chile con los mejores precios y servicio.
              </p>
            </div>
          </main>
        </div>
      </div>
    </div>

    <!-- Search Form -->
    <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 -mt-12 relative z-20">
      <div class="bg-white rounded-xl shadow-xl p-6">
        <form @submit.prevent="handleSearch" class="space-y-4">
          <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
            <!-- Origin -->
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Origen</label>
              <select
                v-model="searchParams.origin"
                class="w-full rounded-lg border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
                required
              >
                <option value="">Selecciona origen</option>
                <option v-for="terminal in terminals" :key="terminal.code" :value="terminal.code">
                  {{ terminal.city }} - {{ terminal.name }}
                </option>
              </select>
            </div>

            <!-- Destination -->
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Destino</label>
              <select
                v-model="searchParams.destination"
                class="w-full rounded-lg border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
                required
              >
                <option value="">Selecciona destino</option>
                <option 
                  v-for="terminal in availableDestinations" 
                  :key="terminal.code" 
                  :value="terminal.code"
                >
                  {{ terminal.city }} - {{ terminal.name }}
                </option>
              </select>
            </div>

            <!-- Date -->
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Fecha de viaje</label>
              <input
                type="date"
                v-model="searchParams.date"
                :min="minDate"
                class="w-full rounded-lg border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
                required
              />
            </div>

            <!-- Passengers -->
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Pasajeros</label>
              <select
                v-model="searchParams.passengers"
                class="w-full rounded-lg border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
              >
                <option v-for="n in 6" :key="n" :value="n">{{ n }} {{ n === 1 ? 'pasajero' : 'pasajeros' }}</option>
              </select>
            </div>
          </div>

          <div class="flex justify-center pt-2">
            <button
              type="submit"
              :disabled="loading"
              class="inline-flex items-center px-8 py-3 border border-transparent text-base font-medium rounded-lg shadow-sm text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 disabled:opacity-50"
            >
              <svg v-if="loading" class="animate-spin -ml-1 mr-3 h-5 w-5 text-white" fill="none" viewBox="0 0 24 24">
                <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
              </svg>
              Buscar Viajes
            </button>
          </div>
        </form>
      </div>
    </div>

    <!-- Features -->
    <div class="py-16 bg-gray-50">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="text-center mb-12">
          <h2 class="text-3xl font-extrabold text-gray-900">¿Por qué viajar con nosotros?</h2>
        </div>
        <div class="grid grid-cols-1 md:grid-cols-3 gap-8">
          <div class="text-center">
            <div class="flex items-center justify-center h-12 w-12 rounded-md bg-indigo-500 text-white mx-auto">
              <svg class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" />
              </svg>
            </div>
            <h3 class="mt-4 text-lg font-medium text-gray-900">Compra Segura</h3>
            <p class="mt-2 text-gray-500">Transacciones protegidas con la mejor tecnología de seguridad.</p>
          </div>
          <div class="text-center">
            <div class="flex items-center justify-center h-12 w-12 rounded-md bg-indigo-500 text-white mx-auto">
              <svg class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
              </svg>
            </div>
            <h3 class="mt-4 text-lg font-medium text-gray-900">Confirmación Inmediata</h3>
            <p class="mt-2 text-gray-500">Recibe tu pasaje al instante en tu correo electrónico.</p>
          </div>
          <div class="text-center">
            <div class="flex items-center justify-center h-12 w-12 rounded-md bg-indigo-500 text-white mx-auto">
              <svg class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z" />
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z" />
              </svg>
            </div>
            <h3 class="mt-4 text-lg font-medium text-gray-900">Cobertura Nacional</h3>
            <p class="mt-2 text-gray-500">Llegamos a los principales destinos de todo Chile.</p>
          </div>
        </div>
      </div>
    </div>

    <!-- Popular Routes -->
    <div class="py-16">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <h2 class="text-3xl font-extrabold text-gray-900 text-center mb-12">Rutas Populares</h2>
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          <div 
            v-for="route in popularRoutes" 
            :key="route.key"
            @click="selectRoute(route)"
            class="bg-white rounded-lg shadow-md overflow-hidden cursor-pointer hover:shadow-lg transition-shadow"
          >
            <div class="p-6">
              <div class="flex items-center justify-between">
                <div>
                  <p class="text-lg font-semibold text-gray-900">{{ route.origin }} → {{ route.destination }}</p>
                  <p class="text-sm text-gray-500">{{ route.duration }}</p>
                </div>
                <div class="text-right">
                  <p class="text-sm text-gray-500">Desde</p>
                  <p class="text-lg font-bold text-indigo-600">{{ route.priceFrom }}</p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useSearchStore } from '../stores/search'

const router = useRouter()
const searchStore = useSearchStore()

const searchParams = ref({
  origin: '',
  destination: '',
  date: '',
  passengers: 1
})

const loading = computed(() => searchStore.loading)
const terminals = computed(() => searchStore.terminals)

const availableDestinations = computed(() => 
  terminals.value.filter(t => t.code !== searchParams.value.origin)
)

const minDate = computed(() => {
  const today = new Date()
  return today.toISOString().split('T')[0]
})

const popularRoutes = [
  { key: 'scl-vin', origin: 'Santiago', destination: 'Viña del Mar', duration: '1h 30min', priceFrom: '$8.000', originCode: 'SCL', destCode: 'VIN' },
  { key: 'scl-val', origin: 'Santiago', destination: 'Valparaíso', duration: '1h 40min', priceFrom: '$8.500', originCode: 'SCL', destCode: 'VAL' },
  { key: 'scl-ccp', origin: 'Santiago', destination: 'Concepción', duration: '6h', priceFrom: '$15.000', originCode: 'SCL', destCode: 'CCP' },
  { key: 'scl-zco', origin: 'Santiago', destination: 'Temuco', duration: '8h', priceFrom: '$20.000', originCode: 'SCL', destCode: 'ZCO' },
  { key: 'scl-pmc', origin: 'Santiago', destination: 'Puerto Montt', duration: '12h', priceFrom: '$28.000', originCode: 'SCL', destCode: 'PMC' },
  { key: 'scl-lsc', origin: 'Santiago', destination: 'La Serena', duration: '6h', priceFrom: '$16.000', originCode: 'SCL', destCode: 'LSC' }
]

onMounted(() => {
  searchStore.loadTerminals()
})

function handleSearch() {
  searchStore.setSearchParams(searchParams.value)
  router.push({ 
    name: 'search',
    query: {
      origin: searchParams.value.origin,
      destination: searchParams.value.destination,
      date: searchParams.value.date,
      passengers: searchParams.value.passengers
    }
  })
}

function selectRoute(route) {
  searchParams.value.origin = route.originCode
  searchParams.value.destination = route.destCode
  const tomorrow = new Date()
  tomorrow.setDate(tomorrow.getDate() + 1)
  searchParams.value.date = tomorrow.toISOString().split('T')[0]
}
</script>
