import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gestor_tareas_local/db/tareas_database.dart';
import 'package:gestor_tareas_local/main.dart';

void main() {
  testWidgets(
    'La pantalla inicial y el formulario CRUD aparecen',
    (tester) async {
      final db = TareasDatabase(NativeDatabase.memory());

      await tester.runAsync(() async {
        await db.listarTareas();
      });

      await tester.pumpWidget(
        GestorTareasApp(database: db),
      );

      expect(find.text('Gestor de tareas'), findsOneWidget);
      expect(find.text('Agregar tarea'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());

      await tester.runAsync(() async {
        await db.close();
      });
    },
  );
}
