import 'package:flutter/material.dart';
import 'models/estudiante.dart';
import 'services/estudiante_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CRUD de Estudiantes',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const EstudiantePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class EstudiantePage extends StatefulWidget {
  const EstudiantePage({super.key});
  @override
  State<EstudiantePage> createState() => _EstudiantePageState();
}

class _EstudiantePageState extends State<EstudiantePage> {
  final EstudianteService _service = EstudianteService();
  List<Estudiante> estudiantes = [];
  final _formKey = GlobalKey<FormState>();

  final carnetCtrl = TextEditingController();
  final nombreCtrl = TextEditingController();
  final apellidoCtrl = TextEditingController();
  final correoCtrl = TextEditingController();
  final telefonoCtrl = TextEditingController();

  Estudiante? estudianteEditando;

  @override
  void initState() {
    super.initState();
    cargarEstudiantes();
  }

  void cargarEstudiantes() async {
    final lista = await _service.obtenerEstudiantes();
    setState(() {
      estudiantes = lista;
    });
  }

  void limpiarFormulario() {
    carnetCtrl.clear();
    nombreCtrl.clear();
    apellidoCtrl.clear();
    correoCtrl.clear();
    telefonoCtrl.clear();
    estudianteEditando = null;
  }

  void guardar() async {
  if (!_formKey.currentState!.validate()) return;

  final nuevo = Estudiante(
    idEstudiante: estudianteEditando != null ? estudianteEditando!.idEstudiante : 0,
    carnet: carnetCtrl.text,
    nombre: nombreCtrl.text,
    apellido: apellidoCtrl.text,
    correoElectronico: correoCtrl.text,
    telefono: telefonoCtrl.text,
  );

  bool ok = estudianteEditando == null
      ? await _service.registrarEstudiante(nuevo)
      : await _service.actualizarEstudiante(nuevo);

  if (ok) {
    limpiarFormulario();
    cargarEstudiantes();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(estudianteEditando == null ? 'Estudiante agregado' : 'Estudiante actualizado')),
    );
  }
}


  void eliminar(int id) async {
    await _service.eliminarEstudiante(id);
    cargarEstudiantes();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Estudiante eliminado con éxito')),
    );
  }

  void cargarParaEditar(Estudiante est) {
    setState(() {
      estudianteEditando = est;
      carnetCtrl.text = est.carnet;
      nombreCtrl.text = est.nombre;
      apellidoCtrl.text = est.apellido;
      correoCtrl.text = est.correoElectronico ?? '';
      telefonoCtrl.text = est.telefono ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Estudiantes')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            
            Form(
              key: _formKey,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: carnetCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Carnet',
                          ),
                          validator: (val) => val!.isEmpty ? 'Requerido' : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: nombreCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Nombre',
                          ),
                          validator: (val) => val!.isEmpty ? 'Requerido' : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: apellidoCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Apellido',
                          ),
                          validator: (val) => val!.isEmpty ? 'Requerido' : null,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: correoCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Correo Electrónico',
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: telefonoCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Teléfono',
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: guardar,
                        child: Text(
                          estudianteEditando == null ? 'Agregar' : 'Actualizar',
                        ),
                      ),
                      if (estudianteEditando != null)
                        TextButton(
                          onPressed: limpiarFormulario,
                          child: const Text('Cancelar'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Lista
            Expanded(
              child: ListView(
                children: estudiantes.map((e) {
                  return Card(
                    child: ListTile(
                      title: Text('${e.nombre} ${e.apellido}'),
                      subtitle: Text(
                        'Carnet: ${e.carnet}\nCorreo: ${e.correoElectronico ?? "-"} | Tel: ${e.telefono ?? "-"}',
                      ),
                      isThreeLine: true,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => cargarParaEditar(e),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => eliminar(e.idEstudiante!),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
