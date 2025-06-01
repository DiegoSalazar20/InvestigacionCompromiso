class Estudiante {
  int? idEstudiante;
  String carnet;
  String nombre;
  String apellido;
  String? correoElectronico;
  String? telefono;

  Estudiante({
    this.idEstudiante,
    required this.carnet,
    required this.nombre,
    required this.apellido,
    this.correoElectronico,
    this.telefono,
  });

  factory Estudiante.fromJson(Map<String, dynamic> json) {
    return Estudiante(
      idEstudiante: json['idEstudiante'],
      carnet: json['carnet'],
      nombre: json['nombre'],
      apellido: json['apellido'],
      correoElectronico: json['correoElectronico'],
      telefono: json['telefono'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idEstudiante': idEstudiante,
      'carnet': carnet,
      'nombre': nombre,
      'apellido': apellido,
      'correoElectronico': correoElectronico,
      'telefono': telefono,
    };
  }
}
