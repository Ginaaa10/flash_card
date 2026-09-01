import 'package:flutter/material.dart';
import 'package:flash_card_app/shared/models/question_model.dart';

class QuestionGenerationDialog extends StatefulWidget {
  final String recognizedText;
  final String flashcardId;
  final Future<List<QuestionModel>> Function({
    required String text,
    required String flashcardId,
    required String questionType,
    required int numberOfQuestions,
  }) onGenerateQuestions;

  const QuestionGenerationDialog({
    super.key,
    required this.recognizedText,
    required this.flashcardId,
    required this.onGenerateQuestions,
  });

  @override
  State<QuestionGenerationDialog> createState() => _QuestionGenerationDialogState();
}

class _QuestionGenerationDialogState extends State<QuestionGenerationDialog> {
  String _selectedType = 'essay';
  int _numberOfQuestions = 3;
  bool _isGenerating = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Generate Questions',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              
              Text(
                'Question Type',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              
              _buildTypeSelector(theme),
              const SizedBox(height: 24),
              
              Text(
                'Number of Questions',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              
              _buildNumberSelector(theme),
              const SizedBox(height: 24),
              
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.colorScheme.outline.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Preview Text',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.outline,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.recognizedText.length > 150
                          ? '${widget.recognizedText.substring(0, 150)}...'
                          : widget.recognizedText,
                      style: theme.textTheme.bodySmall,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              _buildActionButtons(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSelector(ThemeData theme) {
    return Column(
      children: [
        _buildTypeOption(
          type: 'essay',
          label: 'Essay Questions',
          description: 'Open-ended questions for deeper understanding',
          theme: theme,
        ),
        const SizedBox(height: 12),
        _buildTypeOption(
          type: 'multiple_choice',
          label: 'Multiple Choice',
          description: 'Questions with 4 options to choose from',
          theme: theme,
        ),
      ],
    );
  }

  Widget _buildTypeOption({
    required String type,
    required String label,
    required String description,
    required ThemeData theme,
  }) {
    final isSelected = _selectedType == type;
    return GestureDetector(
      onTap: () => setState(() => _selectedType = type),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withOpacity(0.1)
              : Colors.transparent,
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Radio<String>(
              value: type,
              groupValue: _selectedType,
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedType = value);
                }
              },
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberSelector(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: Slider(
            value: _numberOfQuestions.toDouble(),
            min: 1,
            max: 10,
            divisions: 9,
            label: '$_numberOfQuestions',
            onChanged: _isGenerating
                ? null
                : (value) => setState(() => _numberOfQuestions = value.toInt()),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$_numberOfQuestions',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: _isGenerating ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: _isGenerating ? null : _generateQuestions,
          icon: _isGenerating
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(
                      theme.colorScheme.onPrimary,
                    ),
                  ),
                )
              : const Icon(Icons.auto_fix_high),
          label: Text(_isGenerating ? 'Generating...' : 'Generate'),
        ),
      ],
    );
  }

  Future<void> _generateQuestions() async {
    setState(() => _isGenerating = true);

    try {
      final questions = await widget.onGenerateQuestions(
        text: widget.recognizedText,
        flashcardId: widget.flashcardId,
        questionType: _selectedType,
        numberOfQuestions: _numberOfQuestions,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Generated $_numberOfQuestions questions'),
            duration: const Duration(seconds: 2),
          ),
        );
        Navigator.pop(context, questions);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }
}
