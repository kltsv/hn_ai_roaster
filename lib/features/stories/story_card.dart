import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../api/models/story.dart';

class StoryCard extends StatelessWidget {
  final Story story;
  final VoidCallback? onTap;

  const StoryCard({
    super.key,
    required this.story,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeAgo = _formatTimeAgo(story.dateTime);

    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                story.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (story.domain.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  story.domain,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.arrow_upward, size: 16, color: theme.colorScheme.primary),
                  const SizedBox(width: 4),
                  Text('${story.score}'),
                  const SizedBox(width: 16),
                  Icon(Icons.person_outline, size: 16, color: theme.colorScheme.secondary),
                  const SizedBox(width: 4),
                  Text(story.by),
                  const Spacer(),
                  Text(timeAgo, style: theme.textTheme.bodySmall),
                ],
              ),
              if (story.descendants > 0) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.comment_outlined, size: 16, color: theme.colorScheme.secondary),
                    const SizedBox(width: 4),
                    Text('${story.descendants} comments'),
                  ],
                ),
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