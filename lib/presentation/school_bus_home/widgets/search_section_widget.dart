import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SearchSectionWidget extends StatefulWidget {
  const SearchSectionWidget({super.key});

  @override
  State<SearchSectionWidget> createState() => _SearchSectionWidgetState();
}

class _SearchSectionWidgetState extends State<SearchSectionWidget>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();
  final FocusNode _fromFocus = FocusNode();
  final FocusNode _toFocus = FocusNode();

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
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fromController.dispose();
    _toController.dispose();
    _fromFocus.dispose();
    _toFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 5.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Where are you going?',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryLight,
                  ),
            ),
            SizedBox(height: 2.h),
            _buildSearchCards(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchCards() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4.w),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryLight.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        border: Border.all(
          color: focusNode.hasFocus
              ? AppTheme.secondaryLight
              : AppTheme.neutralLight.withValues(alpha: 0.3),
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
            color: AppTheme.primaryLight,
            size: 6.w,
          ),
          suffixIcon: IconButton(
            onPressed: () => _showLocationSuggestions(controller),
            icon: Icon(
              Icons.search,
              color: AppTheme.primaryLight,
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
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: AppTheme.secondaryLight,
            borderRadius: BorderRadius.circular(2.w),
            boxShadow: [
              BoxShadow(
                color: AppTheme.secondaryLight.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            Icons.swap_vert,
            color: AppTheme.onSecondaryLight,
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
          backgroundColor: AppTheme.primaryLight,
          foregroundColor: AppTheme.onPrimaryLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(3.w),
          ),
          elevation: 4,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 5.w),
            SizedBox(width: 2.w),
            Text(
              'Search Buses',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.onPrimaryLight,
                    fontWeight: FontWeight.w600,
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
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(6.w)),
      ),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.symmetric(vertical: 2.h),
            width: 15.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: AppTheme.neutralLight,
              borderRadius: BorderRadius.circular(0.5.h),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.w),
            child: Text(
              'Recent Locations',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
                    color: AppTheme.primaryLight,
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
        const SnackBar(
          content: Text('Please enter both from and to locations'),
          backgroundColor: AppTheme.errorLight,
        ),
      );
    }
  }
}
