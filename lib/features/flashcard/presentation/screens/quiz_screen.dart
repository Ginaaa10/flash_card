import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flash_card_app/features/flashcard/domain/providers/flashcard_provider.dart';
import 'package:flash_card_app/features/settings/domain/providers/app_settings_provider.dart';
import 'package:flash_card_app/shared/models/flashcard_model.dart';
import 'package:flash_card_app/shared/models/stroke_model.dart';
import 'package:flash_card_app/shared/models/point_model.dart';
import 'package:flash_card_app/shared/services/ai_service.dart';

class QuizScreen extends ConsumerStatefulWidget {
  final String? groupId;

  const QuizScreen({super.key, this.groupId});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  String _mode = 'flip';
  List<FlashcardModel> _cards = [];
  int _currentIndex = 0;
  bool _showAnswer = false;
  int? _selectedOption;
  bool _answered = false;
  int _correctCount = 0;
  bool _quizStarted = false;
  bool _quizFinished = false;
  bool _isLoadingOptions = false;
  List<FlashcardModel>? _currentOptions;

  // Draw answer
  final List<StrokeModel> _userStrokes = [];
  StrokeModel? _currentStroke;
  final List<PointModel> _currentPoints = [];
  bool _showCorrectAnswer = false;

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  void _loadCards() {
    final allCards = ref.read(flashcardProvider);
    if (widget.groupId != null && widget.groupId!.isNotEmpty) {
      _cards = allCards.where((c) => c.groupName == widget.groupId).toList();
    } else {
      _cards = List.from(allCards);
    }
    _cards.shuffle(Random());
  }

  void _startQuiz(String mode) {
    setState(() {
      _mode = mode;
      _quizStarted = true;
      _quizFinished = false;
      _currentIndex = 0;
      _showAnswer = false;
      _selectedOption = null;
      _answered = false;
      _correctCount = 0;
      _userStrokes.clear();
      _showCorrectAnswer = false;
      _currentOptions = null;
    });
    _loadOptionsForCurrentCard();
  }

  void _nextCard() {
    if (_currentIndex < _cards.length - 1) {
      setState(() {
        _currentIndex++;
        _showAnswer = false;
        _selectedOption = null;
        _answered = false;
        _userStrokes.clear();
        _showCorrectAnswer = false;
        _currentOptions = null;
      });
      _loadOptionsForCurrentCard();
    } else {
      for (final card in _cards) {
        ref.read(flashcardProvider.notifier).incrementReviewCount(card.id);
      }
      setState(() => _quizFinished = true);
    }
  }

  Future<void> _loadOptionsForCurrentCard() async {
    if (_mode != 'mcq') return;
    final card = _currentCard;
    final text = card.backText ?? card.backRecognizedText;
    if (text == null || text.isEmpty) {
      setState(() {
        _currentOptions = _getLocalOptions();
      });
      return;
    }

    setState(() => _isLoadingOptions = true);

    final aiAnswers = await AiService.generateWrongAnswers(
      question: card.frontText ?? card.frontRecognizedText ?? card.title,
      correctAnswer: text,
      count: 3,
    );

    if (aiAnswers != null && aiAnswers.isNotEmpty) {
      final random = Random();
      final options = <FlashcardModel>[];
      for (final wrong in aiAnswers) {
        options.add(FlashcardModel(
          id: 'wrong_${random.nextInt(999999)}',
          title: 'Wrong',
          frontStrokes: [],
          backStrokes: [],
          backText: wrong,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ));
      }
      options.add(card);
      options.shuffle(random);
      setState(() {
        _currentOptions = options;
        _isLoadingOptions = false;
      });
    } else {
      setState(() {
        _currentOptions = _getLocalOptions();
        _isLoadingOptions = false;
      });
    }
  }

  void _answerCorrect() {
    _correctCount++;
    _nextCard();
  }

  FlashcardModel get _currentCard => _cards[_currentIndex];

  List<FlashcardModel> _getOptions() {
    if (_currentOptions != null) return _currentOptions!;
    return _getLocalOptions();
  }

  List<FlashcardModel> _getLocalOptions() {
    final correctText = _currentCard.backText ?? _currentCard.backRecognizedText;

    if (correctText != null && correctText.isNotEmpty) {
      return _generateTextOptions(correctText);
    }

    final others = _cards.where((c) => c.id != _currentCard.id).toList();
    others.shuffle(Random());
    final count = min(3, others.length);
    final options = others.take(count).toList();
    options.add(_currentCard);
    options.shuffle(Random());
    return options;
  }

  List<FlashcardModel> _generateTextOptions(String correctText) {
    final random = Random();
    final List<String> wrongAnswers = [];

    final words = correctText.split(RegExp(r'\s+'));
    final lowerText = correctText.toLowerCase();

    final List<String> similarWords = [
      'knowledge', 'understanding', 'concept', 'principle', 'theory',
      'method', 'process', 'system', 'structure', 'function',
      'element', 'component', 'feature', 'characteristic', 'property',
      'example', 'instance', 'case', 'situation', 'scenario',
      'analysis', 'evaluation', 'assessment', 'examination', 'investigation',
      'approach', 'technique', 'strategy', 'procedure', 'operation',
      'definition', 'description', 'explanation', 'interpretation', 'application',
      'result', 'outcome', 'effect', 'impact', 'consequence',
      'reason', 'cause', 'source', 'origin', 'basis',
      'purpose', 'goal', 'objective', 'target', 'aim',
      'advantage', 'benefit', 'value', 'importance', 'significance',
      'difference', 'distinction', 'contrast', 'comparison', 'variation',
      'problem', 'issue', 'challenge', 'difficulty', 'obstacle',
      'solution', 'answer', 'response', 'reply', 'reaction',
      'type', 'kind', 'sort', 'category', 'class',
      'pattern', 'model', 'framework', 'format', 'structure',
      'step', 'stage', 'phase', 'period', 'stage',
      'part', 'section', 'segment', 'portion', 'area',
      'level', 'degree', 'extent', 'range', 'scope',
    ];

    for (int i = 0; i < 3; i++) {
      String wrong;
      final strategy = random.nextInt(5);

      switch (strategy) {
        case 0:
          final shuffled = List<String>.from(words)..shuffle(random);
          wrong = shuffled.join(' ');
          if (wrong.toLowerCase() == lowerText) {
            wrong = words.reversed.join(' ');
          }
          break;
        case 1:
          final replacement = similarWords[random.nextInt(similarWords.length)];
          if (words.length > 1) {
            final idx = random.nextInt(words.length);
            final newWords = List<String>.from(words);
            newWords[idx] = replacement;
            wrong = newWords.join(' ');
          } else {
            wrong = replacement;
          }
          break;
        case 2:
          final similar = similarWords[random.nextInt(similarWords.length)];
          final similar2 = similarWords[random.nextInt(similarWords.length)];
          wrong = '$similar $similar2';
          break;
        case 3:
          final newWords = <String>[];
          for (final w in words) {
            if (random.nextBool() && similarWords.isNotEmpty) {
              newWords.add(similarWords[random.nextInt(similarWords.length)]);
            } else {
              newWords.add(w);
            }
          }
          wrong = newWords.join(' ');
          if (wrong.toLowerCase() == lowerText) {
            wrong = words.reversed.join(' ');
          }
          break;
        default:
          wrong = similarWords[random.nextInt(similarWords.length)];
      }

      if (wrong.toLowerCase() != lowerText && !wrongAnswers.contains(wrong)) {
        wrongAnswers.add(wrong);
      } else {
        i--;
      }
    }

    final options = <FlashcardModel>[];
    for (final wrong in wrongAnswers) {
      options.add(FlashcardModel(
        id: 'wrong_${random.nextInt(999999)}',
        title: 'Wrong',
        frontStrokes: [],
        backStrokes: [],
        backText: wrong,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
    }
    options.add(_currentCard);
    options.shuffle(random);
    return options;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (!_quizStarted) {
      return _buildModeSelection(theme);
    }

    if (_quizFinished) {
      return _buildResult(theme);
    }

    return _buildQuizView(theme);
  }

  Widget _buildModeSelection(ThemeData theme) {
    final appBg = ref.watch(appSettingsProvider).appBackgroundImage;

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
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/'),
          ),
          title: const Text('Quiz'),
          centerTitle: true,
        ),
        body: Center(
          child: _cards.isEmpty
              ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.quiz, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'No flashcards to quiz',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create some flashcards first!',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Choose Quiz Mode',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_cards.length} flashcards available',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 48),
                  _buildModeCard(
                    theme,
                    icon: Icons.flip,
                    title: 'Flip Review',
                    subtitle: 'See front → Tap to reveal back',
                    onTap: () => _startQuiz('flip'),
                  ),
                  const SizedBox(height: 16),
                  _buildModeCard(
                    theme,
                    icon: Icons.quiz,
                    title: 'Multiple Choice',
                    subtitle: 'Pick the correct answer',
                    onTap: () => _startQuiz('mcq'),
                  ),
                  const SizedBox(height: 16),
                  _buildModeCard(
                    theme,
                    icon: Icons.draw,
                    title: 'Draw Answer',
                    subtitle: 'Draw what you think the answer is',
                    onTap: () => _startQuiz('draw'),
                  ),
                ],
              ),
        ),
      ),
    );
  }

  Widget _buildModeCard(
    ThemeData theme, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: _cards.isEmpty ? null : onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 320,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 36, color: theme.colorScheme.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizView(ThemeData theme) {
    final appBg = ref.watch(appSettingsProvider).appBackgroundImage;

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
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.go('/'),
        ),
        title: Text(
          '${_currentIndex + 1} / ${_cards.length}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '$_correctCount correct',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: _mode == 'flip'
                    ? _buildFlipMode(theme)
                    : _mode == 'mcq'
                        ? _buildMCQMode(theme)
                        : _buildDrawMode(theme),
              ),
            ),
            _buildBottomBar(theme),
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildFlipMode(ThemeData theme) {
    return GestureDetector(
      onTap: () => setState(() => _showAnswer = !_showAnswer),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _showAnswer ? _buildAnswerCard(theme) : _buildQuestionCard(theme),
      ),
    );
  }

  Widget _buildQuestionCard(ThemeData theme) {
    return Container(
      key: const ValueKey('question'),
      height: 350,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.help_outline,
                    size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Question',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const Spacer(),
                if (_currentCard.title.isNotEmpty)
                  Text(
                    _currentCard.title,
                    style: TextStyle(
                      color: theme.colorScheme.primary.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: _currentCard.frontStrokes.isEmpty
                ? Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _currentCard.frontText ?? _currentCard.frontRecognizedText ?? 'Empty',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(12),
                    child: CustomPaint(
                      painter: QuizCardPainter(
                          strokes: _currentCard.frontStrokes),
                      size: Size.infinite,
                    ),
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            child: Text(
              'Tap to reveal answer',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerCard(ThemeData theme) {
    return Container(
      key: const ValueKey('answer'),
      height: 350,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.lightbulb_outline, size: 18, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'Answer',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _currentCard.backStrokes.isEmpty
                ? Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _currentCard.backText ?? _currentCard.backRecognizedText ?? 'Empty',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(12),
                    child: CustomPaint(
                      painter: QuizCardPainter(
                          strokes: _currentCard.backStrokes),
                      size: Size.infinite,
                    ),
                  ),
          ),
          if (_currentCard.backRecognizedText != null &&
              _currentCard.backRecognizedText!.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(8),
              child: Text(
                _currentCard.backRecognizedText!,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMCQMode(ThemeData theme) {
    final options = _getOptions();
    return Column(
      children: [
        _buildQuestionCard(theme),
        const SizedBox(height: 20),
        ...options.asMap().entries.map((entry) {
          final idx = entry.key;
          final option = entry.value;
          final isSelected = _selectedOption == idx;
          final isCorrect = option.id == _currentCard.id;

          Color? bgColor;
          Color? borderColor;
          if (_answered) {
            if (isCorrect) {
              bgColor = Colors.green.withOpacity(0.1);
              borderColor = Colors.green;
            } else if (isSelected && !isCorrect) {
              bgColor = Colors.red.withOpacity(0.1);
              borderColor = Colors.red;
            }
          } else if (isSelected) {
            bgColor = theme.colorScheme.primary.withOpacity(0.1);
            borderColor = theme.colorScheme.primary;
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: _answered
                  ? null
                  : () {
                      setState(() {
                        _selectedOption = idx;
                        _answered = true;
                        if (isCorrect) _correctCount++;
                      });
                    },
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: bgColor ?? theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: borderColor ?? Colors.grey.shade200,
                    width: borderColor != null ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _answered && isCorrect
                            ? Colors.green
                            : _answered && isSelected && !isCorrect
                                ? Colors.red
                                : theme.colorScheme.primary.withOpacity(0.1),
                      ),
                      child: Center(
                        child: _answered && isCorrect
                            ? const Icon(Icons.check,
                                size: 16, color: Colors.white)
                            : _answered && isSelected && !isCorrect
                                ? const Icon(Icons.close,
                                    size: 16, color: Colors.white)
                                : Text(
                                    String.fromCharCode(65 + idx),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: option.backStrokes.isNotEmpty
                          ? SizedBox(
                              height: 60,
                              child: CustomPaint(
                                painter: QuizCardPainter(
                                    strokes: option.backStrokes),
                                size: Size.infinite,
                              ),
                            )
                          : Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.85),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                option.backText ?? option.backRecognizedText ?? option.title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildDrawMode(ThemeData theme) {
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: _currentCard.frontStrokes.isEmpty
              ? Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      _currentCard.frontRecognizedText ?? 'Question',
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                )
              : Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: CustomPaint(
                      painter: QuizCardPainter(
                          strokes: _currentCard.frontStrokes),
                      size: Size.infinite,
                    ),
                  ),
                ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Text(
                'Draw your answer below',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (_userStrokes.isNotEmpty)
                TextButton.icon(
                  onPressed: () => setState(() => _userStrokes.clear()),
                  icon: const Icon(Icons.delete_outline, size: 16),
                  label: const Text('Clear'),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onPanStart: _onDrawStart,
          onPanUpdate: _onDrawUpdate,
          onPanEnd: _onDrawEnd,
          child: Container(
            height: 250,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: CustomPaint(
              painter: DrawAnswerPainter(strokes: _userStrokes),
              size: Size.infinite,
            ),
          ),
        ),
        if (_showCorrectAnswer) ...[
          const SizedBox(height: 16),
          Text(
            'Correct answer:',
            style: theme.textTheme.titleSmall?.copyWith(
              color: Colors.green,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: _currentCard.backStrokes.isEmpty
                ? Center(
                    child: Text(
                      _currentCard.backRecognizedText ?? '',
                      style: const TextStyle(fontSize: 20),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(8),
                    child: CustomPaint(
                      painter: QuizCardPainter(
                          strokes: _currentCard.backStrokes),
                      size: Size.infinite,
                    ),
                  ),
          ),
        ],
      ],
    );
  }

  Widget _buildBottomBar(ThemeData theme) {
    if (_mode == 'flip') {
      return Container(
        padding: const EdgeInsets.all(16),
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
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _answerCorrect(),
                icon: const Icon(Icons.check, color: Colors.green),
                label: const Text('Got it',
                    style: TextStyle(color: Colors.green)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.green),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _nextCard(),
                icon: const Icon(Icons.skip_next),
                label: const Text('Skip'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_mode == 'mcq' && _answered) {
      return Container(
        padding: const EdgeInsets.all(16),
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
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _nextCard,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: Text(
              _currentIndex < _cards.length - 1 ? 'Next' : 'See Results',
            ),
          ),
        ),
      );
    }

    if (_mode == 'draw') {
      return Container(
        padding: const EdgeInsets.all(16),
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
          children: [
            if (!_showCorrectAnswer)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () =>
                      setState(() => _showCorrectAnswer = true),
                  icon: const Icon(Icons.visibility),
                  label: const Text('Show Answer'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            if (!_showCorrectAnswer) const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _nextCard(),
                icon: const Icon(Icons.check),
                label: Text(
                  _currentIndex < _cards.length - 1 ? 'Next' : 'See Results',
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildResult(ThemeData theme) {
    final total = _cards.length;
    final percentage = total > 0 ? (_correctCount / total * 100).round() : 0;
    final appBg = ref.watch(appSettingsProvider).appBackgroundImage;

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
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.go('/'),
        ),
        title: const Text('Quiz Results'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: percentage >= 70
                    ? Colors.green.withOpacity(0.1)
                    : Colors.orange.withOpacity(0.1),
                border: Border.all(
                  color: percentage >= 70 ? Colors.green : Colors.orange,
                  width: 4,
                ),
              ),
              child: Center(
                child: Text(
                  '$percentage%',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: percentage >= 70 ? Colors.green : Colors.orange,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              percentage >= 70 ? 'Great job!' : 'Keep practicing!',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$_correctCount / $total correct',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 48),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _quizStarted = false;
                  _quizFinished = false;
                  _loadCards();
                });
              },
              icon: const Icon(Icons.replay),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.go('/'),
              child: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    ),
    );
  }

  // Drawing handlers
  void _onDrawStart(DragStartDetails details) {
    _currentPoints.clear();
    final point = PointModel(
      x: details.localPosition.dx,
      y: details.localPosition.dy,
      time: DateTime.now().millisecondsSinceEpoch.toDouble(),
    );
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

  void _onDrawUpdate(DragUpdateDetails details) {
    final point = PointModel(
      x: details.localPosition.dx,
      y: details.localPosition.dy,
      time: DateTime.now().millisecondsSinceEpoch.toDouble(),
    );
    _currentPoints.add(point);
    setState(() {
      _currentStroke = StrokeModel(
        id: _currentStroke!.id,
        points: _currentPoints.toList(),
        color: Colors.black,
        width: 3.0,
        timestamp: _currentStroke!.timestamp,
      );
    });
  }

  void _onDrawEnd(DragEndDetails details) {
    if (_currentStroke != null) {
      setState(() {
        _userStrokes.add(_currentStroke!);
        _currentStroke = null;
      });
    }
  }
}

class QuizCardPainter extends CustomPainter {
  final List<StrokeModel> strokes;

  QuizCardPainter({required this.strokes});

  @override
  void paint(Canvas canvas, Size size) {
    if (strokes.isEmpty) return;

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
    final scaleY =
        contentHeight > 0 ? (size.height - 16) / contentHeight : 1.0;
    final scale = scaleX < scaleY ? scaleX : scaleY;

    final offsetX = (size.width - contentWidth * scale) / 2 - minX * scale;
    final offsetY = (size.height - contentHeight * scale) / 2 - minY * scale;

    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

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
  bool shouldRepaint(covariant QuizCardPainter oldDelegate) => true;
}

class DrawAnswerPainter extends CustomPainter {
  final List<StrokeModel> strokes;

  DrawAnswerPainter({required this.strokes});

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = Colors.white;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    for (final stroke in strokes) {
      if (stroke.points.isEmpty) continue;

      final paint = Paint()
        ..color = stroke.color
        ..strokeWidth = stroke.width
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      final path = Path();
      final first = stroke.points.first;
      path.moveTo(first.x, first.y);
      for (int i = 1; i < stroke.points.length; i++) {
        final p = stroke.points[i];
        path.lineTo(p.x, p.y);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant DrawAnswerPainter oldDelegate) => true;
}
