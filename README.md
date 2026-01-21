# Posku - Plataforma de Venta de Pasajes de Bus

Plataforma realista de agendamiento y venta de pasajes de bus inspirada en Turbus.cl, construida con Ruby on Rails 8, Vue 3 y Tailwind CSS.

## Características

### Flujo de Compra (Cliente)
- **Buscador**: Origen, destino, fecha, cantidad de pasajeros
- **Resultados**: Lista de salidas con hora, duración, tipo de bus, precio y disponibilidad
- **Selección de asientos**: Mapa interactivo del bus con estados (disponible/ocupado/seleccionado)
- **Checkout**: Datos de pasajeros, contacto, resumen y políticas
- **Pago**: Mock de Fintoc con simulación de estados
- **Confirmación**: Código de reserva, detalle del viaje y botón de descarga

### Panel de Administración
- Dashboard con estadísticas
- CRUD de terminales, rutas, buses y viajes
- Vista de ocupación por viaje
- Gestión de reservas con filtros
- Exportación CSV de reservas

### Reglas de Negocio
- **Hold de asientos**: 8 minutos (configurable) con expiración automática
- **Locking transaccional**: Previene sobreventa con `FOR UPDATE`
- **Precios dinámicos**: Variaciones por día de la semana y horario
- **Estados de reserva**: pending → held → confirmed/expired/cancelled

## Stack Tecnológico

- **Backend**: Ruby on Rails 8.0
- **Frontend**: Vue 3 + Pinia + Vue Router
- **Estilos**: Tailwind CSS 4
- **Base de datos**: PostgreSQL
- **Jobs**: Solid Queue (Rails 8 default)
- **Autenticación**: Rails 8 native authentication

## Requisitos

- Ruby 3.2+
- Node.js 20+
- PostgreSQL 14+

## Instalación Local

```bash
# Clonar el repositorio
git clone <repo-url>
cd posku

# Instalar dependencias Ruby
bundle install

# Instalar dependencias Node
npm install

# Configurar base de datos
bin/rails db:create db:migrate db:seed

# Compilar assets
npm run build
npm run build:css

# Iniciar servidor de desarrollo
bin/dev
```

La aplicación estará disponible en `http://localhost:3000`

### Credenciales de Admin

```
Email: admin@posku.cl
Password: password123
```

## Estructura del Proyecto

```
app/
├── controllers/
│   ├── api/           # API JSON endpoints
│   │   ├── terminals_controller.rb
│   │   ├── trips_controller.rb
│   │   ├── reservations_controller.rb
│   │   └── payment_intents_controller.rb
│   └── admin/         # Panel de administración
├── models/
│   ├── terminal.rb
│   ├── route.rb
│   ├── bus.rb
│   ├── seat.rb
│   ├── trip.rb
│   ├── fare.rb
│   ├── reservation.rb
│   ├── passenger.rb
│   ├── reservation_seat.rb
│   └── payment_intent.rb
├── services/
│   ├── seat_hold_service.rb    # Lógica de hold de asientos
│   ├── reservation_service.rb  # Gestión de reservas
│   ├── pricing_service.rb      # Cálculo de precios
│   └── fintoc_mock_service.rb  # Mock de pagos
├── jobs/
│   ├── hold_expiration_job.rb
│   └── payment_expiration_job.rb
└── javascript/
    └── vue/
        ├── App.vue
        ├── router/
        ├── stores/
        └── views/
```

## API Endpoints

### Terminales
```
GET /api/terminals           # Lista de terminales
GET /api/terminals/:id       # Detalle de terminal
```

### Viajes
```
GET /api/trips/search        # Buscar viajes
GET /api/trips/:id           # Detalle de viaje
GET /api/trips/:id/seats     # Mapa de asientos
```

### Reservas
```
POST   /api/reservations              # Crear reserva (hold)
GET    /api/reservations/:locator     # Ver reserva
PATCH  /api/reservations/:locator     # Actualizar datos
POST   /api/reservations/:locator/checkout  # Iniciar pago
DELETE /api/reservations/:locator     # Cancelar
```

### Pagos (Mock Fintoc)
```
GET  /api/payment_intents/:id         # Estado del pago
POST /api/payment_intents/:id/start   # Iniciar pago
POST /api/webhooks/fintoc_mock        # Webhook simulado
```

## Configuración de Variables de Entorno

```bash
# Base de datos
DATABASE_URL=postgres://user:pass@host:5432/dbname

# Rails
RAILS_ENV=production
SECRET_KEY_BASE=your-secret-key
RAILS_MASTER_KEY=your-master-key

# Configuración de negocio
SEAT_HOLD_DURATION=8          # Minutos de hold de asiento
PAYMENT_EXPIRATION_DURATION=15 # Minutos para completar pago
```

## Deploy a Render

1. Fork/clone este repositorio a GitHub
2. Crear cuenta en [Render](https://render.com)
3. Conectar repositorio de GitHub
4. Usar "New Blueprint" y seleccionar el archivo `render.yaml`
5. Configurar `RAILS_MASTER_KEY` con el valor de `config/master.key`
6. Deploy!

El archivo `render.yaml` incluye:
- Web service (Ruby)
- PostgreSQL database (free tier)
- Variables de entorno automáticas

## Decisiones Técnicas

### ¿Por qué monolito Rails + Vue?
- **Simplicidad de deploy**: Un solo proceso, sin CORS
- **Sesiones compartidas**: Autenticación transparente
- **Desarrollo rápido**: Ideal para MVP
- **Vite/esbuild**: HMR rápido para Vue

### ¿Por qué Solid Queue en lugar de Sidekiq?
- **Rails 8 default**: Sin dependencias adicionales
- **Sin Redis**: Usa PostgreSQL, simplifica infraestructura
- **Jobs programados**: Soporte nativo con `set(wait_until:)`

### ¿Por qué autenticación nativa de Rails 8?
- **Sin gemas**: Menos dependencias
- **Suficiente para admin**: No necesitamos features complejas
- **Fácil de extender**: Código propio, no magia

## Próximos Pasos (Post-MVP)

1. **Integración real con Fintoc API**
2. **Viajes ida y vuelta**
3. **Sistema de cupones de descuento**
4. **Notificaciones por email** (confirmación, recordatorio)
5. **PWA para móvil**
6. **Autenticación de usuarios** (historial de compras)
7. **Cambios y cancelaciones** con reembolso real
8. **PDF de pasaje** con código QR

## Testing

```bash
# Ejecutar todos los tests
bin/rails test

# Tests específicos
bin/rails test test/services/seat_hold_service_test.rb
```

## Licencia

MIT License - Ver [LICENSE](LICENSE) para más detalles.

---

Desarrollado como proyecto demo para demostrar integración Rails 8 + Vue 3 + Tailwind.
