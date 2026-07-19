import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flash_card_app/core/theme/app_theme.dart';
import 'package:flash_card_app/features/flashcard/domain/providers/flashcard_provider.dart';
import 'package:flash_card_app/features/flashcard/domain/providers/groups_provider.dart';
import 'package:flash_card_app/features/settings/domain/providers/app_settings_provider.dart';
import 'package:flash_card_app/features/recognition/domain/services/tesseract_ocr_service.dart';
import 'package:flash_card_app/shared/models/flashcard_model.dart';
import 'package:flash_card_app/shared/models/stroke_model.dart';
import 'package:flash_card_app/shared/models/point_model.dart';
import 'package:flash_card_app/shared/services/image_upload_service.dart';
import 'dart:typed_data';

class FlashcardEditorScreen extends ConsumerStatefulWidget {
  final String? flashcardId;

  const FlashcardEditorScreen({super.key, this.flashcardId});

  @override
  ConsumerState<FlashcardEditorScreen> createState() =>
      _FlashcardEditorScreenState();
}

class _FlashcardEditorScreenState extends ConsumerState<FlashcardEditorScreen> {
  bool _isFront = true;
  bool _isRecognizing = false;
  bool _isEditingTitle = false;
  bool _isSaving = false;
  bool _isFavorite = false;
  bool _isTextInputMode = false;
  String? _groupName;
  String? _frontBackgroundImage;
  String? _backBackgroundImage;
  String? _frontText;
  String? _backText;
  String _borderStyle = 'solid';
  int _borderColor = 0xFF6366F1;
  double _borderWidth = 2.0;
  double _borderRadius = 16.0;
  String? _activeTool;
  String? _hoveredTool;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _frontTextController = TextEditingController();
  final TextEditingController _backTextController = TextEditingController();
  final TesseractOcrService _ocrService = TesseractOcrService();
  final GlobalKey<_WhiteboardDrawingAreaState> _frontCanvasKey = GlobalKey();
  final GlobalKey<_WhiteboardDrawingAreaState> _backCanvasKey = GlobalKey();
  String? _frontRecognizedText;
  String? _backRecognizedText;
  bool _hasLoadedFlashcard = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    if (widget.flashcardId == null) {
      _titleController.text = 'New Flashcard';
      _hasLoadedFlashcard = true;
    }
  }

  void _loadFlashcardFromProvider(FlashcardModel flashcard) {
    if (_hasLoadedFlashcard) return;
    _hasLoadedFlashcard = true;
    _titleController.text = flashcard.title;
    _frontRecognizedText = flashcard.frontRecognizedText;
    _backRecognizedText = flashcard.backRecognizedText;
    _isFavorite = flashcard.isFavorite;
    _groupName = flashcard.groupName;
    _frontBackgroundImage = flashcard.frontBackgroundImage;
    _backBackgroundImage = flashcard.backBackgroundImage;
    _frontText = flashcard.frontText;
    _backText = flashcard.backText;
    _frontTextController.text = flashcard.frontText ?? '';
    _backTextController.text = flashcard.backText ?? '';
    _borderStyle = flashcard.borderStyle;
    _borderColor = flashcard.borderColor;
    _borderWidth = flashcard.borderWidth;
    _borderRadius = flashcard.borderRadius;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _frontCanvasKey.currentState?.loadStrokes(flashcard.frontStrokes);
        _backCanvasKey.currentState?.loadStrokes(flashcard.backStrokes);
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _titleController.dispose();
    _frontTextController.dispose();
    _backTextController.dispose();
    super.dispose();
  }

  void _flipCard() {
    setState(() => _isFront = !_isFront);
  }

  _WhiteboardDrawingAreaState? get _currentCanvas =>
      _isFront ? _frontCanvasKey.currentState : _backCanvasKey.currentState;

  void _undo() {
    _currentCanvas?.undo();
    setState(() {});
  }

  void _redo() {
    _currentCanvas?.redo();
    setState(() {});
  }

  void _clearCurrent() {
    _currentCanvas?.clear();
    setState(() {
      if (_isFront) {
        _frontRecognizedText = null;
      } else {
        _backRecognizedText = null;
      }
    });
  }

  void _toggleFavorite() {
    setState(() => _isFavorite = !_isFavorite);
  }

  void _showImageSettings() {
    final side = _isFront ? 'Front' : 'Back';
    final currentBg = _isFront ? _frontBackgroundImage : _backBackgroundImage;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('$side Side Settings'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (currentBg != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    currentBg,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () async {
                    await ImageUploadService.deleteImage(currentBg);
                    setState(() {
                      if (_isFront) {
                        _frontBackgroundImage = null;
                      } else {
                        _backBackgroundImage = null;
                      }
                    });
                    setDialogState(() {});
                    if (mounted) Navigator.pop(context);
                  },
                  icon: const Icon(Icons.delete, color: Colors.red),
                  label: const Text('Remove Background',
                      style: TextStyle(color: Colors.red)),
                ),
                const Divider(),
              ],
              ListTile(
                leading: const Icon(Icons.image),
                title: const Text('Upload Background Image'),
                subtitle: const Text('Pick from device'),
                onTap: () async {
                  final flashcardId = widget.flashcardId ?? DateTime.now().millisecondsSinceEpoch.toString();
                  final url = await ImageUploadService.uploadImage(
                    flashcardId: flashcardId,
                    side: _isFront ? 'front' : 'back',
                    type: 'bg',
                  );
                  if (url != null) {
                    setState(() {
                      if (_isFront) {
                        _frontBackgroundImage = url;
                      } else {
                        _backBackgroundImage = url;
                      }
                    });
                    if (mounted) Navigator.pop(context);
                  }
                },
              ),
              const SizedBox(height: 8),
              Text('Border Color', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _colorOption(0xFF6366F1, 'Indigo'),
                  _colorOption(0xFFFF6B9D, 'Pink'),
                  _colorOption(0xFF9B5DE5, 'Purple'),
                  _colorOption(0xFF00BBF9, 'Blue'),
                  _colorOption(0xFF00F5D4, 'Green'),
                  _colorOption(0xFFFFD166, 'Yellow'),
                  _colorOption(0xFFFF9F1C, 'Orange'),
                  _colorOption(0xFFFF6B6B, 'Red'),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('Border: '),
                  Expanded(
                    child: Slider(
                      value: _borderWidth,
                      min: 0,
                      max: 8,
                      divisions: 16,
                      label: _borderWidth.toStringAsFixed(1),
                      onChanged: (v) => setState(() => _borderWidth = v),
                    ),
                  ),
                  Text('${_borderWidth.toStringAsFixed(1)}px'),
                ],
              ),
              Row(
                children: [
                  const Text('Radius: '),
                  Expanded(
                    child: Slider(
                      value: _borderRadius,
                      min: 0,
                      max: 40,
                      divisions: 20,
                      label: _borderRadius.toStringAsFixed(0),
                      onChanged: (v) => setState(() => _borderRadius = v),
                    ),
                  ),
                  Text('${_borderRadius.toStringAsFixed(0)}px'),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _colorOption(int colorValue, String name) {
    final isSelected = _borderColor == colorValue;
    return GestureDetector(
      onTap: () => setState(() => _borderColor = colorValue),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(colorValue),
              Color(colorValue).withOpacity(0.7),
            ],
          ),
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.white : Colors.grey.shade300,
            width: isSelected ? 3 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Color(colorValue).withOpacity(0.5),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: isSelected
            ? const Icon(Icons.check, color: Colors.white, size: 18)
            : null,
      ),
    );
  }

  Widget _buildAppBarIconButton({
    required IconData icon,
    required LinearGradient gradient,
    required Color glowColor,
    required bool isActive,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          gradient: isActive ? gradient : null,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: glowColor.withOpacity(0.4),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Icon(
          icon,
          color: isActive ? Colors.white : Colors.grey,
          size: 22,
        ),
      ),
    );
  }

  void _showGroupDialog() {
    final existingGroups = ref.read(groupsProvider);
    final groupController = TextEditingController(text: _groupName ?? '');

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
            const Text('Flashcard Group'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: groupController,
              decoration: InputDecoration(
                hintText: 'Enter group name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            if (existingGroups.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text('Existing groups:',
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: existingGroups.map((group) {
                  final isSelected = _groupName == group;
                  return ActionChip(
                    label: Text(group),
                    avatar: isSelected ? const Icon(Icons.check, size: 16) : null,
                    backgroundColor:
                        isSelected ? AppTheme.purpleLight.withOpacity(0.15) : null,
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() => _groupName = group);
                    },
                  );
                }).toList(),
              ),
            ],
          ],
        ),
        actions: [
          if (_groupName != null)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() => _groupName = null);
              },
              child: const Text('Remove', style: TextStyle(color: Colors.red)),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final name = groupController.text.trim();
              Navigator.pop(context);
              if (name.isNotEmpty) {
                // Auto-add new group to groups collection
                final currentGroups = ref.read(groupsProvider);
                if (!currentGroups.contains(name)) {
                  ref.read(groupsProvider.notifier).addGroup(name);
                }
              }
              setState(() => _groupName = name.isEmpty ? null : name);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _recognizeText() async {
    final strokes = _currentStrokes;
    if (strokes.isEmpty) return;

    setState(() => _isRecognizing = true);

    try {
      final imageBytes = await _ocrService.strokesToImageBytes(strokes);
      if (imageBytes == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to process image')),
          );
        }
        return;
      }

      final result = await _ocrService.recognizeImage(imageBytes);
      if (mounted && result != null && result.isNotEmpty) {
        setState(() {
          if (_isFront) {
            _frontRecognizedText = result;
          } else {
            _backRecognizedText = result;
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Recognized: "$result"'),
            duration: const Duration(seconds: 2),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No text recognized'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Recognition failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isRecognizing = false);
    }
  }

  List<StrokeModel> get _currentStrokes =>
      _currentCanvas?.strokes ?? [];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.9;
    final cardHeight = cardWidth * 0.65;
    final appBg = ref.watch(appSettingsProvider).appBackgroundImage;

    final flashcardById = widget.flashcardId != null
        ? ref.watch(flashcardByIdProvider(widget.flashcardId!))
        : null;

    if (flashcardById != null && !_hasLoadedFlashcard) {
      _loadFlashcardFromProvider(flashcardById);
    }

    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (event) {
        if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.arrowRight) {
          _flipCard();
        }
      },
      child: Container(
        decoration: appBg != null
          ? BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(appBg),
                fit: BoxFit.cover,
              ),
            )
          : const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFF8F9FE),
                  Color(0xFFF0F2FF),
                  Color(0xFFE8EDFF),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.white.withOpacity(0.85),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
            onPressed: () async {
              await _saveFlashcard();
              if (mounted) context.go('/');
            },
          ),
        title: _isEditingTitle
            ? TextField(
                controller: _titleController,
                autofocus: true,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Enter title',
                ),
                onSubmitted: (value) {
                  setState(() => _isEditingTitle = false);
                },
              )
            : GestureDetector(
                onTap: () => setState(() => _isEditingTitle = true),
                child: Text(
                  _titleController.text.isEmpty
                      ? 'New Flashcard'
                      : _titleController.text,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                ),
              ),
        centerTitle: true,
        actions: [
          _buildAppBarIconButton(
            icon: _isFavorite ? Icons.star : Icons.star_border,
            gradient: const LinearGradient(
              colors: [Color(0xFFFFD166), Color(0xFFFF9F1C)],
            ),
            glowColor: const Color(0xFFFFD166),
            isActive: _isFavorite,
            onPressed: _toggleFavorite,
          ),
          _buildAppBarIconButton(
            icon: Icons.folder,
            gradient: const LinearGradient(
              colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
            ),
            glowColor: const Color(0xFF764BA2),
            isActive: _groupName != null,
            onPressed: _showGroupDialog,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            _buildSideSelector(theme),
            const SizedBox(height: 8),
            _buildImageUploadBar(theme),
            const SizedBox(height: 8),
            Expanded(
              child: Center(
                child: _buildFlashcard(cardWidth, cardHeight, theme),
              ),
            ),
            if (_isRecognizing) const LinearProgressIndicator(),
            _buildToolbar(theme),
          ],
        ),
      ),
    ),
    ),
    );
  }

  Widget _buildSideSelector(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSideButton('Front', _isFront, theme, () {
          if (!_isFront) _flipCard();
        }),
        const SizedBox(width: 12),
        _buildSideButton('Back', !_isFront, theme, () {
          if (_isFront) _flipCard();
        }),
      ],
    );
  }

  Widget _buildSideButton(
      String label, bool isActive, ThemeData theme, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
        decoration: BoxDecoration(
          gradient: isActive
              ? const LinearGradient(
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                )
              : null,
          color: isActive ? null : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isActive
              ? [
                  const BoxShadow(
                    color: Color(0xFF764BA2),
                    blurRadius: 12,
                    spreadRadius: 1,
                    offset: Offset(0, 3),
                  ),
                  BoxShadow(
                    color: const Color(0xFF667EEA).withOpacity(0.3),
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
          border: Border.all(
            color: isActive
                ? Colors.transparent
                : Colors.grey.shade200,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? Icons.check_circle : Icons.circle_outlined,
              size: 16,
              color: isActive ? Colors.white : Colors.grey.shade400,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey.shade600,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageUploadBar(ThemeData theme) {
    final side = _isFront ? 'Front' : 'Back';
    final currentBg = _isFront ? _frontBackgroundImage : _backBackgroundImage;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white,
            Colors.white.withOpacity(0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.blueLight.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.blueLight.withOpacity(0.08),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.image, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 8),
          Text(
            '$side Background',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(width: 8),
          if (currentBg != null) ...[
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                image: DecorationImage(
                  image: NetworkImage(currentBg),
                  fit: BoxFit.cover,
                ),
                border: Border.all(
                  color: AppTheme.greenLight,
                  width: 2,
                ),
              ),
            ),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: () async {
                await ImageUploadService.deleteImage(currentBg);
                setState(() {
                  if (_isFront) {
                    _frontBackgroundImage = null;
                  } else {
                    _backBackgroundImage = null;
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: AppTheme.coralLight.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(Icons.close, size: 12, color: AppTheme.coralLight),
              ),
            ),
          ],
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () async {
              final flashcardId = widget.flashcardId ?? DateTime.now().millisecondsSinceEpoch.toString();
              final url = await ImageUploadService.uploadImage(
                flashcardId: flashcardId,
                side: _isFront ? 'front' : 'back',
                type: 'bg',
              );
              if (url != null) {
                setState(() {
                  if (_isFront) {
                    _frontBackgroundImage = url;
                  } else {
                    _backBackgroundImage = url;
                  }
                });
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
                ),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00F2FE).withOpacity(0.3),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    currentBg != null ? Icons.swap_horiz : Icons.add_a_photo,
                    color: Colors.white,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    currentBg != null ? 'Change' : 'Upload',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlashcard(double width, double height, ThemeData theme) {
    final recognizedText =
        _isFront ? _frontRecognizedText : _backRecognizedText;

    return _buildCardContent(width, height, theme, recognizedText);
  }

  Widget _buildCardContent(
    double width,
    double height,
    ThemeData theme,
    String? recognizedText,
  ) {
    final bgImage = _isFront ? _frontBackgroundImage : _backBackgroundImage;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_borderRadius),
        border: _borderWidth > 0
            ? Border.all(
                color: Color(_borderColor),
                width: _borderWidth,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 40,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_borderRadius),
        child: Stack(
          children: [
            if (bgImage != null)
              Positioned.fill(
                child: Image.network(
                  bgImage,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey.shade100,
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  ),
                ),
              ),
            Positioned.fill(
              child: _buildDrawingArea(theme),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildCardHeader(theme),
            ),
            if (!_isTextInputMode)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => setState(() => _isTextInputMode = true),
                  child: _buildCardContentText(theme),
                ),
              ),
            if (_isTextInputMode)
              Positioned.fill(
                child: Container(
                  color: Colors.white.withOpacity(0.95),
                  padding: const EdgeInsets.fromLTRB(16, 52, 16, 16),
                  child: TextField(
                    controller: _isFront ? _frontTextController : _backTextController,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                    decoration: InputDecoration(
                      hintText: 'Type your content here...',
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      border: InputBorder.none,
                    ),
                    onChanged: (value) {
                      setState(() {
                        if (_isFront) {
                          _frontText = value;
                        } else {
                          _backText = value;
                        }
                      });
                    },
                  ),
                ),
              ),
            if (recognizedText != null && recognizedText.isNotEmpty)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildRecognizedText(recognizedText, theme),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardContentText(ThemeData theme) {
    final currentText = _isFront ? _frontText : _backText;
    if (currentText == null || currentText.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 52, 16, 16),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            currentText,
            style: const TextStyle(
              fontSize: 18,
              height: 1.6,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
            textAlign: TextAlign.center,
            maxLines: 15,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  Widget _buildCardHeader(ThemeData theme) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          _buildColorDot(Colors.black),
          _buildColorDot(Colors.red),
          _buildColorDot(Colors.blue),
          _buildColorDot(Colors.green),
          const SizedBox(width: 8),
          Container(width: 1, height: 20, color: Colors.grey.shade300),
          const SizedBox(width: 8),
          _buildWidthDot(2.0),
          _buildWidthDot(3.0),
          _buildWidthDot(5.0),
          const Spacer(),
          IconButton(
            onPressed: _currentStrokes.isNotEmpty ? _undo : null,
            icon: const Icon(Icons.undo, size: 18),
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
          IconButton(
            onPressed: _currentCanvas?.canRedo == true ? _redo : null,
            icon: const Icon(Icons.redo, size: 18),
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
          IconButton(
            onPressed: _currentStrokes.isNotEmpty ? _clearCurrent : null,
            icon: const Icon(Icons.delete_outline, size: 18),
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildColorDot(Color color) {
    return Container(
      width: 22,
      height: 22,
      margin: const EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
    );
  }

  Widget _buildWidthDot(double width) {
    return Container(
      width: 28,
      height: 22,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Container(
          width: width * 2,
          height: width * 2,
          decoration: const BoxDecoration(
            color: Colors.black,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  Widget _buildDrawingArea(ThemeData theme) {
    return Container(
      color: Colors.white,
      child: IndexedStack(
        index: _isFront ? 0 : 1,
        children: [
          _WhiteboardDrawingArea(
            key: _frontCanvasKey,
            onStateChanged: () {
              if (mounted) setState(() {});
            },
          ),
          _WhiteboardDrawingArea(
            key: _backCanvasKey,
            onStateChanged: () {
              if (mounted) setState(() {});
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRecognizedText(String text, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Icon(Icons.auto_fix_high,
              size: 14, color: theme.colorScheme.primary),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
            color: theme.colorScheme.primary.withOpacity(0.08),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, -4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildToolbarButton(
            toolId: 'undo',
            icon: Icons.undo,
            label: 'Undo',
            enabled: _currentStrokes.isNotEmpty,
            isActive: false,
            onTap: _undo,
            theme: theme,
          ),
          _buildToolbarButton(
            toolId: 'redo',
            icon: Icons.redo,
            label: 'Redo',
            enabled: _currentCanvas?.canRedo == true,
            isActive: false,
            onTap: _redo,
            theme: theme,
          ),
          _buildToolbarButton(
            toolId: 'flip',
            icon: Icons.flip_to_front,
            label: 'Flip',
            enabled: true,
            isActive: false,
            onTap: _flipCard,
            theme: theme,
          ),
          _buildToolbarButton(
            toolId: 'text',
            icon: Icons.keyboard,
            label: 'Text',
            enabled: true,
            isActive: _isTextInputMode,
            onTap: () {
              setState(() => _isTextInputMode = !_isTextInputMode);
            },
            theme: theme,
          ),
          _buildToolbarButton(
            toolId: 'ocr',
            icon: Icons.text_snippet,
            label: 'OCR',
            enabled: _currentStrokes.isNotEmpty,
            isActive: _isRecognizing,
            onTap: _recognizeText,
            theme: theme,
          ),
          _buildToolbarButton(
            toolId: 'image',
            icon: Icons.image,
            label: 'Image',
            enabled: true,
            isActive: false,
            onTap: _showImageSettings,
            theme: theme,
          ),
          _buildToolbarButton(
            toolId: 'save',
            icon: Icons.save,
            label: _isSaving ? 'Saving...' : 'Save',
            enabled: !_isSaving,
            isActive: _isSaving,
            onTap: () async {
              setState(() => _isSaving = true);
              await _saveFlashcard();
              if (mounted) {
                setState(() => _isSaving = false);
                context.go('/');
              }
            },
            theme: theme,
          ),
        ],
      ),
    );
  }

  Widget _buildToolbarButton({
    required String toolId,
    required IconData icon,
    required String label,
    required bool enabled,
    required bool isActive,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    final isHovered = _hoveredTool == toolId;

    final toolColors = {
      'undo': [const Color(0xFF667EEA), const Color(0xFF764BA2)],
      'redo': [const Color(0xFF6B73FF), const Color(0xFF00D2FF)],
      'flip': [const Color(0xFF11998E), const Color(0xFF38EF7D)],
      'ocr': [const Color(0xFFF093FB), const Color(0xFFF5576C)],
      'image': [const Color(0xFF4FACFE), const Color(0xFF00F2FE)],
      'save': [const Color(0xFF43E97B), const Color(0xFF38F9D7)],
    };

    final colors = toolColors[toolId] ?? [Colors.grey, Colors.grey];
    final baseColor = colors[0];
    final glowColor = colors[1];

    return MouseRegion(
      onEnter: enabled ? (_) => setState(() => _hoveredTool = toolId) : null,
      onExit: enabled ? (_) => setState(() => _hoveredTool = null) : null,
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(
            horizontal: isActive || isHovered ? 16 : 12,
            vertical: isActive || isHovered ? 12 : 8,
          ),
          decoration: BoxDecoration(
            gradient: (isActive || isHovered) && enabled
                ? LinearGradient(
                    colors: [
                      baseColor.withOpacity(0.15),
                      glowColor.withOpacity(0.08),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            borderRadius: BorderRadius.circular(16),
            border: (isActive || isHovered) && enabled
                ? Border.all(
                    color: baseColor.withOpacity(0.3),
                    width: 1.5,
                  )
                : null,
            boxShadow: (isActive || isHovered) && enabled
                ? [
                    BoxShadow(
                      color: glowColor.withOpacity(0.25),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                    BoxShadow(
                      color: baseColor.withOpacity(0.1),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.all(isActive ? 6 : 4),
                decoration: BoxDecoration(
                  gradient: isActive
                      ? LinearGradient(colors: colors)
                      : null,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: glowColor.withOpacity(0.4),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  icon,
                  size: isActive ? 24 : (isHovered ? 22 : 20),
                  color: (isActive || isHovered) ? Colors.white : baseColor,
                ),
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: isActive ? 11 : 10,
                  fontWeight: (isActive || isHovered)
                      ? FontWeight.w700
                      : FontWeight.w500,
                  color: (isActive || isHovered)
                      ? baseColor
                      : Colors.grey.shade600,
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveFlashcard() async {
    final notifier = ref.read(flashcardProvider.notifier);
    final frontStrokes = _frontCanvasKey.currentState?.strokes ?? [];
    final backStrokes = _backCanvasKey.currentState?.strokes ?? [];
    final title = _titleController.text.isEmpty
        ? 'New Flashcard'
        : _titleController.text;

    try {
      if (widget.flashcardId != null) {
        final existing =
            ref.read(flashcardByIdProvider(widget.flashcardId!));
        if (existing != null) {
          await notifier.updateFlashcard(
            existing.copyWith(
              title: title,
              frontStrokes: frontStrokes,
              backStrokes: backStrokes,
              frontText: _frontText,
              backText: _backText,
              frontRecognizedText: _frontRecognizedText,
              backRecognizedText: _backRecognizedText,
              isFavorite: _isFavorite,
              groupName: _groupName,
              frontBackgroundImage: _frontBackgroundImage,
              backBackgroundImage: _backBackgroundImage,
              borderStyle: _borderStyle,
              borderColor: _borderColor,
              borderWidth: _borderWidth,
              borderRadius: _borderRadius,
            ),
          );
        } else {
          await notifier.createFlashcard(
            title: title,
            frontStrokes: frontStrokes,
            backStrokes: backStrokes,
            frontText: _frontText,
            backText: _backText,
            frontBackgroundImage: _frontBackgroundImage,
            backBackgroundImage: _backBackgroundImage,
            borderStyle: _borderStyle,
            borderColor: _borderColor,
            borderWidth: _borderWidth,
            borderRadius: _borderRadius,
          );
        }
      } else {
        await notifier.createFlashcard(
          title: title,
          frontStrokes: frontStrokes,
          backStrokes: backStrokes,
          frontText: _frontText,
          backText: _backText,
          frontBackgroundImage: _frontBackgroundImage,
          backBackgroundImage: _backBackgroundImage,
          borderStyle: _borderStyle,
          borderColor: _borderColor,
          borderWidth: _borderWidth,
          borderRadius: _borderRadius,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Saved'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Save failed: $e')),
        );
      }
    }
  }
}

class _WhiteboardDrawingArea extends StatefulWidget {
  final VoidCallback? onStateChanged;

  const _WhiteboardDrawingArea({super.key, this.onStateChanged});

  @override
  State<_WhiteboardDrawingArea> createState() =>
      _WhiteboardDrawingAreaState();
}

class _WhiteboardDrawingAreaState extends State<_WhiteboardDrawingArea> {
  final List<StrokeModel> _strokes = [];
  final List<StrokeModel> _redoStack = [];
  StrokeModel? _currentStroke;
  final List<PointModel> _currentPoints = [];
  final GlobalKey _paintKey = GlobalKey();

  List<StrokeModel> get strokes => List.unmodifiable(_strokes);
  bool get canRedo => _redoStack.isNotEmpty;

  void loadStrokes(List<StrokeModel> strokes) {
    setState(() {
      _strokes
        ..clear()
        ..addAll(strokes);
      _redoStack.clear();
    });
    widget.onStateChanged?.call();
  }

  void undo() {
    if (_strokes.isEmpty) return;
    setState(() {
      _redoStack.add(_strokes.removeLast());
    });
    widget.onStateChanged?.call();
  }

  void redo() {
    if (_redoStack.isEmpty) return;
    setState(() {
      _strokes.add(_redoStack.removeLast());
    });
    widget.onStateChanged?.call();
  }

  void clear() {
    setState(() {
      _strokes.clear();
      _redoStack.clear();
      _currentStroke = null;
      _currentPoints.clear();
    });
    widget.onStateChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: CustomPaint(
        key: _paintKey,
        painter: _WhiteboardPainter(
          strokes: _strokes,
          currentStroke: _currentStroke,
          backgroundColor: Colors.white,
        ),
        size: Size.infinite,
      ),
    );
  }

  PointModel _globalToLocal(Offset globalPosition) {
    final RenderBox box =
        _paintKey.currentContext!.findRenderObject() as RenderBox;
    final local = box.globalToLocal(globalPosition);
    return PointModel(
      x: local.dx,
      y: local.dy,
      time: DateTime.now().millisecondsSinceEpoch.toDouble(),
    );
  }

  void _onPanStart(DragStartDetails details) {
    final point = _globalToLocal(details.globalPosition);
    _currentPoints.clear();
    _currentPoints.add(point);
    setState(() {
      _currentStroke = StrokeModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        points: _currentPoints.toList(),
        color: Colors.black,
        width: 3.0,
        timestamp: DateTime.now(),
      );
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final point = _globalToLocal(details.globalPosition);
    _currentPoints.add(point);
    _currentStroke = StrokeModel(
      id: _currentStroke!.id,
      points: List.unmodifiable(_currentPoints),
      color: Colors.black,
      width: 3.0,
      timestamp: _currentStroke!.timestamp,
    );
    setState(() {});
  }

  void _onPanEnd(DragEndDetails details) {
    if (_currentStroke != null && _currentPoints.isNotEmpty) {
      setState(() {
        _strokes.add(_currentStroke!);
        if (_strokes.length > 50) {
          _strokes.removeAt(0);
        }
      });
    }
    setState(() {
      _currentStroke = null;
      _currentPoints.clear();
    });
    widget.onStateChanged?.call();
  }
}

class _WhiteboardPainter extends CustomPainter {
  final List<StrokeModel> strokes;
  final StrokeModel? currentStroke;
  final Color backgroundColor;

  _WhiteboardPainter({
    required this.strokes,
    this.currentStroke,
    this.backgroundColor = Colors.white,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = backgroundColor;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    for (final stroke in strokes) {
      _drawStroke(canvas, stroke);
    }
    if (currentStroke != null) {
      _drawStroke(canvas, currentStroke!);
    }
  }

  void _drawStroke(Canvas canvas, StrokeModel stroke) {
    if (stroke.points.isEmpty) return;

    final paint = Paint()
      ..color = stroke.color
      ..strokeWidth = stroke.width
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    if (stroke.points.length == 1) {
      final p = stroke.points.first;
      path.moveTo(p.x, p.y);
      path.lineTo(p.x + 0.1, p.y + 0.1);
    } else if (stroke.points.length == 2) {
      path.moveTo(stroke.points.first.x, stroke.points.first.y);
      path.lineTo(stroke.points.last.x, stroke.points.last.y);
    } else {
      path.moveTo(stroke.points.first.x, stroke.points.first.y);
      for (int i = 1; i < stroke.points.length - 1; i++) {
        final p0 = stroke.points[i];
        final p1 = stroke.points[i + 1];
        final midX = (p0.x + p1.x) / 2;
        final midY = (p0.y + p1.y) / 2;
        path.quadraticBezierTo(p0.x, p0.y, midX, midY);
      }
      final last = stroke.points.last;
      path.lineTo(last.x, last.y);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _WhiteboardPainter oldDelegate) => true;
}
