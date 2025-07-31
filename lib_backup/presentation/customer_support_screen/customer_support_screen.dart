import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_drawer.dart';
import '../../widgets/floating_back_to_top_button.dart';

class CustomerSupportScreen extends StatefulWidget {
  const CustomerSupportScreen({super.key});

  @override
  State<CustomerSupportScreen> createState() => _CustomerSupportScreenState();
}

class _CustomerSupportScreenState extends State<CustomerSupportScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerAnimationController;
  late AnimationController _cardsAnimationController;
  late Animation<double> _headerAnimation;
  late Animation<double> _cardsAnimation;
  late ScrollController _scrollController;

  final TextEditingController _messageController = TextEditingController();
  String _selectedIssueType = 'General Inquiry';
  
  final List<String> _issueTypes = [
    'General Inquiry',
    'Booking Issues',
    'Payment Problems',
    'Refund Request',
    'Technical Support',
    'Lost Items',
    'Complaint',
    'Feedback',
  ];

  final List<Map<String, dynamic>> _supportOptions = [
    {
      'title': 'Live Chat',
      'subtitle': 'Chat with our support team',
      'description': 'Get instant help from our customer service representatives',
      'icon': 'chat',
      'color': Colors.blue,
      'available': true,
      'response_time': 'Instant',
      'status': 'Online',
    },
    {
      'title': 'Phone Support',
      'subtitle': 'Call our helpline',
      'description': 'Speak directly with our support team for urgent matters',
      'icon': 'phone',
      'color': Colors.green,
      'available': true,
      'response_time': 'Immediate',
      'phone': '+237 6XX XXX XXX',
    },
    {
      'title': 'Email Support',
      'subtitle': 'Send us an email',
      'description': 'Get detailed responses to your queries via email',
      'icon': 'email',
      'color': Colors.orange,
      'available': true,
      'response_time': '2-4 hours',
      'email': 'support@tease.cm',
    },
    {
      'title': 'WhatsApp',
      'subtitle': 'Message us on WhatsApp',
      'description': 'Quick support through your favorite messaging app',
      'icon': 'message',
      'color': Colors.green.shade600,
      'available': true,
      'response_time': '15 minutes',
      'whatsapp': '+237 6XX XXX XXX',
    },
  ];

  final List<Map<String, dynamic>> _recentTickets = [
    {
      'id': 'TCK001',
      'title': 'Refund Request for Cancelled Trip',
      'status': 'resolved',
      'priority': 'high',
      'date': DateTime.now().subtract(const Duration(days: 1)),
      'lastUpdate': 'Refund processed successfully',
    },
    {
      'id': 'TCK002',
      'title': 'Payment Failed During Booking',
      'status': 'in_progress',
      'priority': 'medium',
      'date': DateTime.now().subtract(const Duration(days: 2)),
      'lastUpdate': 'Payment team investigating the issue',
    },
    {
      'id': 'TCK003',
      'title': 'Seat Selection Not Working',
      'status': 'resolved',
      'priority': 'low',
      'date': DateTime.now().subtract(const Duration(days: 5)),
      'lastUpdate': 'Issue fixed in latest app update',
    },
  ];

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

    _cardsAnimationController = AnimationController(
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

    _cardsAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _cardsAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _headerAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _cardsAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _cardsAnimationController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
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
              _buildQuickStats(),
              _buildSupportOptions(),
              _buildQuickContactForm(),
              _buildRecentTickets(),
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
                                  onPressed: _showSupportStatusDialog,
                                  icon: Stack(
                                    children: [
                                      CustomIconWidget(
                                        iconName: 'support_agent',
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
                                            color: Colors.green,
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
                                        iconName: 'support_agent',
                                        color: const Color(0xFFC8E53F),
                                        size: 4.w,
                                      ),
                                      SizedBox(width: 1.w),
                                      Text(
                                        'Customer Support',
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
                                  'We\'re Here\nTo Help',
                                  style: AppTheme.lightTheme.textTheme.headlineLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    height: 1.1,
                                  ),
                                ),
                                SizedBox(height: 1.h),
                                Text(
                                  '24/7 support for all your travel needs and concerns',
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

  Widget _buildQuickStats() {
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        child: Row(
          children: [
            Expanded(child: _buildStatCard('Response Time', '< 15 min', 'schedule', Colors.blue)),
            SizedBox(width: 3.w),
            Expanded(child: _buildStatCard('Satisfaction', '98%', 'sentiment_satisfied', Colors.green)),
            SizedBox(width: 3.w),
            Expanded(child: _buildStatCard('Availability', '24/7', 'support', Colors.orange)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, String icon, Color color) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(3.w),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 10.w,
            height: 10.w,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(5.w),
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: icon,
                color: color,
                size: 5.w,
              ),
            ),
          ),
          SizedBox(height: 1.5.h),
          Text(
            value,
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
          Text(
            title,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSupportOptions() {
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contact Methods',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppTheme.lightTheme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 2.h),
            AnimatedBuilder(
              animation: _cardsAnimation,
              builder: (context, child) {
                return Column(
                  children: _supportOptions.asMap().entries.map((entry) {
                    final index = entry.key;
                    final option = entry.value;
                    return Transform.translate(
                      offset: Offset(0, 30 * (1 - _cardsAnimation.value)),
                      child: Opacity(
                        opacity: _cardsAnimation.value,
                        child: Container(
                          margin: EdgeInsets.only(bottom: 3.h),
                          child: _buildSupportOptionCard(option),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportOptionCard(Map<String, dynamic> option) {
    final color = option['color'] as Color;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _handleSupportOptionTap(option),
        borderRadius: BorderRadius.circular(4.w),
        child: Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4.w),
            border: Border.all(
              color: color.withValues(alpha: 0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.1),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: IntrinsicHeight(
            child: Row(
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
                    borderRadius: BorderRadius.circular(3.w),
                  ),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: option['icon'],
                      color: color,
                      size: 7.w,
                    ),
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              option['title'],
                              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppTheme.lightTheme.colorScheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (option['available'] == true)
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(1.w),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 2.w,
                                    height: 2.w,
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(1.w),
                                    ),
                                  ),
                                  SizedBox(width: 1.w),
                                  Text(
                                    'ONLINE',
                                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                                      color: Colors.green,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 9,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        option['subtitle'],
                        style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        option['description'],
                        style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 1.5.h),
                      Row(
                        children: [
                          Flexible(
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.8.h),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(1.5.w),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CustomIconWidget(
                                    iconName: 'schedule',
                                    color: color,
                                    size: 3.w,
                                  ),
                                  SizedBox(width: 1.w),
                                  Flexible(
                                    child: Text(
                                      option['response_time'],
                                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                                        color: color,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 10,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 2.w),
                          CustomIconWidget(
                            iconName: 'arrow_forward',
                            color: color,
                            size: 5.w,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickContactForm() {
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4.w),
          boxShadow: [
            BoxShadow(
              color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Contact',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppTheme.lightTheme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Send us a quick message and we\'ll get back to you soon',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 2.h),
            
            // Issue Type Dropdown
            Text(
              'Issue Type',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 0.5.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w),
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
                ),
                borderRadius: BorderRadius.circular(2.w),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedIssueType,
                  isExpanded: true,
                  items: _issueTypes.map((String type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedIssueType = newValue!;
                    });
                  },
                ),
              ),
            ),
            
            SizedBox(height: 2.h),
            
            // Message Field
            Text(
              'Message',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 0.5.h),
            TextField(
              controller: _messageController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Describe your issue or question...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(2.w),
                  borderSide: BorderSide(
                    color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(2.w),
                  borderSide: BorderSide(
                    color: AppTheme.lightTheme.colorScheme.primary,
                  ),
                ),
              ),
            ),
            
            SizedBox(height: 2.h),
            
            SizedBox(
              width: double.infinity,
              height: 5.h,
              child: ElevatedButton(
                onPressed: _submitQuickContact,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3.w),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomIconWidget(
                      iconName: 'send',
                      color: Colors.white,
                      size: 5.w,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Send Message',
                      style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
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

  Widget _buildRecentTickets() {
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Tickets',
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                  ),
                ),
                TextButton(
                  onPressed: _showAllTickets,
                  child: Text(
                    'View All',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            ..._recentTickets.map((ticket) => _buildTicketCard(ticket)).toList(),
            SizedBox(height: 10.h),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketCard(Map<String, dynamic> ticket) {
    final status = ticket['status'] as String;
    final statusColor = _getStatusColor(status);
    
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showTicketDetails(ticket),
          borderRadius: BorderRadius.circular(3.w),
          child: Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(3.w),
              border: Border.all(
                color: statusColor.withValues(alpha: 0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: statusColor.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 12.w,
                  height: 12.w,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6.w),
                  ),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: _getStatusIcon(status),
                      color: statusColor,
                      size: 6.w,
                    ),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              ticket['title'],
                              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(1.w),
                            ),
                            child: Text(
                              status.toUpperCase(),
                              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                                color: statusColor,
                                fontWeight: FontWeight.w700,
                                fontSize: 9,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        'ID: ${ticket['id']}',
                        style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        ticket['lastUpdate'],
                        style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                CustomIconWidget(
                  iconName: 'chevron_right',
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                  size: 5.w,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'resolved':
        return Colors.green;
      case 'in_progress':
        return Colors.orange;
      case 'pending':
        return Colors.blue;
      default:
        return AppTheme.lightTheme.colorScheme.primary;
    }
  }

  String _getStatusIcon(String status) {
    switch (status) {
      case 'resolved':
        return 'check_circle';
      case 'in_progress':
        return 'hourglass_empty';
      case 'pending':
        return 'pending';
      default:
        return 'help';
    }
  }

  void _handleSupportOptionTap(Map<String, dynamic> option) {
    HapticFeedback.lightImpact();
    final title = option['title'] as String;
    
    switch (title.toLowerCase()) {
      case 'live chat':
        _startLiveChat();
        break;
      case 'phone support':
        _makePhoneCall(option['phone']);
        break;
      case 'email support':
        _sendEmail(option['email']);
        break;
      case 'whatsapp':
        _openWhatsApp(option['whatsapp']);
        break;
    }
  }

  void _startLiveChat() {
    // Implementation for live chat
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Live Chat'),
        content: Text('Live chat functionality will be implemented soon.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _makePhoneCall(String? phone) {
    // Implementation for phone call
  }

  void _sendEmail(String? email) {
    // Implementation for email
  }

  void _openWhatsApp(String? whatsapp) {
    // Implementation for WhatsApp
  }

  void _submitQuickContact() {
    HapticFeedback.mediumImpact();
    // Implementation for submitting quick contact form
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Message Sent'),
        content: Text('Your message has been sent successfully. We\'ll get back to you soon.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _messageController.clear();
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSupportStatusDialog() {
    // Implementation for support status
  }

  void _showAllTickets() {
    // Implementation for showing all tickets
  }

  void _showTicketDetails(Map<String, dynamic> ticket) {
    // Implementation for showing ticket details
  }
}