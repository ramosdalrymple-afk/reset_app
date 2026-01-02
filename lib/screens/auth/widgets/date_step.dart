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

  void _validateAndNotify() {
    if (_monthController.text.length == 2 &&
        _dayController.text.length == 2 &&
        _yearController.text.length == 4) {
      try {
        final date = DateTime(
          int.parse(_yearController.text),
          int.parse(_monthController.text),
          int.parse(_dayController.text),
        );
        if (date.isBefore(DateTime.now().add(const Duration(minutes: 1)))) {
          widget.onDateChanged(date);
        }
      } catch (e) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.calendar_month_rounded,
          size: 60,
          color: Colors.white24,
        ),
        const SizedBox(height: 24),
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
          "MM / DD / YYYY",
          style: TextStyle(
            color: Colors.white38,
            fontSize: 14,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildInput(
              _monthController,
              _monthFocus,
              _dayFocus,
              null,
              "MM",
              2,
            ),
            _buildDiv(),
            _buildInput(
              _dayController,
              _dayFocus,
              _yearFocus,
              _monthFocus,
              "DD",
              2,
            ),
            _buildDiv(),
            _buildInput(
              _yearController,
              _yearFocus,
              null,
              _dayFocus,
              "YYYY",
              4,
              isYear: true,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDiv() => const Padding(
    padding: EdgeInsets.symmetric(horizontal: 10),
    child: Text(
      "/",
      style: TextStyle(
        color: Colors.white12,
        fontSize: 30,
        fontWeight: FontWeight.w200,
      ),
    ),
  );

  Widget _buildInput(
    TextEditingController controller,
    FocusNode node,
    FocusNode? next,
    FocusNode? prev,
    String hint,
    int len, {
    bool isYear = false,
  }) {
    return Container(
      width: isYear ? 90 : 70,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: TextField(
        controller: controller,
        focusNode: node,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: len,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white12),
          counterText: "",
          border: InputBorder.none,
          isDense: true,
        ),
        onChanged: (v) {
          if (v.length == len && next != null)
            FocusScope.of(context).requestFocus(next);
          _validateAndNotify();
        },
      ),
    );
  }
}
