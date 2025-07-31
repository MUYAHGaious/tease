import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_drawer.dart';
import '../../widgets/floating_back_to_top_button.dart';

class HelpFaqScreen extends StatefulWidget {
  const HelpFaqScreen({super.key});

  @override
  State<HelpFaqScreen> createState() => _HelpFaqScreenState();
}

class _HelpFaqScreenState extends State<HelpFaqScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerAnimationController;
  late AnimationController _contentAnimationController;
  late Animation<double> _headerAnimation;
  late Animation<double> _contentAnimation;
  late ScrollController _scrollController;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';
  
  final List<String> _categories = [
    'All',
    'Booking',
    'Payment',
    'Cancellation',
    'Account',
    'Technical',
    'General',
  ];

  final List<Map<String, dynamic>> _faqItems = [
    {
      'category': 'Booking',
      'question': 'How do I book a bus ticket?',
      'answer': 'To book a bus ticket:\n\n1. Select your departure and destination cities\n2. Choose your travel date and time\n3. Pick your preferred seat\n4. Enter passenger details\n5. Complete payment\n6. Receive your e-ticket via email/SMS',
      'tags': ['booking', 'ticket', 'reservation'],
      'helpful': 245,
      'not_helpful': 12,
      'views': 1250,
    },
    {
      'category': 'Payment',
      'question': 'What payment methods do you accept?',
      'answer': 'We accept multiple payment methods:\n\n• Mobile Money (MTN, Orange)\n• Credit/Debit Cards\n• Bank Transfers\n• Digital Wallets\n• Cash payments at partner locations\n\nAll payments are secure and encrypted for your safety.',
      'tags': ['payment', 'mobile money', 'cards'],
      'helpful': 189,
      'not_helpful': 8,
      'views': 980,
    },
    {
      'category': 'Cancellation',
      'question': 'Can I cancel or modify my booking?',
      'answer': 'Yes, you can cancel or modify your booking:\n\n• Cancellations: Up to 24 hours before departure\n• Modifications: Up to 6 hours before departure\n• Refund processing: 3-5 business days\n• Cancellation fees may apply based on timing\n\nContact customer support for assistance.',
      'tags': ['cancel', 'modify', 'refund'],
      'helpful': 156,
      'not_helpful': 23,
      'views': 750,
    },
    {
      'category': 'Account',
      'question': 'How do I create an account?',
      'answer': 'Creating an account is simple:\n\n1. Download the Tease app\n2. Tap "Sign Up" on the welcome screen\n3. Enter your phone number\n4. Verify with the SMS code\n5. Complete your profile information\n6. Start booking!\n\nYour account helps you track bookings and earn rewards.',
      'tags': ['account', 'signup', 'registration'],
      'helpful': 203,
      'not_helpful': 5,
      'views': 1100,
    },
    {
      'category': 'Technical',
      'question': 'The app is not working properly. What should I do?',
      'answer': 'If you\'re experiencing technical issues:\n\n1. Check your internet connection\n2. Update the app to the latest version\n3. Restart the app\n4. Clear app cache (Android)\n5. Restart your device\n\nIf problems persist, contact our technical support team.',
      'tags': ['technical', 'bug', 'app issues'],
      'helpful': 87,
      'not_helpful': 15,
      'views': 450,
    },
    {
      'category': 'General',
      'question': 'What are your operating hours?',
      'answer': 'Our services are available:\n\n• Booking: 24/7 online\n• Customer Support: 6:00 AM - 10:00 PM\n• Bus Operations: Varies by route\n• Emergency Support: 24/7\n\nMost popular routes have multiple daily departures.',
      'tags': ['hours', 'schedule', 'availability'],
      'helpful': 134,
      'not_helpful': 7,
      'views': 620,
    },
    {
      'category': 'Booking',
      'question': 'Can I book tickets for other people?',
      'answer': 'Yes, you can book for family and friends:\n\n• Enter their details during booking\n• You can book up to 6 passengers per transaction\n• Each passenger needs valid ID for travel\n• The booking confirmation will be sent to your account\n\nEnsure all passenger information is accurate.',
      'tags': ['group booking', 'family', 'multiple passengers'],
      'helpful': 98,
      'not_helpful': 4,
      'views': 380,
    },
    {
      'category': 'Payment',
      'question': 'Is my payment information secure?',
      'answer': 'Your payment security is our priority:\n\n• SSL encryption for all transactions\n• PCI DSS compliant payment processing\n• No card details stored on our servers\n• Two-factor authentication available\n• Regular security audits\n\nWe partner with trusted payment providers for maximum security.',
      'tags': ['security', 'encryption', 'payment safety'],
      'helpful': 167,
      'not_helpful': 3,
      'views': 890,
    },
  ];

  final List<Map<String, dynamic>> _quickHelp = [
    {
      'title': 'Booking Guide',
      'subtitle': 'Step-by-step booking process',
      'icon': 'book_online',
      'color': Colors.blue,
      'action': 'booking_guide',
    },
    {
      'title': 'Payment Help',
      'subtitle': 'Payment methods and issues',
      'icon': 'payment',
      'color': Colors.green,
      'action': 'payment_help',
    },
    {
      'title': 'Contact Support',
      'subtitle': 'Get human assistance',
      'icon': 'support_agent',
      'color': Colors.orange,
      'action': 'contact_support',
    },
    {
      'title': 'Video Tutorials',
      'subtitle': 'Watch how-to videos',
      'icon': 'play_circle',
      'color': Colors.purple,
      'action': 'video_tutorials',
    },
  ];

  Set<int> _expandedItems = {};

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _contentAnimationController = AnimationController(
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

    _contentAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _contentAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _headerAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _contentAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _contentAnimationController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredFaqs {
    var filtered = _faqItems;

    // Filter by category
    if (_selectedCategory != 'All') {
      filtered = filtered.where((faq) => faq['category'] == _selectedCategory).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((faq) {
        final question = faq['question'].toString().toLowerCase();
        final answer = faq['answer'].toString().toLowerCase();
        final tags = (faq['tags'] as List<String>).join(' ').toLowerCase();
        final query = _searchQuery.toLowerCase();
        
        return question.contains(query) || answer.contains(query) || tags.contains(query);
      }).toList();
    }

    return filtered;
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
              _buildSearchSection(),
              _buildQuickHelpSection(),
              _buildCategoriesSection(),
              _buildFaqSection(),
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
                                  onPressed: _showHelpStats,
                                  icon: CustomIconWidget(
                                    iconName: 'analytics',
                                    color: Colors.white,
                                    size: 6.w,
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
                                        iconName: 'help',
                                        color: const Color(0xFFC8E53F),
                                        size: 4.w,
                                      ),
                                      SizedBox(width: 1.w),
                                      Text(
                                        'Help & FAQ',
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
                                  'Get Answers\\nInstantly',
                                  style: AppTheme.lightTheme.textTheme.headlineLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    height: 1.1,
                                  ),
                                ),
                                SizedBox(height: 1.h),
                                Text(
                                  'Find solutions to common questions and get help',
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

  Widget _buildSearchSection() {
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        child: AnimatedBuilder(
          animation: _contentAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, 30 * (1 - _contentAnimation.value)),
              child: Opacity(
                opacity: _contentAnimation.value,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(3.w),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'search',
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        size: 5.w,
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Search help articles...',
                            border: InputBorder.none,
                            hintStyle: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                      if (_searchQuery.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                          child: CustomIconWidget(
                            iconName: 'close',
                            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                            size: 5.w,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildQuickHelpSection() {
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Help',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppTheme.lightTheme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 2.h),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.1,
                crossAxisSpacing: 3.w,
                mainAxisSpacing: 3.w,
              ),
              itemCount: _quickHelp.length,
              itemBuilder: (context, index) {
                final item = _quickHelp[index];
                return _buildQuickHelpCard(item);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickHelpCard(Map<String, dynamic> item) {
    final color = item['color'] as Color;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          _handleQuickHelpTap(item['action']);
        },
        borderRadius: BorderRadius.circular(3.w),
        child: Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(3.w),
            border: Border.all(
              color: color.withValues(alpha: 0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 15.w,
                height: 15.w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color.withValues(alpha: 0.1),
                      color.withValues(alpha: 0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(7.5.w),
                ),
                child: Center(
                  child: CustomIconWidget(
                    iconName: item['icon'],
                    color: color,
                    size: 7.w,
                  ),
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                item['title'],
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 0.5.h),
              Text(
                item['subtitle'],
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesSection() {
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Categories',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
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
                          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
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
                            boxShadow: [
                              BoxShadow(
                                color: isSelected
                                    ? AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.3)
                                    : Colors.black.withValues(alpha: 0.05),
                                blurRadius: isSelected ? 8 : 4,
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

  Widget _buildFaqSection() {
    final filteredFaqs = _filteredFaqs;
    
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index == 0) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 2.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Frequently Asked Questions',
                        style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.lightTheme.colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        '${filteredFaqs.length} articles',
                        style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                ],
              );
            }
            
            final faqIndex = index - 1;
            if (faqIndex >= filteredFaqs.length) {
              return SizedBox(height: 10.h);
            }
            
            final faq = filteredFaqs[faqIndex];
            return _buildFaqItem(faq, faqIndex);
          },
          childCount: filteredFaqs.length + 2,
        ),
      ),
    );
  }

  Widget _buildFaqItem(Map<String, dynamic> faq, int index) {
    final isExpanded = _expandedItems.contains(index);
    final category = faq['category'] as String;
    final categoryColor = _getCategoryColor(category);
    
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            setState(() {
              if (isExpanded) {
                _expandedItems.remove(index);
              } else {
                _expandedItems.add(index);
              }
            });
          },
          borderRadius: BorderRadius.circular(3.w),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(3.w),
              border: Border.all(
                color: isExpanded 
                    ? categoryColor.withValues(alpha: 0.3)
                    : AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.1),
                width: isExpanded ? 1.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: isExpanded
                      ? categoryColor.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.05),
                  blurRadius: isExpanded ? 12 : 4,
                  offset: Offset(0, isExpanded ? 6 : 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                      decoration: BoxDecoration(
                        color: categoryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(1.w),
                      ),
                      child: Text(
                        category.toUpperCase(),
                        style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: categoryColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 9,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'visibility',
                          color: AppTheme.lightTheme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                          size: 3.w,
                        ),
                        SizedBox(width: 0.5.w),
                        Text(
                          '${faq['views']}',
                          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 2.w),
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: CustomIconWidget(
                        iconName: 'keyboard_arrow_down',
                        color: categoryColor,
                        size: 6.w,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Text(
                  faq['question'],
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                  ),
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: isExpanded
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 2.h),
                            Container(
                              padding: EdgeInsets.all(3.w),
                              decoration: BoxDecoration(
                                color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.03),
                                borderRadius: BorderRadius.circular(2.w),
                                border: Border.all(
                                  color: categoryColor.withValues(alpha: 0.1),
                                ),
                              ),
                              child: Text(
                                faq['answer'],
                                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                                  height: 1.5,
                                ),
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Row(
                              children: [
                                Text(
                                  'Was this helpful?',
                                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const Spacer(),
                                _buildHelpfulButton(true, faq['helpful'], index),
                                SizedBox(width: 2.w),
                                _buildHelpfulButton(false, faq['not_helpful'], index),
                              ],
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHelpfulButton(bool isHelpful, int count, int index) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          _handleHelpfulTap(isHelpful, index);
        },
        borderRadius: BorderRadius.circular(2.w),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
          decoration: BoxDecoration(
            color: isHelpful 
                ? Colors.green.withValues(alpha: 0.1)
                : Colors.red.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(2.w),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomIconWidget(
                iconName: isHelpful ? 'thumb_up' : 'thumb_down',
                color: isHelpful ? Colors.green : Colors.red,
                size: 4.w,
              ),
              SizedBox(width: 1.w),
              Text(
                count.toString(),
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: isHelpful ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'booking':
        return Colors.blue;
      case 'payment':
        return Colors.green;
      case 'cancellation':
        return Colors.orange;
      case 'account':
        return Colors.purple;
      case 'technical':
        return Colors.red;
      case 'general':
        return Colors.grey;
      default:
        return AppTheme.lightTheme.colorScheme.primary;
    }
  }

  void _handleQuickHelpTap(String action) {
    switch (action) {
      case 'booking_guide':
        _showBookingGuide();
        break;
      case 'payment_help':
        _showPaymentHelp();
        break;
      case 'contact_support':
        _contactSupport();
        break;
      case 'video_tutorials':
        _showVideoTutorials();
        break;
    }
  }

  void _handleHelpfulTap(bool isHelpful, int index) {
    // Handle helpful/not helpful feedback
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Thank You!'),
        content: Text('Your feedback helps us improve our help articles.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showBookingGuide() {
    // Implementation for booking guide
  }

  void _showPaymentHelp() {
    // Implementation for payment help
  }

  void _contactSupport() {
    Navigator.pushNamed(context, '/support');
  }

  void _showVideoTutorials() {
    // Implementation for video tutorials
  }

  void _showHelpStats() {
    // Implementation for help statistics
  }
}