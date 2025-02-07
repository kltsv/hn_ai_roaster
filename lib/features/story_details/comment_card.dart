import 'package:flutter/material.dart';
import '../../api/models/comment.dart';
import '../../core/services/ai_service.dart';
import '../../core/utils/text_utils.dart';
import '../../core/widgets/ai_comment_card.dart';
import '../../core/widgets/roast_button.dart';
import '../../core/widgets/roasted_content.dart';

class CommentCard extends StatefulWidget {
  final Comment comment;
  final bool isLoadingReplies;
  final VoidCallback? onLoadReplies;
  final bool showReplies;

  const CommentCard({
    super.key,
    required this.comment,
    this.isLoadingReplies = false,
    this.onLoadReplies,
    this.showReplies = false,
  });

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  final _aiService = AiService();
  String? _roastComment;
  bool _isLoadingRoast = false;

  Future<void> _loadRoast() async {
    setState(() {
      _isLoadingRoast = true;
    });

    try {
      final comment = await _aiService.getCommentaryForStory(
        widget.comment.text,
        null,
        null,
      );
      setState(() {
        _roastComment = comment;
      });
    } catch (e) {
      setState(() {
        _roastComment = 'Failed to generate AI commentary: $e';
      });
    } finally {
      setState(() {
        _isLoadingRoast = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F7FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                widget.comment.by,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _formatTimeAgo(widget.comment.dateTime),
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(cleanHtmlText(widget.comment.text)),
          const SizedBox(height: 8),
          Row(
            children: [
              if (widget.comment.kids.isNotEmpty && !widget.showReplies)
                TextButton.icon(
                  onPressed:
                      widget.isLoadingReplies ? null : widget.onLoadReplies,
                  icon: widget.isLoadingReplies
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.reply),
                  label: Text('${widget.comment.kids.length} replies'),
                ),
              const Spacer(),
              RoastButton(
                isLoading: _isLoadingRoast,
                onPressed: _loadRoast,
              ),
            ],
          ),
          if (_roastComment != null) ...[
            const SizedBox(height: 16),
            AiCommentCard(comment: _roastComment!),
          ],
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'just now';
    }
  }
}
