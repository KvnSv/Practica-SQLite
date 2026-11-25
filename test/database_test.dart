import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gestor_tareas_local/db/tareas_database.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('CRUD SQLite y persistencia al cerrar y reabrir una base local', () async {
    final temp = await Directory.systemTemp.createTemp('sqlite_practica_');
    final ruta = '${temp.path}${Platform.pathSeparator}prueba.sqlite';

    var db = TareasDatabase(NativeDatabase(File(ruta)));
    try {
      final id = await db.agregarTarea('Aprender SQLite');
      var lista = await db.listarTareas();
      expect(lista, hasLength(1));
      expect(lista.single.titulo, 'Aprender SQLite');
      expect(lista.single.completada, isFalse);

      await db.editarTarea(id, 'Aprender Drift');
      await db.cambiarEstado(id, true);
      lista = await db.listarTareas();
      expect(lista.single.titulo, 'Aprender Drift');
      expect(lista.single.completada, isTrue);

      await db.close();
      db = TareasDatabase(NativeDatabase(File(ruta)));
      lista = await db.listarTareas();
      expect(lista, hasLength(1));
      expect(lista.single.titulo, 'Aprender Drift');
      expect(lista.single.completada, isTrue);

      await db.eliminarTarea(id);
      expect(await db.listarTareas(), isEmpty);
    } finally {
      await db.close();
      await temp.delete(recursive: true);
    }
  });

  test('El cambio de estado se refleja en el stream reactivo', () async {
    final db = TareasDatabase(NativeDatabase.memory());
    try {
      final id = await db.agregarTarea('Comprobar streams');
      final inicial = await db.observarTareas().first;
      expect(inicial.single.completada, false);
      await db.cambiarEstado(id, true);
      final finalizado = await db.observarTareas().first;
      expect(finalizado.single.completada, true);
    } finally {
      await db.close();
    }
  });
}
