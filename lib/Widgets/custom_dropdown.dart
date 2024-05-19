import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:cafetero/Models/trabajador_model.dart';

class CustomDropdown extends StatelessWidget {
  final List<TrabajadorModel> items;
  final TrabajadorModel? selectedItem;
  final ValueChanged<TrabajadorModel?> onChanged;
  final TextEditingController controller;

  const CustomDropdown({
    required this.items,
    required this.selectedItem,
    required this.onChanged,
    required this.controller,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(10),
        ),
        width: 230,
        height: 65,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: DropdownButton2<TrabajadorModel>(
            isExpanded: true,
            value: selectedItem,
            items: items.map((TrabajadorModel trabajador) {
              return DropdownMenuItem<TrabajadorModel>(
                  value: trabajador,
                  child: Text(
                    trabajador.nombre,
                    style: TextStyle(
                        fontSize: 20,
                        color: Theme.of(context).colorScheme.primary),
                  ));
            }).toList(),
            onChanged: onChanged,
            hint: Text('trabajador',
                style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurface)),
            buttonStyleData: const ButtonStyleData(
              padding: EdgeInsets.symmetric(horizontal: 16),
              height: 40,
              width: 200,
            ),
            dropdownStyleData: const DropdownStyleData(
              maxHeight: 200,
            ),
            menuItemStyleData: const MenuItemStyleData(
              height: 40,
            ),
            dropdownSearchData: DropdownSearchData(
                searchController: controller,
                searchInnerWidgetHeight: 50,
                searchInnerWidget: Container(
                  height: 50,
                  padding: const EdgeInsets.only(
                    top: 8,
                    bottom: 4,
                    right: 8,
                    left: 8,
                  ),
                  child: TextFormField(
                    expands: true,
                    maxLines: null,
                    controller: controller,
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      hintText: 'Buscar trabajador',
                      hintStyle: const TextStyle(
                        fontSize: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                searchMatchFn: (item, searchValue) {
                  return item.value != null &&
                      item.value!.nombre
                          .toLowerCase()
                          .contains(searchValue.toLowerCase());
                }),
            onMenuStateChange: (isOpen) {
              if (!isOpen) {
                controller.clear();
              }
            },
          ),
        ),
      ),
    );
  }
}
