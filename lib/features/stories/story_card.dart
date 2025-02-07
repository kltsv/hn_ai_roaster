import 'package:flutter/material.dart';
import '../../api/models/story.dart';
import '../../core/services/ai_service.dart';
import '../../core/utils/text_utils.dart';
import '../../core/widgets/ai_comment_card.dart';
import '../../core/widgets/roast_button.dart';
import '../../core/widgets/roasted_content.dart';

class StoryCard extends StatefulWidget {
  final Story story;
  final VoidCallback? onTap;

  const StoryCard({
    super.key,
    required this.story,
    this.onTap,
  });

  @override
  State<StoryCard> createState() => _StoryCardState();
}

class _StoryCardState extends State<StoryCard> {
  final _aiService = AiService();
  String? _roastComment;
  bool _isLoadingRoast = false;

  Future<void> _loadRoast() async {
    setState(() {
      _isLoadingRoast = true;
    });

    try {
      final comment = await _aiService.getCommentaryForStory(
        widget.story.title,
        widget.story.text,
        widget.story.url,
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
    final timeAgo = _formatTimeAgo(widget.story.dateTime);

    return Card(
      child: InkWell(
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor:
                        theme.colorScheme.primary.withValues(alpha: 0.1),
                    child: Text(
                      widget.story.by[0].toUpperCase(),
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.story.by,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          timeAgo,
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_horiz),
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                widget.story.title,
                style: theme.textTheme.titleMedium,
              ),
              if (widget.story.text != null &&
                  widget.story.text!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  cleanHtmlText(widget.story.text!),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 16),
              // Replace the existing roast button and AI comment section with:
              Row(
                children: [
                  _StatsChip(
                    icon: Icons.arrow_upward,
                    label: '${widget.story.score}',
                  ),
                  const SizedBox(width: 16),
                  _StatsChip(
                    icon: Icons.comment_outlined,
                    label: '${widget.story.descendants}',
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
        ),
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

class _StatsChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatsChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
    );
  }
}
