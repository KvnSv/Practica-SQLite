import 'package:flutter/material.dart';

import '../db/tareas_database.dart';

class TareasPage extends StatefulWidget {
  final TareasDatabase database;

  const TareasPage({super.key, required this.database});

  @override
  State<TareasPage> createState() => _TareasPageState();
}

class _TareasPageState extends State<TareasPage> {
  final TextEditingController _tituloController = TextEditingController();
  late final Stream<List<Tarea>> _tareasStream;

  @override
  void initState() {
    super.initState();
    _tareasStream = widget.database.observarTareas();
  }

  Future<void> _operacion(Future<void> Function() accion) async {
    try {
      await accion();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar en SQLite: $error')),
      );
    }
  }

  Future<void> _agregarTarea() async {
    final titulo = _tituloController.text.trim();
    if (titulo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escribe un titulo para la tarea')),
      );
      return;
    }
    if (titulo.length > 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximo 200 caracteres')),
      );
      return;
    }
    await _operacion(() async {
      await widget.database.agregarTarea(titulo);
      if (mounted) _tituloController.clear();
    });
  }

  Future<void> _alternarCompletada(Tarea tarea, bool valor) async {
    await _operacion(() async {
      await widget.database.cambiarEstado(tarea.id, valor);
    });
  }

  Future<void> _editarTarea(Tarea tarea) async {
    var tituloEditado = tarea.titulo;
    final nuevoTitulo = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Editar tarea'),
        content: TextFormField(
          initialValue: tarea.titulo,
          onChanged: (valor) => tituloEditado = valor,
          autofocus: true,
          maxLength: 200,
          decoration: const InputDecoration(labelText: 'Titulo'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, tituloEditado),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    if (!mounted || nuevoTitulo == null) return;
    final titulo = nuevoTitulo.trim();
    if (titulo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El titulo no puede estar vacio')),
      );
      return;
    }
    await _operacion(() async {
      await widget.database.editarTarea(tarea.id, titulo);
    });
  }

  Future<void> _eliminarTarea(Tarea tarea) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar tarea'),
        content: Text('¿Eliminar "${tarea.titulo}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (!mounted || confirmar != true) return;
    await _operacion(() async {
      await widget.database.eliminarTarea(tarea.id);
    });
  }

  @override
  void dispose() {
    _tituloController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestor de tareas')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  key: const Key('titulo-input'),
                  controller: _tituloController,
                  maxLength: 200,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _agregarTarea(),
                  decoration: const InputDecoration(
                    labelText: 'Nueva tarea',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: _agregarTarea,
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar tarea'),
                ),
                const SizedBox(height: 12),
                const Text('Mis tareas', style: TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                Expanded(
                  child: StreamBuilder<List<Tarea>>(
                    stream: _tareasStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(
                          child: Text('Error al abrir SQLite: ${snapshot.error}'),
                        );
                      }
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final tareas = snapshot.data!;
                      if (tareas.isEmpty) {
                        return const Center(
                          child: Text('Todavia no hay tareas guardadas'),
                        );
                      }
                      return ListView.builder(
                        itemCount: tareas.length,
                        itemBuilder: (context, index) {
                          final tarea = tareas[index];
                          return Card(
                            child: ListTile(
                              leading: Checkbox(
                                value: tarea.completada,
                                onChanged: (valor) {
                                  if (valor != null) {
                                    _alternarCompletada(tarea, valor);
                                  }
                                },
                              ),
                              title: Text(
                                tarea.titulo,
                                style: TextStyle(
                                  decoration: tarea.completada
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                              subtitle: Text('ID: ${tarea.id}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    tooltip: 'Editar',
                                    icon: const Icon(Icons.edit),
                                    onPressed: () => _editarTarea(tarea),
                                  ),
                                  IconButton(
                                    tooltip: 'Eliminar',
                                    icon: const Icon(Icons.delete_outline),
                                    onPressed: () => _eliminarTarea(tarea),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
