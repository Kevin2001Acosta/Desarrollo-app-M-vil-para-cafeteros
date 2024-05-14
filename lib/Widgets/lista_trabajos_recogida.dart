import 'package:cafetero/Models/trabaja_model.dart';
import 'package:flutter/material.dart';
import 'package:group_list_view/group_list_view.dart';

class GroupListViewWidget extends StatelessWidget {
  final Map<String, List<TrabajaModel>> trabajos;

  const GroupListViewWidget({required this.trabajos, super.key});

  @override
  Widget build(BuildContext context) {
    return GroupListView(
      sectionsCount: trabajos.keys.toList().length,
      countOfItemInSection: (int section) {
        return trabajos.values.toList()[section].length;
      },
      itemBuilder: (BuildContext context, IndexPath index) {
        var trabajo = trabajos.values.toList()[index.section][index.index];
        return Card(
          margin: const EdgeInsets.all(8.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.45,
                  child: Text(
                    '${trabajo.nombre}: ${trabajo.kilosTrabajador} kg',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.45,
                  child: Text(
                    'Pago: ${trabajo.pago} \$',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      groupHeaderBuilder: (BuildContext context, int section) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          child: Text(
            trabajos.keys.toList()[section],
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        );
      },
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      sectionSeparatorBuilder: (context, section) => const SizedBox(height: 10),
    );
  }
}
