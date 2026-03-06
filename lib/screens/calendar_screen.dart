import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/theme/app_theme.dart';
import 'package:app/providers/calendar_provider.dart';
import 'package:intl/intl.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
            ),
            child: Column(
              children: [
                _buildHeaderAndCalendar(context),
                _buildEventsList(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderAndCalendar(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _buildSkyGradientHeader(context),
        Positioned(
           top: 140,
           left: 0,
           right: 0,
           child: _buildCalendarCard(context)
        )
      ],
    );
  }

  Widget _buildSkyGradientHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 16, bottom: 90, left: 24, right: 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppTheme.skyBlue, Color(0xFF38BDF8)],
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 40), // Placeholder to maintain centered title
              const Text(
                'Sky Club Calendar',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.5,
                ),
              ),
              _buildIconButton(Icons.search),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SELECTED MONTH',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const Text(
                    'November 2023',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ],
              ),
              Row(
                children: [
                  _buildSmallIconButton(Icons.chevron_left),
                  const SizedBox(width: 8),
                  _buildSmallIconButton(Icons.chevron_right),
                ],
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }

  Widget _buildSmallIconButton(IconData icon) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: 16),
    );
  }

  Widget _buildCalendarCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
          boxShadow: [
            BoxShadow(
              color: AppTheme.skyBlue.withValues(alpha: 0.1),
              blurRadius: 25,
              offset: const Offset(0, 10),
            )
          ]
        ),
        child: Column(
          children: [
            _buildDaysOfWeekRow(),
            const SizedBox(height: 8),
            _buildCalendarGrid(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDaysOfWeekRow() {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: days.map((day) => 
        Expanded(
          child: Text(
            day.toUpperCase(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppTheme.skyBlue,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        )
      ).toList(),
    );
  }

  Widget _buildCalendarGrid(BuildContext context) {
    return Consumer<CalendarProvider>(
      builder: (context, calProvider, child) {
        List<Widget> rows = [];
        List<int?> daysInGrid = [
          30, 31, 1, 2, 3, 4, 5,
          6, 7, 8, 9, 10, 11, 12,
          13, 14, 15, 16, 17, 18, 19
        ];
        
        List<Widget> currentRow = [];
        for (int i = 0; i < daysInGrid.length; i++) {
          final isPrevMonth = i < 2; 
          final dayNum = daysInGrid[i]!;
          
          DateTime cellDate;
          if (isPrevMonth) {
             cellDate = DateTime(2023, 10, dayNum);
          } else {
             cellDate = DateTime(2023, 11, dayNum);
          }

          final isSelected = calProvider.isSameDay(cellDate, calProvider.selectedDate);
          final hasEvent = calProvider.hasEvents(cellDate);

          currentRow.add(
            Expanded(
              child: GestureDetector(
                onTap: () => calProvider.selectDate(cellDate),
                child: Container(
                  height: 40,
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.skyBlue : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: isSelected ? [
                      BoxShadow(color: AppTheme.skyLight.withValues(alpha: 0.5), blurRadius: 4)
                    ] : null,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        dayNum.toString(),
                        style: TextStyle(
                          color: isSelected ? Colors.white 
                               : (isPrevMonth ? Colors.grey.shade400 : AppTheme.textDark),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (hasEvent && !isSelected)
                        Positioned(
                          bottom: 4,
                          child: Container(
                            width: 4, height: 4,
                            decoration: const BoxDecoration(
                              color: AppTheme.skyBlue,
                              shape: BoxShape.circle,
                            ),
                          ),
                        )
                    ],
                  ),
                ),
              ),
            )
          );

          if (currentRow.length == 7) {
            rows.add(Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: currentRow));
            currentRow = [];
          }
        }
        
        return Column(children: rows);
      }
    );
  }

  Widget _buildEventsList(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 160),
      color: Colors.white,
      padding: const EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 100),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Events Today',
                style: TextStyle(
                  color: AppTheme.textDark,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'ADD EVENT',
                style: TextStyle(
                  color: AppTheme.skyBlue,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              )
            ],
          ),
          const SizedBox(height: 16),
          Consumer<CalendarProvider>(
            builder: (context, calProvider, child) {
               final events = calProvider.getEventsForDate(calProvider.selectedDate);
               
               if (events.isEmpty) {
                 return const Center(child: Text("No events today."));
               }

               return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    return _buildEventItem(events[index]);
                  },
               );
            }
          )
        ],
      ),
    );
  }

  Widget _buildEventItem(ClubEvent event) {
    final formatTime = DateFormat('hh:mm');
    final formatAmPm = DateFormat('a');

    return Container(
      padding: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.skyLight.withValues(alpha: 0.5))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50,
            padding: const EdgeInsets.only(top: 4),
            child: Column(
              children: [
                Text(
                  formatTime.format(event.dateTime),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppTheme.textDark,
                  ),
                ),
                Text(
                  formatAmPm.format(event.dateTime),
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 10,
                    color: Colors.grey.shade400,
                  ),
                )
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.skyLight.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.skyLight.withValues(alpha: 0.8)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(event.icon, color: AppTheme.skyBlue, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        event.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: AppTheme.textDark,
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${event.location} • ${event.participants == 0 ? "All" : event.participants} Participants',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  if (event.participants > 0) ...[
                    const SizedBox(height: 12),
                    _buildParticipantsAvatars()
                  ]
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildParticipantsAvatars() {
    return Row(
      children: [
         _buildAvatar('JD', AppTheme.skyLight),
         Transform.translate(offset: const Offset(-8, 0), child: _buildAvatar('AS', AppTheme.softSky)),
         Transform.translate(offset: const Offset(-16, 0), child: _buildAvatar('MK', AppTheme.zenBlue)),
         Transform.translate(offset: const Offset(-24, 0), child: _buildAvatar('+42', Colors.grey.shade100, textColor: Colors.grey.shade500)),
      ],
    );
  }

  Widget _buildAvatar(String text, Color bg, {Color? textColor}) {
    return Container(
      width: 24, height: 24,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.bold,
            color: textColor ?? Colors.white,
          ),
        ),
      ),
    );
  }
}
