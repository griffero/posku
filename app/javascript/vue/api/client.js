import axios from 'axios'

const api = axios.create({
  baseURL: '/api',
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json'
  }
})

// Request interceptor for CSRF token
api.interceptors.request.use(config => {
  const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content
  if (csrfToken) {
    config.headers['X-CSRF-Token'] = csrfToken
  }
  return config
})

// Response interceptor for error handling
api.interceptors.response.use(
  response => response,
  error => {
    console.error('API Error:', error.response?.data || error.message)
    return Promise.reject(error)
  }
)

export default api

// API methods
export const terminalsApi = {
  getAll: () => api.get('/terminals'),
  getOne: (id) => api.get(`/terminals/${id}`)
}

export const tripsApi = {
  search: (params) => api.get('/trips/search', { params }),
  getOne: (id) => api.get(`/trips/${id}`),
  getSeats: (id) => api.get(`/trips/${id}/seats`)
}

export const reservationsApi = {
  create: (data) => api.post('/reservations', data),
  getByLocator: (locator) => api.get(`/reservations/${locator}`),
  update: (locator, data) => api.patch(`/reservations/${locator}`, data),
  checkout: (locator) => api.post(`/reservations/${locator}/checkout`),
  cancel: (locator) => api.delete(`/reservations/${locator}`)
}

export const paymentApi = {
  getStatus: (externalId) => api.get(`/payment_intents/${externalId}`),
  start: (externalId) => api.post(`/payment_intents/${externalId}/start`),
  simulateWebhook: (paymentIntentId, eventType) => 
    api.post('/webhooks/fintoc_mock', { payment_intent_id: paymentIntentId, event_type: eventType })
}
