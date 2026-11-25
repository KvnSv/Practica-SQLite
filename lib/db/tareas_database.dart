import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';


part 'tareas_database.g.dart'; // Se genera con dart run build_runner build

// Tabla SQLite: ID unico, titulo y estado de completada.
class Tareas extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get titulo => text().withLength(min: 1, max: 200)();
  BoolColumn get completada => boolean().withDefault(const Constant(false))();
}

@DriftDatabase(tables: [Tareas])
class TareasDatabase extends _$TareasDatabase {
  TareasDatabase([QueryExecutor? executor]) : super(executor ?? _abrirDb());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _abrirDb() {
    return driftDatabase(
      name: 'gestor_tareas_local',
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse('sqlite3.wasm'),
        driftWorker: Uri.parse('drift_worker.dart.js'),
      ),
    );
  }

  // READ (reactivo): cuando cambia SQLite, la lista se actualiza sola.
  Stream<List<Tarea>> observarTareas() {
    final query = select(tareas)
      ..orderBy([
        (tabla) => OrderingTerm.asc(tabla.completada),
        (tabla) => OrderingTerm.desc(tabla.id),
      ]);
    return query.watch().map(
          (filas) => filas
              .map((fila) => Tarea(
                    id: fila.id,
                    titulo: fila.titulo,
                    completada: fila.completada,
                  ))
              .toList(),
        );
  }

  // READ (unica consulta): practica y pruebas.
  Future<List<Tarea>> listarTareas() async {
    final filas = await select(tareas).get();
    return filas
        .map((fila) => Tarea(
              id: fila.id,
              titulo: fila.titulo,
              completada: fila.completada,
            ))
        .toList();
  }

  // CREATE
  Future<int> agregarTarea(String titulo) {
    return into(tareas).insert(
      TareasCompanion.insert(titulo: titulo.trim()),
    );
  }

  // UPDATE titulo
  Future<int> editarTarea(int id, String nuevoTitulo) {
    return (update(tareas)..where((tabla) => tabla.id.equals(id))).write(
      TareasCompanion(titulo: Value(nuevoTitulo.trim())),
    );
  }

  // UPDATE completada
  Future<int> cambiarEstado(int id, bool completada) {
    return (update(tareas)..where((tabla) => tabla.id.equals(id))).write(
      TareasCompanion(completada: Value(completada)),
    );
  }

  // DELETE
  Future<int> eliminarTarea(int id) {
    return (delete(tareas)..where((tabla) => tabla.id.equals(id))).go();
  }
}
