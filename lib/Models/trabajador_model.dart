class TrabajadorModel {
  int? idTrabajador;
  String nombre;

  TrabajadorModel({this.idTrabajador, required this.nombre});

  factory TrabajadorModel.fromJson(Map<String, dynamic> json) {
    return TrabajadorModel(
      idTrabajador: json['id_trabajador'],
      nombre: json['nombre'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id_trabajador'] = idTrabajador;
    data['nombre'] = nombre;
    return data;
  }
}
