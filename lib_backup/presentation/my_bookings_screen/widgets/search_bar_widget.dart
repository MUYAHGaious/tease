import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SearchBarWidget extends StatefulWidget {
  final String hintText;
  final Function(String) onSearchChanged;
  final VoidCallback? onFilterTap;

  const SearchBarWidget({
    Key? key,
    required this.hintText,
    required this.onSearchChanged,
    this.onFilterTap,
  }) : super(key: key);

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchActive = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.shadowLight,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _isSearchActive = value.isNotEmpty;
                  });
                  widget.onSearchChanged(value);
                },
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textDisabledLight,
                  ),
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(3.w),
                    child: CustomIconWidget(
                      iconName: 'search',
                      color: _isSearchActive
                          ? AppTheme.primaryLight
                          : AppTheme.textSecondaryLight,
                      size: 5.w,
                    ),
                  ),
                  suffixIcon: _isSearchActive
                      ? IconButton(
                          onPressed: _clearSearch,
                          icon: CustomIconWidget(
                            iconName: 'clear',
                            color: AppTheme.textSecondaryLight,
                            size: 5.w,
                          ),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 4.w,
                    vertical: 2.h,
                  ),
                ),
                style: AppTheme.lightTheme.textTheme.bodyMedium,
              ),
            ),
          ),
          if (widget.onFilterTap != null) ...[
            SizedBox(width: 3.w),
            _buildFilterButton(context),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowLight,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        onPressed: widget.onFilterTap,
        icon: CustomIconWidget(
          iconName: 'tune',
          color: AppTheme.primaryLight,
          size: 6.w,
        ),
        padding: EdgeInsets.all(3.w),
        constraints: BoxConstraints(
          minWidth: 12.w,
          minHeight: 12.w,
        ),
      ),
    );
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _isSearchActive = false;
    });
    widget.onSearchChanged('');
  }
}
