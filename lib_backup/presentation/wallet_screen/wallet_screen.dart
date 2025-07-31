import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_drawer.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  double _balance = 25000.0;
  
  final List<Map<String, dynamic>> _transactions = [
    {
      'id': 'TXN001',
      'type': 'payment',
      'amount': -3500.0,
      'description': 'Bus ticket - Douala to Yaoundé',
      'date': DateTime.now().subtract(const Duration(hours: 2)),
      'status': 'completed',
    },
    {
      'id': 'TXN002',
      'type': 'topup',
      'amount': 10000.0,
      'description': 'Wallet top-up via Mobile Money',
      'date': DateTime.now().subtract(const Duration(days: 1)),
      'status': 'completed',
    },
    {
      'id': 'TXN003',
      'type': 'refund',
      'amount': 4500.0,
      'description': 'Refund - Cancelled booking',
      'date': DateTime.now().subtract(const Duration(days: 2)),
      'status': 'completed',
    },
    {
      'id': 'TXN004',
      'type': 'payment',
      'amount': -2500.0,
      'description': 'Bus ticket - Kumba to Limbe',
      'date': DateTime.now().subtract(const Duration(days: 3)),
      'status': 'completed',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      drawer: const CustomDrawer(),
      appBar: AppBar(
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        elevation: 0,
        title: Text(
          'My Wallet',
          style: AppTheme.lightTheme.appBarTheme.titleTextStyle,
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: AppTheme.lightTheme.colorScheme.onPrimary,
            size: 24,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _showTransactionHistory,
            icon: CustomIconWidget(
              iconName: 'history',
              color: AppTheme.lightTheme.colorScheme.onPrimary,
              size: 24,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 2.h),
            _buildWalletCard(),
            SizedBox(height: 2.h),
            _buildQuickActions(),
            SizedBox(height: 2.h),
            _buildRecentTransactions(),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.lightTheme.colorScheme.primary,
            AppTheme.lightTheme.colorScheme.primaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
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
                'Available Balance',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
              CustomIconWidget(
                iconName: 'account_balance_wallet',
                color: AppTheme.lightTheme.colorScheme.secondary,
                size: 24,
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            'XFA ${_balance.toStringAsFixed(0)}',
            style: AppTheme.lightTheme.textTheme.headlineLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.secondary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomIconWidget(
                      iconName: 'verified',
                      color: AppTheme.lightTheme.colorScheme.secondary,
                      size: 16,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      'Verified Account',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  'Add Money',
                  'add_circle',
                  () => _showTopUpDialog(),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildActionButton(
                  'Send Money',
                  'send',
                  () => _showSendMoneyDialog(),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildActionButton(
                  'Withdraw',
                  'account_balance',
                  () => _showWithdrawDialog(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String title, String icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 3.h),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 12.w,
              height: 12.w,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6.w),
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: icon,
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 6.w,
                ),
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              title,
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTransactions() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Transactions',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: _showTransactionHistory,
                child: Text(
                  'View All',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _transactions.take(4).length,
              separatorBuilder: (context, index) => Divider(
                color: AppTheme.lightTheme.dividerColor,
                height: 1,
              ),
              itemBuilder: (context, index) {
                final transaction = _transactions[index];
                return _buildTransactionItem(transaction);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> transaction) {
    final isPositive = transaction['amount'] > 0;
    final icon = transaction['type'] == 'payment' 
        ? 'payment' 
        : transaction['type'] == 'topup' 
          ? 'add_circle' 
          : 'account_balance';
    
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      leading: Container(
        width: 12.w,
        height: 12.w,
        decoration: BoxDecoration(
          color: isPositive 
              ? Colors.green.withValues(alpha: 0.1)
              : AppTheme.lightTheme.colorScheme.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6.w),
        ),
        child: Center(
          child: CustomIconWidget(
            iconName: icon,
            color: isPositive ? Colors.green : AppTheme.lightTheme.colorScheme.error,
            size: 5.w,
          ),
        ),
      ),
      title: Text(
        transaction['description'],
        style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        _formatDate(transaction['date']),
        style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
          color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: Text(
        '${isPositive ? '+' : ''}XFA ${transaction['amount'].abs().toStringAsFixed(0)}',
        style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
          color: isPositive ? Colors.green : AppTheme.lightTheme.colorScheme.error,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else {
      return '${difference.inDays} days ago';
    }
  }

  void _showTopUpDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 60.h,
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            children: [
              Container(
                width: 12.w,
                height: 0.5.h,
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                'Add Money to Wallet',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 3.h),
              // Top-up amount options and form would go here
              Text(
                'Top-up functionality coming soon...',
                style: AppTheme.lightTheme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSendMoneyDialog() {
    // Implementation for send money
  }

  void _showWithdrawDialog() {
    // Implementation for withdraw
  }

  void _showTransactionHistory() {
    // Implementation for transaction history
  }
}