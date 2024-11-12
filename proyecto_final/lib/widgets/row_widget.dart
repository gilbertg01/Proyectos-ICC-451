import 'package:flutter/material.dart';
import 'dart:math';

class RowWidget extends StatelessWidget {
  final String statTitle;
  final int statValue;

  const RowWidget({
    super.key,
    required this.statTitle,
    required this.statValue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          statTitle,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Stack(
          children: [
            Container(
              height: 20,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            FractionallySizedBox(
              widthFactor: min(statValue / 100, 1.0),
              child: Container(
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            Positioned.fill(
              child: Center(
                child: Text(
                  '$statValue%',
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
