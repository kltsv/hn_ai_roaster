import 'package:flutter/material.dart';

class RoastButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const RoastButton({
    super.key,
    this.isLoading = false,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: isLoading 
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Icon(Icons.psychology),
      label: const Text('Roast it!'),
    );
  }
}