import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/estudiante.dart';

class EstudianteService {
  final String baseUrl = 'https://localhost:7067/api/Estudiante';

  Future<List<Estudiante>> obtenerEstudiantes() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List<dynamic> datos = json.decode(response.body);
      return datos.map((e) => Estudiante.fromJson(e)).toList();
    } else {
      throw Exception('Error al obtener los estudiantes');
    }
  }

  Future<bool> registrarEstudiante(Estudiante estudiante) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(estudiante.toJson()),
    );
    return response.statusCode == 200;
  }

  Future<bool> actualizarEstudiante(Estudiante estudiante) async {
    final response = await http.put(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(estudiante.toJson()),
    );
    return response.statusCode == 200;
  }

  Future<bool> eliminarEstudiante(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    return response.statusCode == 200;
  }
}
