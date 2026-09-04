# War_Ants

## Descripción

**War_Ants** es un juego de estrategia en tiempo real (RTS) centrado en la simulación y gestión de una colonia de hormigas.

El jugador controla grupos de hormigas, administra los recursos de la colonia, explora y modifica el hormiguero, recolecta alimento y se enfrenta a otros insectos y amenazas del entorno.

El proyecto busca combinar elementos de estrategia con características inspiradas en el comportamiento y la biología real de las hormigas.

## Características

### 🐜 Colonia y hormigas

- Diferentes especies y castas, cada una con características y funciones propias.
- Sistema de estadísticas para definir las características de cada casta.
- Las hormigas se representan mediante grupos, permitiendo controlar varias hormigas como una sola unidad.
- Cada grupo mantiene información sobre su estado, cantidad de integrantes, velocidad, carga, vida y capacidades de combate.
- Selección individual y selección múltiple de grupos.
- Selección mediante arrastre.
- Formaciones para el movimiento de varios grupos.

### 🌿 Recolección de recursos

- Sistema de recolección de hojas.
- Puntos de recursos con cantidad disponible y tiempo de regeneración.
- Sistema de reserva de recursos para evitar que varios grupos intenten recolectar el mismo recurso.
- Las hormigas pueden desplazarse hasta los árboles, subir hasta los puntos de recolección y transportar los recursos de regreso al hormiguero.
- La carga transportada afecta la velocidad del grupo.
- Almacenamiento de hojas dentro del hormiguero.

### 🌳 Árboles e interacción con el entorno

- Los árboles poseen un interior propio que puede ser visualizado por el jugador.
- Las hormigas pueden entrar y salir de los árboles.
- Sistema visual de hormigas escaladoras durante la recolección.
- Los puntos de hojas pueden quedar ocupados temporalmente mientras son utilizados.

### ⚔️ Combate

- Sistema básico de combate entre grupos de hormigas e insectos.
- Detección automática de enemigos mediante áreas de detección.
- Los grupos pueden entrar en estado de combate al detectar un enemigo.
- Sistema de daño y reducción progresiva del número de integrantes del grupo.
- Los grupos pueden perseguir a sus objetivos dentro de un radio determinado.
- Los grupos pueden regresar a su comportamiento anterior después del combate.

### 🕳️ Hormiguero y niveles subterráneos

- Sistema de múltiples pisos dentro del hormiguero.
- Cambio de vista entre la superficie y los diferentes niveles subterráneos.
- Navegación independiente dentro de los pisos.
- Construcción de túneles.
- Construcción de cámaras.
- Eliminación de estructuras excavadas.
- Puntos de conexión entre diferentes niveles del hormiguero y la superficie.
- Las hormigas pueden desplazarse entre los diferentes niveles utilizando estas conexiones.

### 🧭 Navegación y órdenes

- Movimiento mediante navegación en la superficie.
- Navegación mediante caminos dentro de los niveles subterráneos.
- Sistema de órdenes de movimiento.
- Sistema de patrulla mediante múltiples puntos.
- Formación automática al enviar varios grupos a una posición.
- Posibilidad de enviar todos los grupos a una posición mediante doble clic.

### 🐣 Producción de grupos

- Sistema de cola para la creación de nuevos grupos.
- Coste de creación basado en los recursos almacenados.
- Tiempo de producción configurable para cada casta.
- Visualización del progreso de producción.
- Posibilidad de cancelar elementos de la cola.

## Controles

| Tecla / Acción | Función |
|---|---|
| **W, A, S, D** | Mover la cámara |
| **Mouse izquierdo** | Seleccionar grupos / interactuar con el entorno |
| **Arrastrar con mouse izquierdo** | Seleccionar múltiples grupos |
| **Shift + selección** | Añadir grupos a la selección |
| **Mouse derecho** | Mover grupos |
| **Doble clic derecho** | Mover todos los grupos |
| **Rueda del mouse** | Zoom |
| **R** | Activar modo de recolección |
| **Z + clic derecho** | Crear puntos de patrulla |
| **Z** | Enviar los grupos seleccionados a la patrulla creada |
| **0–9** | Cambiar entre superficie y pisos subterráneos |
| **T** | Modo de excavación de túneles |
| **C** | Modo de construcción de cámaras |
| **E** | Modo de eliminación |
| **V** | Crear conexión hacia un piso inferior |
| **B** | Crear conexión hacia la superficie |
| **ESC** | Cancelar el modo actual / salir de una vista interior |

## Estructura

```text
War_Ants/
│
├── assets/
│   └── Recursos gráficos, sprites, animaciones y otros recursos.
│
├── data/
│   └── stats/
│       └── Datos y estadísticas de especies y castas.
│
├── docs/
│   └── Documentación relacionada con la biología,
│       diseño y desarrollo del juego.
│
├── scenes/
│   └── Escenas utilizadas por el proyecto.
│
├── scripts/
│   └── Scripts de lógica y comportamiento del juego.
│
└── project.godot
```

## Sistemas principales

Actualmente el proyecto cuenta con varios sistemas funcionales que se encuentran en diferentes niveles de desarrollo:

- Gestión de grupos de hormigas.
- Selección de unidades.
- Movimiento y navegación.
- Formaciones.
- Patrullaje.
- Recolección y transporte de hojas.
- Sistema de recursos.
- Interacción con árboles.
- Interior de árboles.
- Combate básico.
- Detección de enemigos.
- Producción mediante cola.
- Sistema de pisos subterráneos.
- Excavación de túneles.
- Construcción de cámaras.
- Eliminación de estructuras.
- Conexiones entre niveles.
- Cambio de vista entre superficie y hormiguero.
- Sistema de tipos de terreno/cámaras.
- Interfaz para información de castas y grupos.

## Estado actual

War_Ants se encuentra actualmente en una **etapa de prototipo jugable y desarrollo activo**.

El proyecto ya cuenta con una base funcional de los principales sistemas de juego: movimiento, selección, patrullaje, recolección, transporte de recursos, producción de grupos, combate y navegación dentro del hormiguero.

También se ha comenzado a desarrollar la estructura subterránea del hormiguero, incluyendo diferentes pisos, excavación de túneles y cámaras y conexiones entre niveles.

La prioridad actual del desarrollo es consolidar estos sistemas, mejorar su integración y establecer una arquitectura capaz de soportar colonias de gran tamaño sin comprometer el rendimiento.

## Biología y especies

Una parte importante del proyecto está dedicada a la investigación de las especies y castas que pueden formar parte del juego.

La documentación biológica se encuentra en:

```text
docs/
```

Los datos utilizados por el juego se encuentran principalmente en:

```text
data/stats/
```

El objetivo es que las diferentes especies y castas tengan diferencias significativas en comportamiento, estadísticas y funciones dentro de la colonia.

## Instalación

Para ejecutar el proyecto:

1. Descarga o clona este repositorio.
2. Abre **Godot Engine**.
3. Importa el proyecto desde la carpeta del repositorio.
4. Abre el proyecto.
5. Ejecuta el proyecto desde el editor.

## Desarrollo

War_Ants se encuentra en desarrollo activo. Las mecánicas actuales pueden sufrir modificaciones importantes a medida que evoluciona la arquitectura del juego.

Entre los sistemas previstos para futuras versiones se encuentran:

- Mejoras al sistema de combate.
- Mayor variedad de enemigos.
- Alimentación y necesidades de la colonia.
- Reproducción y crecimiento de la colonia.
- Construcción y gestión avanzada del hormiguero.
- Sistemas de comportamiento y organización de la colonia.
- Mayor variedad de recursos.
- Nuevas especies y castas.
- Eventos y condiciones ambientales.
- Modo historia.
- Modo supervivencia.
- Multijugador.

## Tecnologías

- **Godot Engine**
- **GDScript**
- **Git / GitHub**

## Autor

Proyecto desarrollado por **JNDNCZAS**.

War_Ants es un proyecto experimental y educativo enfocado en el desarrollo de videojuegos, programación, simulación y representación de sistemas biológicos mediante mecánicas de estrategia.
