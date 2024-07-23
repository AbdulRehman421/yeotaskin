import 'package:flutter/material.dart';
import 'package:yeotaskin/services/user_profile_manager.dart';
import 'package:yeotaskin/utilities/utilities.dart';

import '../../../utilities/app_colors.dart';
import '../../../utilities/app_fonts.dart';

class TeamList extends StatelessWidget {
  final ScrollController scrollController;
  final List data;
  const TeamList(
      {super.key, required this.data, required this.scrollController});
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: data.length,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          padding: EdgeInsets.zero,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                AppColors.background,
                AppColors.background,
              ],
            ),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(width: 1, color: Colors.white),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                alignment: Alignment.centerLeft,
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.horizontal(
                    left: Radius.circular(100),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(16, 12, 0, 12),
                child: Text(
                  (1 + index).toString(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: AppFonts.optima,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.horizontal(
                    right: Radius.circular(100),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(8, 12, 30, 12),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).orientation ==
                            Orientation.portrait
                        ? MediaQuery.of(context).size.width * 0.45
                        : MediaQuery.of(context).size.width * 0.6,
                    minWidth: MediaQuery.of(context).size.width * 0.15,
                  ),
                  child: Text(
                    data[index]?.toString().toTitleCase() ?? '-',
                    softWrap: true,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontFamily: AppFonts.optima,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
