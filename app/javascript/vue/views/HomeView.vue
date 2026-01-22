<template>
  <div>
    <!-- Hero Section with Gradient Background -->
    <div class="relative bg-gradient-to-br from-indigo-600 via-indigo-700 to-purple-800 overflow-hidden">
      <!-- Decorative Elements -->
      <div class="absolute inset-0 overflow-hidden">
        <div class="absolute -top-40 -right-40 w-80 h-80 bg-white/10 rounded-full blur-3xl"></div>
        <div class="absolute -bottom-40 -left-40 w-80 h-80 bg-purple-500/20 rounded-full blur-3xl"></div>
        <div class="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-96 h-96 bg-indigo-400/10 rounded-full blur-3xl"></div>
      </div>

      <div class="relative max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="pt-16 pb-24 sm:pt-24 sm:pb-32">
          <div class="text-center">
            <h1 class="text-4xl sm:text-5xl lg:text-6xl font-extrabold tracking-tight">
              <span class="block text-white">Viaja por Chile</span>
              <span class="block text-indigo-200 mt-2">con comodidad y seguridad</span>
            </h1>
            <p class="mt-6 max-w-2xl mx-auto text-lg sm:text-xl text-indigo-100">
              Compra tus pasajes de bus online. Más de 50 destinos en todo Chile con los mejores precios.
            </p>
          </div>
        </div>
      </div>
    </div>

    <!-- Search Form Card - Floating -->
    <div class="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 -mt-16 relative z-20">
      <div class="bg-white rounded-2xl shadow-2xl p-6 sm:p-8 border border-gray-100">
        <form @submit.prevent="handleSearch">
          <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 sm:gap-6">
            <!-- Origin -->
            <div class="space-y-2">
              <label class="flex items-center text-sm font-semibold text-gray-700">
                <svg class="w-4 h-4 mr-2 text-indigo-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <circle cx="12" cy="12" r="3" stroke-width="2"/>
                  <path stroke-linecap="round" stroke-width="2" d="M12 2v4m0 12v4M2 12h4m12 0h4"/>
                </svg>
                Origen
              </label>
              <select
                v-model="searchParams.origin"
                class="w-full h-12 px-4 rounded-xl border-2 border-gray-200 bg-gray-50 text-gray-900 font-medium focus:border-indigo-500 focus:bg-white focus:ring-4 focus:ring-indigo-500/10 transition-all"
                required
              >
                <option value="">¿Desde dónde viajas?</option>
                <optgroup v-for="(terms, city) in terminalsByCity" :key="city" :label="city">
                  <option v-for="terminal in terms" :key="terminal.code" :value="terminal.code">
                    {{ terminal.name }}
                  </option>
                </optgroup>
              </select>
            </div>

            <!-- Destination -->
            <div class="space-y-2">
              <label class="flex items-center text-sm font-semibold text-gray-700">
                <svg class="w-4 h-4 mr-2 text-indigo-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z" />
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z" />
                </svg>
                Destino
              </label>
              <select
                v-model="searchParams.destination"
                class="w-full h-12 px-4 rounded-xl border-2 border-gray-200 bg-gray-50 text-gray-900 font-medium focus:border-indigo-500 focus:bg-white focus:ring-4 focus:ring-indigo-500/10 transition-all"
                required
              >
                <option value="">¿A dónde vas?</option>
                <optgroup v-for="(terms, city) in availableDestinationsByCity" :key="city" :label="city">
                  <option v-for="terminal in terms" :key="terminal.code" :value="terminal.code">
                    {{ terminal.name }}
                  </option>
                </optgroup>
              </select>
            </div>

            <!-- Date -->
            <div class="space-y-2">
              <label class="flex items-center text-sm font-semibold text-gray-700">
                <svg class="w-4 h-4 mr-2 text-indigo-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
                </svg>
                Fecha de viaje
              </label>
              <input
                type="date"
                v-model="searchParams.date"
                :min="minDate"
                class="w-full h-12 px-4 rounded-xl border-2 border-gray-200 bg-gray-50 text-gray-900 font-medium focus:border-indigo-500 focus:bg-white focus:ring-4 focus:ring-indigo-500/10 transition-all"
                required
              />
            </div>

            <!-- Passengers -->
            <div class="space-y-2">
              <label class="flex items-center text-sm font-semibold text-gray-700">
                <svg class="w-4 h-4 mr-2 text-indigo-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0z" />
                </svg>
                Pasajeros
              </label>
              <select
                v-model="searchParams.passengers"
                class="w-full h-12 px-4 rounded-xl border-2 border-gray-200 bg-gray-50 text-gray-900 font-medium focus:border-indigo-500 focus:bg-white focus:ring-4 focus:ring-indigo-500/10 transition-all"
              >
                <option v-for="n in 6" :key="n" :value="n">{{ n }} {{ n === 1 ? 'pasajero' : 'pasajeros' }}</option>
              </select>
            </div>
          </div>

          <!-- Search Button -->
          <div class="mt-6 sm:mt-8">
            <button
              type="submit"
              :disabled="loading || !isFormValid"
              class="w-full sm:w-auto sm:min-w-[200px] sm:mx-auto sm:block h-14 px-8 bg-gradient-to-r from-indigo-600 to-purple-600 text-white text-lg font-semibold rounded-xl shadow-lg shadow-indigo-500/30 hover:shadow-xl hover:shadow-indigo-500/40 hover:from-indigo-700 hover:to-purple-700 focus:outline-none focus:ring-4 focus:ring-indigo-500/50 disabled:opacity-50 disabled:cursor-not-allowed disabled:shadow-none transition-all duration-200 flex items-center justify-center gap-2"
            >
              <svg v-if="loading" class="animate-spin h-5 w-5" fill="none" viewBox="0 0 24 24">
                <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z"></path>
              </svg>
              <svg v-else class="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
              </svg>
              {{ loading ? 'Buscando...' : 'Buscar pasajes' }}
            </button>
          </div>
        </form>
      </div>
    </div>

    <!-- Features Section -->
    <div class="py-20 bg-white">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="text-center mb-16">
          <h2 class="text-3xl sm:text-4xl font-bold text-gray-900">¿Por qué elegirnos?</h2>
          <p class="mt-4 text-lg text-gray-600">Más de 10,000 viajeros confían en nosotros cada mes</p>
        </div>
        
        <div class="grid grid-cols-1 md:grid-cols-3 gap-8 lg:gap-12">
          <div class="relative group">
            <div class="absolute inset-0 bg-gradient-to-r from-indigo-500 to-purple-500 rounded-2xl blur-xl opacity-20 group-hover:opacity-30 transition-opacity"></div>
            <div class="relative bg-white rounded-2xl p-8 shadow-lg border border-gray-100 hover:shadow-xl transition-shadow">
              <div class="w-14 h-14 bg-gradient-to-br from-indigo-500 to-purple-600 rounded-xl flex items-center justify-center mb-6">
                <svg class="w-7 h-7 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" />
                </svg>
              </div>
              <h3 class="text-xl font-bold text-gray-900 mb-3">Compra 100% Segura</h3>
              <p class="text-gray-600 leading-relaxed">Tus datos protegidos con encriptación de nivel bancario. Paga con tranquilidad.</p>
            </div>
          </div>

          <div class="relative group">
            <div class="absolute inset-0 bg-gradient-to-r from-emerald-500 to-teal-500 rounded-2xl blur-xl opacity-20 group-hover:opacity-30 transition-opacity"></div>
            <div class="relative bg-white rounded-2xl p-8 shadow-lg border border-gray-100 hover:shadow-xl transition-shadow">
              <div class="w-14 h-14 bg-gradient-to-br from-emerald-500 to-teal-600 rounded-xl flex items-center justify-center mb-6">
                <svg class="w-7 h-7 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z" />
                </svg>
              </div>
              <h3 class="text-xl font-bold text-gray-900 mb-3">Confirmación Inmediata</h3>
              <p class="text-gray-600 leading-relaxed">Recibe tu pasaje al instante en tu correo. Sin esperas ni trámites.</p>
            </div>
          </div>

          <div class="relative group">
            <div class="absolute inset-0 bg-gradient-to-r from-orange-500 to-rose-500 rounded-2xl blur-xl opacity-20 group-hover:opacity-30 transition-opacity"></div>
            <div class="relative bg-white rounded-2xl p-8 shadow-lg border border-gray-100 hover:shadow-xl transition-shadow">
              <div class="w-14 h-14 bg-gradient-to-br from-orange-500 to-rose-600 rounded-xl flex items-center justify-center mb-6">
                <svg class="w-7 h-7 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3.055 11H5a2 2 0 012 2v1a2 2 0 002 2 2 2 0 012 2v2.945M8 3.935V5.5A2.5 2.5 0 0010.5 8h.5a2 2 0 012 2 2 2 0 104 0 2 2 0 012-2h1.064M15 20.488V18a2 2 0 012-2h3.064M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
              </div>
              <h3 class="text-xl font-bold text-gray-900 mb-3">Todo Chile Conectado</h3>
              <p class="text-gray-600 leading-relaxed">Más de 50 destinos desde Arica hasta Puerto Montt. Viaja a donde quieras.</p>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Popular Routes Section -->
    <div class="py-20 bg-gradient-to-b from-gray-50 to-white">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex items-center justify-between mb-12">
          <div>
            <h2 class="text-3xl sm:text-4xl font-bold text-gray-900">Rutas más buscadas</h2>
            <p class="mt-2 text-gray-600">Los destinos favoritos de nuestros viajeros</p>
          </div>
        </div>
        
        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
          <div 
            v-for="route in popularRoutes" 
            :key="route.key"
            @click="selectRoute(route)"
            class="group cursor-pointer"
          >
            <div class="relative bg-white rounded-2xl p-6 shadow-md border border-gray-100 hover:shadow-xl hover:border-indigo-200 hover:-translate-y-1 transition-all duration-200">
              <div class="flex items-center justify-between">
                <div class="flex-1">
                  <div class="flex items-center gap-3 mb-2">
                    <span class="text-lg font-bold text-gray-900">{{ route.origin }}</span>
                    <svg class="w-5 h-5 text-indigo-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 8l4 4m0 0l-4 4m4-4H3" />
                    </svg>
                    <span class="text-lg font-bold text-gray-900">{{ route.destination }}</span>
                  </div>
                  <div class="flex items-center gap-2 text-sm text-gray-500">
                    <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                    </svg>
                    {{ route.duration }}
                  </div>
                </div>
                <div class="text-right">
                  <p class="text-xs text-gray-500 uppercase tracking-wide">Desde</p>
                  <p class="text-2xl font-bold text-indigo-600">{{ route.priceFrom }}</p>
                </div>
              </div>
              <div class="absolute bottom-0 left-0 right-0 h-1 bg-gradient-to-r from-indigo-500 to-purple-500 rounded-b-2xl opacity-0 group-hover:opacity-100 transition-opacity"></div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Stats Section -->
    <div class="py-16 bg-gradient-to-r from-indigo-600 to-purple-700">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="grid grid-cols-2 lg:grid-cols-4 gap-8">
          <div class="text-center">
            <p class="text-4xl sm:text-5xl font-bold text-white">50+</p>
            <p class="mt-2 text-indigo-200">Destinos</p>
          </div>
          <div class="text-center">
            <p class="text-4xl sm:text-5xl font-bold text-white">100+</p>
            <p class="mt-2 text-indigo-200">Buses diarios</p>
          </div>
          <div class="text-center">
            <p class="text-4xl sm:text-5xl font-bold text-white">10K+</p>
            <p class="mt-2 text-indigo-200">Viajeros/mes</p>
          </div>
          <div class="text-center">
            <p class="text-4xl sm:text-5xl font-bold text-white">4.8</p>
            <p class="mt-2 text-indigo-200">Calificación</p>
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

const terminalsByCity = computed(() => {
  const grouped = {}
  terminals.value.forEach(t => {
    if (!grouped[t.city]) grouped[t.city] = []
    grouped[t.city].push(t)
  })
  return grouped
})

const availableDestinationsByCity = computed(() => {
  const filtered = terminals.value.filter(t => t.code !== searchParams.value.origin)
  const grouped = {}
  filtered.forEach(t => {
    if (!grouped[t.city]) grouped[t.city] = []
    grouped[t.city].push(t)
  })
  return grouped
})

const isFormValid = computed(() => 
  searchParams.value.origin && searchParams.value.destination && searchParams.value.date
)

const minDate = computed(() => {
  const today = new Date()
  return today.toISOString().split('T')[0]
})

const popularRoutes = [
  { key: 'scl-vin', origin: 'Santiago', destination: 'Viña del Mar', duration: '1h 30min', priceFrom: '$6.000', originCode: 'SCL', destCode: 'VIN' },
  { key: 'scl-val', origin: 'Santiago', destination: 'Valparaíso', duration: '1h 40min', priceFrom: '$6.500', originCode: 'SCL', destCode: 'VAL' },
  { key: 'scl-ccp', origin: 'Santiago', destination: 'Concepción', duration: '6h', priceFrom: '$12.000', originCode: 'SCL', destCode: 'CCP' },
  { key: 'scl-zco', origin: 'Santiago', destination: 'Temuco', duration: '8h', priceFrom: '$16.000', originCode: 'SCL', destCode: 'ZCO' },
  { key: 'scl-pmc', origin: 'Santiago', destination: 'Puerto Montt', duration: '12h', priceFrom: '$25.000', originCode: 'SCL', destCode: 'PMC' },
  { key: 'scl-lsc', origin: 'Santiago', destination: 'La Serena', duration: '6h', priceFrom: '$13.000', originCode: 'SCL', destCode: 'LSC' }
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
  const tomorrow = new Date()
  tomorrow.setDate(tomorrow.getDate() + 1)
  const date = tomorrow.toISOString().split('T')[0]
  
  // Set params and navigate directly to search
  searchStore.setSearchParams({
    origin: route.originCode,
    destination: route.destCode,
    date: date,
    passengers: 1
  })
  
  router.push({ 
    name: 'search',
    query: {
      origin: route.originCode,
      destination: route.destCode,
      date: date,
      passengers: 1
    }
  })
}
</script>
