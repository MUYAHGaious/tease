import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SearchSuggestionsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> suggestions;
  final Function(Map<String, dynamic>) onSuggestionSelected;

  const SearchSuggestionsWidget({
    super.key,
    required this.suggestions,
    required this.onSuggestionSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: suggestions.length > 5 ? 5 : suggestions.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
        itemBuilder: (context, index) {
          final suggestion = suggestions[index];
          return ListTile(
            onTap: () => onSuggestionSelected(suggestion),
            leading: Container(
              padding: EdgeInsets.all(1.5.w),
              decoration: BoxDecoration(
                color: _getIconBackgroundColor(suggestion['type'] as String),
                borderRadius: BorderRadius.circular(6),
              ),
              child: CustomIconWidget(
                iconName: _getIconName(suggestion['type'] as String),
                color: _getIconColor(suggestion['type'] as String),
                size: 16,
              ),
            ),
            title: Text(
              suggestion['name'] as String,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              suggestion['address'] as String,
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.6),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: CustomIconWidget(
              iconName: 'arrow_forward_ios',
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.4),
              size: 16,
            ),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          );
        },
      ),
    );
  }

  String _getIconName(String type) {
    switch (type) {
      case 'bus_stop':
        return 'directions_bus';
      case 'landmark':
        return 'place';
      case 'city':
        return 'location_city';
      default:
        return 'location_on';
    }
  }

  Color _getIconColor(String type) {
    switch (type) {
      case 'bus_stop':
        return AppTheme.lightTheme.colorScheme.secondary;
      case 'landmark':
        return AppTheme.lightTheme.colorScheme.tertiary;
      case 'city':
        return AppTheme.lightTheme.colorScheme.primary;
      default:
        return AppTheme.lightTheme.colorScheme.onSurface.withValues(alpha: 0.6);
    }
  }

  Color _getIconBackgroundColor(String type) {
    switch (type) {
      case 'bus_stop':
        return AppTheme.lightTheme.colorScheme.secondary.withValues(alpha: 0.1);
      case 'landmark':
        return AppTheme.lightTheme.colorScheme.tertiary.withValues(alpha: 0.1);
      case 'city':
        return AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1);
      default:
        return AppTheme.lightTheme.colorScheme.onSurface
            .withValues(alpha: 0.05);
    }
  }
}
