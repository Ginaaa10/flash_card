import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flash_card_app/features/flashcard/domain/providers/flashcard_provider.dart';
import 'package:flash_card_app/shared/models/flashcard_model.dart';
import 'package:flash_card_app/shared/services/data_export_service.dart';

class FlashcardListScreen extends ConsumerStatefulWidget {
  const FlashcardListScreen({super.key});

  @override
  ConsumerState<FlashcardListScreen> createState() =>
      _FlashcardListScreenState();
}

class _FlashcardListScreenState extends ConsumerState<FlashcardListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final flashcards = ref.watch(filteredFlashcardProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? _buildSearchField(theme)
            : const Text('Flash Cards'),
        actions: _buildActions(theme),
        bottom: _isSearching
            ? null
            : TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(icon: Icon(Icons.all_inclusive), text: 'All'),
                  Tab(icon: Icon(Icons.star), text: 'Favorites'),
                  Tab(icon: Icon(Icons.schedule), text: 'Recent'),
                ],
              ),
      ),
      body: _isSearching
          ? _buildSearchResults(flashcards, theme)
          : TabBarView(
              controller: _tabController,
              children: [
                _buildFlashcardList(flashcards, theme),
                _buildFlashcardList(
                  flashcards.where((fc) => fc.reviewCount > 0).toList(),
                  theme,
                ),
                _buildFlashcardList(
                  flashcards
                      .where((fc) =>
                          fc.lastReviewedAt != null &&
                          fc.lastReviewedAt!.isAfter(
                              DateTime.now().subtract(const Duration(days: 7))))
                      .toList(),
                  theme,
                ),
              ],
            ),
      floatingActionButton: _buildFAB(theme),
      bottomNavigationBar: _buildFilterBar(theme),
    );
  }

  Widget _buildSearchField(ThemeData theme) {
    return TextField(
      controller: _searchController,
      autofocus: true,
      decoration: InputDecoration(
        hintText: 'Search flashcards...',
        border: InputBorder.none,
        suffixIcon: IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            _searchController.clear();
            ref.read(flashcardSearchProvider.notifier).state = '';
            setState(() => _isSearching = false);
          },
        ),
      ),
      onChanged: (value) {
        ref.read(flashcardSearchProvider.notifier).state = value;
      },
    );
  }

  List<Widget> _buildActions(ThemeData theme) {
    if (_isSearching) {
      return [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () => setState(() => _isSearching = false),
        ),
      ];
    }

    return [
      IconButton(
        icon: const Icon(Icons.search),
        onPressed: () => setState(() => _isSearching = true),
      ),
      PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert),
        onSelected: (value) => _handleMenuAction(value, theme),
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'sort',
            child: ListTile(
              leading: Icon(Icons.sort),
              title: Text('Sort'),
            ),
          ),
          const PopupMenuItem(
            value: 'backup',
            child: ListTile(
              leading: Icon(Icons.backup),
              title: Text('Backup Data'),
            ),
          ),
          const PopupMenuItem(
            value: 'restore',
            child: ListTile(
              leading: Icon(Icons.restore),
              title: Text('Restore Data'),
            ),
          ),
          const PopupMenuItem(
            value: 'delete_all',
            child: ListTile(
              leading: Icon(Icons.delete_sweep, color: Colors.red),
              title: Text('Delete All', style: TextStyle(color: Colors.red)),
            ),
          ),
        ],
      ),
    ];
  }

  void _handleMenuAction(String value, ThemeData theme) {
    switch (value) {
      case 'sort':
        _showSortDialog(theme);
        break;
      case 'backup':
        _backupData();
        break;
      case 'restore':
        _restoreData();
        break;
      case 'delete_all':
        _showDeleteAllDialog(theme);
        break;
    }
  }

  void _confirmDelete(FlashcardModel flashcard, ThemeData theme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Flashcard'),
        content: Text('Delete "${flashcard.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref
                  .read(flashcardProvider.notifier)
                  .deleteFlashcard(flashcard.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Deleted')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _backupData() async {
    try {
      await DataExportService.saveBackupToFile();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data backed up successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Backup failed: $e')),
        );
      }
    }
  }

  Future<void> _restoreData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore Data'),
        content: const Text('This will restore data from the last backup. Current data may be overwritten.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Restore'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final success = await DataExportService.restoreBackupFromFile();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(success ? 'Data restored successfully' : 'No backup found'),
            ),
          );
          if (success) {
            ref.read(flashcardProvider.notifier).loadFlashcards();
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Restore failed: $e')),
          );
        }
      }
    }
  }

  void _showSortDialog(ThemeData theme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sort by'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Date created (newest)'),
              value: 'created_desc',
              groupValue: _selectedFilter,
              onChanged: (value) {
                setState(() => _selectedFilter = value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Date created (oldest)'),
              value: 'created_asc',
              groupValue: _selectedFilter,
              onChanged: (value) {
                setState(() => _selectedFilter = value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Title (A-Z)'),
              value: 'title_asc',
              groupValue: _selectedFilter,
              onChanged: (value) {
                setState(() => _selectedFilter = value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Review count'),
              value: 'review_count',
              groupValue: _selectedFilter,
              onChanged: (value) {
                setState(() => _selectedFilter = value!);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteAllDialog(ThemeData theme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete All Flashcards'),
        content: const Text('Are you sure you want to delete all flashcards? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(flashcardProvider.notifier).deleteAllFlashcards();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All flashcards deleted')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(List<FlashcardModel> flashcards, ThemeData theme) {
    if (flashcards.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No results found', style: TextStyle(fontSize: 18)),
          ],
        ),
      );
    }
    return _buildFlashcardList(flashcards, theme);
  }

  Widget _buildFlashcardList(List<FlashcardModel> flashcards, ThemeData theme) {
    if (flashcards.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.note_add, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No flashcards yet',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap + to create your first flashcard',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.read(flashcardProvider.notifier).refreshFlashcards();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: flashcards.length,
        itemBuilder: (context, index) {
          final flashcard = flashcards[index];
          return _buildFlashcardItem(flashcard, theme);
        },
      ),
    );
  }

  Widget _buildFlashcardItem(FlashcardModel flashcard, ThemeData theme) {
    return GestureDetector(
      onTap: () => context.push('/editor/${flashcard.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        height: 180,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.style, size: 18, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        flashcard.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (flashcard.reviewCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${flashcard.reviewCount}',
                          style: TextStyle(
                            fontSize: 11,
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () => _confirmDelete(flashcard, theme),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.close,
                          size: 16,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _buildMiniWhiteboard(flashcard.frontStrokes, theme),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  border: Border(
                    top: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today,
                        size: 12, color: Colors.grey.shade400),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(flashcard.updatedAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade400,
                        fontSize: 11,
                      ),
                    ),
                    const Spacer(),
                    if (flashcard.frontRecognizedText != null)
                      Icon(Icons.auto_fix_high,
                          size: 14, color: theme.colorScheme.primary),
                    if (flashcard.tags.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Icon(Icons.label,
                          size: 14, color: theme.colorScheme.primary),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniWhiteboard(List strokes, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CustomPaint(
          painter: MiniWhiteboardPainter(strokes: strokes),
          size: Size.infinite,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (diff.inDays > 0) {
      return '${diff.inDays}d ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  Widget _buildFAB(ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton.small(
          heroTag: 'whiteboard',
          onPressed: () => context.push('/whiteboard'),
          child: const Icon(Icons.draw),
          tooltip: 'New Whiteboard',
        ),
        const SizedBox(height: 12),
        FloatingActionButton.large(
          heroTag: 'add',
          onPressed: _createNewFlashcard,
          child: const Icon(Icons.add, size: 32),
          tooltip: 'New Flashcard',
        ),
      ],
    );
  }

  Future<void> _createNewFlashcard() async {
    final flashcard = await ref
        .read(flashcardProvider.notifier)
        .createFlashcard(title: 'New Flashcard');
    if (mounted) {
      context.push('/editor/${flashcard.id}');
    }
  }

  Widget _buildFilterBar(ThemeData theme) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FilterChip(
            label: const Text('All'),
            selected: _selectedFilter == 'all',
            onSelected: (selected) {
              setState(() => _selectedFilter = 'all');
            },
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('With Text'),
            selected: _selectedFilter == 'with_text',
            onSelected: (selected) {
              setState(() => _selectedFilter = 'with_text');
            },
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('No Text'),
            selected: _selectedFilter == 'no_text',
            onSelected: (selected) {
              setState(() => _selectedFilter = 'no_text');
            },
          ),
        ],
      ),
    );
  }
}

class MiniWhiteboardPainter extends CustomPainter {
  final List strokes;

  MiniWhiteboardPainter({required this.strokes});

  @override
  void paint(Canvas canvas, Size size) {
    if (strokes.isEmpty) return;

    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    double minX = double.infinity, maxX = double.negativeInfinity;
    double minY = double.infinity, maxY = double.negativeInfinity;

    for (final stroke in strokes) {
      for (final p in stroke.points) {
        if (p.x < minX) minX = p.x;
        if (p.x > maxX) maxX = p.x;
        if (p.y < minY) minY = p.y;
        if (p.y > maxY) maxY = p.y;
      }
    }

    if (minX == double.infinity) return;

    final contentWidth = maxX - minX;
    final contentHeight = maxY - minY;
    if (contentWidth == 0 && contentHeight == 0) return;

    final scaleX = contentWidth > 0 ? (size.width - 16) / contentWidth : 1.0;
    final scaleY = contentHeight > 0 ? (size.height - 16) / contentHeight : 1.0;
    final scale = scaleX < scaleY ? scaleX : scaleY;

    final offsetX = (size.width - contentWidth * scale) / 2 - minX * scale;
    final offsetY = (size.height - contentHeight * scale) / 2 - minY * scale;

    for (final stroke in strokes) {
      if (stroke.points.isEmpty) continue;

      paint.color = stroke.color;
      paint.strokeWidth = (stroke.width * scale).clamp(1.0, 4.0);

      if (stroke.points.length == 1) {
        final p = stroke.points.first;
        canvas.drawCircle(
          Offset(p.x * scale + offsetX, p.y * scale + offsetY),
          (stroke.width * scale * 0.5).clamp(1.0, 3.0),
          paint,
        );
      } else {
        final path = Path();
        final first = stroke.points.first;
        path.moveTo(first.x * scale + offsetX, first.y * scale + offsetY);
        for (int i = 1; i < stroke.points.length; i++) {
          final p = stroke.points[i];
          path.lineTo(p.x * scale + offsetX, p.y * scale + offsetY);
        }
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant MiniWhiteboardPainter oldDelegate) => true;
}
