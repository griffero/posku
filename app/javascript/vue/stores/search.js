import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { terminalsApi, tripsApi } from '../api/client'

export const useSearchStore = defineStore('search', () => {
  // State
  const terminals = ref([])
  const searchParams = ref({
    origin: null,
    destination: null,
    date: null,
    passengers: 1
  })
  const searchResults = ref(null)
  const loading = ref(false)
  const error = ref(null)

  // Getters
  const originTerminal = computed(() => 
    terminals.value.find(t => t.code === searchParams.value.origin)
  )
  
  const destinationTerminal = computed(() => 
    terminals.value.find(t => t.code === searchParams.value.destination)
  )

  const hasSearchParams = computed(() => 
    searchParams.value.origin && searchParams.value.destination && searchParams.value.date
  )

  // Actions
  async function loadTerminals() {
    if (terminals.value.length > 0) return

    try {
      const response = await terminalsApi.getAll()
      terminals.value = response.data.terminals
    } catch (err) {
      error.value = 'Error al cargar terminales'
      console.error(err)
    }
  }

  function setSearchParams(params) {
    searchParams.value = { ...searchParams.value, ...params }
  }

  async function search() {
    if (!hasSearchParams.value) return

    loading.value = true
    error.value = null

    try {
      const response = await tripsApi.search({
        origin: searchParams.value.origin,
        destination: searchParams.value.destination,
        date: searchParams.value.date,
        passengers: searchParams.value.passengers
      })
      searchResults.value = response.data
    } catch (err) {
      error.value = err.response?.data?.message || 'Error al buscar viajes'
      searchResults.value = null
    } finally {
      loading.value = false
    }
  }

  function clearResults() {
    searchResults.value = null
  }

  return {
    terminals,
    searchParams,
    searchResults,
    loading,
    error,
    originTerminal,
    destinationTerminal,
    hasSearchParams,
    loadTerminals,
    setSearchParams,
    search,
    clearResults
  }
})
