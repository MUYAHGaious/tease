import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class RouteOptimizationWidget extends StatefulWidget {
  final List<Map<String, dynamic>> routes;
  final Function(Map<String, dynamic>)? onOptimizationApplied;

  const RouteOptimizationWidget({
    super.key,
    required this.routes,
    this.onOptimizationApplied,
  });

  @override
  State<RouteOptimizationWidget> createState() =>
      _RouteOptimizationWidgetState();
}

class _RouteOptimizationWidgetState extends State<RouteOptimizationWidget> {
  bool _isAnalyzing = false;
  List<Map<String, dynamic>> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _generateOptimizationSuggestions();
  }

  void _generateOptimizationSuggestions() {
    setState(() {
      _isAnalyzing = true;
    });

    // Simulate analysis delay
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isAnalyzing = false;
        _suggestions = [
          {
            'id': '1',
            'type': 'efficiency',
            'title': 'Route R003 Optimization',
            'description': 'Reorder stops to reduce travel time by 15 minutes',
            'impact': 'High',
            'savings': '15 min',
            'route': 'R003',
            'icon': 'trending_up',
            'color': AppTheme.successLight,
          },
          {
            'id': '2',
            'type': 'demand',
            'title': 'Low Demand Stop',
            'description': 'Oak Street stop has only 2 regular passengers',
            'impact': 'Medium',
            'savings': '8 min',
            'route': 'R001',
            'icon': 'trending_down',
            'color': AppTheme.warningLight,
          },
          {
            'id': '3',
            'type': 'capacity',
            'title': 'Overcapacity Alert',
            'description': 'Route R005 exceeds 90% capacity during peak hours',
            'impact': 'High',
            'savings': 'Safety',
            'route': 'R005',
            'icon': 'warning',
            'color': AppTheme.errorLight,
          },
          {
            'id': '4',
            'type': 'merge',
            'title': 'Route Merge Opportunity',
            'description': 'Routes R007 and R008 have overlapping segments',
            'impact': 'Medium',
            'savings': '12 min',
            'route': 'R007, R008',
            'icon': 'merge',
            'color': AppTheme.primaryLight,
          },
        ];
      });
    });
  }

  void _applyOptimization(Map<String, dynamic> suggestion) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Apply Optimization'),
        content: Text(
          'Are you sure you want to apply this optimization?\n\n${suggestion['description']}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onOptimizationApplied?.call(suggestion);
              setState(() {
                _suggestions.removeWhere((s) => s['id'] == suggestion['id']);
              });
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.all(4.w),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppTheme.primaryLight.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'auto_awesome',
                    color: AppTheme.primaryLight,
                    size: 24,
                  ),
                  SizedBox(width: 3.w),
                  Text(
                    'Route Optimization',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const Spacer(),
                  if (_isAnalyzing)
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.primaryLight),
                      ),
                    )
                  else
                    IconButton(
                      onPressed: _generateOptimizationSuggestions,
                      icon: CustomIconWidget(
                        iconName: 'refresh',
                        color: AppTheme.primaryLight,
                        size: 20,
                      ),
                    ),
                ],
              ),
            ),

            // Content
            Container(
              padding: EdgeInsets.all(4.w),
              child: _isAnalyzing
                  ? Column(
                      children: [
                        SizedBox(height: 4.h),
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.primaryLight),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Analyzing routes for optimization opportunities...',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 4.h),
                      ],
                    )
                  : _suggestions.isEmpty
                      ? Column(
                          children: [
                            SizedBox(height: 2.h),
                            CustomIconWidget(
                              iconName: 'check_circle',
                              color: AppTheme.successLight,
                              size: 48,
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              'All routes are optimized!',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: AppTheme.successLight,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            SizedBox(height: 1.h),
                            Text(
                              'No optimization suggestions at this time.',
                              style: Theme.of(context).textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 2.h),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_suggestions.length} optimization suggestions found',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: isDark
                                        ? AppTheme.textMediumEmphasisDark
                                        : AppTheme.textMediumEmphasisLight,
                                  ),
                            ),
                            SizedBox(height: 2.h),
                            ...List.generate(_suggestions.length, (index) {
                              final suggestion = _suggestions[index];
                              return Container(
                                margin: EdgeInsets.only(bottom: 2.h),
                                padding: EdgeInsets.all(3.w),
                                decoration: BoxDecoration(
                                  color: (suggestion['color'] as Color)
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: (suggestion['color'] as Color)
                                        .withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(2.w),
                                          decoration: BoxDecoration(
                                            color: suggestion['color'] as Color,
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: CustomIconWidget(
                                            iconName: suggestion['icon'],
                                            color: AppTheme.onPrimaryLight,
                                            size: 16,
                                          ),
                                        ),
                                        SizedBox(width: 3.w),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                suggestion['title'],
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleSmall
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                              ),
                                              Text(
                                                'Route: ${suggestion['route']}',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall
                                                    ?.copyWith(
                                                      color: isDark
                                                          ? AppTheme
                                                              .textMediumEmphasisDark
                                                          : AppTheme
                                                              .textMediumEmphasisLight,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 2.w,
                                            vertical: 0.5.h,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _getImpactColor(
                                                    suggestion['impact'])
                                                .withValues(alpha: 0.2),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            suggestion['impact'],
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  color: _getImpactColor(
                                                      suggestion['impact']),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 2.h),
                                    Text(
                                      suggestion['description'],
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                    ),
                                    SizedBox(height: 2.h),
                                    Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 2.w,
                                            vertical: 0.5.h,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppTheme.secondaryLight
                                                .withValues(alpha: 0.2),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            'Saves: ${suggestion['savings']}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  color: AppTheme.primaryLight,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                          ),
                                        ),
                                        const Spacer(),
                                        TextButton(
                                          onPressed: () =>
                                              _applyOptimization(suggestion),
                                          child: const Text('Apply'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getImpactColor(String impact) {
    switch (impact.toLowerCase()) {
      case 'high':
        return AppTheme.errorLight;
      case 'medium':
        return AppTheme.warningLight;
      case 'low':
        return AppTheme.successLight;
      default:
        return AppTheme.primaryLight;
    }
  }
}
