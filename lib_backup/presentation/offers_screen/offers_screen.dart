import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_drawer.dart';
import '../../widgets/floating_back_to_top_button.dart';

class OffersScreen extends StatefulWidget {
  const OffersScreen({super.key});

  @override
  State<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _headerAnimationController;
  late AnimationController _cardAnimationController;
  late Animation<double> _headerAnimation;
  late Animation<double> _cardAnimation;
  late ScrollController _scrollController;

  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'Flash Sale', 'Premium', 'Weekend', 'Monthly'];

  final List<Map<String, dynamic>> _offers = [
    {
      'id': '1',
      'title': 'Flash Sale - 50% Off',
      'subtitle': 'Limited time offer',
      'description': 'Get 50% off on all routes to Yaoundé this weekend only!',
      'discount': '50%',
      'originalPrice': 'XFA 4000',
      'discountedPrice': 'XFA 2000',
      'validUntil': DateTime.now().add(const Duration(days: 2)),
      'category': 'Flash Sale',
      'gradient': [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
      'icon': 'flash_on',
      'routes': ['Douala → Yaoundé', 'Bamenda → Yaoundé'],
      'terms': ['Valid for weekend travel only', 'Non-refundable', 'Limited seats available'],
      'isPopular': true,
      'usedCount': 127,
    },
    {
      'id': '2',
      'title': 'Premium Comfort Deal',
      'subtitle': 'Luxury travel experience',
      'description': 'Experience premium comfort with AC sleeper buses at regular prices.',
      'discount': '30%',
      'originalPrice': 'XFA 6000',
      'discountedPrice': 'XFA 4200',
      'validUntil': DateTime.now().add(const Duration(days: 15)),
      'category': 'Premium',
      'gradient': [Color(0xFF667eea), Color(0xFF764ba2)],
      'icon': 'airline_seat_legroom_extra',
      'routes': ['Douala → Garoua', 'Yaoundé → Bamenda'],
      'terms': ['Includes complimentary snacks', 'Extra legroom', 'USB charging available'],
      'isPopular': false,
      'usedCount': 89,
    },
    {
      'id': '3',
      'title': 'Student Special',
      'subtitle': 'Education discount',
      'description': 'Special rates for students with valid ID. Travel smart, save money!',
      'discount': '25%',
      'originalPrice': 'XFA 3000',
      'discountedPrice': 'XFA 2250',
      'validUntil': DateTime.now().add(const Duration(days: 30)),
      'category': 'Monthly',
      'gradient': [Color(0xFF11998e), Color(0xFF38ef7d)],
      'icon': 'school',
      'routes': ['All student routes', 'University shuttles'],
      'terms': ['Valid student ID required', 'Age limit: 18-30 years', 'Semester validity'],
      'isPopular': true,
      'usedCount': 234,
    },
    {
      'id': '4',
      'title': 'Weekend Explorer',
      'subtitle': 'Weekend adventures',
      'description': 'Explore Cameroon with weekend travel packages. Adventure awaits!',
      'discount': '40%',
      'originalPrice': 'XFA 5000',
      'discountedPrice': 'XFA 3000',
      'validUntil': DateTime.now().add(const Duration(days: 7)),
      'category': 'Weekend',
      'gradient': [Color(0xFFf093fb), Color(0xFFf5576c)],
      'icon': 'landscape',
      'routes': ['Douala → Limbe', 'Yaoundé → Bertoua'],
      'terms': ['Weekend departure only', 'Return by Sunday', 'Package includes tours'],
      'isPopular': false,
      'usedCount': 156,
    },
  ];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _tabController = TabController(length: _categories.length, vsync: this);
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _headerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeOutBack,
    ));

    _cardAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _cardAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _headerAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _cardAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _headerAnimationController.dispose();
    _cardAnimationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredOffers {
    if (_selectedCategory == 'All') return _offers;
    return _offers.where((offer) => offer['category'] == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      drawer: const CustomDrawer(),
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              _buildSophisticatedAppBar(),
              _buildCategoryTabs(),
              _buildOffersGrid(),
            ],
          ),
          FloatingBackToTopButton(
            scrollController: _scrollController,
            showOffset: 300.0,
          ),
        ],
      ),
    );
  }

  Widget _buildSophisticatedAppBar() {
    return SliverAppBar(
      expandedHeight: 20.h,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: const Color(0xFF1A4A47),
      flexibleSpace: FlexibleSpaceBar(
        background: AnimatedBuilder(
          animation: _headerAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: 0.8 + (0.2 * _headerAnimation.value),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1A4A47),
                      Color(0xFF2A5D5A),
                      Color(0xFF1A4A47),
                    ],
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.1),
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 2.h),
                          Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(3.w),
                                ),
                                child: IconButton(
                                  onPressed: () => Navigator.pop(context),
                                  icon: CustomIconWidget(
                                    iconName: 'arrow_back',
                                    color: Colors.white,
                                    size: 6.w,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(3.w),
                                ),
                                child: IconButton(
                                  onPressed: _showNotifications,
                                  icon: Stack(
                                    children: [
                                      CustomIconWidget(
                                        iconName: 'notifications',
                                        color: Colors.white,
                                        size: 6.w,
                                      ),
                                      Positioned(
                                        top: 0,
                                        right: 0,
                                        child: Container(
                                          width: 2.w,
                                          height: 2.w,
                                          decoration: BoxDecoration(
                                            color: AppTheme.lightTheme.colorScheme.secondary,
                                            borderRadius: BorderRadius.circular(1.w),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          FadeTransition(
                            opacity: _headerAnimation,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFC8E53F).withValues(alpha: 0.3),
                                    borderRadius: BorderRadius.circular(2.w),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CustomIconWidget(
                                        iconName: 'local_offer',
                                        color: const Color(0xFFC8E53F),
                                        size: 4.w,
                                      ),
                                      SizedBox(width: 1.w),
                                      Text(
                                        'Special Offers',
                                        style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 1.h),
                                Text(
                                  'Exclusive Deals\n& Discounts',
                                  style: AppTheme.lightTheme.textTheme.headlineLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    height: 1.1,
                                  ),
                                ),
                                SizedBox(height: 1.h),
                                Text(
                                  'Save big on your next journey with our limited-time offers',
                                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 2.h),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
      leading: Container(),
    );
  }

  Widget _buildCategoryTabs() {
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Categories',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppTheme.lightTheme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 1.h),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _categories.map((category) {
                  final isSelected = _selectedCategory == category;
                  return Container(
                    margin: EdgeInsets.only(right: 2.w),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            _selectedCategory = category;
                          });
                        },
                        borderRadius: BorderRadius.circular(3.w),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? LinearGradient(
                                    colors: [
                                      AppTheme.lightTheme.colorScheme.primary,
                                      AppTheme.lightTheme.colorScheme.primaryContainer,
                                    ],
                                  )
                                : null,
                            color: isSelected ? null : Colors.white,
                            borderRadius: BorderRadius.circular(3.w),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.transparent
                                  : AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                          ),
                          child: Text(
                            category,
                            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                              color: isSelected
                                  ? Colors.white
                                  : AppTheme.lightTheme.colorScheme.onSurface,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOffersGrid() {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      sliver: AnimatedBuilder(
        animation: _cardAnimation,
        builder: (context, child) {
          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final offer = _filteredOffers[index];
                return Transform.translate(
                  offset: Offset(0, 50 * (1 - _cardAnimation.value)),
                  child: Opacity(
                    opacity: _cardAnimation.value,
                    child: _buildSophisticatedOfferCard(offer, index),
                  ),
                );
              },
              childCount: _filteredOffers.length,
            ),
          );
        },
      ),
    );
  }

  Widget _buildSophisticatedOfferCard(Map<String, dynamic> offer, int index) {
    final gradient = offer['gradient'] as List<Color>;
    
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showOfferDetails(offer),
          borderRadius: BorderRadius.circular(4.w),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradient,
              ),
              borderRadius: BorderRadius.circular(4.w),
              boxShadow: [
                BoxShadow(
                  color: gradient.first.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.w),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.1),
                  ],
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(3.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Row
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(2.w),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(2.w),
                          ),
                          child: CustomIconWidget(
                            iconName: offer['icon'],
                            color: Colors.white,
                            size: 5.w,
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  if (offer['isPopular'])
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                                      decoration: BoxDecoration(
                                        color: AppTheme.lightTheme.colorScheme.secondary,
                                        borderRadius: BorderRadius.circular(1.w),
                                      ),
                                      child: Text(
                                        'POPULAR',
                                        style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                                          color: AppTheme.lightTheme.colorScheme.onSecondary,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 8,
                                        ),
                                      ),
                                    ),
                                  const Spacer(),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(2.w),
                                    ),
                                    child: Text(
                                      '${offer['discount']} OFF',
                                      style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 3.h),
                    // Title and Description
                    Text(
                      offer['title'],
                      style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      offer['subtitle'],
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      offer['description'],
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    // Price Section
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Starting from',
                              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                                color: Colors.white.withValues(alpha: 0.7),
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  offer['originalPrice'],
                                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.7),
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                                SizedBox(width: 2.w),
                                Text(
                                  offer['discountedPrice'],
                                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Spacer(),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(3.w),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Claim Offer',
                                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                                  color: gradient.first,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(width: 1.w),
                              CustomIconWidget(
                                iconName: 'arrow_forward',
                                color: gradient.first,
                                size: 4.w,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    // Footer info
                    Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'schedule',
                          color: Colors.white.withValues(alpha: 0.7),
                          size: 3.w,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          'Valid until ${_formatDate(offer['validUntil'])}',
                          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${offer['usedCount']} used',
                          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]}';
  }

  void _showOfferDetails(Map<String, dynamic> offer) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildOfferDetailsSheet(offer),
    );
  }

  Widget _buildOfferDetailsSheet(Map<String, dynamic> offer) {
    final gradient = offer['gradient'] as List<Color>;
    
    return Container(
      height: 85.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: EdgeInsets.only(top: 2.h),
            width: 12.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Container(
            margin: EdgeInsets.all(4.w),
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradient),
              borderRadius: BorderRadius.circular(3.w),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(2.w),
                      ),
                      child: CustomIconWidget(
                        iconName: offer['icon'],
                        color: Colors.white,
                        size: 5.w,
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            offer['title'],
                            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            offer['subtitle'],
                            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(2.w),
                      ),
                      child: Text(
                        '${offer['discount']} OFF',
                        style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description
                  _buildDetailSection(
                    'Description',
                    offer['description'],
                    'info',
                  ),
                  SizedBox(height: 3.h),
                  // Routes
                  _buildDetailSection(
                    'Available Routes',
                    (offer['routes'] as List<String>).join('\n'),
                    'route',
                  ),
                  SizedBox(height: 3.h),
                  // Terms
                  _buildDetailSection(
                    'Terms & Conditions',
                    (offer['terms'] as List<String>).map((term) => '• $term').join('\n'),
                    'assignment',
                  ),
                  SizedBox(height: 3.h),
                  // Price breakdown
                  Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(3.w),
                      border: Border.all(
                        color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Price Breakdown',
                          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Regular Price'),
                            Text(
                              offer['originalPrice'],
                              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                                decoration: TextDecoration.lineThrough,
                                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 1.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Discount (${offer['discount']})'),
                            Text(
                              '-XFA ${(int.parse(offer['originalPrice'].replaceAll('XFA ', '')) - int.parse(offer['discountedPrice'].replaceAll('XFA ', ''))).toString()}',
                              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                                color: Colors.green,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Final Price',
                              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              offer['discountedPrice'],
                              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                                color: AppTheme.lightTheme.colorScheme.primary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 4.h),
                ],
              ),
            ),
          ),
          // Action Button
          Container(
            padding: EdgeInsets.all(4.w),
            child: SizedBox(
              width: double.infinity,
              height: 6.h,
              child: ElevatedButton(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  Navigator.pop(context);
                  _claimOffer(offer);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: gradient.first,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3.w),
                  ),
                ),
                child: Text(
                  'Claim This Offer',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, String content, String iconName) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(3.w),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.1),
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
                  color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(2.w),
                ),
                child: CustomIconWidget(
                  iconName: iconName,
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 4.w,
                ),
              ),
              SizedBox(width: 2.w),
              Text(
                title,
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            content,
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              height: 1.5,
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  void _claimOffer(Map<String, dynamic> offer) {
    // Handle offer claiming logic
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Offer Claimed!'),
        content: Text('You have successfully claimed the ${offer['title']} offer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showNotifications() {
    // Handle notifications
  }
}