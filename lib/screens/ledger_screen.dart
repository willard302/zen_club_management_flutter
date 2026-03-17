import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/theme/app_theme.dart';
import 'package:app/providers/ledger_provider.dart';
import 'package:app/screens/club_ledger_edit_screen.dart';
import 'package:app/models/transaction.dart';
import 'package:app/constants/app_routes.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class LedgerScreen extends StatefulWidget {
  const LedgerScreen({super.key});

  @override
  State<LedgerScreen> createState() => _LedgerScreenState();
}

class _LedgerScreenState extends State<LedgerScreen> {
  bool _showAll = false;
  bool _showCalendar = false;
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedDay = DateTime.now();

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
                    if (_showCalendar) 
                      _buildCalendar(context)
                    else ...[
                      _buildBalanceCard(context),
                      _buildSummaryCards(context),
                    ],
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
          const SizedBox(width: 80), // Placeholder to maintain centered title
          const Text(
            '社費帳本',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 18,
              letterSpacing: -0.5,
            ),
          ),
          _buildViewToggle(),
        ],
      ),
    );
  }

  Widget _buildViewToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleIconButton(Icons.bar_chart, !_showCalendar),
          _buildToggleIconButton(Icons.calendar_today, _showCalendar),
        ],
      ),
    );
  }

  Widget _buildToggleIconButton(IconData icon, bool isActive) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showCalendar = icon == Icons.calendar_today;
        });
      },
      child: Container(
        width: 40,
        height: 48,
        decoration: BoxDecoration(
          color: isActive ? Colors.white.withValues(alpha: 0.3) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }

  Widget _buildCalendar(BuildContext context) {
    return Container(
      color: Colors.white,
      child: TableCalendar(
        firstDay: DateTime.utc(2000, 1, 1),
        lastDay: DateTime.utc(2100, 12, 31),
        focusedDay: _focusedDay,
        calendarFormat: CalendarFormat.month,
        selectedDayPredicate: (day) {
          return isSameDay(_selectedDate, day);
        },
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDate = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
        ),
        calendarStyle: CalendarStyle(
          selectedDecoration: const BoxDecoration(
            color: AppTheme.skyBlue,
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: AppTheme.skyBlue.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context) {
    return Consumer<LedgerProvider>(
      builder: (context, ledger, child) {
        final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
        
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
                           _navigateToEditScreen(null);
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
              if (!_showAll)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _showAll = true;
                    });
                  },
                  child: Text(
                    '查看全部',
                    style: TextStyle(
                      color: AppTheme.skyBlue,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
            ],
          ),
          const SizedBox(height: 16),
          Consumer<LedgerProvider>(
             builder: (context, ledger, child) {
                // Determine current month range
                final now = DateTime.now();
                
                // Filter current month or specific date and sort descending (newest first)
                var displayList = ledger.transactions.where((tx) {
                  if (_showCalendar) {
                    return isSameDay(tx.date, _selectedDate);
                  } else {
                    return tx.date.year == now.year && tx.date.month == now.month;
                  }
                }).toList();
                  
                displayList.sort((a, b) => b.date.compareTo(a.date));

                // Restrict to max 10 if not _showAll
                if (!_showAll && displayList.length > 10) {
                  displayList = displayList.sublist(0, 10);
                }

                if (displayList.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(
                      child: Text('本月尚無紀錄', style: TextStyle(color: Colors.grey)),
                    ),
                  );
                }

                return ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: displayList.length,
                  separatorBuilder: (context, index) => Divider(color: Colors.grey.shade100, height: 1),
                  itemBuilder: (context, index) {
                    final tx = displayList[index];
                    return GestureDetector(
                      onTap: () {
                        _navigateToEditScreen(tx);
                      },
                      behavior: HitTestBehavior.opaque,
                      child: _buildTransactionItem(tx),
                    );
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
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
    
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
                child: Icon(tx.getIcon(), color: isIncome ? AppTheme.skyBlue : Colors.grey),
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
                  const SizedBox(height: 4),
                  Text(
                    tx.category,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    tx.category,
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 11,
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
              const SizedBox(height: 4),
              Text(
                _formatDate(tx.date),
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    tx.status.toUpperCase(),
                    style: TextStyle(
                      color: AppTheme.skyBlue.withValues(alpha: 0.8),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  if (tx.isApproved) ...[
                    const SizedBox(width: 4),
                    Icon(
                      Icons.verified,
                      size: 12,
                      color: AppTheme.skyBlue.withValues(alpha: 0.8),
                    ),
                  ],
                ],
              )
            ],
          )
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('yyyy/MM/dd').format(date);
  }

  /// 導航到編輯屏幕（用於新增或編輯事務）
  void _navigateToEditScreen(Transaction? transaction) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClubLedgerEditScreen(transaction: transaction),
      ),
    );
  }
}
