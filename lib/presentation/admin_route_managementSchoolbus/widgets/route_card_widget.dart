import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class RouteCardWidget extends StatefulWidget {
  final Map<String, dynamic> route;
  final VoidCallback? onEdit;
  final VoidCallback? onDuplicate;
  final VoidCallback? onArchive;
  final Function(List<Map<String, dynamic>>)? onStopsReordered;

  const RouteCardWidget({
    super.key,
    required this.route,
    this.onEdit,
    this.onDuplicate,
    this.onArchive,
    this.onStopsReordered,
  });

  @override
  State<RouteCardWidget> createState() => _RouteCardWidgetState();
}

class _RouteCardWidgetState extends State<RouteCardWidget>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;
  List<Map<String, dynamic>> _stops = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _stops = List<Map<String, dynamic>>.from(
        (widget.route['stops'] as List? ?? [])
            .map((stop) => stop as Map<String, dynamic>));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _reorderStops(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = _stops.removeAt(oldIndex);
      _stops.insert(newIndex, item);
    });
    widget.onStopsReordered?.call(_stops);
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            // Main route card content
            InkWell(
              onTap: _toggleExpansion,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: EdgeInsets.all(4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Route header
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 3.w,
                            vertical: 1.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.secondaryLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Route ${widget.route['routeNumber'] ?? 'N/A'}',
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(
                                  color: AppTheme.onSecondaryLight,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 2.w,
                            vertical: 0.5.h,
                          ),
                          decoration: BoxDecoration(
                            color: (widget.route['status'] == 'Active')
                                ? AppTheme.successLight.withValues(alpha: 0.1)
                                : AppTheme.warningLight.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            widget.route['status'] ?? 'Inactive',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: (widget.route['status'] == 'Active')
                                      ? AppTheme.successLight
                                      : AppTheme.warningLight,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ),
                        SizedBox(width: 2.w),
                        AnimatedRotation(
                          turns: _isExpanded ? 0.5 : 0,
                          duration: const Duration(milliseconds: 300),
                          child: CustomIconWidget(
                            iconName: 'keyboard_arrow_down',
                            color: isDark
                                ? AppTheme.textHighEmphasisDark
                                : AppTheme.textHighEmphasisLight,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),

                    // Route details
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CustomIconWidget(
                                    iconName: 'directions_bus',
                                    color: AppTheme.primaryLight,
                                    size: 18,
                                  ),
                                  SizedBox(width: 2.w),
                                  Text(
                                    'Bus: ${widget.route['assignedBus'] ?? 'Not Assigned'}',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                              SizedBox(height: 1.h),
                              Row(
                                children: [
                                  CustomIconWidget(
                                    iconName: 'person',
                                    color: AppTheme.primaryLight,
                                    size: 18,
                                  ),
                                  SizedBox(width: 2.w),
                                  Expanded(
                                    child: Text(
                                      'Driver: ${widget.route['driverName'] ?? 'Not Assigned'}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 1.h),
                              Row(
                                children: [
                                  CustomIconWidget(
                                    iconName: 'location_on',
                                    color: AppTheme.primaryLight,
                                    size: 18,
                                  ),
                                  SizedBox(width: 2.w),
                                  Text(
                                    '${_stops.length} Stops',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Action buttons
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            switch (value) {
                              case 'edit':
                                widget.onEdit?.call();
                                break;
                              case 'duplicate':
                                widget.onDuplicate?.call();
                                break;
                              case 'archive':
                                widget.onArchive?.call();
                                break;
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  CustomIconWidget(
                                    iconName: 'edit',
                                    color: AppTheme.primaryLight,
                                    size: 18,
                                  ),
                                  SizedBox(width: 2.w),
                                  const Text('Edit'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'duplicate',
                              child: Row(
                                children: [
                                  CustomIconWidget(
                                    iconName: 'content_copy',
                                    color: AppTheme.primaryLight,
                                    size: 18,
                                  ),
                                  SizedBox(width: 2.w),
                                  const Text('Duplicate'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'archive',
                              child: Row(
                                children: [
                                  CustomIconWidget(
                                    iconName: 'archive',
                                    color: AppTheme.warningLight,
                                    size: 18,
                                  ),
                                  SizedBox(width: 2.w),
                                  const Text('Archive'),
                                ],
                              ),
                            ),
                          ],
                          child: Container(
                            padding: EdgeInsets.all(2.w),
                            decoration: BoxDecoration(
                              color: AppTheme.secondaryLight
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: CustomIconWidget(
                              iconName: 'more_vert',
                              color: AppTheme.primaryLight,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Expandable stops section
            SizeTransition(
              sizeFactor: _expandAnimation,
              child: Container(
                padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Divider(
                      color:
                          isDark ? AppTheme.dividerDark : AppTheme.dividerLight,
                      thickness: 1,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Route Stops',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    SizedBox(height: 2.h),

                    // Reorderable stops list
                    Container(
                      constraints: BoxConstraints(maxHeight: 40.h),
                      child: ReorderableListView.builder(
                        shrinkWrap: true,
                        itemCount: _stops.length,
                        onReorder: _reorderStops,
                        itemBuilder: (context, index) {
                          final stop = _stops[index];
                          return Container(
                            key: ValueKey(stop['id']),
                            margin: EdgeInsets.only(bottom: 1.h),
                            padding: EdgeInsets.all(3.w),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppTheme.surfaceDark.withValues(alpha: 0.5)
                                  : AppTheme.surfaceLight
                                      .withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isDark
                                    ? AppTheme.dividerDark
                                    : AppTheme.dividerLight,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 8.w,
                                  height: 4.h,
                                  decoration: BoxDecoration(
                                    color: AppTheme.secondaryLight,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${index + 1}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium
                                          ?.copyWith(
                                            color: AppTheme.onSecondaryLight,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 3.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        stop['name'] ?? 'Unknown Stop',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w500,
                                            ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (stop['address'] != null) ...[
                                        SizedBox(height: 0.5.h),
                                        Text(
                                          stop['address'],
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                CustomIconWidget(
                                  iconName: 'drag_handle',
                                  color: isDark
                                      ? AppTheme.textMediumEmphasisDark
                                      : AppTheme.textMediumEmphasisLight,
                                  size: 20,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
