import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../theme/theme_notifier.dart';
import '../../../core/app_export.dart';

// 2025 Design Constants - Using Theme System
// Colors are now theme-aware and will automatically switch between light/dark modes

class SearchSectionWidget extends StatefulWidget {
  const SearchSectionWidget({super.key});

  @override
  State<SearchSectionWidget> createState() => _SearchSectionWidgetState();
}

class _SearchSectionWidgetState extends State<SearchSectionWidget> {
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();
  final FocusNode _fromFocus = FocusNode();
  final FocusNode _toFocus = FocusNode();

  // Theme-aware colors that prevent glitching
  Color get primaryColor => const Color(0xFF008B8B);
  Color get backgroundColor => ThemeNotifier().isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
  Color get textColor => ThemeNotifier().isDarkMode ? Colors.white : Colors.black87;
  Color get surfaceColor => ThemeNotifier().isDarkMode ? const Color(0xFF2D2D2D) : Colors.white;
  Color get onSurfaceColor => ThemeNotifier().isDarkMode ? Colors.white70 : Colors.black54;

  final List<String> _recentLocations = [
    'Downtown Terminal',
    'University Campus',
    'Airport Express',
    'Shopping Mall',
    'Business District',
  ];

  @override
  void initState() {
    super.initState();
    ThemeNotifier().addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    ThemeNotifier().removeListener(_onThemeChanged);
    _fromController.dispose();
    _toController.dispose();
    _fromFocus.dispose();
    _toFocus.dispose();
    super.dispose();
  }

  void _onThemeChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Where are you going?',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: textColor,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: 2.h),
          _buildSearchCards(),
        ],
      ),
    );
  }

  Widget _buildSearchCards() {
    return Container(
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(5.w),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSearchField(
            controller: _fromController,
            focusNode: _fromFocus,
            hint: 'Search From',
            icon: Icons.my_location,
            isTop: true,
          ),
          SizedBox(height: 2.h),
          _buildSwapButton(),
          SizedBox(height: 2.h),
          _buildSearchField(
            controller: _toController,
            focusNode: _toFocus,
            hint: 'Search To',
            icon: Icons.location_on,
            isTop: false,
          ),
          SizedBox(height: 3.h),
          _buildSearchButton(),
        ],
      ),
    );
  }

  Widget _buildSearchField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hint,
    required IconData icon,
    required bool isTop,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: focusNode.hasFocus
              ? primaryColor
              : Colors.grey.withOpacity(0.3),
          width: focusNode.hasFocus ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(3.w),
      ),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(
            icon,
            color: primaryColor,
            size: 6.w,
          ),
          suffixIcon: IconButton(
            onPressed: () => _showLocationSuggestions(controller),
            icon: Icon(
              Icons.search,
              color: primaryColor,
              size: 5.w,
            ),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 4.w,
            vertical: 3.h,
          ),
        ),
        onChanged: (value) {
          setState(() {});
        },
      ),
    );
  }

  Widget _buildSwapButton() {
    return Center(
      child: GestureDetector(
        onTap: _swapLocations,
        child: Container(
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(3.w),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            Icons.swap_vert,
            color: surfaceColor,
            size: 6.w,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchButton() {
    return SizedBox(
      width: double.infinity,
      height: 6.h,
      child: ElevatedButton(
        onPressed: _performSearch,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.w),
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
        ).copyWith(
          overlayColor: WidgetStateProperty.all(
            Colors.white.withOpacity(0.1),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 5.w),
            SizedBox(width: 2.w),
            Text(
              'Search Buses',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _swapLocations() {
    final tempText = _fromController.text;
    _fromController.text = _toController.text;
    _toController.text = tempText;
  }

  void _showLocationSuggestions(TextEditingController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildSuggestionsBottomSheet(controller),
    );
  }

  Widget _buildSuggestionsBottomSheet(TextEditingController controller) {
    return Container(
      height: 40.h,
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(6.w)),
      ),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.symmetric(vertical: 2.h),
            width: 15.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(0.5.h),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.w),
            child: Text(
              'Recent Locations',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _recentLocations.length,
              padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Icon(
                    Icons.history,
                    color: primaryColor,
                  ),
                  title: Text(_recentLocations[index]),
                  onTap: () {
                    controller.text = _recentLocations[index];
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _performSearch() {
    if (_fromController.text.isNotEmpty && _toController.text.isNotEmpty) {
      Navigator.pushNamed(context, AppRoutes.busBookingForm, arguments: {
        'from': _fromController.text,
        'to': _toController.text,
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter both from and to locations'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}