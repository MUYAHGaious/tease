import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class SavedCardCarousel extends StatefulWidget {
  final List<Map<String, dynamic>> savedCards;
  final Function(Map<String, dynamic>) onCardSelected;
  final Function(Map<String, dynamic>) onCardDeleted;

  const SavedCardCarousel({
    Key? key,
    required this.savedCards,
    required this.onCardSelected,
    required this.onCardDeleted,
  }) : super(key: key);

  @override
  State<SavedCardCarousel> createState() => _SavedCardCarouselState();
}

class _SavedCardCarouselState extends State<SavedCardCarousel> {
  final PageController _pageController = PageController(viewportFraction: 0.85);
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.savedCards.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.w),
          child: Text(
            'Saved Cards',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        SizedBox(height: 2.h),
        SizedBox(
          height: 22.h,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: widget.savedCards.length,
            itemBuilder: (context, index) {
              return _buildCardItem(widget.savedCards[index], index);
            },
          ),
        ),
        SizedBox(height: 2.h),
        _buildPageIndicator(),
      ],
    );
  }

  Widget _buildCardItem(Map<String, dynamic> card, int index) {
    final isActive = index == _currentIndex;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(horizontal: 2.w),
      child: Transform.scale(
        scale: isActive ? 1.0 : 0.9,
        child: Dismissible(
          key: Key(card['id'].toString()),
          direction: DismissDirection.up,
          background: Container(
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomIconWidget(
                    iconName: 'delete',
                    color: Colors.white,
                    size: 32,
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'Delete Card',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
          ),
          onDismissed: (direction) {
            widget.onCardDeleted(card);
          },
          child: GestureDetector(
            onTap: () => widget.onCardSelected(card),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _getCardGradient(card['type'] as String),
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        card['bankName'] as String,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      CustomIconWidget(
                        iconName: _getCardIcon(card['type'] as String),
                        color: Colors.white,
                        size: 24,
                      ),
                    ],
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    _formatCardNumber(card['cardNumber'] as String),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 2,
                        ),
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CARD HOLDER',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 8.sp,
                                ),
                          ),
                          Text(
                            card['holderName'] as String,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'EXPIRES',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 8.sp,
                                ),
                          ),
                          Text(
                            card['expiryDate'] as String,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.savedCards.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: EdgeInsets.symmetric(horizontal: 1.w),
          width: index == _currentIndex ? 8.w : 2.w,
          height: 1.h,
          decoration: BoxDecoration(
            color: index == _currentIndex
                ? AppTheme.lightTheme.colorScheme.primary
                : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  List<Color> _getCardGradient(String cardType) {
    switch (cardType.toLowerCase()) {
      case 'visa':
        return [
          const Color(0xFF1A237E),
          const Color(0xFF3949AB),
        ];
      case 'mastercard':
        return [
          const Color(0xFFD32F2F),
          const Color(0xFFFF5722),
        ];
      case 'amex':
        return [
          const Color(0xFF00695C),
          const Color(0xFF26A69A),
        ];
      default:
        return [
          AppTheme.lightTheme.colorScheme.primary,
          AppTheme.lightTheme.colorScheme.primaryContainer,
        ];
    }
  }

  String _getCardIcon(String cardType) {
    switch (cardType.toLowerCase()) {
      case 'visa':
        return 'credit_card';
      case 'mastercard':
        return 'credit_card';
      case 'amex':
        return 'credit_card';
      default:
        return 'credit_card';
    }
  }

  String _formatCardNumber(String cardNumber) {
    return '**** **** **** ${cardNumber.substring(cardNumber.length - 4)}';
  }
}
