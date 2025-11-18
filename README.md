<div align="center">

#  Hackathon Code4Future 2025

### Sistema de Gestión Integral para Hackathons

[![Elixir](https://img.shields.io/badge/Elixir-1.14+-4B275F?style=for-the-badge&logo=elixir&logoColor=white)](https://elixir-lang.org/)
[![Erlang/OTP](https://img.shields.io/badge/Erlang%2FOTP-24+-A90533?style=for-the-badge&logo=erlang&logoColor=white)](https://www.erlang.org/)
[![License](https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge)](LICENSE)

**Plataforma distribuida desarrollada en Elixir para organizar y gestionar hackathons con colaboración en tiempo real**

[Características](#-características-principales) •
[Instalación](#-instalación) •
[Uso](#-uso) •
[Arquitectura](#-arquitectura) •
[Documentación](#-documentación)

</div>

---

##  **Tabla de Contenidos**

- [Descripción](#-descripción)
- [Características Principales](#-características-principales)
- [Tecnologías](#️-tecnologías-utilizadas)
- [Requisitos Previos](#-requisitos-previos)
- [Instalación](#-instalación)
- [Uso](#-uso)
- [Arquitectura](#-arquitectura)
- [Modo Distribuido](#-modo-distribuido)
- [Testing](#-testing)
- [Credenciales](#-credenciales-de-acceso)
- [Estructura del Proyecto](#-estructura-del-proyecto)
- [Contribuir](#-contribuir)
- [Equipo](#-equipo-de-desarrollo)
- [Licencia](#-licencia)

---

##  **Descripción**

**Hackathon Code4Future 2025** es un sistema integral de gestión para eventos de innovación y desarrollo colaborativo. Permite a los organizadores administrar equipos, proyectos, participantes y mentores de manera eficiente, con comunicación en tiempo real y sincronización automática entre múltiples nodos.

### **¿Por qué este proyecto?**

Durante las hackathons, gestionar la comunicación, formación de equipos, registro de ideas y seguimiento de avances puede ser caótico. Este sistema centraliza todas estas actividades, mejorando significativamente la experiencia de participantes y organizadores.

---

##  **Características Principales**

###  **Gestión Completa**

- **Equipos**: Creación, asignación de miembros, límites configurables (máx. 6 miembros)
- **Proyectos**: Registro de ideas, seguimiento de avances, cambio de estados
- **Participantes**: Registro con autenticación segura, habilidades, asignación a equipos
- **Mentores**: Especialidades, asignación a equipos, retroalimentación experta

###  **Comunicación en Tiempo Real**

- **Chat por Equipo**: Canal privado para cada equipo
- **Canal General**: Anuncios de organización visibles para todos
- **Salas Temáticas**: Networking, soporte técnico, ideación
- **Sistema Distribuido**: Sincronización automática entre múltiples nodos

###  **Seguridad**

- **Autenticación**: Contraseñas hasheadas con SHA-256
- **Sesiones**: Manejo seguro con ETS (Erlang Term Storage)
- **Cifrado**: Mensajes cifrados con AES-256-GCM
- **Control de Acceso**: Protección de datos sensibles con contraseña administrativa

###  **Distribución y Alta Disponibilidad**

- **Nodos Distribuidos**: Ejecución en múltiples PCs simultáneamente
- **Auto-Reconexión**: Reintento automático cuando un nodo se desconecta
- **Broadcasting**: Sincronización de mensajes y eventos en todo el cluster
- **Dashboard en Vivo**: Monitoreo en tiempo real del estado del cluster

###  **Métricas y Monitoreo**

- **Dashboard de Sistema**: Estadísticas de uso, memoria, procesos
- **Métricas de Rendimiento**: Throughput, latencia, concurrencia
- **Estadísticas del Cluster**: Estado de nodos, datos distribuidos

---

##  **Tecnologías Utilizadas**

| Tecnología | Versión | Propósito |
|------------|---------|-----------|
| **Elixir** | 1.14+ | Lenguaje funcional y concurrente |
| **Erlang/OTP** | 24+ | Plataforma de alta disponibilidad |
| **GenServer** | Built-in | Procesos concurrentes |
| **ETS** | Built-in | Base de datos en memoria |
| **:crypto** | Built-in | Cifrado SHA-256, AES-256-GCM |
| **Mix** | Built-in | Herramienta de construcción y testing |

### **Arquitectura del Sistema**
```
┌─────────────────────────────────────────┐
│         INTERFAZ CLI (Menú)             │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│       CAPA DE SERVICIOS                 │
│  • GestionEquipos                       │
│  • GestionProyectos                     │
│  • GestionParticipantes                 │
│  • GestionMentores                      │
│  • SistemaChat (GenServer Global)       │
│  • Autenticacion                        │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│       CAPA DE DOMINIO                   │
│  • Equipo, Proyecto, Participante       │
│  • Mentor, Mensaje, Sala                │
│  • Validadores de Negocio               │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│     CAPA DE PERSISTENCIA                │
│  • RepositorioEquipos                   │
│  • RepositorioProyectos                 │
│  • RepositorioParticipantes             │
│  • RepositorioMentores                  │
│  • RepositorioMensajes                  │
└─────────────────────────────────────────┘
```

**Patrón de Diseño**: Arquitectura Hexagonal + OTP Supervision Tree

---

##  **Requisitos Previos**

Antes de comenzar, asegúrate de tener instalado:

- **Elixir** 1.14 o superior
- **Erlang/OTP** 24 o superior

### **Verificar Instalación**
```bash
elixir --version
# Elixir 1.14.x (compiled with Erlang/OTP 24)
```

### **Instalar Elixir (si es necesario)**

**macOS:**
```bash
brew install elixir
```

**Ubuntu/Debian:**
```bash
sudo apt-get update
sudo apt-get install elixir
```

**Windows:**
- Descargar desde [elixir-lang.org](https://elixir-lang.org/install.html)

---

##  **Instalación**

### **1. Clonar el Repositorio**
```bash
git clone https://github.com/melanyy12/hackathon-code4future.git
cd hackathon-code4future
```

### **2. Instalar Dependencias**
```bash
mix deps.get
mix compile
```

### **3. Ejecutar Tests (Opcional)**
```bash
# Tests unitarios
mix test

# Tests de rendimiento
mix test --only performance
```

### **4. Iniciar la Aplicación**
```bash
mix run -e "Hackathon.CLI.main()"
```

---

##  **Uso**

### **Inicio Rápido**

1. **Ejecutar el sistema:**
```bash
   mix run -e "Hackathon.CLI.main()"
```

2. **Navegar por el menú principal:**
```
   =============== MENU PRINCIPAL ================
   
    1. CONSULTAS
    2. REGISTROS
    3. COLABORACION
    4. ELIMINACION
    5. SISTEMA
   
    0. Salir
   
   ===============================================
```

3. **Flujo recomendado para nuevos usuarios:**
   - `2 → 1`: Registrar nuevo participante
   - `1 → 1`: Ver equipos disponibles
   - `2 → 2`: Unirse a un equipo
   - `3 → 3`: Enviar mensajes al equipo
   - `3 → 1`: Agregar avances al proyecto

### **Funcionalidades por Menú**

#### **1️ CONSULTAS**
- Ver todos los equipos
- Ver todos los proyectos
- Buscar proyecto por equipo
- Filtrar proyectos por estado
- Ver participantes (requiere contraseña)
- Ver mentores (requiere contraseña)

#### **2️ REGISTROS**
- Registrar nuevo participante
- Unirse a un equipo
- Crear nuevo equipo
- Crear nuevo proyecto
- Registrar nuevo mentor
- Asignar mentor a equipo
- Cambiar estado de proyecto

#### **3️ COLABORACIÓN**
- Agregar avance a proyecto
- Ver chat de equipo
- Enviar mensaje a equipo
- Ver canal general de anuncios
- Enviar anuncio general (mentor)
- Dar retroalimentación (mentor)
- Gestionar salas temáticas
- Ver métricas del sistema

#### **4 ELIMINACIÓN**
- Eliminar participante (requiere contraseña)
- Eliminar mentor (requiere contraseña)
- Eliminar equipo
- Eliminar proyecto

#### **5️ SISTEMA**
- Ayuda y comandos
- Recargar datos
- Cluster Distribuido (Nodos)

---

##  **Modo Distribuido**

El sistema puede ejecutarse en múltiples computadoras conectadas en red.

### **Conectar Múltiples Nodos**

**PC 1 (Nodo Principal):**
```bash
iex --sname nodo1 -S mix
```

Luego en IEx:
```elixir
Hackathon.CLI.main([])
# Navegar: Menú 5 → Opción 3 → Opción 1 (Ver estado del cluster)
```

**PC 2 (Nodo Secundario):**
```bash
iex --sname nodo2 -S mix
```

Luego en IEx:
```elixir
Hackathon.CLI.main([])
# Navegar: Menú 5 → Opción 3 → Opción 2 (Conectar a nodo)
# Ingresar: nodo1@nombre-pc1
```

### **Verificar Conexión**
```elixir
Node.list()
# [:nodo1@pc1]
```

### **Características del Cluster**

-  **Sincronización automática** de equipos, proyectos y mensajes
-  **Auto-reconexión** si un nodo se desconecta
-  **Dashboard en tiempo real** con estadísticas de todos los nodos
-  **Broadcasting** de eventos a todo el cluster
-  **Notificaciones visuales** cuando nodos se conectan/desconectan

---

##  **Testing**

### **Tests Unitarios**
```bash
mix test
```

**Cobertura:**
- Gestión de equipos
- Gestión de proyectos
- Gestión de participantes y mentores
- Sistema de chat
- Validadores de dominio
- Flujo de integración completo

### **Tests de Rendimiento**
```bash
mix test --only performance
```

**Pruebas incluidas:**

| Prueba | Objetivo | Resultado Esperado |
|--------|----------|-------------------|
| 1000 mensajes concurrentes | Throughput del chat | ~1000-2000 msg/seg |
| 100 equipos simultáneos | Creación concurrente | <200ms |
| Múltiples canales | Aislamiento de mensajes | Sin mezcla de datos |
| Simulación hackathon completa | Sistema bajo carga real | 50 equipos, 150 participantes |

### **Ejemplo de Output**
```
═══════════════════════════════════════════
   PRUEBA COMPLETADA: Chat - 1000 mensajes
═══════════════════════════════════════════
   Mensajes enviados: 1000/1000
   Tiempo total: 500ms
   Promedio: 0.5ms/mensaje
   Throughput: 2000 msg/seg
═══════════════════════════════════════════
```

---

##  **Credenciales de Acceso**

### **Contraseña Universal para Usuarios**
```
password123
```

### **Contraseña Administrativa**
```
ingreso123
```
*Requerida para ver/eliminar participantes y mentores*

### **Participantes de Ejemplo**

| Nombre | Correo | Habilidades |
|--------|--------|-------------|
| Juan Perez | `juan.perez@email.com` | Backend, Elixir |
| Maria Garcia | `maria.garcia@email.com` | Frontend, React |
| Carlos Lopez | `carlos.lopez@email.com` | IA, Python |
| Ana Martinez | `ana.martinez@email.com` | UX/UI, Figma |

### **Mentores de Ejemplo**

| Nombre | Correo | Especialidad |
|--------|--------|-------------|
| Dr. Roberto Garcia | `roberto.garcia@mentor.com` | Inteligencia Artificial |
| Ing. Patricia Lopez | `patricia.lopez@mentor.com` | Desarrollo Backend |
| Arq. Fernando Ruiz | `fernando.ruiz@mentor.com` | Arquitectura de Software |

---

##  **Estructura del Proyecto**
```
hackathon/
├── lib/
│   └── hackathon/
│       ├── Adapters/              # Capa de persistencia
│       │   ├── RepositorioEquipos.ex
│       │   ├── RepositorioProyectos.ex
│       │   ├── RepositorioParticipantes.ex
│       │   ├── RepositorioMentores.ex
│       │   ├── RepositorioMensajes.ex
│       │   └── RepositorioSalas.ex
│       │
│       ├── Domain/                # Entidades de dominio
│       │   ├── Equipo.ex
│       │   ├── Proyecto.ex
│       │   ├── Participante.ex
│       │   ├── Mentor.ex
│       │   ├── Mensaje.ex
│       │   ├── Sala.ex
│       │   ├── ValidadorEquipo.ex
│       │   ├── ValidadorProyecto.ex
│       │   └── ValidadorParticipante.ex
│       │
│       ├── Services/              # Lógica de negocio
│       │   ├── GestionEquipos.ex
│       │   ├── GestionProyectos.ex
│       │   ├── GestionParticipantes.ex
│       │   ├── GestionMentores.ex
│       │   ├── GestionSalas.ex
│       │   ├── SistemaChat.ex
│       │   ├── ChatCifrado.ex
│       │   └── Autenticacion.ex
│       │
│       ├── Distribucion/          # Sistema distribuido
│       │   ├── Nodo.ex
│       │   ├── AutoReconexion.ex
│       │   ├── Dashboard.ex
│       │   └── Notificador.ex
│       │
│       ├── Metricas/              # Monitoreo
│       │   ├── Monitor.ex
│       │   └── Visualizador.ex
│       │
│       ├── Seguridad/             # Cifrado
│       │   └── Cifrado.ex
│       │
│       ├── application.ex         # Supervisor OTP
│       ├── cli.ex                 # Interfaz usuario
│       └── semilla.ex             # Datos iniciales
│
├── test/
│   ├── hackathon_test.exs         # Tests unitarios
│   ├── performance_test.exs       # Tests de rendimiento
│   └── test_helper.exs            # Configuración tests
│
├── data/                          # Persistencia (gitignored)
│   ├── equipos.txt
│   ├── proyectos.txt
│   ├── participantes.txt
│   ├── mentores.txt
│   ├── mensajes.txt
│   └── salas.txt
│
├── .gitignore
├── mix.exs                        # Configuración del proyecto
├── mix.lock                       # Lock de dependencias
└── README.md                      # Este archivo
```

---

##  **Contribuir**

Las contribuciones son bienvenidas. Para contribuir:

1. **Fork** el proyecto
2. Crea una **rama** para tu feature (`git checkout -b feature/AmazingFeature`)
3. **Commit** tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. **Push** a la rama (`git push origin feature/AmazingFeature`)
5. Abre un **Pull Request**

### **Estándares de Código**

- Seguir las convenciones de Elixir
- Documentar funciones públicas con `@doc`
- Agregar tests para nuevas funcionalidades
- Mantener la cobertura de tests >80%

---

##  **Equipo de Desarrollo**

<table>
  <tr>
    <td align="center">
      <a href="https://github.com/melanyy12">
        <img src="https://github.com/melanyy12.png" width="100px;" alt=""/>
        <br />
        <sub><b>melanyy12</b></sub>
      </a>
      <br />
      <sub>Participantes, Mentores, Autenticación, CLI</sub>
    </td>
    <td align="center">
      <a href="https://github.com/Mauro251006">
        <img src="https://github.com/Mauro251006.png" width="100px;" alt=""/>
        <br />
        <sub><b>Mauro251006</b></sub>
      </a>
      <br />
      <sub>Equipos, Proyectos, Chat, OTP, Distribución</sub>
    </td>
  </tr>
</table>

---

##  **Licencia**

Este proyecto está bajo la Licencia MIT. Ver el archivo [LICENSE](LICENSE) para más detalles.

---