// Core imports
import "@hotwired/turbo-rails"
import "./controllers"

// Vue 3 app
import { createApp } from 'vue'
import { createPinia } from 'pinia'
import App from './vue/App.vue'
import router from './vue/router'

// Initialize Vue app when DOM is ready
document.addEventListener('DOMContentLoaded', () => {
  const appElement = document.getElementById('app')
  
  if (appElement) {
    const app = createApp(App)
    app.use(createPinia())
    app.use(router)
    app.mount('#app')
  }
})
