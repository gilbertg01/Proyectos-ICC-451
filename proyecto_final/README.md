# Descripción General

La aplicación Pokedex proporciona una interfaz intuitiva para explorar y buscar información detallada sobre Pokémon. Utiliza una API GraphQL para recuperar datos y presentarlos de forma dinámica. Los usuarios pueden ver listados de Pokémon, filtrar por tipo o generación, y explorar detalles como estadísticas, movimientos y evoluciones.

# Estructura del Proyecto

El proyecto está estructurado de manera modular para facilitar el mantenimiento y la escalabilidad:

- `lib/`: Carpeta principal que contiene el código fuente de Dart.
    - `entidades/`: Modelos de datos.
        - `pokemon_data.dart`: Información básica del Pokémon.
        - `pokemon_info.dart`: Detalles adicionales como hábitat y tasa de crecimiento.
        - `pokemon_more_info.dart`: Detalles como altura, peso y habilidades.
        - `pokemon_stats.dart`: Estadísticas del Pokémon.
        - `pokemon_evolution.dart`: Detalles sobre la cadena evolutiva.
    - `fonts/`: Fuentes personalizadas.
        - `Pokemon-Bold.ttf`
        - `Pokemon-Normal.ttf`
    - `images/`: Imágenes de la interfaz de usuario.
        - `pokeball.svg`
    - `servicios/`: Maneja las consultas a la API.
        - `graphql_calls.dart`: Define las consultas GraphQL.
        - `graphql_service.dart`: Configuración del cliente GraphQL.
    - `vistas/`: Pantallas principales de la aplicación.
        - `home.dart`: Pantalla inicial con listado de Pokémon.
        - `perfil_pokemon.dart`: Detalles de un Pokémon seleccionado.
    - `widgets/`: Componentes reutilizables de la interfaz.
        - `pokemon_card.dart`: Tarjetas de Pokémon en la vista principal.
        - `stats_widget.dart`: Presenta estadísticas del Pokémon.
        - `movimientos_widget.dart`: Lista de movimientos del Pokémon.
        - `evoluciones_widget.dart`: Muestra la cadena evolutiva.
        - Otros widgets para mostrar diferentes secciones de información.

# Uso de la API

La aplicación hace uso de la [API GraphQL](https://beta.pokeapi.co/graphql/console/) para obtener información sobre los Pokémon. Las consultas permiten recuperar datos básicos, evoluciones, estadísticas y más.

## Endpoints Utilizados

- `pokemon_v2_pokemon`: Lista de Pokémon con sus datos básicos.
- `pokemon_v2_pokemonspecy`: Detalles específicos como cadena evolutiva.
- `pokemon_v2_pokemonstats`: Estadísticas base del Pokémon.
- `pokemon_v2_pokemonmoves`: Lista de movimientos del Pokémon.

# Librerías Principales Utilizadas

- `graphql_flutter`: Para realizar consultas GraphQL.
- `cached_network_image`: Carga y almacenamiento en caché de imágenes.
- `flutter_svg`: Muestra imágenes SVG.
- `pull_to_refresh`: Funcionalidad de actualización de la vista.
- `flutter_speed_dial`: Menú de acceso rápido.

# Características

- **Listado de Pokémon**: Muestra un grid de tarjetas con el nombre e imagen de cada Pokémon, coloreadas según su tipo.
- **Filtros Avanzados**: Permite filtrar Pokémon por tipo o generación.
- **Perfil de Pokémon**:
    - **Información General**: Peso, altura, habilidades, descripción.
    - **Estadísticas**: HP, ataque, defensa, entre otros.
    - **Movimientos**: Lista de movimientos disponibles.
    - **Evoluciones**: Cadena evolutiva visualizada.
- **Transiciones Dinámicas**: Transición animada entre el listado y el perfil del Pokémon seleccionado.

# Problemas Conocidos y Soluciones

- **Optimización de Imágenes**: Se utiliza `cached_network_image` para reducir el tiempo de carga y consumo de datos.
- **Transiciones y Navegación**: Actualmente en desarrollo para implementar una navegación fluida entre pantallas.
- **Consistencia Visual**: Uso de colores y tipografía personalizada para mantener una estética coherente y temática.

