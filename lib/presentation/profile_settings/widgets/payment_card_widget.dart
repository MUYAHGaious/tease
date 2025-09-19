import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class PaymentCardWidget extends StatelessWidget {
  final Map<String, dynamic> cardData;
  final VoidCallback onDelete;
  final bool isDefault;

  const PaymentCardWidget({
    Key? key,
    required this.cardData,
    required this.onDelete,
    this.isDefault = false,
  }) : super(key: key);

  Color _getCardColor() {
    switch (cardData["cardColor"]) {
      case "black":
        return Colors.black;
      case "gold":
        return Color(0xFFFFD700); // Gold color
      case "red":
        return Color(0xFF590303); // Red (89, 3, 3)
      case "orange":
        return Color(0xFFD65A02); // Orange #d65a02
      case "blue":
        return Color(0xFF045DBD); // Blue #045dbd
      default:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = _getCardColor();
    final cardType = cardData["type"];

    return Container(
      width: 70.w,
      height: 42.w, // Reduced height to prevent overflow
      margin: EdgeInsets.only(right: 4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cardColor,
            cardColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: cardColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Card background pattern
          _buildCardPattern(cardType),

          // Main card content
          Padding(
            padding: EdgeInsets.all(3.w), // Reduced padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // Prevent overflow
              children: [
                // Top section with brand logo and default badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildCardBrand(cardType),
                    if (isDefault)
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 1.5.w,
                            vertical: 0.3.h), // Reduced padding
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          "DEFAULT",
                          style: TextStyle(
                            color: cardColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 7.sp, // Reduced font size
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                  ],
                ),

                SizedBox(height: 1.h), // Fixed spacing instead of Spacer

                // Card number
                Flexible(
                  child: Text(
                    "•••• •••• •••• ${cardData["lastFour"]}",
                    style: TextStyle(
                      fontSize: 12.sp, // Reduced font size
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      letterSpacing: 1.5, // Reduced letter spacing
                      fontFamily: 'Courier',
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                SizedBox(height: 0.8.h), // Reduced spacing

                // Bottom section with cardholder and expiry
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "CARDHOLDER",
                            style: TextStyle(
                              fontSize: 7.sp, // Reduced font size
                              color: Colors.white.withOpacity(0.8),
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.3,
                            ),
                          ),
                          SizedBox(height: 0.2.h), // Reduced spacing
                          Text(
                            cardData["holderName"],
                            style: TextStyle(
                              fontSize: 9.sp, // Reduced font size
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.2,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "EXPIRES",
                          style: TextStyle(
                            fontSize: 7.sp, // Reduced font size
                            color: Colors.white.withOpacity(0.8),
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.3,
                          ),
                        ),
                        SizedBox(height: 0.2.h), // Reduced spacing
                        Text(
                          cardData["expiryDate"],
                          style: TextStyle(
                            fontSize: 9.sp, // Reduced font size
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Delete button
          Positioned(
            top: 1.5.w, // Adjusted position
            right: 1.5.w, // Adjusted position
            child: GestureDetector(
              onTap: onDelete,
              child: Container(
                padding: EdgeInsets.all(0.8.w), // Reduced padding
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: CustomIconWidget(
                  iconName: 'delete',
                  color: Colors.white,
                  size: 3.5.w, // Reduced size
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardPattern(String cardType) {
    return Positioned.fill(
      child: CustomPaint(
        painter: CardPatternPainter(cardType),
      ),
    );
  }

  Widget _buildCardBrand(String cardType) {
    switch (cardType.toLowerCase()) {
      case 'visa':
        return Container(
          padding: EdgeInsets.all(1.w),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            'VISA',
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1F71), // Visa blue
              letterSpacing: 1,
            ),
          ),
        );
      case 'mastercard':
        return Container(
          padding: EdgeInsets.all(1.w),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            'MC',
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
              color: Color(0xFFEB001B), // Mastercard red
              letterSpacing: 1,
            ),
          ),
        );
      case 'american express':
        return Container(
          padding: EdgeInsets.all(1.w),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            'AMEX',
            style: TextStyle(
              fontSize: 9.sp,
              fontWeight: FontWeight.w700,
              color: Color(0xFF006FCF), // Amex blue
              letterSpacing: 0.5,
            ),
          ),
        );
      case 'discover':
        return Container(
          padding: EdgeInsets.all(1.w),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            'DISC',
            style: TextStyle(
              fontSize: 9.sp,
              fontWeight: FontWeight.w700,
              color: Color(0xFFFF6000), // Discover orange
              letterSpacing: 0.5,
            ),
          ),
        );
      case 'paypal':
        return Container(
          padding: EdgeInsets.all(1.w),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            'PP',
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0070BA), // PayPal blue
              letterSpacing: 1,
            ),
          ),
        );
      default:
        return Container(
          padding: EdgeInsets.all(1.w),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            'CARD',
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black,
              letterSpacing: 1,
            ),
          ),
        );
    }
  }
}

class CardPatternPainter extends CustomPainter {
  final String cardType;

  CardPatternPainter(this.cardType);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    // Add subtle patterns based on card type
    switch (cardType.toLowerCase()) {
      case 'visa':
        _drawVisaPattern(canvas, size);
        break;
      case 'mastercard':
        _drawMastercardPattern(canvas, size);
        break;
      case 'american express':
        _drawAmexPattern(canvas, size);
        break;
      case 'discover':
        _drawDiscoverPattern(canvas, size);
        break;
      case 'paypal':
        _drawPayPalPattern(canvas, size);
        break;
      default:
        _drawDefaultPattern(canvas, size);
    }
  }

  void _drawVisaPattern(Canvas canvas, Size size) {
    // Visa-style geometric pattern
    for (int i = 0; i < 5; i++) {
      canvas.drawCircle(
        Offset(size.width * 0.8, size.height * 0.2 + i * 8),
        2,
        Paint()..color = Colors.white.withOpacity(0.1),
      );
    }
  }

  void _drawMastercardPattern(Canvas canvas, Size size) {
    // Mastercard-style overlapping circles
    canvas.drawCircle(
      Offset(size.width * 0.7, size.height * 0.3),
      15,
      Paint()..color = Colors.white.withOpacity(0.05),
    );
    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.3),
      15,
      Paint()..color = Colors.white.withOpacity(0.05),
    );
  }

  void _drawAmexPattern(Canvas canvas, Size size) {
    // Amex-style lines
    for (int i = 0; i < 3; i++) {
      canvas.drawRect(
        Rect.fromLTWH(size.width * 0.6, size.height * 0.2 + i * 8, 30, 2),
        Paint()..color = Colors.white.withOpacity(0.1),
      );
    }
  }

  void _drawDiscoverPattern(Canvas canvas, Size size) {
    // Discover-style dots
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 3; j++) {
        canvas.drawCircle(
          Offset(size.width * 0.6 + i * 8, size.height * 0.2 + j * 8),
          1.5,
          Paint()..color = Colors.white.withOpacity(0.1),
        );
      }
    }
  }

  void _drawPayPalPattern(Canvas canvas, Size size) {
    // PayPal-style waves
    final path = Path();
    path.moveTo(size.width * 0.6, size.height * 0.3);
    path.quadraticBezierTo(size.width * 0.7, size.height * 0.2,
        size.width * 0.8, size.height * 0.3);
    path.quadraticBezierTo(size.width * 0.9, size.height * 0.4,
        size.width * 0.95, size.height * 0.3);
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white.withOpacity(0.1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  void _drawDefaultPattern(Canvas canvas, Size size) {
    // Default subtle pattern
    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.2),
      8,
      Paint()..color = Colors.white.withOpacity(0.1),
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
