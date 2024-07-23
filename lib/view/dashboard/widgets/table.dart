import 'package:flutter/material.dart';
import 'package:yeotaskin/utilities/app_colors.dart';

import '../../../utilities/app_fonts.dart';

class TableWidget extends StatelessWidget {
  final List<String> headerText;
  final List columnData;
  final bool isStockData;

  const TableWidget({
    super.key,
    required this.headerText,
    required this.columnData,
    this.isStockData = false,
  });

  final double tableRowHeight = 50;
  @override
  Widget build(BuildContext context) {
    return Table(
      columnWidths: const {
        0: FixedColumnWidth(40),
        1: FixedColumnWidth(0.5),
        2: FlexColumnWidth(5),
        3: FlexColumnWidth(2)
      },
      children: [
        TableRow(
          decoration: const BoxDecoration(
              color: AppColors.theme,
              borderRadius: BorderRadius.vertical(top: Radius.circular(8))),
          children: headerText
              .map(
                (e) => SizedBox(
              height: tableRowHeight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      e,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        color: AppColors.backgroundColor,
                        fontFamily: AppFonts.palatino,
                      ),
                    ),
                  )
                ],
              ),
            ),
          )
              .toList(),
        ),
        ...columnData
            .asMap()
            .entries
            .map(
              (item) => TableRow(
              decoration: BoxDecoration(
                color: item.key % 2 == 1
                    ? AppColors.accent.withOpacity(0.4)
                    : AppColors.background,
                borderRadius: (item.key == columnData.length - 1)
                    ? const BorderRadius.vertical(
                    bottom: Radius.circular(8))
                    : null,
              ),
              children: [
                SizedBox(
                  height: tableRowHeight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        (item.key + 1).toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          fontFamily: AppFonts.optima,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: tableRowHeight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      VerticalDivider(
                        width: 0.5,
                        thickness: 0.5,
                        color: AppColors.accent.withOpacity(0.8),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: tableRowHeight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(
                        width: 4,
                      ),
                      Flexible(
                        child: Text(
                          (isStockData
                              ? (item.value['product_name'])
                              : item.value['name']) ??
                              '',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontFamily: AppFonts.palatino,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 40,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        (isStockData
                            ? item.value['available_stock'].toString()
                            : item.value['total_sales'].toString()) ??
                            '',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: AppFonts.optima,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
        )
            .toList(),
      ],
    );
  }
}
