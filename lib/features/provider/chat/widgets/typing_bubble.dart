import 'package:flutter/material.dart';
import 'dart:math' as Math;

class TypingBubble extends StatefulWidget {
  const TypingBubble({super.key});

  @override
  State<TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<TypingBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(); // Repetir animación en bucle
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(left: 16, right: 50, top: 4, bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
            bottomLeft: Radius.circular(4),
          ),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            return AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                // Matemáticas simples para hacer que los puntos salten en secuencia
                final delay = index * 0.2;
                var value = (_controller.value - delay) % 1.0;
                if (value < 0) value += 1.0;

                final dy = value < 0.5
                    ? -4.0 * Math.sin(value * 3.1416 * 2)
                    : 0.0;

                return Transform.translate(
                  offset: Offset(0, dy),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
                    child: CircleAvatar(
                      radius: 3,
                      backgroundColor: Colors.grey.shade400,
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ),
    );
  }
}
