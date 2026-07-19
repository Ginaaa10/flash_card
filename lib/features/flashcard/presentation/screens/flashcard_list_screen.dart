import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flash_card_app/core/theme/app_theme.dart';
import 'package:flash_card_app/features/flashcard/domain/providers/flashcard_provider.dart';
import 'package:flash_card_app/features/flashcard/domain/providers/groups_provider.dart';
import 'package:flash_card_app/features/settings/domain/providers/app_settings_provider.dart';
import 'package:flash_card_app/shared/models/flashcard_model.dart';
import 'package:flash_card_app/shared/services/data_export_service.dart';
import 'package:flash_card_app/shared/services/image_upload_service.dart';
import 'package:flash_card_app/features/flashcard/presentation/screens/ai_connect_dialog.dart';

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
  String? _selectedGroup;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
    final appBg = ref.watch(appSettingsProvider).appBackgroundImage;
    final theme = Theme.of(context);

    return Container(
      decoration: appBg != null
          ? BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(appBg),
                fit: BoxFit.cover,
              ),
            )
          : null,
      child: Scaffold(
        backgroundColor: appBg != null ? Colors.transparent : null,
      appBar: AppBar(
        title: _isSearching
            ? _buildSearchField(theme)
            : ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [AppTheme.pinkLight, AppTheme.purpleLight, AppTheme.blueLight],
                ).createShader(bounds),
                child: const Text(
                  'Flash Cards',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                  ),
                ),
              ),
        actions: _buildActions(theme),
        bottom: _isSearching
            ? null
            : TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(icon: Icon(Icons.all_inclusive), text: 'All'),
                  Tab(icon: Icon(Icons.star), text: 'Favorites'),
                  Tab(icon: Icon(Icons.folder), text: 'Groups'),
                  Tab(icon: Icon(Icons.schedule), text: 'Recheck'),
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
                  ref.watch(favoriteFlashcardProvider),
                  theme,
                ),
                _buildGroupsTab(theme),
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
    ),
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
        _buildActionIconButton(
          icon: Icons.close,
          gradient: const LinearGradient(colors: [Color(0xFFF093FB), Color(0xFFF5576C)]),
          glowColor: const Color(0xFFF5576C),
          onPressed: () {
            _searchController.clear();
            ref.read(flashcardSearchProvider.notifier).state = '';
            setState(() => _isSearching = false);
          },
        ),
      ];
    }

    return [
      _buildActionIconButton(
        icon: Icons.search,
        gradient: const LinearGradient(colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)]),
        glowColor: const Color(0xFF00F2FE),
        onPressed: () => setState(() => _isSearching = true),
      ),
      _buildActionIconButton(
        icon: Icons.sort,
        gradient: const LinearGradient(colors: [Color(0xFF667EEA), Color(0xFF764BA2)]),
        glowColor: const Color(0xFF764BA2),
        onPressed: () => _showSortDialog(theme),
      ),
      PopupMenuButton<String>(
        icon: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.grey.shade600, Colors.grey.shade800],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.more_vert, color: Colors.white, size: 20),
        ),
        onSelected: (value) => _handleMenuAction(value, theme),
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'ai_connect',
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF667EEA), Color(0xFF764BA2)]),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.smart_toy, color: Colors.white, size: 18),
              ),
              title: const Text('AI Connection'),
            ),
          ),
          PopupMenuItem(
            value: 'app_background',
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)]),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.wallpaper, color: Colors.white, size: 18),
              ),
              title: const Text('App Background'),
            ),
          ),
          PopupMenuItem(
            value: 'backup',
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF43E97B), Color(0xFF38F9D7)]),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.backup, color: Colors.white, size: 18),
              ),
              title: const Text('Backup Data'),
            ),
          ),
          PopupMenuItem(
            value: 'restore',
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)]),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.restore, color: Colors.white, size: 18),
              ),
              title: const Text('Restore Data'),
            ),
          ),
          PopupMenuItem(
            value: 'delete_all',
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)]),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.delete_sweep, color: Colors.white, size: 18),
              ),
              title: const Text('Delete All', style: TextStyle(color: Colors.red)),
            ),
          ),
        ],
      ),
    ];
  }

  Widget _buildActionIconButton({
    required IconData icon,
    required LinearGradient gradient,
    required Color glowColor,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: glowColor.withOpacity(0.3),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  void _handleMenuAction(String value, ThemeData theme) {
    switch (value) {
      case 'ai_connect':
        _showAiConnectDialog();
        break;
      case 'app_background':
        _showAppBackgroundDialog(theme);
        break;
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

  void _showAiConnectDialog() {
    showDialog(
      context: context,
      builder: (context) => const AiConnectDialog(),
    );
  }

  void _showAppBackgroundDialog(ThemeData theme) {
    final currentBg = ref.read(appSettingsProvider).appBackgroundImage;

    showDialog(
      context: context,
      builder: (context) => _AppBackgroundDialog(
        currentBg: currentBg,
        onBackgroundChanged: (url) {
          ref.read(appSettingsProvider.notifier).setAppBackground(url);
        },
      ),
    );
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
          return _buildFlashcardItem(flashcard, theme, index);
        },
      ),
    );
  }

  Widget _buildFlashcardItem(FlashcardModel flashcard, ThemeData theme, int index) {
    final cardColor = AppTheme.getCardColor(index);
    final bgImage = flashcard.frontBackgroundImage;
    final borderColorInt = flashcard.borderColor;
    final borderWidth = flashcard.borderWidth;
    final borderRadius = flashcard.borderRadius;
    final borderStyle = flashcard.borderStyle;

    return GestureDetector(
      onTap: () => context.push('/editor/${flashcard.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        height: 180,
        decoration: BoxDecoration(
          color: bgImage == null ? cardColor : Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
          border: borderStyle != 'none'
              ? Border.all(
                  color: Color(borderColorInt),
                  width: borderWidth,
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.15),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
          image: bgImage != null
              ? DecorationImage(
                  image: NetworkImage(bgImage),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: bgImage != null
                      ? Colors.white.withOpacity(0.8)
                      : cardColor.withOpacity(0.5),
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
                    if (flashcard.isFavorite)
                      const Padding(
                        padding: EdgeInsets.only(right: 4),
                        child: Icon(Icons.star, size: 16, color: Colors.amber),
                      ),
                    if (flashcard.groupName != null && flashcard.groupName!.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        margin: const EdgeInsets.only(right: 4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          flashcard.groupName!,
                          style: TextStyle(
                            fontSize: 10,
                            color: theme.colorScheme.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    if (flashcard.reviewCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.greenLight.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${flashcard.reviewCount}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.greenDark,
                            fontWeight: FontWeight.w700,
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
                child: _buildMiniWhiteboard(
                  flashcard.frontStrokes,
                  theme,
                  bgImage,
                  flashcard.backBackgroundImage,
                  text: flashcard.frontText,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: bgImage != null
                      ? Colors.white.withOpacity(0.8)
                      : cardColor.withOpacity(0.3),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today,
                        size: 12, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(flashcard.updatedAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade500,
                        fontSize: 11,
                      ),
                    ),
                    const Spacer(),
                    if (flashcard.frontRecognizedText != null)
                      Icon(Icons.auto_fix_high,
                          size: 14, color: theme.colorScheme.tertiary),
                    if (flashcard.tags.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Icon(Icons.label,
                          size: 14, color: theme.colorScheme.tertiary),
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

  Widget _buildMiniWhiteboard(List strokes, ThemeData theme, String? frontBg, String? backBg, {String? text}) {
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: text != null && text.isNotEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    text,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            )
          : CustomPaint(
              painter: MiniWhiteboardPainter(
                strokes: strokes,
                strokeColor: theme.colorScheme.primary,
                frontBg: frontBg,
                backBg: backBg,
              ),
              size: Size.infinite,
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

  Widget _buildGroupsTab(ThemeData theme) {
    final groups = ref.watch(groupsProvider);
    final flashcards = ref.watch(filteredFlashcardProvider);

    return Column(
      children: [
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showCreateGroupDialog(theme),
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Create Group'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        if (groups.isEmpty)
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.folder_off, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'No groups yet',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create a group first, then assign flashcards to it',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: groups.length,
              itemBuilder: (context, index) {
                final group = groups[index];
                final groupFlashcards = flashcards
                    .where((fc) => fc.groupName == group)
                    .toList();
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.getCardColor(index),
                        AppTheme.getCardColor(index).withOpacity(0.5),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.getCardColor(index).withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ExpansionTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.folder,
                          color: theme.colorScheme.primary, size: 22),
                    ),
                    title: Text(
                      group,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    subtitle: Text(
                      '${groupFlashcards.length} flashcards',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (groupFlashcards.isEmpty)
                          GestureDetector(
                            onTap: () => _confirmDeleteGroup(group, theme),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: AppTheme.coralLight.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(Icons.delete_outline,
                                  size: 18, color: AppTheme.coralLight),
                            ),
                          ),
                      ],
                    ),
                    children: groupFlashcards
                        .asMap()
                        .entries
                        .map((e) => _buildFlashcardItem(e.value, theme, e.key))
                        .toList(),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  void _showCreateGroupDialog(ThemeData theme) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.folder_open, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Text('New Group'),
          ],
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Group name',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              ref.read(groupsProvider.notifier).addGroup(value.trim());
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                ref.read(groupsProvider.notifier).addGroup(controller.text.trim());
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteGroup(String group, ThemeData theme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Group'),
        content: Text('Delete group "$group"? Flashcards in this group will not be deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(groupsProvider.notifier).removeGroup(group);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildFAB(ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _buildGradientFAB(
          heroTag: 'quiz',
          onPressed: () => context.push('/quiz'),
          icon: Icons.quiz,
          tooltip: 'Start Quiz',
          gradient: const LinearGradient(
            colors: [Color(0xFFF093FB), Color(0xFFF5576C)],
          ),
          glowColor: const Color(0xFFF5576C),
        ),
        const SizedBox(height: 12),
        _buildGradientFAB(
          heroTag: 'whiteboard',
          onPressed: () => context.push('/whiteboard'),
          icon: Icons.draw,
          tooltip: 'New Whiteboard',
          gradient: const LinearGradient(
            colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
          ),
          glowColor: const Color(0xFF00F2FE),
        ),
        const SizedBox(height: 12),
        _buildGradientFAB(
          heroTag: 'add',
          onPressed: _createNewFlashcard,
          icon: Icons.add,
          tooltip: 'New Flashcard',
          gradient: const LinearGradient(
            colors: [Color(0xFF43E97B), Color(0xFF38F9D7)],
          ),
          glowColor: const Color(0xFF38F9D7),
          isLarge: true,
        ),
      ],
    );
  }

  Widget _buildGradientFAB({
    required String heroTag,
    required VoidCallback onPressed,
    required IconData icon,
    required String tooltip,
    required LinearGradient gradient,
    required Color glowColor,
    bool isLarge = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(isLarge ? 20 : 16),
        boxShadow: [
          BoxShadow(
            color: glowColor.withOpacity(0.4),
            blurRadius: 16,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: gradient.colors[0].withOpacity(0.2),
            blurRadius: 24,
            spreadRadius: 4,
          ),
        ],
      ),
      child: isLarge
          ? FloatingActionButton.large(
              heroTag: heroTag,
              onPressed: onPressed,
              tooltip: tooltip,
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              elevation: 0,
              child: Icon(icon, size: 32),
            )
          : FloatingActionButton.small(
              heroTag: heroTag,
              onPressed: onPressed,
              tooltip: tooltip,
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              elevation: 0,
              child: Icon(icon),
            ),
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
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.surface,
            theme.colorScheme.surface.withOpacity(0.95),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.purpleLight.withOpacity(0.08),
            blurRadius: 16,
            spreadRadius: 2,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildFilterChip(
            label: 'All',
            icon: Icons.all_inclusive,
            isSelected: _selectedFilter == 'all',
            gradient: const LinearGradient(colors: [Color(0xFF667EEA), Color(0xFF764BA2)]),
            glowColor: const Color(0xFF764BA2),
            onTap: () => setState(() => _selectedFilter = 'all'),
          ),
          const SizedBox(width: 10),
          _buildFilterChip(
            label: 'With Text',
            icon: Icons.text_snippet,
            isSelected: _selectedFilter == 'with_text',
            gradient: const LinearGradient(colors: [Color(0xFFF093FB), Color(0xFFF5576C)]),
            glowColor: const Color(0xFFF5576C),
            onTap: () => setState(() => _selectedFilter = 'with_text'),
          ),
          const SizedBox(width: 10),
          _buildFilterChip(
            label: 'No Text',
            icon: Icons.draw,
            isSelected: _selectedFilter == 'no_text',
            gradient: const LinearGradient(colors: [Color(0xFF43E97B), Color(0xFF38F9D7)]),
            glowColor: const Color(0xFF38F9D7),
            onTap: () => setState(() => _selectedFilter = 'no_text'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required LinearGradient gradient,
    required Color glowColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected ? gradient : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.grey.shade200,
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: glowColor.withOpacity(0.4),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                  BoxShadow(
                    color: gradient.colors[0].withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : Colors.grey.shade600,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MiniWhiteboardPainter extends CustomPainter {
  final List strokes;
  final Color strokeColor;
  final String? frontBg;
  final String? backBg;

  MiniWhiteboardPainter({
    required this.strokes,
    this.strokeColor = Colors.black,
    this.frontBg,
    this.backBg,
  });

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

class _AppBackgroundDialog extends StatefulWidget {
  final String? currentBg;
  final Function(String?) onBackgroundChanged;

  const _AppBackgroundDialog({
    required this.currentBg,
    required this.onBackgroundChanged,
  });

  @override
  State<_AppBackgroundDialog> createState() => _AppBackgroundDialogState();
}

class _AppBackgroundDialogState extends State<_AppBackgroundDialog> {
  bool _isUploading = false;
  String? _error;

  Future<void> _uploadImage() async {
    setState(() {
      _isUploading = true;
      _error = null;
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        if (mounted) {
          setState(() {
            _isUploading = false;
          });
        }
        return;
      }

      final file = result.files.first;
      final bytes = file.bytes;
      if (bytes == null) {
        if (mounted) {
          setState(() {
            _isUploading = false;
            _error = 'Could not read file. Please try another image.';
          });
        }
        return;
      }

      final base64Data = base64Encode(bytes);
      final ext = file.name.split('.').last.toLowerCase();
      final dataUrl = 'data:image/$ext;base64,$base64Data';

      if (mounted) {
        widget.onBackgroundChanged(dataUrl);
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploading = false;
          _error = 'Error: $e';
        });
      }
    }
  }

  Future<void> _removeImage() async {
    if (widget.currentBg != null) {
      await ImageUploadService.deleteImage(widget.currentBg!);
    }
    widget.onBackgroundChanged(null);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.wallpaper, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          const Text('App Background'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.currentBg != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                widget.currentBg!,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isUploading ? null : _removeImage,
                icon: const Icon(Icons.delete, color: Colors.red),
                label: const Text('Remove Background',
                    style: TextStyle(color: Colors.red)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const Divider(height: 24),
          ],
          if (_error != null)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.red, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isUploading ? null : _uploadImage,
              icon: _isUploading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.add_photo_alternate),
              label: Text(_isUploading ? 'Uploading...' : 'Upload Background'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
