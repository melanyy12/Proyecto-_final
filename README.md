Hackathon Code4Future 2025
Sistema de gestión integral para hackathons desarrollado en Elixir con arquitectura OTP y soporte para nodos distribuidos.Características Principales

- Gestión Completa: Equipos, proyectos, participantes y mentores
- Chat en Tiempo Real: Distribuido entre múltiples nodos
- Salas Temáticas: Networking, soporte técnico, ideación
- Sistema de Mentoría: Retroalimentación de expertos
- Autenticación Segura: Contraseñas hasheadas + sesiones ETS
- Arquitectura Distribuida: Sincronización automática entre PCs
- Alta Disponibilidad: Supervisores OTP y auto-reconexión
- Métricas en Vivo: Dashboard con estadísticas del sistema

Equipo de Desarrollo
melanyy12(Participantes, mentores, autenticación, CLI)
Mauro251006(Equipos, proyectos, chat, OTP)

 Inicio Rápido
Requisitos Previos

Elixir 1.14+
Erlang/OTP 24+

Verificar instalación:
bashelixir --version
# Elixir 1.14.x (compiled with Erlang/OTP 24)
Instalación
bash# 1. Clonar repositorio
git clone https://github.com/TU_USUARIO/hackathon-code4future.git
cd hackathon-code4future

# 2. Instalar dependencias
mix deps.get
mix compile

# 3. Ejecutar tests
mix test

# 4. Iniciar aplicación
mix run -e "Hackathon.CLI.main()"
Credenciales por Defecto
 Contraseña universal: password123
 Contraseña admin: ingreso123

 Correos de ejemplo:
   juan.perez@email.com
   maria.garcia@email.com
   roberto.garcia@mentor.com (mentor)




 Arquitectura
┌─────────────────────────────────────────┐
│           INTERFAZ (CLI)                │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│        CAPA DE SERVICIOS                │
│  - GestionEquipos                       │
│  - GestionProyectos                     │
│  - SistemaChat (GenServer Global)       │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│        CAPA DE DOMINIO                  │
│  - Equipo, Proyecto, Participante       │
│  - Validadores                          │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│       CAPA DE PERSISTENCIA              │
│  - Repositorios (data/*.txt)            │
└─────────────────────────────────────────┘
Patrón: Arquitectura Hexagonal + OTP Supervision

 Modo Distribuido
Conectar Múltiples PCs
PC 1:
bashiex --sname nodo1 -S mix
elixir# En IEx
Hackathon.CLI.main([])
# Menú 5 → Opción 9 → Ver estado del cluster
PC 2:
bashiex --sname nodo2 -S mix
elixirHackathon.CLI.main([])
# Menú 5 → Opción 9 → Opción 2 (Conectar a nodo)
# Ingresar: nodo1@nombre-pc1
Verificar conexión:
elixirNode.list()
# [:nodo1@pc1]

 Tests
Tests Unitarios
bashmix test
Tests de Rendimiento
bashmix test --only performance
Resultados esperados:

 1000 mensajes concurrentes: ~500-1000ms
 Throughput: ~1000-2000 msg/seg
 100 equipos concurrentes: ~200ms


 Estructura del Proyecto
hackathon/
├── lib/
│   └── hackathon/
│       ├── Adapters/           # Persistencia
│       ├── Domain/             # Entidades
│       ├── Services/           # Lógica de aplicación
│       ├── Distribucion/       # Sistema distribuido
│       ├── Metricas/           # Monitoreo
│       ├── Seguridad/          # Cifrado
│       ├── application.ex      # Supervisor OTP
│       ├── cli.ex              # Interfaz usuario
│       └── semilla.ex          # Datos iniciales
├── test/
│   ├── hackathon_test.exs
│   └── performance_test.exs
├── docs/                       # Documentación
├── data/                       # Persistencia (gitignored)
└── mix.exs

 Tecnologías Utilizadas

Elixir 1.14+ - Lenguaje funcional
Erlang/OTP - Plataforma de alta concurrencia
GenServer - Procesos concurrentes
ETS - Base de datos en memoria
:crypto - Criptografía (SHA-256, AES-256-GCM)
Mix - Herramienta de construcción


 Contribuir

Fork el proyecto
Crea tu feature branch (git checkout -b feature/AmazingFeature)
Commit tus cambios (git commit -m 'Add some AmazingFeature')
Push al branch (git push origin feature/AmazingFeature)
Abre un Pull Request







