import 'package:flutter/material.dart';
import '../services/ai_service.dart';
import 'ai_comment_card.dart';
import 'roast_button.dart';

class RoastedContent extends StatefulWidget {
  final String title;
  final String? text;
  final String? url;

  const RoastedContent({
    super.key,
    required this.title,
    this.text,
    this.url,
  });

  @override
  State<RoastedContent> createState() => _RoastedContentState();
}

class _RoastedContentState extends State<RoastedContent> {
  final _aiService = AiService();
  String? _aiComment;
  bool _isLoading = false;

  Future<void> _loadAiComment() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final comment = await _aiService.getCommentaryForStory(
        widget.title,
        widget.text,
        widget.url,
      );
      setState(() {
        _aiComment = comment;
      });
    } catch (e) {
      setState(() {
        _aiComment = 'Failed to generate AI commentary: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        RoastButton(
          isLoading: _isLoading,
          onPressed: _loadAiComment,
        ),
        if (_aiComment != null) ...[
          const SizedBox(height: 16),
          AiCommentCard(comment: _aiComment!),
        ],
      ],
    );
  }
}