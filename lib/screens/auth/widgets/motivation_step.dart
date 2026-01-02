import 'package:flutter/material.dart';

class MotivationStep extends StatelessWidget {
  final TextEditingController controller;
  const MotivationStep({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.05),
            border: Border.all(color: Colors.white10),
          ),
          child: const Icon(
            Icons.auto_awesome,
            size: 50,
            color: Colors.blueAccent,
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          "Define Your Purpose",
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          "Why are you starting this journey?\nThis is your anchor.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white60, fontSize: 16, height: 1.5),
        ),
        const SizedBox(height: 32),
        TextField(
          controller: controller,
          maxLines: 4,
          style: const TextStyle(color: Colors.white, fontSize: 17),
          decoration: InputDecoration(
            hintText: "I want to quit because...",
            hintStyle: const TextStyle(color: Colors.white24),
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: Colors.white12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: Colors.blueAccent),
            ),
          ),
        ),
      ],
    );
  }
}
