# Prompts Maestros — Plataforma "Chupaca Directo" 🌿

---

## PROMPT 1 — Diseño UI/UX Completo para Gemini Stitch

> Copiar este prompt íntegro y pegarlo en Gemini Stitch para generar el sistema de diseño y todas las pantallas de la plataforma.

```text
You are designing the complete UI/UX for "Chupaca Directo", a sustainable agricultural
e-commerce platform whose academic purpose is to prove that e-commerce improves the
profitability of farmers in Chupaca province (Junín, Peru) during 2026. The research
follows a Pre-Experimental design (Pre-Test / Post-Test) with 30 farmers and uses the
T-Student test. Every screen you create must serve a dual purpose: functional product
AND scientific data-collection instrument.

═══════════════════════════════════════════════════════════════════════════════
SECTION A — DESIGN SYSTEM TOKENS
═══════════════════════════════════════════════════════════════════════════════

Brand Name: "Chupaca Directo"
Tagline: "Del campo a tu mesa, sin intermediarios"

Color Palette (Eco-Sustainable & High-Contrast for rural accessibility):
  • Primary         → Deep Forest Green   #1B5E20  (HSL 123 52% 24%)
  • Primary Light   → Leaf Green          #4CAF50  (CTAs, success states)
  • Secondary       → Warm Terracotta     #BF5B34  (earth tones of Chupaca)
  • Secondary Light → Ochre Gold          #E8A838  (highlights, badges)
  • Neutral Dark    → Charcoal            #1E1E1E  (body text, WCAG AAA)
  • Neutral Light   → Warm Cream          #FAFAF5  (backgrounds, low glare)
  • Surface Card    → White               #FFFFFF  (card surfaces)
  • Error           → Brick Red           #C62828
  • Info            → Sky Blue            #0288D1
  • Warning         → Amber               #FF8F00

Typography (Google Fonts, optimized for slow rural connections):
  • Headings   → "Outfit", 600–700 weight, tracking -0.02em
  • Body       → "Inter", 400–500 weight, 16px base, line-height 1.6
  • Captions   → "Inter", 400 weight, 13px, muted charcoal

Spacing Scale: 4px base unit (4, 8, 12, 16, 24, 32, 48, 64)
Border Radius: Small 6px · Medium 10px · Large 16px · Pill 999px
Shadows: Minimal — only elevation-1 (0 1px 3px rgba(0,0,0,0.08)) for cards
Icons: Lucide Icons (lightweight, accessible)
Micro-animations: 200ms ease-out transitions on hover/focus; skeleton loaders on data fetch

Responsive breakpoints:
  • Mobile-first (< 640px) — critical: most farmers access via smartphone
  • Tablet (640–1024px)
  • Desktop (> 1024px)

Accessibility (Variable X1 — Accesibilidad):
  • All text must meet WCAG 2.1 AA contrast ratios (4.5:1 body, 3:1 large)
  • Touch targets ≥ 48×48px for rural users with calloused hands
  • All form inputs must have visible labels (no placeholder-only labels)
  • Every interactive element needs a unique descriptive HTML id attribute
  • Support for slow 3G connections: lightweight assets, no heavy animations

═══════════════════════════════════════════════════════════════════════════════
SECTION B — SCREEN-BY-SCREEN SPECIFICATION
═══════════════════════════════════════════════════════════════════════════════

Generate ALL of the following screens as a cohesive, multi-screen application.
Each screen description includes the Functional Requirement (RF-XX) and Research
Variable/Dimension (X or Y) it addresses.

─────────────────────────────────────────────────────────────────────────────
SCREEN 1: LANDING PAGE / HOME
Purpose: Public-facing entry point. Communicate value proposition and build trust.
─────────────────────────────────────────────────────────────────────────────

Layout:
  • Hero Section — full-width background image of Chupaca Valley agricultural
    landscape with a dark overlay gradient. Centered headline: "Del Campo a Tu
    Mesa, Sin Intermediarios". Subtitle: "Plataforma de comercio electrónico que
    conecta productores agrícolas de Chupaca directamente con compradores
    mayoristas, eliminando la especulación y mejorando la rentabilidad del
    agricultor." Two CTA buttons side by side: "Soy Productor" (Primary Green)
    and "Soy Comprador" (Secondary Terracotta). Both link to the registration
    page with the corresponding role pre-selected.
  • Trust Indicators Row — 3 stat cards in a horizontal flex row:
    "30+ Productores Verificados" | "9 Distritos de Chupaca" |
    "25% Ahorro vs. Intermediarios"
  • How It Works — 3-step visual flow with numbered circles and icons:
    Step 1: "El productor publica su cosecha con fotos y precios justos" (icon: upload)
    Step 2: "El comprador busca, filtra y simula costos en tiempo real" (icon: search)
    Step 3: "Compra directa: más ganancia para el agricultor, menos costo para ti" (icon: handshake)
  • Market Transparency Preview (RF-06, Variable X1) — A compact live-ticker
    banner scrolling referential prices of 5 key crops (Papa, Maíz, Cebada,
    Hortalizas, Habas) comparing "Precio Mercado Mayorista" vs "Precio Chupaca
    Directo". Green arrow-down icon when platform price is lower.
  • Footer — Links: Términos, Privacidad, Contacto, "Proyecto de Investigación
    UNCP 2026". Social icons. Copyright.

─────────────────────────────────────────────────────────────────────────────
SCREEN 2: REGISTRATION & ONBOARDING (RF-01, RF-02, RF-03 · Variables X1, X2)
Purpose: Register users by role. Capture demographic data for farmer profiles.
Measure: "Tasa de abandono de registro" (X2) and "Dispositivos compatibles" (X1).
─────────────────────────────────────────────────────────────────────────────

Layout: Split-screen on desktop (illustration left, form right). Stacked on mobile.
  • Left Panel — Illustration of Chupaca landscape with overlay text:
    "Únete a la red de productores que están transformando la agricultura en
    Chupaca. Tu cosecha merece un precio justo."
  • Right Panel — Multi-step wizard form (progress bar at top: Step 1/3, 2/3, 3/3):

    STEP 1 — Role Selection:
      • Large toggle cards (not a dropdown): "🌾 Productor Agrícola" and
        "🛒 Comprador / Mayorista". Selecting one highlights it with Primary Green
        border and background tint.

    STEP 2 — Account Credentials:
      • Full Name (text input)
      • Email (email input with validation)
      • Phone / WhatsApp (tel input — critical for rural users, with country code +51)
      • Password (password input with strength indicator bar)
      • Confirm Password

    STEP 3A — IF role = "Productor Agrícola" (RF-02 profile data):
      • DNI / RUC (text input)
      • Comunidad de Origen (dropdown select with the 9 districts of Chupaca):
        Chupaca, Tres de Diciembre, Ahuac, Chongos Bajo, Huachac,
        Huamancaca Chico, San Juan de Iscos, Yanacancha, San Juan de Jarpa
      • Ubicación de Parcela (text field + interactive map pin preview area
        showing Chupaca region; users can drag the pin or enter coordinates)
      • Años de Experiencia Agrícola (number input, min 0)
      • Principales Cultivos (multi-select chips: Papa, Maíz, Cebada, Habas,
        Hortalizas, Quinua, Arveja, Otros)
      • Método de Contacto Preferido (radio: WhatsApp / Llamada / Email)
      • Checkbox: "Acepto los términos del servicio y autorizo el uso de mis datos
        para fines del estudio de investigación sobre rentabilidad agrícola
        (Proyecto UNCP Chupaca 2026)."
      • CTA Button: "Registrarme como Productor"

    STEP 3B — IF role = "Comprador / Mayorista":
      • Razón Social / Nombre de Negocio
      • RUC (text input)
      • Tipo de Negocio (dropdown: Mercado Mayorista, Restaurante, Exportador,
        Tienda Minorista, Otro)
      • Ciudad / Dirección de Entrega Principal
      • CTA Button: "Registrarme como Comprador"

  • Post-registration, show a success modal:
    For farmers: "¡Registro exitoso! Un administrador verificará tu perfil
    pronto. Mientras tanto, ya puedes publicar tus productos." (RF-03)
    For buyers: "¡Bienvenido! Explora el catálogo de productos frescos de Chupaca."

  • Admin Verification Badge Logic (RF-03): In the admin panel, each farmer
    profile shows a "Verificar Productor" button that toggles a green
    "✓ Verificado" badge visible across the platform.

─────────────────────────────────────────────────────────────────────────────
SCREEN 3: LOGIN
─────────────────────────────────────────────────────────────────────────────

Layout: Centered card on a subtle green gradient background.
  • Logo at top
  • Email input
  • Password input (with show/hide toggle)
  • "Iniciar Sesión" button (Primary Green, full-width)
  • Link: "¿Olvidaste tu contraseña?"
  • Link: "¿No tienes cuenta? Regístrate aquí"
  • Divider: "o continuar con"
  • Google Sign-In button (outlined style)

─────────────────────────────────────────────────────────────────────────────
SCREEN 4: BUYER PORTAL — PRODUCT CATALOG & SEARCH (RF-04, RF-06, RF-07 · X3, Y2)
Purpose: Browse and filter agricultural products. Show market transparency.
Measure: "Número de zonas de cobertura" (X3), "Costo de intermediación %" (Y2).
─────────────────────────────────────────────────────────────────────────────

Layout: Sticky top nav → Transparency ticker → Sidebar filters + Product grid.

  • Top Navigation Bar:
    Logo "Chupaca Directo" | Global Search Bar (placeholder: "Buscar papa,
    maíz, hortalizas...") | Cart/Simulation Icon with item count badge |
    Notification Bell | User Avatar dropdown (Perfil, Mis Pedidos, Cerrar Sesión)

  • Market Transparency Ticker (RF-06, Y2):
    Horizontal scrolling banner below nav. Shows 5–8 products with:
    "[Crop Icon] Papa Blanca: S/. 1.80/kg Mercado Huancayo ↔ S/. 1.35/kg
    Chupaca Directo (▼ 25% ahorro)". Green highlight when platform is cheaper.
    Link "Ver Panel Completo de Precios →" opens a detailed comparison modal
    with table: Producto | Precio Mercado Mayorista | Precio Plataforma |
    Diferencia % | Fuente.

  • Left Sidebar — Advanced Filters (RF-07):
    Collapsible accordion sections:
    ▸ Tipo de Cultivo: Checkboxes (Papa, Maíz, Cebada, Habas, Hortalizas,
      Quinua, Arveja, Otros)
    ▸ Comunidad de Origen: Checkboxes (9 districts of Chupaca) — feeds X3 metric
    ▸ Rango de Precio: Dual-handle range slider (S/. 0.50 – S/. 20.00 per unit)
    ▸ Volumen Disponible Mínimo: Input number (kg)
    ▸ Solo Productores Verificados: Toggle switch
    ▸ "Limpiar Filtros" and "Aplicar" buttons

  • Product Grid (RF-04):
    Responsive grid (1 col mobile, 2 cols tablet, 3–4 cols desktop).
    Each Product Card contains:
    — High-quality crop photo (16:10 aspect ratio, lazy-loaded)
    — Badge overlay on photo: "✓ Verificado" (green) or "Nuevo" (ochre)
    — Product Name: "Papa Yungay Orgánica" (bold, 1.1rem)
    — Farmer Name + Community: "Juan Pérez · Ahuac" (caption, muted)
    — Price: "S/. 1.35 / kg" (large, Primary Green, bold)
    — Stock Indicator: "📦 500 kg disponibles" (with color: green > 100kg,
      amber 20–100kg, red < 20kg)
    — CTA Button: "Agregar a Cotización" (outlined green, full-width bottom)
    — On hover: subtle card lift (translateY -2px) and border color transition.

  • Pagination or infinite scroll with skeleton card loaders.

─────────────────────────────────────────────────────────────────────────────
SCREEN 5: PRODUCT DETAIL PAGE (RF-04, RF-05)
─────────────────────────────────────────────────────────────────────────────

Layout: 2-column (image gallery left, details right).
  • Left: Photo carousel with thumbnails (farmer-uploaded images of the crop
    and origin plot). Zoom on click.
  • Right:
    — Breadcrumb: Catálogo > Papa > Papa Yungay Orgánica
    — Product Name (h1)
    — Farmer profile mini-card: Avatar, Name, Community, "✓ Verificado" badge,
      Years of experience, link "Ver perfil del productor"
    — Price per unit (large): "S/. 1.35 / kg"
    — Stock available (RF-05): "📦 500 kg disponibles" — updates in real-time
    — Variety: "Yungay"
    — Description: Long text from the farmer about the product, origin, harvest method.
    — Quantity selector: Number input (kg) with +/- stepper buttons
    — Live subtotal calculator: "Subtotal: S/. 675.00 (500 kg × S/. 1.35)"
    — CTA: "Agregar a Cotización" (large green button)
    — Secondary CTA: "Contactar al Productor" (WhatsApp link icon)
  • Below: Related products carousel from the same community.

─────────────────────────────────────────────────────────────────────────────
SCREEN 6: QUOTE SIMULATOR & CHECKOUT (RF-08, RF-09 · Variables Y1, Y2, Y3)
Purpose: Simulate total costs before formalizing. Show intermediation savings.
Measure: "Ingreso promedio por transacción" (Y1), "Costo por transacción" (Y2),
         "Relación ingreso/costo total" (Y3).
─────────────────────────────────────────────────────────────────────────────

Layout: 2-column (Order Builder left, Summary sidebar right). Single column on mobile.

  • Left Column — Order Builder (RF-08):
    — Section Title: "Simulador de Cotización"
    — List of added products, each row showing:
      Product photo (small), Name, Farmer + Community, Unit Price,
      Quantity input (editable with +/- steppers and direct input),
      Line Subtotal, Remove (X) button.
    — Below the product list:
      • "Agregar más productos" link → returns to catalog
      • Shipping Simulator:
        — Input: "Dirección de entrega" (text + autocomplete)
        — Dropdown: "Tipo de transporte" (Camión propio, Flete compartido,
          Recojo en parcela)
        — Calculated estimate: "Costo estimado de flete: S/. 120.00"
    — Cost Breakdown Table (RF-08 simulation):
      | Concepto                        | Monto         |
      | Subtotal de Productos           | S/. 2,350.00  |
      | Flete Estimado                  | S/. 120.00    |
      | Comisión Plataforma (2%)        | S/. 47.00     |
      | ──────────────────────────────  | ────────────  |
      | TOTAL ESTIMADO                  | S/. 2,517.00  |
    — Savings Highlight Box (green background, Y2):
      "💰 Ahorro estimado al comprar sin intermediarios: S/. 587.50 (≈ 25%)
       Comparado con el precio promedio del Mercado Mayorista de Huancayo."
      Show a visual bar chart comparing: Traditional Chain cost vs Platform cost.

  • Right Column — Order Summary Sidebar (Sticky on scroll):
    — Card titled "Resumen de Pedido"
    — Item count: "3 productos de 2 productores"
    — Total weight: "750 kg"
    — Total: "S/. 2,517.00" (large, bold, green)
    — Savings badge: "Ahorras 25% vs intermediarios"
    — Delivery details form:
      • Fecha de entrega deseada (date picker)
      • Notas para el productor (textarea)
    — CTA: "Formalizar Intención de Compra" (large green button, full-width)
      Clicking this triggers:
      1. Order creation with status "pending" (RF-09)
      2. Real-time notification to each farmer involved
      3. Automatic stock reservation (RF-05)
      4. Confirmation modal: "Tu pedido ha sido enviado a los productores.
         Recibirás una notificación cuando confirmen el despacho."
    — Secondary link: "Descargar Cotización en PDF"

─────────────────────────────────────────────────────────────────────────────
SCREEN 7: FARMER DASHBOARD (RF-02, RF-04, RF-05, RF-09 · Variables Y1, Y3)
Purpose: Central management panel for the agricultural producer.
Measure: "Frecuencia de ventas" (Y1), "Margen neto mensual" (Y3).
─────────────────────────────────────────────────────────────────────────────

Layout: Left sidebar nav + Main content area.

  • Sidebar Navigation:
    — 🏠 Inicio (Dashboard)
    — 🌾 Mis Productos (Catalog management)
    — 📦 Pedidos (Order management)
    — 📊 Mis Ingresos (Revenue stats)
    — 👤 Mi Perfil (Profile editor)
    — 🔔 Notificaciones

  • Dashboard Home — KPI Cards Row (top):
    Card 1: "Ventas del Mes" → "S/. 4,520.00" with trend arrow ▲12% (green)
    Card 2: "Pedidos Pendientes" → "3" (amber badge if > 0)
    Card 3: "Productos Activos" → "7"
    Card 4: "Margen Neto Promedio" → "38%" with mini sparkline (Y3 metric)

  • Recent Orders Section (RF-09):
    Table/card list of the 5 most recent orders. Each row:
    Order ID | Buyer Name | Products (summary) | Total Amount | Volume |
    Status badge (Pendiente/Aprobado/Despachado/Completado) | Date |
    Action buttons: "✓ Aprobar" (green) / "✕ Rechazar" (gray) / "📦 Marcar
    como Despachado" — each action triggers status update notification to buyer
    and auto-writes to the immutable sales log (RF-10).

  • Stock Alerts Section (RF-05):
    Cards for products where stock < 20% of original listing. Each shows:
    Product photo, name, current stock (red text), and quick-action
    "Actualizar Stock" button that opens an inline edit modal.

  • Revenue Chart (Y1):
    Line chart showing monthly income over the last 6 months.
    Overlay annotation: "Pre-Plataforma" (dashed line at average pre-test
    income) vs "Con Plataforma" (solid green line).

─────────────────────────────────────────────────────────────────────────────
SCREEN 8: FARMER — MY PRODUCTS & INVENTORY (RF-04, RF-05)
─────────────────────────────────────────────────────────────────────────────

  • "Agregar Nuevo Producto" button (top-right, green + icon).
  • Product Inventory Table:
    Columns: Foto | Nombre | Variedad | Precio/unidad | Stock Actual |
    Estado (Verificado/Pendiente badge) | Acciones (Editar, Pausar, Eliminar)
  • Inline stock editor: Click on "Stock Actual" cell to open a popover with
    +/- buttons and direct number input. Changes save immediately via API
    and show a subtle green flash confirmation.
  • Add/Edit Product Modal (RF-04):
    — Photo uploader (drag & drop, max 5 photos, client-side compression)
    — Product name (text input)
    — Crop type (dropdown matching filter categories)
    — Variety (text input)
    — Description (textarea)
    — Unit of measure (select: kg, arroba, saco, tonelada)
    — Price per unit (number input, currency S/.)
    — Available stock (number input)
    — Harvest date (date picker)
    — "Publicar Producto" button

─────────────────────────────────────────────────────────────────────────────
SCREEN 9: BUYER — MY ORDERS & HISTORY
─────────────────────────────────────────────────────────────────────────────

  • Tabs: "Activos" | "Completados" | "Cancelados"
  • Order cards showing: Order ID, Date, Farmer(s) involved, Items summary,
    Total, Status with timeline (Solicitado → Aprobado → Despachado → Entregado).
  • Click to expand: Full order detail with itemized breakdown, delivery info,
    and action "Confirmar Recepción" (which completes the order and triggers
    the final sales log entry RF-10).
  • "Repetir Pedido" button to re-add the same products to a new simulation.

─────────────────────────────────────────────────────────────────────────────
SCREEN 10: ADMIN — RESEARCH METRICS DASHBOARD (RF-03, RF-10 · X1–X3, Y1–Y3)
Purpose: Scientific data visualization for the research team. Maps directly
         to the Consistency Matrix dimensions and indicators.
─────────────────────────────────────────────────────────────────────────────

Layout: Full-width analytics dashboard with dark mode aesthetic (charcoal #1E1E1E
background, bright chart colors for data visibility).

  • Top Filter Bar: Date range picker, District filter, Export buttons (CSV, PDF).

  • Row 1 — Independent Variable (X) Platform Metrics:
    Card X1 (Accesibilidad):
      — Gauge: "Tiempo de Carga Promedio: 1.8s" (green if < 2s)
      — Pie chart: Device breakdown (Mobile vs Desktop vs Tablet)
      — Number: "Dispositivos Compatibles Testeados: 15"

    Card X2 (Usabilidad):
      — KPI: "Tiempo Promedio Primera Transacción: 12 min"
      — Funnel Chart: Registration → Profile Complete → First Product Published
        → First Sale (showing drop-off %, measuring "Tasa de abandono de registro")
      — KPI: "Tasa de Abandono de Registro: 8%"

    Card X3 (Alcance de Mercado):
      — Counter: "Productores Registrados: 30 / Verificados: 27"
      — Interactive Map of Chupaca Province with district boundaries. Each
        district is color-coded by density of registered producers (heatmap).
        Tooltip on hover: "Ahuac: 5 productores, 12 productos activos"
      — Counter: "Zonas de Cobertura: 8 de 9 distritos"

  • Row 2 — Dependent Variable (Y) Profitability Metrics:
    Card Y1 (Ingresos por Ventas):
      — Bar chart: "Frecuencia de Ventas por Productor" (monthly, grouped by farmer)
      — KPI: "Ingreso Promedio por Transacción: S/. 385.00"
      — Comparison overlay: Pre-test average (gray dashed) vs Post-test (green solid)

    Card Y2 (Costos de Comercialización):
      — Side-by-side bar chart: "Costo de Intermediación Tradicional (%)" vs
        "Costo en Plataforma (%)" — proving reduction hypothesis
      — KPI: "Costo Promedio por Transacción en Plataforma: S/. 12.50"
      — KPI: "Reducción de Intermediación: -23.4%"

    Card Y3 (Márgenes de Ganancia):
      — Area chart: "Margen Neto Mensual por Productor" (time series, last 6 months)
      — KPI: "Relación Ingreso/Costo Total Promedio: 1.62" (green if > 1)
      — Comparison Table: Pre-Test Margin vs Post-Test Margin per farmer (anonymized)

  • Row 3 — Sales Log Viewer (RF-10):
    — Searchable, sortable, read-only data grid with columns:
      Transaction ID | Timestamp | Farmer ID | Buyer ID | Products | Volume (kg) |
      Amount (S/.) | Intermediation Saved (%) | Status
    — "Exportar Registro Completo" button (CSV for SPSS/R import)
    — Note: "Este registro es inalterable y constituye el instrumento de
      recolección de datos automatizado del proyecto de investigación."

  • Row 4 — Producer Verification Panel (RF-03):
    — Table of all registered farmers with columns:
      Name | Community | DNI | Registration Date | Products Count |
      Verification Status (toggle switch to mark as "Verificado")
    — Filter: Show only "Pendientes de Verificación"

═══════════════════════════════════════════════════════════════════════════════
SECTION C — NAVIGATION & FLOW MAP
═══════════════════════════════════════════════════════════════════════════════

Public Flow:    Landing → Register (role split) → Login
Buyer Flow:     Login → Catalog (filters + transparency) → Product Detail →
                Quote Simulator → Checkout → Order Tracking → Order History
Farmer Flow:    Login → Dashboard (KPIs + orders + alerts) → My Products
                (CRUD + stock) → Order Management (approve/dispatch) → Revenue Stats
Admin Flow:     Login → Research Dashboard (X1–X3, Y1–Y3 charts) →
                Sales Log Viewer → Producer Verification Panel

All navigation uses a persistent top nav bar (for buyers) or left sidebar
(for farmers/admin). Role-based routing hides unauthorized sections.
Mobile: Bottom tab navigation for the 4 main sections per role.
```

---

## PROMPT 2 — Desarrollo Full-Stack MERN Completo

> Copiar este prompt íntegro y usarlo como guía maestra para que un agente AI o equipo de desarrollo construya todo el sistema backend y frontend.

```text
You are a Senior Full-Stack Developer building "Chupaca Directo", a MERN-stack
(MongoDB, Express.js, React, Node.js) agricultural e-commerce platform. This is
an academic research project proving that e-commerce improves farmer profitability
in Chupaca province (Junín, Peru) — 2026. The research design is Pre-Experimental
(Pre/Post Test) with 30 farmers, using T-Student statistical analysis.

The system must implement 10 Functional Requirements (RF-01 to RF-10) and provide
automated data collection for 6 research dimensions from the Consistency Matrix
(X1 Accessibility, X2 Usability, X3 Market Reach, Y1 Sales Revenue, Y2 Marketing
Costs, Y3 Profit Margins).

═══════════════════════════════════════════════════════════════════════════════
PART 1 — PROJECT INITIALIZATION & ARCHITECTURE
═══════════════════════════════════════════════════════════════════════════════

1.1. Create a monorepo structure:

    chupaca-directo/
    ├── server/                    # Node.js + Express backend
    │   ├── src/
    │   │   ├── config/            # DB connection, env vars, constants
    │   │   ├── models/            # Mongoose schemas
    │   │   ├── routes/            # Express routers
    │   │   ├── controllers/       # Request handlers
    │   │   ├── services/          # Business logic layer
    │   │   ├── middlewares/       # Auth, validation, error handling, telemetry
    │   │   ├── utils/             # Helpers (slugify, formatCurrency, etc.)
    │   │   └── seeds/             # Initial data (communities, crop types, mock prices)
    │   ├── .env.example
    │   ├── package.json
    │   └── server.js              # Entry point
    ├── client/                    # React + Vite frontend
    │   ├── src/
    │   │   ├── assets/            # Images, icons
    │   │   ├── components/        # Reusable UI components
    │   │   ├── pages/             # Route-level page components
    │   │   ├── context/           # AuthContext, CartContext
    │   │   ├── hooks/             # Custom hooks (useDebounce, useFetch, etc.)
    │   │   ├── services/          # Axios API service layer
    │   │   ├── styles/            # Modular CSS files (no Tailwind)
    │   │   └── utils/             # Frontend helpers
    │   ├── index.html
    │   ├── vite.config.js
    │   └── package.json
    └── README.md

1.2. Tech Stack Details:
    • Runtime: Node.js 20 LTS
    • Backend: Express.js 4.x, Mongoose 8.x
    • Frontend: React 18+ with Vite 5+, React Router v6, Axios
    • Database: MongoDB Atlas (or local MongoDB 7+)
    • Auth: JWT (jsonwebtoken) + bcryptjs for password hashing
    • Validation: express-validator on backend, custom hooks on frontend
    • Charts: Chart.js + react-chartjs-2 (lightweight, for research dashboard)
    • File Upload: Multer + Cloudinary (or local /uploads with sharp for compression)
    • Logging: Winston (structured JSON logs for research telemetry)
    • Environment: dotenv for configuration

═══════════════════════════════════════════════════════════════════════════════
PART 2 — DATABASE SCHEMAS (MongoDB / Mongoose)
═══════════════════════════════════════════════════════════════════════════════

Define the following Mongoose schemas with proper validation, indexes, and
references. Each schema note indicates which RF and research variable it supports.

2.1. User Schema — (RF-01, RF-02, RF-03 · X2, X3)
    {
      email:            { type: String, required, unique, lowercase, trim },
      password:         { type: String, required, minlength: 8 },
      role:             { type: String, enum: ['farmer', 'buyer', 'admin'], required },
      fullName:         { type: String, required, trim },
      phone:            { type: String, required },  // +51 format
      preferredContact: { type: String, enum: ['whatsapp', 'call', 'email'] },

      // Farmer-specific fields (RF-02)
      farmerProfile: {
        dni:            { type: String },
        community:      { type: String, enum: [
          'Chupaca', 'Tres de Diciembre', 'Ahuac', 'Chongos Bajo',
          'Huachac', 'Huamancaca Chico', 'San Juan de Iscos',
          'Yanacancha', 'San Juan de Jarpa'
        ]},
        plotCoordinates: { lat: Number, lng: Number },
        experienceYears: { type: Number, min: 0 },
        mainCrops:       [{ type: String }],
        isVerified:      { type: Boolean, default: false },  // RF-03
        verifiedAt:      { type: Date },
        verifiedBy:      { type: ObjectId, ref: 'User' }
      },

      // Buyer-specific fields
      buyerProfile: {
        businessName:   { type: String },
        ruc:            { type: String },
        businessType:   { type: String, enum: [
          'wholesale_market', 'restaurant', 'exporter', 'retail', 'other'
        ]},
        deliveryAddress: { type: String }
      },

      // Research telemetry (X2: Usability)
      registrationStartedAt:   { type: Date },  // Track abandonment
      registrationCompletedAt: { type: Date },
      firstTransactionAt:      { type: Date },  // Time to first transaction

      createdAt: { type: Date, default: Date.now },
      updatedAt: { type: Date, default: Date.now }
    }
    Indexes: { email: 1 }, { role: 1, 'farmerProfile.community': 1 },
             { 'farmerProfile.isVerified': 1 }

2.2. Product Schema — (RF-04, RF-05, RF-07 · X3)
    {
      farmer:       { type: ObjectId, ref: 'User', required, index: true },
      name:         { type: String, required, trim },
      cropType:     { type: String, required, enum: [
        'papa', 'maiz', 'cebada', 'habas', 'hortalizas',
        'quinua', 'arveja', 'otros'
      ]},
      variety:      { type: String, trim },
      description:  { type: String },
      unit:         { type: String, enum: ['kg', 'arroba', 'saco', 'tonelada'], default: 'kg' },
      pricePerUnit: { type: Number, required, min: 0 },
      stock:        { type: Number, required, min: 0 },  // RF-05: real-time inventory
      photos:       [{ type: String }],  // URLs (Cloudinary or local)
      harvestDate:  { type: Date },
      isActive:     { type: Boolean, default: true },
      createdAt:    { type: Date, default: Date.now },
      updatedAt:    { type: Date, default: Date.now }
    }
    Indexes: { cropType: 1, pricePerUnit: 1 }, { stock: 1 },
             { farmer: 1, isActive: 1 },
             { name: 'text', variety: 'text', description: 'text' }  // text search RF-07

2.3. Order Schema — (RF-08, RF-09 · Y1, Y2)
    {
      buyer:          { type: ObjectId, ref: 'User', required },
      items: [{
        product:      { type: ObjectId, ref: 'Product', required },
        farmer:       { type: ObjectId, ref: 'User', required },
        productName:  { type: String },  // Snapshot at order time
        quantity:     { type: Number, required, min: 1 },
        unitPrice:    { type: Number, required },
        lineTotal:    { type: Number, required }
      }],
      subtotal:         { type: Number, required },
      shippingCost:     { type: Number, default: 0 },
      platformFee:      { type: Number, default: 0 },  // 2% commission
      totalAmount:      { type: Number, required },
      estimatedSavings: { type: Number },  // vs intermediary price (Y2)
      savingsPercent:   { type: Number },  // % saved

      deliveryAddress:  { type: String },
      deliveryDate:     { type: Date },
      buyerNotes:       { type: String },

      status: { type: String, enum: [
        'pending', 'approved', 'dispatched', 'completed', 'cancelled'
      ], default: 'pending' },

      statusHistory: [{
        status:    { type: String },
        changedAt: { type: Date, default: Date.now },
        changedBy: { type: ObjectId, ref: 'User' }
      }],

      createdAt: { type: Date, default: Date.now },
      updatedAt: { type: Date, default: Date.now }
    }
    Indexes: { buyer: 1, status: 1 }, { 'items.farmer': 1, status: 1 },
             { createdAt: -1 }

2.4. SalesLog Schema — IMMUTABLE (RF-10 · Y1, Y2, Y3)
    Purpose: Unalterable audit trail. This IS the automated "Registro de Ventas"
    instrument from the research methodology.
    {
      order:              { type: ObjectId, ref: 'Order', required, unique },
      transactionDate:    { type: Date, required, default: Date.now },
      farmer:             { type: ObjectId, ref: 'User', required },
      buyer:              { type: ObjectId, ref: 'User', required },
      products: [{
        name:     String,
        cropType: String,
        quantity: Number,
        unit:     String,
        unitPrice: Number,
        lineTotal: Number
      }],
      totalAmount:        { type: Number, required },           // Y1
      totalVolumeKg:      { type: Number, required },
      platformFeePaid:    { type: Number },                     // Y2
      estimatedSavingsVsIntermediary: { type: Number },         // Y2
      savingsPercent:     { type: Number },                     // Y2
      farmerNetRevenue:   { type: Number },                     // Y3
      farmerCommunity:    { type: String },                     // X3
      createdAt:          { type: Date, default: Date.now, immutable: true }
    }
    IMPORTANT: This collection must have NO update or delete operations exposed
    via any API route. Only the system creates entries when an order status
    transitions to 'completed'. Mark all fields as immutable after creation.
    Index: { transactionDate: -1 }, { farmer: 1 }, { farmerCommunity: 1 }

2.5. MarketPrice Schema — (RF-06 · Y2)
    Purpose: Reference prices from wholesale markets for transparency comparison.
    {
      cropType:       { type: String, required },
      cropName:       { type: String, required },
      marketName:     { type: String, required },  // e.g., "Mercado Mayorista Huancayo"
      pricePerKg:     { type: Number, required },
      source:         { type: String },  // e.g., "MIDAGRI", "Manual Entry"
      effectiveDate:  { type: Date, required },
      createdAt:      { type: Date, default: Date.now }
    }
    Index: { cropType: 1, effectiveDate: -1 }

2.6. TelemetryEvent Schema — (X1, X2)
    Purpose: Automated data collection for accessibility and usability metrics.
    {
      userId:        { type: ObjectId, ref: 'User' },
      sessionId:     { type: String },
      eventType:     { type: String, enum: [
        'page_load', 'registration_start', 'registration_abandon',
        'registration_complete', 'first_product_publish',
        'first_transaction', 'search_performed', 'filter_applied',
        'quote_simulation_start', 'order_submitted'
      ]},
      metadata: {
        pageLoadTimeMs:  Number,   // X1: load time
        deviceType:      String,   // X1: mobile/desktop/tablet
        browserName:     String,
        screenWidth:     Number,
        stepReached:     String,   // X2: for funnel analysis
        searchQuery:     String,
        filtersUsed:     [String]
      },
      timestamp: { type: Date, default: Date.now }
    }
    Index: { eventType: 1, timestamp: -1 }, { userId: 1 }

═══════════════════════════════════════════════════════════════════════════════
PART 3 — BACKEND API ROUTES & CONTROLLERS
═══════════════════════════════════════════════════════════════════════════════

Implement the following RESTful API endpoints. Every route must use:
  • JWT authentication middleware (except public routes)
  • Role-based authorization middleware (farmer, buyer, admin)
  • express-validator for input validation
  • Centralized async error handler wrapper
  • Winston structured logging

3.1. Auth Routes — /api/auth (RF-01, RF-02)
    POST /api/auth/register
      — Accepts: { email, password, role, fullName, phone, preferredContact,
          farmerProfile?: {...}, buyerProfile?: {...} }
      — Hash password with bcryptjs (10 salt rounds)
      — Record registrationStartedAt and registrationCompletedAt timestamps (X2)
      — Create TelemetryEvent: 'registration_complete'
      — Return: JWT token + user object (without password)

    POST /api/auth/login
      — Accepts: { email, password }
      — Validate credentials, return JWT token + user object
      — JWT payload: { userId, role, community? }
      — Token expiry: 7 days

    GET /api/auth/me (protected)
      — Return current user profile from token

3.2. User/Profile Routes — /api/users (RF-02, RF-03 · X3)
    GET    /api/users/profile          — Get own full profile
    PUT    /api/users/profile          — Update own profile (farmer demographics, RF-02)
    PATCH  /api/users/:id/verify       — Admin only: Toggle isVerified (RF-03), set verifiedAt/By
    GET    /api/users/farmers          — Admin: List all farmers with verification status
    GET    /api/users/stats/reach      — Admin: Aggregate { totalFarmers, totalBuyers,
                                          farmersPerCommunity, verifiedCount } (X3 metrics)

3.3. Product Routes — /api/products (RF-04, RF-05, RF-07)
    POST   /api/products               — Farmer: Create product with photo upload (RF-04)
    GET    /api/products                — Public: List with search & filters (RF-07)
           Query params: ?search=papa&cropType=papa&community=Ahuac
           &minPrice=1&maxPrice=5&minStock=10&verified=true
           &sortBy=pricePerUnit&order=asc&page=1&limit=20
           Implement MongoDB text search on name+variety+description
           and compound filtering on cropType, pricePerUnit range, stock, community (via populate)
    GET    /api/products/:id            — Public: Get product detail with farmer info
    PUT    /api/products/:id            — Farmer (owner): Update product details
    PATCH  /api/products/:id/stock      — Farmer (owner): Update stock quantity (RF-05)
           Use findOneAndUpdate with $set (or $inc for relative changes)
           with { new: true } to return updated doc.
           Validate: new stock >= 0
    DELETE /api/products/:id            — Farmer (owner): Soft-delete (set isActive: false)

3.4. Order Routes — /api/orders (RF-08, RF-09 · Y1, Y2)
    POST   /api/orders                  — Buyer: Create order (RF-08 formalization, RF-09)
           Business Logic:
           1. Validate all product IDs exist and have sufficient stock
           2. Calculate subtotal, platformFee (2% of subtotal), shippingCost
           3. Calculate estimatedSavings by comparing product prices with
              MarketPrice collection entries for the same cropType (Y2)
           4. Create order with status 'pending'
           5. Reduce stock for each product atomically using MongoDB sessions (RF-05):
              for each item: Product.findOneAndUpdate(
                { _id: item.product, stock: { $gte: item.quantity } },
                { $inc: { stock: -item.quantity } }
              )
              If any fails, abort transaction and return 409 Conflict.
           6. Create TelemetryEvent: 'order_submitted'
           7. Return created order

    GET    /api/orders                  — List own orders (filtered by role)
           Buyer: orders where buyer = userId
           Farmer: orders where items.farmer includes userId
    GET    /api/orders/:id              — Get order detail
    PATCH  /api/orders/:id/status       — Update order status (RF-09)
           Farmer can: pending → approved, approved → dispatched
           Buyer can: dispatched → completed
           Admin can: any transition + cancelled
           On transition to 'completed': (RF-10)
             1. Create SalesLog entry with all financial data
             2. Calculate farmerNetRevenue = farmer's items total - platformFee share
             3. If first completed order for this farmer, update user.firstTransactionAt (X2)
           On transition to 'cancelled':
             1. Restore stock for all items (reverse the $inc)

3.5. Market Price Routes — /api/market-prices (RF-06 · Y2)
    GET    /api/market-prices           — Public: Get latest prices for all crop types
           Return cached response (in-memory cache, TTL = 1 hour) to minimize DB hits.
           Response format: [{ cropType, cropName, marketPrice, platformAvgPrice,
           savingsPercent, source, effectiveDate }]
           platformAvgPrice is calculated by aggregating Product collection average
           price for each cropType where isActive = true.
    POST   /api/market-prices           — Admin: Add/update reference prices
    GET    /api/market-prices/compare   — Public: Side-by-side comparison table data

3.6. Sales Log Routes — /api/sales-logs (RF-10 · Y1, Y2, Y3)
    GET    /api/sales-logs              — Admin only: List all logs (paginated, filterable)
           Query params: ?startDate=&endDate=&farmerId=&community=&page=&limit=
    GET    /api/sales-logs/export       — Admin: Export as CSV (for SPSS/R import)
           Columns: TransactionID, Date, FarmerID, FarmerCommunity, BuyerID,
           Products, TotalVolumeKg, TotalAmount, PlatformFee, SavingsVsIntermediary,
           SavingsPercent, FarmerNetRevenue
    GET    /api/sales-logs/analytics    — Admin: Aggregated metrics for dashboard
           Return: {
             totalTransactions, totalRevenue, avgRevenuePerTransaction (Y1),
             avgPlatformFee, avgSavingsPercent (Y2),
             avgMarginPerFarmer, revenueOverTime (monthly array) (Y3),
             salesByDistrict, salesByCropType
           }
    IMPORTANT: NO PUT, PATCH, or DELETE routes for sales logs. Read-only.

3.7. Telemetry Routes — /api/telemetry (X1, X2)
    POST   /api/telemetry              — Public/Auth: Record telemetry event
           Accepts: { eventType, metadata: { pageLoadTimeMs, deviceType, ... } }
           This is called from the frontend automatically on key user actions.
    GET    /api/telemetry/analytics     — Admin: Aggregated telemetry for dashboard
           Return: {
             avgPageLoadTime, pageLoadByDevice (X1),
             registrationFunnelDropoff (X2),
             avgTimeToFirstTransaction (X2),
             deviceBreakdown: { mobile: %, desktop: %, tablet: % } (X1)
           }

3.8. Research Dashboard Aggregate — /api/research/dashboard (All variables)
    GET    /api/research/dashboard      — Admin: Single endpoint returning ALL
           research metrics organized by consistency matrix variables:
           {
             X1_accessibility: { avgLoadTime, deviceCompatibility, mobilePercent },
             X2_usability: { avgFirstTransactionTime, registrationAbandonRate,
                             conversionFunnel },
             X3_marketReach: { totalFarmers, verifiedFarmers, districtsWithFarmers,
                               totalProducts, farmersPerDistrict },
             Y1_salesRevenue: { totalSales, avgFrequencyPerFarmer,
                                avgRevenuePerTransaction, monthlyRevenueTrend },
             Y2_marketingCosts: { avgIntermediationCostPct, avgPlatformCostPerTx,
                                  totalSavingsGenerated },
             Y3_profitMargins: { avgNetMarginPerFarmer, incomeToTotalCostRatio,
                                 monthlyMarginTrend,
                                 preVsPostComparison: { preTestAvg, postTestAvg } }
           }

═══════════════════════════════════════════════════════════════════════════════
PART 4 — FRONTEND (React + Vite + CSS Nativo)
═══════════════════════════════════════════════════════════════════════════════

4.1. Core Setup:
    • React 18 with Vite, React Router v6 for routing
    • AuthContext: stores JWT token, user object, role. Provides login/logout/register.
    • CartContext: stores selected products with quantities for the quote simulator.
    • API Service Layer (services/api.js): Axios instance with baseURL from env,
      request interceptor to attach JWT, response interceptor for 401 redirect.
    • Telemetry Hook (hooks/useTelemetry.js): Automatically sends page_load events
      with Performance API timing data on every route change.

4.2. Route Structure:
    Public:
      /                       → LandingPage
      /login                  → LoginPage
      /register               → RegisterPage
      /catalog                → CatalogPage (browse products)
      /catalog/:id            → ProductDetailPage

    Buyer (Protected, role='buyer'):
      /buyer/simulator        → QuoteSimulatorPage
      /buyer/orders           → BuyerOrdersPage
      /buyer/orders/:id       → BuyerOrderDetailPage
      /buyer/profile          → BuyerProfilePage

    Farmer (Protected, role='farmer'):
      /farmer/dashboard       → FarmerDashboardPage
      /farmer/products        → FarmerProductsPage
      /farmer/products/new    → AddProductPage
      /farmer/products/:id    → EditProductPage
      /farmer/orders          → FarmerOrdersPage
      /farmer/revenue         → FarmerRevenuePage
      /farmer/profile         → FarmerProfilePage

    Admin (Protected, role='admin'):
      /admin/dashboard        → ResearchDashboardPage
      /admin/sales-logs       → SalesLogViewerPage
      /admin/verify-farmers   → FarmerVerificationPage
      /admin/market-prices    → MarketPriceManagerPage

4.3. Key Components to Build:
    • Navbar: Role-aware navigation with logo, search, cart icon, notifications, avatar.
    • FarmerSidebar: Dashboard sidebar navigation for farmers.
    • AdminSidebar: Dashboard sidebar for admin/research team.
    • ProductCard: Reusable card displaying product info, stock badge, CTA.
    • ProductFilters: Sidebar with crop type checkboxes, price slider, community
      select, stock minimum, verified toggle. Uses useDebounce (300ms) before API call.
    • MarketPriceTicker: Horizontal scrolling banner comparing market vs platform prices.
    • CostSimulator: Live calculator showing subtotal, shipping, fees, total, and
      savings vs intermediaries with visual comparison bar.
    • OrderStatusTimeline: Visual step indicator (Pending→Approved→Dispatched→Completed).
    • StockEditor: Inline +/- editor with debounced API call for real-time stock update.
    • KPICard: Reusable metric card with title, value, trend indicator, and sparkline.
    • ChartComponents: Wrappers around Chart.js for Line, Bar, Area, Pie, Funnel charts.
    • ChupacaDistrictMap: SVG-based map of Chupaca districts with heatmap coloring.
    • DataTable: Sortable, searchable, paginated table for sales logs.
    • ExportButton: Triggers CSV/PDF download of research data.

4.4. CSS Architecture (Sustainable, No Frameworks):
    • styles/variables.css:   All design tokens (colors, spacing, typography, shadows)
    • styles/reset.css:       Minimal CSS reset / normalize
    • styles/global.css:      Base styles, body, links, scrollbars
    • styles/components/:     One CSS file per component (ProductCard.css, Navbar.css, etc.)
    • styles/pages/:          Page-specific layout styles
    • Use CSS custom properties (var(--color-primary)) everywhere.
    • Mobile-first media queries using the 3 breakpoints.
    • CSS Grid for page layouts, Flexbox for component internals.
    • Smooth transitions (200ms ease-out) on interactive elements.
    • Skeleton loading animations using CSS @keyframes (no JS libraries).

═══════════════════════════════════════════════════════════════════════════════
PART 5 — MIDDLEWARE & CROSS-CUTTING CONCERNS
═══════════════════════════════════════════════════════════════════════════════

5.1. Authentication Middleware:
    • Verify JWT from Authorization: Bearer <token> header
    • Attach decoded user to req.user
    • Return 401 if missing/invalid/expired

5.2. Role Authorization Middleware:
    • authorize('farmer', 'admin') → checks req.user.role against allowed roles
    • Return 403 if unauthorized

5.3. Validation Middleware:
    • Use express-validator chains per route
    • Centralized validationResult handler that returns 400 with field-level errors

5.4. Error Handler:
    • Global async error wrapper (catchAsync)
    • AppError class with statusCode and isOperational flag
    • Development: full stack trace. Production: clean error messages only.

5.5. Telemetry Middleware:
    • On every request: log { method, url, statusCode, responseTimeMs, userId }
    • On specific routes (registration, order creation): create TelemetryEvent entries
    • Calculate and expose X-Response-Time header for frontend consumption

5.6. Security:
    • helmet() for HTTP headers
    • cors() configured for frontend origin
    • express-rate-limit: 100 req/15min per IP for auth routes
    • express-mongo-sanitize to prevent NoSQL injection
    • hpp to prevent HTTP parameter pollution

═══════════════════════════════════════════════════════════════════════════════
PART 6 — SEED DATA & INITIAL CONFIGURATION
═══════════════════════════════════════════════════════════════════════════════

Create a seed script (server/src/seeds/seed.js) that populates:
  • 1 Admin user (admin@chupacadirecto.pe)
  • 5 sample Farmer users across different Chupaca communities (all verified)
  • 3 sample Buyer users
  • 15 sample Products (3 per farmer: papa, maíz, hortalizas varieties)
  • 10 MarketPrice entries for reference comparison
  • 3 sample completed Orders with corresponding SalesLog entries

═══════════════════════════════════════════════════════════════════════════════
PART 7 — TESTING & VERIFICATION STRATEGY
═══════════════════════════════════════════════════════════════════════════════

7.1. Backend Tests:
    • Unit tests for services (cost calculation, savings computation)
    • Integration tests for critical flows:
      - Registration → Login → Create Product → Create Order → Complete → SalesLog created
      - Concurrent stock reduction (2 buyers ordering same product simultaneously)
      - Immutability of SalesLog (attempt PUT/DELETE should return 404/405)

7.2. Frontend Verification:
    • Manual checklist: every screen renders on mobile (375px) and desktop (1440px)
    • Lighthouse CI: LCP < 2.0s, Accessibility > 95% (X1 metric compliance)
    • All interactive elements have unique id attributes for E2E test targeting

7.3. Research Data Verification:
    • Export SalesLog to CSV and validate columns match SPSS variable definitions
    • Verify telemetry events capture all X1/X2 metrics
    • Confirm /api/research/dashboard returns all 6 dimension aggregations
    • Test pre/post comparison endpoint with mock historical data

═══════════════════════════════════════════════════════════════════════════════
PART 8 — DEPLOYMENT (Sustainable & Cost-Effective)
═══════════════════════════════════════════════════════════════════════════════

    • Backend: Deploy on Render.com (free tier) or Railway.app
    • Frontend: Deploy on Vercel (free tier, automatic Vite optimization)
    • Database: MongoDB Atlas free tier (512MB, sufficient for 30 farmers)
    • Images: Cloudinary free tier (25GB bandwidth/month)
    • Domain: chupacadirecto.pe (optional, .pe domain from NIC Peru)
    • SSL: Automatic via hosting providers
    • Environment variables: MONGO_URI, JWT_SECRET, CLOUDINARY_URL, CLIENT_URL
```

---

