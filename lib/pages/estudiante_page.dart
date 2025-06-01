import 'package:flutter/material.dart';
import '../models/estudiante.dart';
import '../services/estudiante_service.dart';

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
  int paginaActual = 1;
  final int estudiantesPorPagina = 5;

  @override
  void initState() {
    super.initState();
    cargarEstudiantes();
  }

  void cargarEstudiantes() async {
    final lista = await _service.obtenerEstudiantes();
    setState(() {
      estudiantes = lista;
      paginaActual = 1;
    });
  }

  void limpiarFormulario() {
    carnetCtrl.clear();
    nombreCtrl.clear();
    apellidoCtrl.clear();
    correoCtrl.clear();
    telefonoCtrl.clear();
    setState(() {
      estudianteEditando = null;
    });
  }

  void guardar() async {
    if (!_formKey.currentState!.validate()) return;

    final nuevo = Estudiante(
      idEstudiante: estudianteEditando?.idEstudiante ?? 0,
      carnet: carnetCtrl.text,
      nombre: nombreCtrl.text,
      apellido: apellidoCtrl.text,
      correoElectronico: correoCtrl.text,
      telefono: telefonoCtrl.text,
    );

    if (estudianteEditando != null) {
      final confirmado = await confirmarDialogo('Confirmar actualización',
          '¿Estás seguro de que querés actualizar este estudiante?');
      if (!confirmado) return;
    }

    final ok = estudianteEditando == null
        ? await _service.registrarEstudiante(nuevo)
        : await _service.actualizarEstudiante(nuevo);

    if (ok) {
      limpiarFormulario();
      cargarEstudiantes();
      mostrarMensaje(estudianteEditando == null
          ? 'Estudiante agregado'
          : 'Estudiante actualizado');
    }
  }

  void eliminar(int id) async {
    final confirmado = await confirmarDialogo(
        'Confirmar eliminación', '¿Estás seguro de que querés eliminar este estudiante?');
    if (!confirmado) return;

    await _service.eliminarEstudiante(id);
    cargarEstudiantes();
    mostrarMensaje('Estudiante eliminado con éxito');
  }

  Future<bool> confirmarDialogo(String titulo, String mensaje) async {
    return (await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(titulo),
            content: Text(mensaje),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
              ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Confirmar')),
            ],
          ),
        )) ??
        false;
  }

  void mostrarMensaje(String texto) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.white),
          const SizedBox(width: 10),
          Text(texto),
        ],
      ),
    ),
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

  List<Estudiante> obtenerPaginaActual() {
    final inicio = (paginaActual - 1) * estudiantesPorPagina;
    final fin = inicio + estudiantesPorPagina;
    return estudiantes.sublist(inicio, fin > estudiantes.length ? estudiantes.length : fin);
  }

  void siguientePagina() {
    if ((paginaActual * estudiantesPorPagina) < estudiantes.length) {
      setState(() => paginaActual++);
    }
  }

  void paginaAnterior() {
    if (paginaActual > 1) {
      setState(() => paginaActual--);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestión de Estudiantes')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _formularioEstudiante(),
            const SizedBox(height: 32),
            const Text('Lista de Estudiantes',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Column(
              children: [
                ...obtenerPaginaActual().map((e) => _tarjetaEstudiante(e)),
                const SizedBox(height: 20),
                if (estudiantes.length > estudiantesPorPagina)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: paginaActual > 1 ? paginaAnterior : null,
                        child: const Text('Anterior'),
                      ),
                      const SizedBox(width: 16),
                      Text('Página $paginaActual'),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: (paginaActual * estudiantesPorPagina) < estudiantes.length
                            ? siguientePagina
                            : null,
                        child: const Text('Siguiente'),
                      ),
                    ],
                  )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _formularioEstudiante() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Formulario de Estudiante',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _campoTexto(carnetCtrl, 'Carnet')),
                  const SizedBox(width: 16),
                  Expanded(child: _campoTexto(nombreCtrl, 'Nombre')),
                  const SizedBox(width: 16),
                  Expanded(child: _campoTexto(apellidoCtrl, 'Apellido')),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _campoTexto(correoCtrl, 'Correo')),
                  const SizedBox(width: 16),
                  Expanded(child: _campoTexto(telefonoCtrl, 'Teléfono')),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: guardar,
                    child: Text(estudianteEditando == null ? 'Agregar' : 'Actualizar'),
                  ),
                  if (estudianteEditando != null)
                    TextButton(onPressed: limpiarFormulario, child: const Text('Cancelar')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _campoTexto(TextEditingController ctrl, String label) {
    return TextFormField(
      controller: ctrl,
      decoration: InputDecoration(labelText: label),
      validator: (val) {
        if (val == null || val.trim().isEmpty) return 'Campo obligatorio';
        if (label == 'Nombre' || label == 'Apellido') {
          if (!RegExp(r'^[a-zA-ZÁÉÍÓÚáéíóúñÑ\s]+$').hasMatch(val)) {
            return 'Solo se permiten letras';
          }
        }
        if (label == 'Correo') {
          if (!val.contains('@')) return 'Debe contener @';
        }
        if (label == 'Teléfono') {
          if (!RegExp(r'^\d+$').hasMatch(val)) return 'Solo números';
        }
        return null;
      },
    );
  }

  Widget _tarjetaEstudiante(Estudiante e) {
    final isEditando = e.idEstudiante == estudianteEditando?.idEstudiante;
    return Card(
      color: isEditando ? const Color.fromARGB(255, 90, 176, 238) : Colors.white,
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: const CircleAvatar(
          backgroundColor: Color(0xFF234563),
          child: Icon(Icons.person, color: Colors.white),
        ),
        title: Text('${e.nombre} ${e.apellido}',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          'Carnet: ${e.carnet}\nCorreo: ${e.correoElectronico ?? "-"}\nTel: ${e.telefono ?? "-"}',
        ),
        isThreeLine: true,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.amber),
              onPressed: () => cargarParaEditar(e),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => eliminar(e.idEstudiante!),
            ),
          ],
        ),
      ),
    );
  }
}
