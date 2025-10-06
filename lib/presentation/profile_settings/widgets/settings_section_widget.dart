import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class SettingsSectionWidget extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const SettingsSectionWidget({
    Key? key,
    required this.title,
    required this.children,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          decoration: AppTheme.getGlassmorphismDecoration(
            borderRadius: 12.0,
            isDark: Theme.of(context).brightness == Brightness.dark,
          ),
          child: Column(
            children: children,
          ),
        ),
        SizedBox(height: 2.h),
      ],
    );
  }
}
