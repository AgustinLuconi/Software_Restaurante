# Configuración de Librerías

Este proyecto usa las siguientes librerías configuradas:

## 1. GetIt (Inyección de Dependencias)

**Archivo:** `lib/service_locator.dart`

### Uso:
```dart
import 'service_locator.dart';

// Obtener una instancia de un caso de uso
final crearReserva = getIt<CrearReserva>();

// Usar el caso de uso
final reserva = await crearReserva.execute(clienteId, mesaId, fecha, hora, numeroPersonas);
```

### Registrados:
- `ReservaRepositorio` (Singleton)
- `MesaRepositorio` (Singleton)
- Casos de uso: `CrearReserva`, `CancelarReserva`, `ObtenerReserva`, etc.

---

## 2. GoRouter (Navegación)

**Archivo:** `lib/router.dart`

### Uso:
```dart
// Navegar a una ruta
context.go('/reservas');

// Navegar con parámetros
context.goNamed('detalleReserva', pathParameters: {'id': '123'});

// Volver atrás
context.pop();
```

### Agregar nuevas rutas:
```dart
GoRoute(
  path: '/reservas',
  name: 'reservas',
  builder: (context, state) => const ReservasScreen(),
),
```

---

## 3. Cubit (State Management)

**Archivos ejemplo:** `lib/presentacion/pantalla_inicio/`

### Estructura:
1. **Estados** (`*_estados_de_cubit.dart`): Define los posibles estados
2. **Cubit** (`*_cubit.dart`): Lógica de negocio
3. **Screen** (`*_screen.dart`): UI que reacciona a los estados

### Uso en una pantalla:
```dart
class MiPantalla extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MiCubit(),
      child: BlocBuilder<MiCubit, MiState>(
        builder: (context, state) {
          if (state is MiLoading) {
            return CircularProgressIndicator();
          }
          // ... otros estados
        },
      ),
    );
  }
}
```

### Llamar métodos del Cubit:
```dart
// Desde el widget
context.read<MiCubit>().miMetodo();
```

---

## Inicialización

Todo se inicializa en `main.dart`:
```dart
void main() {
  setupServiceLocator(); // Inicializa GetIt
  runApp(const MyApp());
}
```

La app usa `MaterialApp.router` con `routerConfig: appRouter` para la navegación.
