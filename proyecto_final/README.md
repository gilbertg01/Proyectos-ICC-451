# Descripción General

La aplicación **Pokedex** proporciona una interfaz intuitiva para explorar y buscar información detallada sobre Pokémon. Utiliza una API **GraphQL** para recuperar datos y presentarlos de forma dinámica. Los usuarios pueden ver listados de Pokémon, filtrar por tipo o generación, y explorar detalles como estadísticas, movimientos, habilidades y evoluciones. Además, se han agregado nuevas funcionalidades que mejoran la interactividad y eficiencia de la aplicación.

# Estructura del Proyecto

El proyecto está estructurado de manera modular para facilitar el mantenimiento y escalabilidad:

- **`lib/`**: Carpeta principal que contiene el código fuente de Dart.
    - **`entidades/`**: Modelos de datos.
        - `pokemon_data.dart`: Información básica del Pokémon, como nombre, imagen, y tipos.
        - `pokemon_info.dart`: Detalles adicionales como hábitat y tasa de crecimiento.
        - `pokemon_more_info.dart`: Información adicional como altura, peso y habilidades.
        - `pokemon_stats.dart`: Estadísticas del Pokémon como HP, ataque, defensa, etc.
        - `pokemon_evolution.dart`: Información sobre la cadena evolutiva del Pokémon.
    - **`fonts/`**: Fuentes personalizadas.
        - `Pokemon-Bold.ttf`: Fuente en negrita.
        - `Pokemon-Normal.ttf`: Fuente normal.
    - **`images/`**: Imágenes de la interfaz de usuario.
        - `pokeball.svg`: Icono de Pokébola en formato SVG.
    - **`servicios/`**: Maneja las consultas a la API GraphQL.
        - `graphql_calls.dart`: Define las consultas GraphQL que se utilizan para obtener los datos de los Pokémon.
        - `graphql_service.dart`: Configuración del cliente GraphQL y manejo de las peticiones.
    - **`vistas/`**: Pantallas principales de la aplicación.
        - `home.dart`: Pantalla de inicio que muestra la lista de Pokémon.
        - `perfil_pokemon.dart`: Pantalla de detalles del Pokémon seleccionado, con su información y estadísticas.
    - **`widgets/`**: Componentes reutilizables de la interfaz de usuario.
        - `pokemon_card.dart`: Tarjetas de Pokémon para la vista principal.
        - `stats_widget.dart`: Widget que muestra las estadísticas del Pokémon.
        - `movimientos_widget.dart`: Widget que lista los movimientos del Pokémon.
        - `evoluciones_widget.dart`: Widget que muestra la cadena evolutiva del Pokémon.
        - Otros widgets reutilizables para mostrar diferentes secciones de información.

# Uso de la API

La aplicación hace uso de la [API GraphQL de PokeAPI](https://beta.pokeapi.co/graphql/console/) para obtener información sobre los Pokémon. Las consultas permiten recuperar datos básicos, estadísticas, movimientos, evoluciones, habilidades, y más.

## Endpoints Utilizados

- **`pokemon_v2_pokemon`**: Obtiene la lista de Pokémon con datos básicos como nombre, imagen y tipos.
- **`pokemon_v2_pokemonspecy`**: Obtiene detalles adicionales sobre el Pokémon como su cadena evolutiva, tasa de captura y hábitat.
- **`pokemon_v2_pokemonstats`**: Obtiene las estadísticas base del Pokémon, como HP, ataque, defensa, entre otros.
- **`pokemon_v2_pokemonmoves`**: Obtiene la lista de movimientos disponibles para el Pokémon, junto con sus detalles como poder y precisión.
- **`pokemon_v2_ability`**: Recupera la lista de habilidades disponibles en el universo Pokémon.
- **`pokemon_v2_pokemontypes`**: Obtiene los tipos de un Pokémon (por ejemplo, Fuego, Agua, Eléctrico).

### Nuevos Endpoints y Funciones:

- **`getPokemonByAttack`**: Filtra Pokémon con un ataque mínimo especificado.
- **`getPokemonByAbility`**: Filtra Pokémon por habilidad.
- **`getPokemonDataByIdOrName`**: Obtiene información de un Pokémon por su ID o nombre.
- **`getPokemonDetailsByName`**: Consulta detallada de un Pokémon por su nombre.
- **`getAllPokemons`**: Devuelve todos los Pokémon disponibles.

# Librerías Principales Utilizadas

- **`graphql_flutter`**: Permite realizar consultas GraphQL en Flutter.
- **`cached_network_image`**: Permite la carga y almacenamiento en caché de imágenes para mejorar el rendimiento y reducir el consumo de datos.
- **`flutter_svg`**: Permite renderizar imágenes en formato SVG.
- **`pull_to_refresh`**: Proporciona la funcionalidad de actualización de la vista al deslizar.
- **`flutter_speed_dial`**: Implementa un menú de acceso rápido en la interfaz.
- **`shared_preferences`**: Permite almacenar preferencias del usuario de manera persistente.
- **`path_provider`**: Ofrece rutas de almacenamiento en el dispositivo.
- **`permission_handler`**: Facilita la gestión de permisos dentro de la aplicación.
- **`share_plus`**: Permite compartir contenido desde la aplicación a otras plataformas.

# Características

- **Listado de Pokémon**: Muestra un grid de tarjetas con el nombre e imagen de cada Pokémon, coloreadas según su tipo.
- **Filtros Avanzados**: Permite filtrar Pokémon por tipo, generación y habilidades.
- **Perfil de Pokémon**:
    - **Información General**: Muestra datos como peso, altura, habilidades y descripción del Pokémon.
    - **Estadísticas**: Muestra estadísticas como HP, ataque, defensa, velocidad, etc.
    - **Movimientos**: Muestra una lista de los movimientos disponibles para el Pokémon.
    - **Evoluciones**: Muestra la cadena evolutiva del Pokémon.
- **Transiciones Dinámicas**: La aplicación implementa transiciones animadas entre el listado de Pokémon y su perfil individual, para una experiencia de usuario fluida.
- **Mejoras de Rendimiento**: Uso de `cached_network_image` para optimizar la carga de imágenes y `shared_preferences` para almacenar los pokemones favoritos.

# Problemas Conocidos y Soluciones

- **Optimización de Imágenes**: Se utiliza `cached_network_image` para reducir el tiempo de carga y el consumo de datos, mejorando la experiencia del usuario.
- **Transiciones y Navegación**: Buena fluidez de las transiciones entre pantallas para hacerlas más naturales.
- **Consistencia Visual**: Se mantiene una estética coherente usando colores y tipografía personalizada que siguen el tema de Pokémon.
