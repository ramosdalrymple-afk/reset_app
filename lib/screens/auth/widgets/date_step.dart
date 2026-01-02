import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DateStep extends StatefulWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateChanged;

  const DateStep({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
  });

  @override
  State<DateStep> createState() => _DateStepState();
}

class _DateStepState extends State<DateStep> {
  final TextEditingController _monthController = TextEditingController();
  final TextEditingController _dayController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();

  final FocusNode _monthFocus = FocusNode();
  final FocusNode _dayFocus = FocusNode();
  final FocusNode _yearFocus = FocusNode();

  @override
  void dispose() {
    _monthController.dispose();
    _dayController.dispose();
    _yearController.dispose();
    _monthFocus.dispose();
    _dayFocus.dispose();
    _yearFocus.dispose();
    super.dispose();
  }

  void _validateAndNotify() {
    if (_monthController.text.length == 2 &&
        _dayController.text.length == 2 &&
        _yearController.text.length == 4) {
      try {
        final int m = int.parse(_monthController.text);
        final int d = int.parse(_dayController.text);
        final int y = int.parse(_yearController.text);

        final DateTime date = DateTime(y, m, d);
        if (date.isBefore(DateTime.now().add(const Duration(minutes: 1)))) {
          widget.onDateChanged(date);
        }
      } catch (e) {
        // Invalid date logic
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "When was your last day?",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "Month / Day / Year",
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 32),

        // Wrapped in a constrained width to prevent overflow
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300),
          child: Row(
            children: [
              _buildSmallInput(
                controller: _monthController,
                focusNode: _monthFocus,
                nextFocus: _dayFocus,
                hint: "MM",
                maxLength: 2,
              ),
              _buildSeparator(),
              _buildSmallInput(
                controller: _dayController,
                focusNode: _dayFocus,
                nextFocus: _yearFocus,
                prevFocus: _monthFocus, // Jump back on backspace
                hint: "DD",
                maxLength: 2,
              ),
              _buildSeparator(),
              _buildSmallInput(
                controller: _yearController,
                focusNode: _yearFocus,
                nextFocus: null,
                prevFocus: _dayFocus, // Jump back on backspace
                hint: "YYYY",
                maxLength: 4,
                isYear: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSmallInput({
    required TextEditingController controller,
    required FocusNode focusNode,
    FocusNode? nextFocus,
    FocusNode? prevFocus,
    required String hint,
    required int maxLength,
    bool isYear = false,
  }) {
    return Expanded(
      flex: isYear ? 3 : 2, // Year gets slightly more space
      child: RawKeyboardListener(
        focusNode: FocusNode(), // Temporary node to catch keys
        onKey: (event) {
          if (event is RawKeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.backspace &&
              controller.text.isEmpty &&
              prevFocus != null) {
            FocusScope.of(context).requestFocus(prevFocus);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white24, width: 1.5),
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: maxLength,
            cursorColor: Colors.white,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.white24, fontSize: 16),
              counterText: "",
              border: InputBorder.none,
              isDense: true,
            ),
            onChanged: (value) {
              if (value.length == maxLength && nextFocus != null) {
                FocusScope.of(context).requestFocus(nextFocus);
              }
              _validateAndNotify();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSeparator() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Text("/", style: TextStyle(color: Colors.white24, fontSize: 24)),
    );
  }
}
