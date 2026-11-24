# homiz

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Actualizar Flutter global en Windows

Este proyecto requiere Dart `^3.13.3` (Dart 3.13.3 o superior, pero menor que 4.0.0). Flutter incluye Dart, por lo que hay que actualizar la instalación global de Flutter; no cambies este requisito para evitar el error.

En PowerShell, primero comprueba qué instalación se ejecuta:

```powershell
where.exe flutter
```

En esta máquina la instalación detectada es `C:\Flutter\flutter`. Actualízala desde PowerShell:

```powershell
& 'C:\Flutter\flutter\bin\flutter.bat' channel stable
& 'C:\Flutter\flutter\bin\flutter.bat' upgrade
& 'C:\Flutter\flutter\bin\flutter.bat' --version
```

En la salida de `--version`, confirma que Dart sea `3.13.3` o superior. Si `where.exe flutter` muestra varias rutas, Windows usa primero la que aparece antes; actualiza la instalación que quieras usar y asegúrate de que su carpeta `bin` tenga prioridad en el `Path` de usuario o del sistema. Esto actualiza la instalación compartida por los proyectos que usan esa ruta, pero no otras copias de Flutter ni instalaciones administradas por herramientas como FVM.

## Configuración de Firebase

La configuración local está en `.env` (formato JSON), excluido de Git. Para preparar otro entorno, copia `.env.example` a `.env` y completa los valores de Firebase. Desde `mobile`, inicia o compila la app pasando el archivo:

```powershell
flutter run --dart-define-from-file=.env
flutter build apk --dart-define-from-file=.env
```

Los valores de Firebase y la clave VAPID son configuración pública de cliente: quedan incluidos en la app compilada y no deben usarse para guardar credenciales privadas de servidor.

Después, desde la raíz de este proyecto Flutter:

```powershell
Set-Location .\mobile
flutter pub get
```

## Densidad de información en pantallas

En el detalle de una solicitud, las secciones de información personal, solicitudes relacionadas, citas, conversación, casas propuestas y seguimiento se presentan como acordeones cerrados inicialmente. El resumen de la solicitud, la asignación del broker y la acción para editar los datos del cliente siguen a la vista. Los acordeones pueden abrirse de forma independiente.

```text
┌─────────────────────────────────────┐
│ ‹ Solicitud [folio]          [borrar]│
├─────────────────────────────────────┤
│ [Motivo]                      [Estado]│
│ [Fecha] · [casa, si aplica]          │
├─────────────────────────────────────┤
│ Broker asignado                     │
│ [Nombre / selector / atender]        │
├─────────────────────────────────────┤
│ ▸ Detalle de la solicitud           │
│ [Editar mi información]             │
│ ▸ Otras solicitudes · [n]            │  solo personal, si hay
│ ▸ Citas · [n]                        │  solo personal
│ ▸ Mensajes con [asesor / cliente]    │
│ ▸ Casas [que proponemos] · [n]       │
│ ▸ Seguimiento                        │  personal con permiso
└─────────────────────────────────────┘
```

### Otras pantallas revisadas

La revisión es visual y estática; excluye formularios y pantallas que todavía muestran «En construcción». La lista prioriza pantallas con varias secciones de información o contenido repetido que puede crecer:

| Prioridad | Pantalla | Por qué revisar |
|---|---|---|
| Alta | [Detalle de cita](lib/screens/appointments/appointment_detail_page.dart) | Combina cita, acciones, ubicación, contacto, formulario de solicitud y conversación. |
| Alta | [Resumen de propiedad](lib/widgets/property/summary_tab.dart) | Puede reunir galería, características, contrato, dirección, contactos y servicios. |
| Alta | [Pagos y pagarés del personal](lib/screens/payments/staff_payments_page.dart) | Lista pagarés agrupados por casa y cliente; puede crecer considerablemente. |
| Media | [Pagos de una propiedad](lib/widgets/payments/payments_tab.dart) | Resumen, aviso, pagarés o recibos; listas potencialmente largas. |
| Media | [Catálogo de propiedades](lib/screens/appointments/catalog_page.dart) | Repite tarjetas con foto, características, precio y filtros. |
| Media | [Notificaciones](lib/screens/notifications/notifications_page.dart) | El historial puede crecer y cada mensaje ocupar varias líneas. |
| Media | [Solicitudes](lib/screens/requests/requests_page.dart) | Lista extensa con filtros y varios datos de contexto por solicitud. |
| Media | [Inventario del personal](lib/widgets/property/staff_properties_list.dart) | Lista potencialmente larga de propiedades; ya incluye búsqueda y filas compactas. |
| Media | [Citas](lib/widgets/appointments/staff_appointments.dart) | Historial/lista filtrada por estado; ya usa pestañas y tarjetas compactas. |

Las pantallas de expediente y perfil muestran listas o datos acotados, y el inicio resume pendientes en tarjetas; no se identificaron como candidatas prioritarias para acordeones. Las pantallas de reportes, proveedores, compras y detalle de reporte están temporalmente en construcción, por lo que no se evaluó su densidad futura.

## Acordeones en módulos de alta y media prioridad

Se reutiliza `AccordionCard`, un `ExpansionTile` con borde y tema visual común, plegado inicialmente. El indicador de estado puede mostrarse junto al título sin reemplazar la flecha de expansión. Las acciones principales y los filtros permanecen fuera de los acordeones.

### Detalle de cita

Se mantienen visibles la cita y las acciones para acordar o gestionar la fecha. Ubicación, contacto, datos de la solicitud y mensajes se consultan al desplegar su sección. Cancelar cita conserva su acción existente.

```text
┌─────────────────────────────────────┐
│ Cita - [propiedad]                  │
│ [Foto]                              │
│ [Fecha · estado · propiedad]        │
│ [Aceptar / proponer / acciones staff]│
├─────────────────────────────────────┤
│ ▸ Ubicación                         │
│ ▸ Inquilino / Prospecto / Asesor    │
│ ▸ Solicitud / Mis datos             │
│ ▸ Mensajes de la cita · [n]         │
│ [Cancelar cita, si aplica]          │
└─────────────────────────────────────┘
```

### Resumen de propiedad

La galería y las características quedan visibles. Vigencia del contrato, mapa, contactos y números de servicio se agrupan en secciones plegables; los detalles de contacto, copiar y abrir enlaces conservan sus acciones.

```text
┌─────────────────────────────────────┐
│ [Galería · nombre · ubicación]      │
│ [Características]                  │
├─────────────────────────────────────┤
│ ▸ Contrato · [vigencia]             │
│ ▸ Ubicación · [dirección]           │
│ ▸ Inquilino y asesor / Tu asesor    │
│ ▸ Servicios de agua y luz           │
└─────────────────────────────────────┘
```

### Pagos y pagarés del personal

Se conservan las pestañas de estado y se agrupan los pagarés por casa y cliente. Cada encabezado plegado muestra la cantidad y el total del grupo; las acciones de cada pagaré aparecen al desplegarlo.

```text
┌─────────────────────────────────────┐
│ Pagos y pagarés                     │
│ [Por cobrar] [Vencidos] [Pagados]…  │
│ Toca un pagaré para ver sus acciones│
├─────────────────────────────────────┤
│ ▸ [Casa] · [Cliente]                │
│   [n pagarés · total]               │
│ ▸ [Casa] · [Cliente]                │
│   [n pagarés · total]               │
└─────────────────────────────────────┘
```

### Solicitudes

Se mantienen visibles el aviso, filtros y creación de solicitud. Cada solicitud contrae su resumen; al desplegar aparecen asignación, atención pendiente, inmueble, propuestas/respuesta y el botón para abrir el detalle.

```text
┌─────────────────────────────────────┐
│ Solicitudes                         │
│ [Aviso]                             │
│ [Filtros / Nueva solicitud]         │
├─────────────────────────────────────┤
│ ▸ [Nombre o motivo · folio] [Estado]│
│   [Motivo y fecha]                  │
│   Al abrir: asignación, inmueble,    │
│   resumen y casas / respuesta       │
│   [Abrir solicitud]                 │
│ ▸ [Siguiente solicitud] [Estado]    │
└─────────────────────────────────────┘
```

### Notificaciones

La bandeja se agrupa por Hoy, Ayer, Últimos 7 días y Anteriores. Cada acordeón indica el total y cuántas siguen sin leer; las notificaciones mantienen su acción de marcar como leída y navegar. «Marcar todas» sigue visible en la barra superior.

```text
┌─────────────────────────────────────┐
│ Notificaciones       [Marcar todas] │
├─────────────────────────────────────┤
│ ▸ Hoy · [n] · [n] sin leer          │
│ ▸ Ayer · [n] · [n] sin leer         │
│ ▸ Últimos 7 días · [n] · [n] sin leer│
│ ▸ Anteriores · [n] · [n] sin leer   │
└─────────────────────────────────────┘
```

### Citas

Las pestañas por estado y las acciones para solicitar o cambiar visitas permanecen visibles. En cada estado, las citas se agrupan por fecha; el encabezado indica el total y resume la primera cita del día.

```text
┌─────────────────────────────────────┐
│ Citas / Mis citas                   │
│ [Por confirmar] [Confirmadas] […]   │
│ [Solicitudes por agendar / Solicitar]│
├─────────────────────────────────────┤
│ ▸ Hoy · [n citas] · Primera: [casa] │
│ ▸ [Fecha] · [n citas] · Primera…    │
│   Al desplegar: tarjetas de citas   │
└─────────────────────────────────────┘
```

### Referencias de implementación

| Cambio | Archivo y líneas |
|---|---|
| Componente plegable compartido | [cards.dart:86](lib/widgets/common/cards.dart#L86) |
| Ubicación, contacto, solicitud y chat de cita | [appointment_detail_page.dart:255](lib/screens/appointments/appointment_detail_page.dart#L255) — [appointment_detail_page.dart:345](lib/screens/appointments/appointment_detail_page.dart#L345) |
| Contrato, ubicación, contactos y servicios de propiedad | [summary_tab.dart:129](lib/widgets/property/summary_tab.dart#L129) — [summary_tab.dart:184](lib/widgets/property/summary_tab.dart#L184) |
| Grupos de pagarés por casa y cliente | [staff_payments_page.dart:94](lib/screens/payments/staff_payments_page.dart#L94) — [staff_payments_page.dart:112](lib/screens/payments/staff_payments_page.dart#L112) |
| Solicitudes contraídas con acceso al detalle | [requests_page.dart:98](lib/screens/requests/requests_page.dart#L98) — [requests_page.dart:134](lib/screens/requests/requests_page.dart#L134) |
| Notificaciones agrupadas por fecha | [notifications_page.dart:73](lib/screens/notifications/notifications_page.dart#L73) — [notifications_page.dart:126](lib/screens/notifications/notifications_page.dart#L126) |
| Citas agrupadas por día dentro del estado | [staff_appointments.dart:177](lib/widgets/appointments/staff_appointments.dart#L177) — [staff_appointments.dart:220](lib/widgets/appointments/staff_appointments.dart#L220) |
