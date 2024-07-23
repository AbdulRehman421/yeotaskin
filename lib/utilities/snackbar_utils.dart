import 'package:flutter/material.dart';
import 'package:yeotaskin/utilities/app_fonts.dart';
import 'package:yeotaskin/utilities/navigator_key.dart';

import 'app_colors.dart';

class SnackBarUtils {
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> show(
      {required String title, required bool isError, int duration = 1}) {
    return ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error : Icons.check_circle,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),

          ],
        ),
        backgroundColor: isError ? AppColors.theme : AppColors.accent,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: duration),
      ),
    );
  }
}
