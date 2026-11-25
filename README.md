# Practica SQLite - Gestor de tareas (Flutter + Drift)

Proyecto individual basado en la estructura inicial de la practica del profesor Irving.

## Funcionalidad
- Agregar tareas (CREATE).
- Listar tareas desde SQLite (READ).
- Editar titulo y marcar completadas (UPDATE).
- Eliminar tareas (DELETE).
- Los datos persisten tras cerrar y abrir la app; en web, en el mismo origen y perfil del navegador.
- UI adaptable a movil, web y escritorio.

## Preparacion rapida en Windows

**IMPORTANTE:** este ZIP contiene el codigo fuente y los archivos adicionales, no las carpetas nativas generadas por Flutter. Las dependencias actuales requieren Flutter con Dart 3.10 o superior (verifica con `flutter --version`).

1. En una carpeta de trabajo, ejecuta:

   ```powershell
   flutter create gestor_tareas_local
   cd gestor_tareas_local
   ```

2. Copia a esa carpeta todos los archivos y carpetas de este ZIP, reemplazando los archivos homonimos. Manten las carpetas generadas `android`, `windows`, `web`, `ios`, `linux`, `macos`.
3. Genera y resuelve las dependencias:

   ```powershell
   flutter pub get
   dart run build_runner build --delete-conflicting-outputs
   ```

4. Prepara los dos archivos WebAssembly/worker:

   ```powershell
   powershell -ExecutionPolicy Bypass -File .\scripts\preparar_web.ps1
   ```

   Si el script falla, baja `sqlite3.wasm` y `drift_worker.dart.js` de la version **drift-2.35.4** en https://github.com/simolus3/drift/releases/tag/drift-2.35.4 y colocalos en `web/`.

5. Analiza y prueba:

   ```powershell
   flutter analyze
   flutter test
   flutter devices
   ```

6. Ejecuta por plataforma:

   ```powershell
   flutter run -d chrome --web-port=7357
   flutter run -d windows
   flutter run -d TU_ID_DE_ANDROID
   ```

   Para Windows, Flutter requiere Visual Studio con la carga de trabajo **Desktop development with C++**. Para Android, un telefono o emulador detectado.

7. Comprueba persistencia: agrega dos tareas, edita una, marca otra, cierra totalmente y vuelve a abrir con el mismo origen (web: usa siempre el puerto 7357), misma instalacion/perfil. Comprueba que se conservan, elimina una y verifica de nuevo.

8. Sube el proyecto **completo generado con Flutter** a TU repositorio individual de GitHub, incluyendo el archivo generado `lib/db/tareas_database.g.dart` y los archivos `web/sqlite3.wasm` y `web/drift_worker.dart.js`.

## Arquitectura

- `lib/main.dart`: ciclo de vida de la app.
- `lib/models/tarea.dart`: modelo de datos.
- `lib/db/tareas_database.dart`: tabla SQLite y metodos CRUD.
- `lib/db/tareas_database.g.dart`: codigo Dart generado por Drift, no se incluye en el ZIP, se genera con build_runner.
- `lib/screens/tareas_page.dart`: interfaz Flutter.
- `test/database_test.dart`: pruebas CRUD, persistencia y stream.
- `test/widget_test.dart`: prueba basica de interfaz.
- `web/sqlite3.wasm` y `web/drift_worker.dart.js`: descargas necesarias para SQLite real en navegadores.

## Notas de evaluacion

La practica original mencionaba seis plataformas, pero la aclaracion del curso cambia la demostracion a **web, movil y escritorio**. No se usa SharedPreferences, MySQL ni una API REST. Los datos de cada plataforma son independientes.

## Fuentes

- Base de la practica: https://github.com/Irving2355/Dispositivos-Moviles-2026/tree/main/tareas/Practica_SQLite
- Drift: https://drift.simonbinder.eu/setup/
- Drift web: https://drift.simonbinder.eu/platforms/web/
- drift_flutter: https://pub.dev/packages/drift_flutter
