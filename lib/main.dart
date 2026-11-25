import 'package:flutter/material.dart';

import 'db/tareas_database.dart';
import 'screens/tareas_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const GestorTareasApp());
}

/// La instancia opcional de base de datos permite pruebas en memoria.
class GestorTareasApp extends StatefulWidget {
  final TareasDatabase? database;

  const GestorTareasApp({super.key, this.database});

  @override
  State<GestorTareasApp> createState() => _GestorTareasAppState();
}

class _GestorTareasAppState extends State<GestorTareasApp> {
  late final TareasDatabase _database;
  late final bool _esPropia;

  @override
  void initState() {
    super.initState();
    _esPropia = widget.database == null;
    _database = widget.database ?? TareasDatabase();
  }

  @override
  void dispose() {
    if (_esPropia) {
      _database.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestor de tareas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: TareasPage(database: _database),
    );
  }
}
