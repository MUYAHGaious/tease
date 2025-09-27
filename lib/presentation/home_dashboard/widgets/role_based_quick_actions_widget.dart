import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../core/app_state.dart';
import '../../../theme/app_theme.dart';
import '../../../services/role_ui_service.dart';

// 2025 Design Constants
const Color primaryColor = Color(0xFF008B8B);
const double cardBorderRadius = 16.0;

class RoleBasedQuickActionsWidget extends StatefulWidget {
  final Function(String) onActionTap;

  const RoleBasedQuickActionsWidget({
    super.key,
    required this.onActionTap,
  });

  @override
  State<RoleBasedQuickActionsWidget> createState() =>
      _RoleBasedQuickActionsWidgetState();
}

class _RoleBasedQuickActionsWidgetState
    extends State<RoleBasedQuickActionsWidget> with TickerProviderStateMixin {
  late List<AnimationController> _animationControllers;
  late List<Animation<double>> _scaleAnimations;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    final appState = AppState();
    final user = appState.currentUser;
    final quickActions =
        user != null ? RoleUIService.getQuickActions(user) : [];

    _animationControllers = List.generate(
      quickActions.length,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
      ),
    );

    _scaleAnimations = _animationControllers.map((controller) {
      return Tween<double>(begin: 1.0, end: 0.95).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.easeInOut,
        ),
      );
    }).toList();
  }

  @override
  void dispose() {
    for (var controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Widget _buildActionCard(Map<String, dynamic> action, int index) {
    return AnimatedBuilder(
      animation: _animationControllers[index],
      builder: (context, child) {
        return ScaleTransition(
          scale: _scaleAnimations[index],
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(cardBorderRadius),
              border: Border.all(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: (action['color'] as Color).withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  HapticFeedback.selectionClick();
                  widget.onActionTap(action['route']);
                },
                onTapDown: (_) => _animationControllers[index].forward(),
                onTapUp: (_) => _animationControllers[index].reverse(),
                onTapCancel: () => _animationControllers[index].reverse(),
                borderRadius: BorderRadius.circular(cardBorderRadius),
                child: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Role-specific icon container
                      Container(
                        padding: EdgeInsets.all(3.w),
                        decoration: BoxDecoration(
                          color: (action['color'] as Color).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: (action['color'] as Color).withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: CustomIconWidget(
                          iconName: action['icon'],
                          color: action['color'],
                          size: 6.w,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      // Title with role-specific styling
                      Text(
                        action['title'],
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                          fontSize: 12.sp,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 0.5.h),
                      // Subtitle
                      Text(
                        action['subtitle'],
                        style: TextStyle(
                          color: (action['color'] as Color).withOpacity(0.7),
                          fontWeight: FontWeight.w500,
                          fontSize: 9.sp,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState(),
      builder: (context, child) {
        final appState = AppState();
        final user = appState.currentUser;

        if (user == null) {
          return const SizedBox.shrink();
        }

        final quickActions = RoleUIService.getQuickActions(user);

        // Reinitialize animations if actions changed
        if (_animationControllers.length != quickActions.length) {
          for (var controller in _animationControllers) {
            controller.dispose();
          }
          _initializeAnimations();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Role-based section header
            Container(
              margin: EdgeInsets.only(left: 5.w, right: 5.w),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Quick Actions',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (RoleUIService.getRoleBadge(user) != null)
                    RoleUIService.getRoleBadge(user)!,
                ],
              ),
            ),
            SizedBox(height: 1.h),

            // Role-based grid layout
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.w),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.3,
                  crossAxisSpacing: 3.w,
                  mainAxisSpacing: 1.h,
                ),
                itemCount: quickActions.length,
                itemBuilder: (context, index) {
                  return _buildActionCard(quickActions[index], index);
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
