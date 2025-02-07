import 'package:flutter/material.dart';
import 'stories_controller.dart';
import 'stories_state.dart';
import 'story_card.dart';

class StoriesPage extends StatefulWidget {
  const StoriesPage({super.key});

  @override
  State<StoriesPage> createState() => _StoriesPageState();
}

class _StoriesPageState extends State<StoriesPage> {
  late final StoriesController _controller;

  @override
  void initState() {
    super.initState();
    _controller = StoriesController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HN Roasted'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          return RefreshIndicator(
            onRefresh: _controller.loadStories,
            child: _buildBody(_controller.state),
          );
        },
      ),
    );
  }

  Widget _buildBody(StoriesState state) {
    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(state.error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _controller.loadStories,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.stories == null || state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: state.stories!.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final story = state.stories![index];
        return StoryCard(
          story: story,
          onTap: () {
            // TODO: Navigate to story details
          },
        );
      },
    );
  }
}