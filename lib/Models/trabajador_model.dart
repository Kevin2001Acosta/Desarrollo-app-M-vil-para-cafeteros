class TrabajadorModel {
  int? id; // TODO: Representa el identificador único del trabajador
  String nombre; // TODO: Representa el nombre del trabajador

  TrabajadorModel({this.id, required this.nombre});

  factory TrabajadorModel.fromJson(Map<String, dynamic> json) {
    // TODO: Crea una instancia de TrabajadorModel a partir de un mapa JSON
    return TrabajadorModel(
      id: json['id_trabajador'], // Consideramos que el campo en el JSON se llama 'id_trabajador'
      nombre: json['nombre'], // Obtenemos el nombre del trabajador del JSON
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id_trabajador'] = id; // TODO: Asigna el id del trabajador al mapa JSON
    data['nombre'] = nombre; // Asigna el nombre del trabajador al mapa JSON
    return data;
  }
}
