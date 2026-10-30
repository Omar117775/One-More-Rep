import 'dart:async';
import 'package:flutter/material.dart';

import '../../components/spartan_companion.dart';
import '../../design/tokens.dart';
import '../../localization/app_strings.dart';

/// Recommendation payload delivered inside an AI coach response.
class AiRecommendation {
  const AiRecommendation({
    required this.title,
    required this.subtitle,
    required this.category,
    required this.metric,
  });

  final String title;
  final String subtitle;
  final String category; // 'workout' or 'nutrition'
  final String metric;
}

/// Chat message in the Spartan AI conversation.
class AiMessage {
  const AiMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.recommendation,
  });

  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final AiRecommendation? recommendation;
}

/// Standalone UI for the Spartan AI Trainer / Coach.
/// Interactive mock conversation providing structured regimen advice,
/// quick prompt chips, and recommendation cards.
class AiTrainerScreen extends StatefulWidget {
  const AiTrainerScreen({super.key});

  @override
  State<AiTrainerScreen> createState() => _AiTrainerScreenState();
}

class _AiTrainerScreenState extends State<AiTrainerScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isThinking = false;

  final List<AiMessage> _messages = [
    AiMessage(
      id: 'welcome',
      text:
          'Hail, warrior! I am your Spartan AI Coach. Built on discipline, consistency, and athletic science. How shall we forge your regimen today?',
      isUser: false,
      timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
      recommendation: const AiRecommendation(
        title: 'Spartan Strength Foundation',
        subtitle: '4-day power progression split focusing on compound movements.',
        category: 'workout',
        metric: '4 Sessions / Week',
      ),
    ),
  ];

  static const List<String> _suggestedPrompts = [
    'Recommend a 4-day Spartan split',
    'How do I break through a bench press plateau?',
    'What should my daily protein intake be?',
    'Suggest a high-intensity cardio finisher',
  ];

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: AppDurations.fast,
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  void _sendMessage(String query) {
    final text = query.trim();
    if (text.isEmpty || _isThinking) return;

    _textController.clear();
    setState(() {
      _messages.add(
        AiMessage(
          id: 'user-${DateTime.now().millisecondsSinceEpoch}',
          text: text,
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );
      _isThinking = true;
    });
    _scrollToBottom();

    // Simulated Spartan AI response
    Timer(const Duration(milliseconds: 1100), () {
      if (!mounted) return;
      final response = _generateMockResponse(text);
      setState(() {
        _isThinking = false;
        _messages.add(response);
      });
      _scrollToBottom();
    });
  }

  AiMessage _generateMockResponse(String query) {
    final q = query.toLowerCase();
    if (q.contains('split') || q.contains('program') || q.contains('workout')) {
      return AiMessage(
        id: 'ai-${DateTime.now().millisecondsSinceEpoch}',
        text:
            'A true Spartan splits strength into relentless progressive phases. Here is your targeted recommendation:',
        isUser: false,
        timestamp: DateTime.now(),
        recommendation: const AiRecommendation(
          title: 'Hypertrophy & Heavy Compounds',
          subtitle: 'Upper Push, Upper Pull, Heavy Legs, and Spartan Conditioning.',
          category: 'workout',
          metric: 'Volume: 18-22 sets/session',
        ),
      );
    }
    if (q.contains('protein') || q.contains('nutrition') || q.contains('meal')) {
      return AiMessage(
        id: 'ai-${DateTime.now().millisecondsSinceEpoch}',
        text:
            'Fuel is armor. To sustain Spartan density and repair torn muscle fibers, target 2.0g per kilogram of lean mass daily with adequate hydration.',
        isUser: false,
        timestamp: DateTime.now(),
        recommendation: const AiRecommendation(
          title: 'Optimal Daily Protein',
          subtitle: 'Spread evenly across 4 meals (35-45g per feeding window).',
          category: 'nutrition',
          metric: 'Target: 160g - 180g / day',
        ),
      );
    }
    return AiMessage(
      id: 'ai-${DateTime.now().millisecondsSinceEpoch}',
      text:
          'Discipline yields results where motivation fades. Keep clean form, lock in the mind-muscle connection, and never compromise on rest periods. Ready for your next set?',
      isUser: false,
      timestamp: DateTime.now(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    return Scaffold(
      backgroundColor: AppColors.deepBlack,
      appBar: AppBar(
        title: Row(
          children: [
            const SpartanCompanion(state: SpartanState.aiActive, size: 36),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    strings.aiTrainerTitle,
                    style: AppText.title.copyWith(fontSize: 15),
                  ),
                  Text(
                    'Disciplined AI Guidance',
                    style: AppText.caption.copyWith(
                      color: AppColors.metallicGold,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppBreakpoints.contentMax,
            ),
            child: Column(
              children: [
                // Quick Suggestion Chips
                Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    itemCount: _suggestedPrompts.length,
                    separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final prompt = _suggestedPrompts[index];
                      return ActionChip(
                        backgroundColor: AppColors.secondaryBlack,
                        side: const BorderSide(color: AppColors.border),
                        label: Text(
                          prompt,
                          style: AppText.secondary.copyWith(
                            fontSize: 11.5,
                            color: AppColors.warmWhite,
                          ),
                        ),
                        onPressed: () => _sendMessage(prompt),
                      );
                    },
                  ),
                ),
                const Divider(height: 1, color: AppColors.border),

                // Chat Messages List
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      return _MessageBubble(message: msg);
                    },
                  ),
                ),

                // Thinking Indicator
                if (_isThinking)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.xs,
                    ),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.metallicGold,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          strings.aiThinking,
                          style: AppText.caption.copyWith(
                            color: AppColors.metallicGold,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Bottom Input Field
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.secondaryBlack,
                    border: Border(top: BorderSide(color: AppColors.border)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          style: AppText.body,
                          textInputAction: TextInputAction.send,
                          onSubmitted: _sendMessage,
                          decoration: InputDecoration(
                            hintText: strings.aiTrainerHint,
                            hintStyle: AppText.secondary.copyWith(fontSize: 13),
                            filled: true,
                            fillColor: AppColors.darkGraphite,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.sm,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppRadii.pill),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      IconButton(
                        onPressed: () => _sendMessage(_textController.text),
                        icon: const Icon(Icons.send_rounded, color: AppColors.metallicGold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final AiMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isUser) ...[
                const SpartanCompanion(state: SpartanState.aiActive, size: 22),
                const SizedBox(width: 6),
                Text(
                  'SPARTAN COACH',
                  style: AppText.caption.copyWith(
                    color: AppColors.metallicGold,
                    fontSize: 9.5,
                  ),
                ),
              ] else ...[
                Text(
                  'YOU',
                  style: AppText.caption.copyWith(
                    color: AppColors.neutralGray,
                    fontSize: 9.5,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Container(
            constraints: const BoxConstraints(maxWidth: 480),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: isUser ? AppColors.darkGraphite : AppColors.secondaryBlack,
              borderRadius: BorderRadius.circular(AppRadii.md),
              border: Border.all(
                color: isUser
                    ? AppColors.border
                    : AppColors.metallicGold.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              message.text,
              style: AppText.body.copyWith(
                height: 1.45,
                color: AppColors.warmWhite,
              ),
            ),
          ),
          if (message.recommendation != null) ...[
            const SizedBox(height: AppSpacing.sm),
            _RecommendationCard(rec: message.recommendation!),
          ],
        ],
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({required this.rec});

  final AiRecommendation rec;

  @override
  Widget build(BuildContext context) {
    final isWorkout = rec.category == 'workout';

    return Container(
      constraints: const BoxConstraints(maxWidth: 480),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.metallicGold.withValues(alpha: 0.45)),
        boxShadow: [
          BoxShadow(
            color: AppColors.metallicGold.withValues(alpha: 0.12),
            blurRadius: 18,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isWorkout ? Icons.fitness_center : Icons.restaurant_menu,
                color: AppColors.metallicGold,
                size: 18,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  isWorkout ? 'WORKOUT REGIMEN' : 'NUTRITION TARGET',
                  style: AppText.caption.copyWith(
                    color: AppColors.metallicGold,
                    fontSize: 10,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.metallicGold.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
                child: Text(
                  rec.metric,
                  style: AppText.caption.copyWith(
                    color: AppColors.metallicGold,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(rec.title, style: AppText.title.copyWith(fontSize: 15)),
          const SizedBox(height: 2),
          Text(rec.subtitle, style: AppText.secondary.copyWith(fontSize: 12)),
        ],
      ),
    );
  }
}
