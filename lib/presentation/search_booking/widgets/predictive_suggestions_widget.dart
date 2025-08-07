import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PredictiveSuggestionsWidget extends StatefulWidget {
  final String query;
  final bool isVisible;
  final Function(String, String) onSuggestionSelected;

  const PredictiveSuggestionsWidget({
    super.key,
    required this.query,
    required this.isVisible,
    required this.onSuggestionSelected,
  });

  @override
  State<PredictiveSuggestionsWidget> createState() =>
      _PredictiveSuggestionsWidgetState();
}

class _PredictiveSuggestionsWidgetState
    extends State<PredictiveSuggestionsWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<Map<String, dynamic>> _mockSuggestions = [
    {
      "id": 1,
      "route": "New York → Boston",
      "duration": "4h 30m",
      "price": "\$45",
      "type": "popular",
      "passengers": "2,340 passengers this week"
    },
    {
      "id": 2,
      "route": "New York → Philadelphia",
      "duration": "2h 15m",
      "price": "\$28",
      "type": "recent",
      "passengers": "1,890 passengers this week"
    },
    {
      "id": 3,
      "route": "New York → Washington DC",
      "duration": "5h 45m",
      "price": "\$52",
      "type": "popular",
      "passengers": "3,120 passengers this week"
    },
    {
      "id": 4,
      "route": "New York → Baltimore",
      "duration": "4h 20m",
      "price": "\$38",
      "type": "recent",
      "passengers": "1,560 passengers this week"
    },
    {
      "id": 5,
      "route": "Boston → New York",
      "duration": "4h 25m",
      "price": "\$47",
      "type": "popular",
      "passengers": "2,890 passengers this week"
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void didUpdateWidget(PredictiveSuggestionsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible && !oldWidget.isVisible) {
      _animationController.forward();
    } else if (!widget.isVisible && oldWidget.isVisible) {
      _animationController.reverse();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _getFilteredSuggestions() {
    if (widget.query.isEmpty) return _mockSuggestions.take(3).toList();

    return _mockSuggestions.where((suggestion) {
      final route = (suggestion["route"] as String).toLowerCase();
      final query = widget.query.toLowerCase();
      return route.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) return const SizedBox.shrink();

    final filteredSuggestions = _getFilteredSuggestions();

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface
                    .withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.shadowLight,
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.all(4.w),
                    child: Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'trending_up',
                          color: AppTheme.lightTheme.colorScheme.secondary,
                          size: 18,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          'Popular Routes',
                          style: AppTheme.lightTheme.textTheme.titleSmall
                              ?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: 40.h),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      itemCount: filteredSuggestions.length,
                      separatorBuilder: (context, index) => Divider(
                        height: 1,
                        color: AppTheme.lightTheme.colorScheme.outline
                            .withValues(alpha: 0.1),
                      ),
                      itemBuilder: (context, index) {
                        final suggestion = filteredSuggestions[index];
                        return _buildSuggestionCard(suggestion, index);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSuggestionCard(Map<String, dynamic> suggestion, int index) {
    return InkWell(
      onTap: () {
        final routeParts = (suggestion["route"] as String).split(' → ');
        if (routeParts.length == 2) {
          widget.onSuggestionSelected(routeParts[0], routeParts[1]);
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(4.w),
        child: Row(
          children: [
            Container(
              width: 10.w,
              height: 10.w,
              decoration: BoxDecoration(
                color: suggestion["type"] == "popular"
                    ? AppTheme.lightTheme.colorScheme.secondary
                        .withValues(alpha: 0.1)
                    : AppTheme.lightTheme.colorScheme.primary
                        .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomIconWidget(
                iconName:
                    suggestion["type"] == "popular" ? 'trending_up' : 'history',
                color: suggestion["type"] == "popular"
                    ? AppTheme.lightTheme.colorScheme.secondary
                    : AppTheme.lightTheme.colorScheme.primary,
                size: 16,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    suggestion["route"] as String,
                    style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Row(
                    children: [
                      Text(
                        suggestion["duration"] as String,
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.textMediumEmphasisLight,
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Container(
                        width: 1,
                        height: 12,
                        color: AppTheme.lightTheme.colorScheme.outline
                            .withValues(alpha: 0.3),
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        suggestion["passengers"] as String,
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.textMediumEmphasisLight,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  suggestion["price"] as String,
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: suggestion["type"] == "popular"
                        ? AppTheme.lightTheme.colorScheme.secondary
                            .withValues(alpha: 0.1)
                        : AppTheme.lightTheme.colorScheme.primary
                            .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    suggestion["type"] == "popular" ? "Popular" : "Recent",
                    style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                      color: suggestion["type"] == "popular"
                          ? AppTheme.lightTheme.colorScheme.secondary
                          : AppTheme.lightTheme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
