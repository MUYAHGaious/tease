import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

/// Global Microphone Button Widget
///
/// Features:
/// - Positioned in bottom right corner
/// - Consistent styling across all screens
/// - Voice assistant functionality
/// - Haptic feedback
class GlobalMicrophoneButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final double bottomOffset;
  final double rightOffset;

  const GlobalMicrophoneButton({
    Key? key,
    this.onPressed,
    this.bottomOffset = 120, // Default position below basket icon
    this.rightOffset = 3.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Theme-aware colors
    final primaryColor = const Color(0xFF008B8B);

    return Positioned(
      bottom: bottomOffset,
      right: rightOffset.w,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          if (onPressed != null) {
            onPressed!();
          } else {
            _showDefaultVoiceAssistant(context);
          }
        },
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            Icons.mic,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }

  void _showDefaultVoiceAssistant(BuildContext context) {
    final primaryColor = const Color(0xFF008B8B);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.4,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Icon(
              Icons.mic,
              size: 64,
              color: primaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Voice Assistant',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap and hold to speak',
              style: TextStyle(
                fontSize: 12.sp,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
}
