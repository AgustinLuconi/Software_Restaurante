# Sistema de Reservas - Intervalos de 1 Hora

## 📋 Descripción General

El sistema de reservas ahora implementa **verificación de disponibilidad en tiempo real** con **intervalos de 1 hora**. Esto significa que:

- Cada reserva ocupa una mesa durante **1 hora completa**
- Si una mesa está reservada en un horario, **no estará disponible** para otros clientes en ese mismo horario
- El sistema verifica automáticamente la disponibilidad antes de crear una reserva

---

## 🔧 Características Implementadas

### 1. **Verificación de Disponibilidad**
```dart
// En ReservaRepositorio
Future<bool> mesaDisponible({
  required String mesaId,
  required DateTime fecha,
  required DateTime hora,
});
```

- Verifica si una mesa está libre en un horario específico
- Considera solo reservas **confirmadas** o **pendientes**
- Ignora reservas **canceladas**

### 2. **Detección de Conflictos de Horario**

El sistema detecta conflictos cuando dos reservas se superponen:

```
Reserva 1: 12:00 - 13:00
Reserva 2: 12:30 - 13:30  ❌ CONFLICTO (se superponen)

Reserva 1: 12:00 - 13:00
Reserva 2: 13:00 - 14:00  ✅ SIN CONFLICTO (no se superponen)
```

**Lógica de Superposición:**
- Intervalo A: [inicio_A, fin_A)
- Intervalo B: [inicio_B, fin_B)
- Hay conflicto si: `inicio_B < fin_A AND fin_B > inicio_A`

### 3. **Filtrado de Mesas Disponibles**

Cuando un cliente busca mesas:
1. Se filtran mesas que **pueden acomodar** el número de personas
2. Se verifican reservas existentes en ese horario
3. Solo se muestran mesas **completamente disponibles**

### 4. **Validación al Crear Reserva**

Antes de crear una reserva, se verifica:
```dart
// En CrearReserva.execute()
final mesaDisponible = await reservaRepositorio.mesaDisponible(
  mesaId: mesaId,
  fecha: fecha,
  hora: fechaHora,
);

if (!mesaDisponible) {
  throw Exception('La mesa ya está reservada en ese horario...');
}
```

---

## 🎯 Flujo de Uso

### Escenario 1: Reserva Exitosa

1. **Cliente A** busca mesa para 4 personas el 30/10/2025 a las 12:00
2. Sistema muestra: Mesa 2 (capacidad 4) **disponible** ✅
3. Cliente A reserva Mesa 2
4. Reserva creada y confirmada con código de verificación

### Escenario 2: Mesa ya Reservada

1. **Cliente B** busca mesa para 4 personas el 30/10/2025 a las 12:00
2. Sistema verifica: Mesa 2 ya tiene reserva de Cliente A
3. Sistema muestra: Mesa 2 **NO disponible** ❌
4. Cliente B solo ve Mesa 3 (capacidad 6) disponible

### Escenario 3: Horario Diferente

1. **Cliente C** busca mesa para 4 personas el 30/10/2025 a las 13:00
2. Sistema verifica: Reserva de Cliente A termina a las 13:00
3. Sistema muestra: Mesa 2 **disponible** ✅ (no hay superposición)
4. Cliente C puede reservar Mesa 2

---

## 🧪 Cómo Probar el Sistema

### Prueba 1: Primera Reserva
```
1. Abrir la app
2. Ir a "Disponibilidad"
3. Seleccionar:
   - Fecha: Mañana
   - Hora: 14:00
   - Personas: 2
4. Buscar → Debe mostrar mesas disponibles
5. Seleccionar "Mesa 1"
6. Ingresar:
   - Nombre: "Juan Pérez"
   - Email: "juan@mail.com"
7. Copiar código de consola
8. Ingresar código
9. ✅ Reserva confirmada
```

### Prueba 2: Reserva en Mismo Horario (Debe Fallar)
```
1. Sin cerrar la app, volver a "Disponibilidad"
2. Seleccionar:
   - Fecha: Mañana (mismo día)
   - Hora: 14:00 (mismo horario)
   - Personas: 2
3. Buscar → Mesa 1 NO debe aparecer
4. Si solo había Mesa 1 disponible, debe mostrar mensaje:
   "No hay mesas disponibles para los criterios seleccionados"
```

### Prueba 3: Reserva en Horario Diferente (Debe Funcionar)
```
1. Seleccionar:
   - Fecha: Mañana (mismo día)
   - Hora: 15:00 (1 hora después)
   - Personas: 2
2. Buscar → Mesa 1 debe aparecer ✅
3. Completar reserva normalmente
```

---

## 📊 Datos Técnicos

### Estados de Reserva Considerados
- **Confirmada**: La mesa está ocupada ❌
- **Pendiente**: La mesa está ocupada ❌
- **Cancelada**: La mesa está libre ✅

### Duración de Reserva
- **Fija**: 1 hora
- **No configurable** (por ahora)

### Precisión de Horario
- Se truncan los minutos a 0
- Ejemplo: 14:30 → 14:00
- Intervalo: 14:00:00 a 14:59:59

---

## 🔍 Debugging

### Ver Reservas en Memoria
```dart
// En ReservaRepositorioMemoria
print('Reservas actuales: ${_reservas.length}');
_reservas.forEach((r) {
  print('- Mesa ${r.mesaId}: ${r.fechaHora} [${r.estado}]');
});
```

### Ver Mesas Filtradas
```dart
// En MesaRepositorioMemoria.obtenerMesasDisponibles()
print('Mesas candidatas: ${mesasCandidatas.length}');
print('Mesas disponibles: ${mesasDisponibles.length}');
```

---

## ⚠️ Consideraciones

1. **Reservas en memoria**: Se pierden al cerrar la app
2. **Sin persistencia**: Implementar base de datos para producción
3. **Zona horaria**: Usar UTC o timezone del restaurante
4. **Validación de horarios**: Verificar horarios de apertura/cierre
5. **Cancelaciones**: Al cancelar, la mesa vuelve a estar disponible

---

## 🚀 Próximas Mejoras

- [ ] Duración de reserva configurable (1h, 2h, etc.)
- [ ] Reservas recurrentes
- [ ] Buffer entre reservas (ej: 15 min de limpieza)
- [ ] Notificación cuando mesa se libera
- [ ] Lista de espera automática
- [ ] Dashboard con mapa de ocupación

---

## 📝 Archivos Modificados

### Nuevos Métodos
- `lib/dominio/repositorios/reserva_repositorio.dart`
  - `obtenerReservasPorMesaYHorario()`
  - `mesaDisponible()`

### Actualizaciones
- `lib/adaptadores/adaptador_en_memoria_reserva.dart`
  - Implementación de verificación de disponibilidad
  - Lógica de detección de superposición de intervalos

- `lib/adaptadores/adaptador_en_memoria_mesa.dart`
  - Integración con ReservaRepositorio
  - Filtrado de mesas ocupadas

- `lib/aplicacion/crear_reserva.dart`
  - Validación antes de crear reserva
  - Mensaje de error descriptivo

- `lib/service_locator.dart`
  - Inyección de ReservaRepositorio en MesaRepositorio

- `lib/presentacion/disponibilidad/disponibilidad_screen.dart`
  - Banner informativo sobre intervalos de 1 hora
  - UI mejorada

---

## ✅ Resultado Final

**El sistema ahora garantiza que:**
- ❌ No se pueden hacer dos reservas para la misma mesa en el mismo horario
- ✅ Los clientes solo ven mesas realmente disponibles
- ✅ Las reservas se crean con validación en tiempo real
- ✅ Mensajes de error claros cuando una mesa no está disponible

**Ejemplo en consola:**
```
🔍 Buscando mesas disponibles...
   Fecha: 30/10/2025 14:00
   Personas: 2

✅ Mesas disponibles: Mesa 2, Mesa 3
❌ Mesas ocupadas: Mesa 1 (reservada por juan@mail.com)

🎯 Reserva solicitada: Mesa 1 a las 14:00
❌ ERROR: La mesa seleccionada ya está reservada en ese horario.
   Por favor elige otra mesa u otro horario.
```
