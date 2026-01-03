import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart'; // <--- Added Import
import '../../../services/habit_provider.dart';
import '../../../models/habit_model.dart';

class ProgressCalendar extends StatefulWidget {
  final Habit selectedHabit;
  final bool isDark;

  const ProgressCalendar({
    super.key,
    required this.selectedHabit,
    required this.isDark,
  });

  @override
  State<ProgressCalendar> createState() => _ProgressCalendarState();
}

class _ProgressCalendarState extends State<ProgressCalendar> {
  DateTime _focusedDay = DateTime.now();
  bool _showAllHabits = false;

  @override
  Widget build(BuildContext context) {
    // Access provider to get combined history
    final habitProvider = Provider.of<HabitProvider>(context, listen: false);

    // Determine which data to show
    final Map<String, dynamic> calendarData = _showAllHabits
        ? habitProvider.combinedHistory
        : widget.selectedHabit.history;

    return Column(
      children: [
        // --- HEADER WITH SWITCH ---
        _buildHeader(context),
        const SizedBox(height: 16),

        // --- CALENDAR CARD ---
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: widget.isDark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: widget.isDark ? Colors.white10 : Colors.black12,
                ),
                boxShadow: widget.isDark
                    ? []
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: Column(
                children: [
                  TableCalendar(
                    firstDay: DateTime.utc(2024, 1, 1),
                    lastDay: DateTime.now().add(const Duration(days: 365)),
                    focusedDay: _focusedDay,
                    onPageChanged: (focusedDay) =>
                        setState(() => _focusedDay = focusedDay),
                    onDaySelected: _showAllHabits ? null : (sel, foc) {},
                    headerStyle: HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: TextStyle(
                        color: widget.isDark ? Colors.white : Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      leftChevronIcon: Icon(
                        PhosphorIcons.caretLeft(),
                        color: widget.isDark ? Colors.white54 : Colors.black54,
                      ),
                      rightChevronIcon: Icon(
                        PhosphorIcons.caretRight(),
                        color: widget.isDark ? Colors.white54 : Colors.black54,
                      ),
                    ),
                    calendarStyle: CalendarStyle(
                      // --- FIX: Explicitly apply Inter font here ---
                      defaultTextStyle: GoogleFonts.inter(
                        color: widget.isDark ? Colors.white70 : Colors.black87,
                      ),
                      weekendTextStyle: GoogleFonts.inter(
                        color: Colors.redAccent,
                      ),
                      outsideDaysVisible: false,
                      todayDecoration: BoxDecoration(
                        color: Colors.blueAccent.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      todayTextStyle: GoogleFonts.inter(
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    calendarBuilders: CalendarBuilders(
                      prioritizedBuilder: (context, day, focusedDay) {
                        final String dateKey =
                            "${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}";
                        if (calendarData.containsKey(dateKey)) {
                          final status = calendarData[dateKey];
                          return _buildDayMarker(
                            day,
                            status == 'clean'
                                ? const Color(0xFF2DD4BF)
                                : Colors.red,
                          );
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildLegend(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                PhosphorIcons.calendarBlank(),
                size: 24,
                color: widget.isDark ? Colors.blueAccent : Colors.blueGrey,
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  "Progress Calendar",
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: widget.isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            Text(
              "All Habits",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: widget.isDark ? Colors.white54 : Colors.black54,
              ),
            ),
            const SizedBox(width: 8),
            Switch(
              value: _showAllHabits,
              activeColor: Colors.blueAccent,
              onChanged: (val) {
                setState(() {
                  _showAllHabits = val;
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDayMarker(DateTime day, Color color) {
    return Container(
      margin: const EdgeInsets.all(6),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
      ),
      child: Text(
        '${day.day}',
        style: GoogleFonts.inter(
          // Apply Inter to marker text as well
          color: widget.isDark ? Colors.white : Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _legendItem(const Color(0xFF2DD4BF), "Clean"),
        const SizedBox(width: 20),
        _legendItem(Colors.red, "Relapse"),
      ],
    );
  }

  Widget _legendItem(Color col, String label) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: col, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
