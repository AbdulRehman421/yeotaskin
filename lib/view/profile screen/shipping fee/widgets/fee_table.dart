import 'package:flutter/material.dart';
import 'package:yeotaskin/utilities/app_colors.dart';
import 'package:yeotaskin/utilities/app_fonts.dart';

class FeeTable extends StatefulWidget {
  final Map<String, dynamic> feeData;
  FeeTable({super.key, required this.feeData});

  @override
  State<FeeTable> createState() => _FeeTableState();
}

class _FeeTableState extends State<FeeTable> {
  String selectedState = 'State 1';
  Map<String, dynamic> selectedData = {};

  @override
  Widget build(BuildContext context) {
    selectedData = widget.feeData[selectedState] ?? {};
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              "Please select a state",
              style: TextStyle(
                fontSize: 16,
                fontFamily: AppFonts.optima,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: DropdownButton(
                  iconEnabledColor: AppColors.backgroundColor,
                  dropdownColor: AppColors.backgroundColor,
                  value: selectedState,
                  items: widget.feeData.keys.map((state) {
                    return DropdownMenuItem(
                      value: state,
                      child: Text(
                        state,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: AppFonts.optima,
                          fontSize: 16,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newState) {
                    if (newState != null) {
                      selectedState = newState;
                      setState(() {});
                    }
                  },
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 10,
        ),
        selectedState.isNotEmpty
            ? Expanded(
                child: SingleChildScrollView(
                  child: DataTable(
                    dividerThickness: 0.0,
                    border: TableBorder.all(
                        width: 1, color: AppColors.backgroundColor),
                    headingRowColor:
                        const MaterialStatePropertyAll(AppColors.primaryColor),
                    headingTextStyle: const TextStyle(
                        fontFamily: AppFonts.palatino,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                    dataRowColor: const MaterialStatePropertyAll(
                        AppColors.threeLevelColor),
                    dataTextStyle: const TextStyle(
                        fontFamily: AppFonts.palatino,
                        color: Colors.black,
                        fontSize: 18),
                    columns: [
                      DataColumn(label: Text('KG')),
                      DataColumn(label: Text('Shipping fee')),
                    ],
                    rows: selectedData.entries.map((entry) {
                      return DataRow(cells: [
                        DataCell(Text(entry.key)),
                        DataCell(Text(entry.value.toString())),
                      ]);
                    }).toList(),
                  ),
                ),
              )
            : Text(
                "No data!",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: AppFonts.palatino,
                  fontSize: 18,
                ),
              ),
      ],
    );
  }
}
