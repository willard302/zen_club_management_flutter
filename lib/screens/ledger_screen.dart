import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/theme/app_theme.dart';
import 'package:app/providers/ledger_provider.dart';
import 'package:intl/intl.dart';

class LedgerScreen extends StatelessWidget {
  const LedgerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F9FF),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildBalanceCard(context),
                    _buildSummaryCards(context),
                    _buildActivityList(context),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: AppTheme.skyBlue,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 40), // Placeholder to maintain centered title
          const Text(
            '社費帳本',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 18,
              letterSpacing: -0.5,
            ),
          ),
          _buildHeaderIcon(Icons.calendar_today),
        ],
      ),
    );
  }

  Widget _buildHeaderIcon(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        color: Colors.transparent,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context) {
    return Consumer<LedgerProvider>(
      builder: (context, ledger, child) {
        final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
        
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Container(
             padding: const EdgeInsets.all(32),
             decoration: BoxDecoration(
               gradient: const LinearGradient(
                 begin: Alignment.topLeft,
                 end: Alignment.bottomRight,
                 colors: [AppTheme.zenBlue, AppTheme.softSky],
               ),
               borderRadius: BorderRadius.circular(32),
               boxShadow: [
                 BoxShadow(
                   color: AppTheme.skyLight.withValues(alpha: 0.5),
                   blurRadius: 20,
                   offset: const Offset(0, 10),
                 )
               ]
             ),
             child: Column(
               children: [
                 const Text(
                    '總可用餘額',
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                 ),
                 const SizedBox(height: 8),
                 Text(
                   currencyFormat.format(ledger.availableBalance),
                   style: const TextStyle(
                     color: Colors.white,
                     fontSize: 40,
                     fontWeight: FontWeight.bold,
                     letterSpacing: -1,
                   ),
                 ),
                 const SizedBox(height: 32),
                 Row(
                   children: [
                     Expanded(
                       child: _buildActionButton(
                         icon: Icons.add_circle,
                         label: '新增紀錄',
                         isPrimary: true,
                         onTap: () {
                           _showAddEntrySheet(context);
                         }
                       ),
                     ),
                     const SizedBox(width: 16),
                     Expanded(
                       child: _buildActionButton(
                         icon: Icons.ios_share,
                         label: '匯出',
                         isPrimary: false,
                         onTap: () {}
                       ),
                     ),
                   ],
                 )
               ],
             ),
          ),
        );
      }
    );
  }

  Widget _buildActionButton({required IconData icon, required String label, required bool isPrimary, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isPrimary ? Colors.white.withValues(alpha: 0.2) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isPrimary ? Border.all(color: Colors.white.withValues(alpha: 0.3)) : null,
          boxShadow: isPrimary ? null : [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
            )
          ]
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isPrimary ? Colors.white : AppTheme.skyBlue, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isPrimary ? Colors.white : AppTheme.skyBlue,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context) {
    return Consumer<LedgerProvider>(
      builder: (context, ledger, child) {
        final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  title: '收入',
                  amount: '+${currencyFormat.format(ledger.totalIncome)}',
                  icon: Icons.arrow_downward,
                  iconBgColor: AppTheme.skyLight.withValues(alpha: 0.5),
                  iconColor: AppTheme.skyBlue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  title: '支出',
                  amount: '-${currencyFormat.format(ledger.totalExpense)}',
                  icon: Icons.arrow_upward,
                  iconBgColor: Colors.grey.withValues(alpha: 0.1),
                  iconColor: Colors.grey,
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String amount,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white),
        boxShadow: [
          BoxShadow(
            color: AppTheme.skyBlue.withValues(alpha: 0.05),
            blurRadius: 20,
          )
        ]
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                 title,
                 style: const TextStyle(
                   color: Colors.grey,
                   fontSize: 10,
                   fontWeight: FontWeight.bold,
                   letterSpacing: 1,
                 ),
              ),
              Text(
                amount,
                style: const TextStyle(
                  color: AppTheme.textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildActivityList(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '最近活動',
                style: TextStyle(
                  color: AppTheme.textDark,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '查看全部',
                style: TextStyle(
                  color: AppTheme.skyBlue,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              )
            ],
          ),
          const SizedBox(height: 16),
          Consumer<LedgerProvider>(
             builder: (context, ledger, child) {
                return ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: ledger.transactions.length,
                  separatorBuilder: (context, index) => Divider(color: Colors.grey.shade100, height: 1),
                  itemBuilder: (context, index) {
                    final tx = ledger.transactions[index];
                    return _buildTransactionItem(tx);
                  },
                );
             }
          )
        ],
      ),
    );
  }

  Widget _buildTransactionItem(Transaction tx) {
    final isIncome = tx.type == TransactionType.income;
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                   color: isIncome ? AppTheme.skyLight.withValues(alpha: 0.5) : Colors.grey.shade50,
                   shape: BoxShape.circle,
                ),
                child: Icon(tx.icon, color: isIncome ? AppTheme.skyBlue : Colors.grey),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tx.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textDark,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    tx.category,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 12,
                    ),
                  )
                ],
              )
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isIncome ? '+' : '-'}${currencyFormat.format(tx.amount)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isIncome ? AppTheme.skyBlue : Colors.grey.shade700,
                  fontSize: 16,
                ),
              ),
              Text(
                tx.status.toUpperCase(),
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  void _showAddEntrySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
           padding: EdgeInsets.only(
             bottom: MediaQuery.of(context).viewInsets.bottom,
             left: 24, right: 24, top: 24
           ),
           child: Column(
             mainAxisSize: MainAxisSize.min,
             children: [
               const Text("新增交易", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
               const SizedBox(height: 24),
               const TextField(decoration: InputDecoration(labelText: '標題', border: OutlineInputBorder())),
               const SizedBox(height: 16),
               const TextField(decoration: InputDecoration(labelText: '金額', border: OutlineInputBorder()), keyboardType: TextInputType.number),
               const SizedBox(height: 24),
               ElevatedButton(
                 onPressed: () => Navigator.pop(context), 
                 child: const Text('儲存')
               ),
               const SizedBox(height: 32),
             ],
           ),
        );
      }
    );
  }
}
