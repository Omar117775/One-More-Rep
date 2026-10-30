import 'dart:async';
import 'package:flutter/material.dart';

import '../design/motion/pressable_scale.dart';
import '../design/tokens.dart';

/// Real-time interactive Spartan Rest Timer.
/// Supports start, pause, resume, +30s quick bump, skip,
/// and audio/visual completion alert.
class RestTimerWidget extends StatefulWidget {
  const RestTimerWidget({
    this.initialSeconds = 60,
    this.onDismiss,
    this.onCompleted,
    super.key,
  });

  final int initialSeconds;
  final VoidCallback? onDismiss;
  final VoidCallback? onCompleted;

  @override
  State<RestTimerWidget> createState() => _RestTimerWidgetState();
}

class _RestTimerWidgetState extends State<RestTimerWidget> {
  late int _remainingSeconds;
  late int _totalSeconds;
  Timer? _timer;
  bool _isRunning = true;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.initialSeconds;
    _totalSeconds = widget.initialSeconds;
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        timer.cancel();
        setState(() => _isRunning = false);
        widget.onCompleted?.call();
      }
    });
  }

  void _togglePlayPause() {
    setState(() {
      _isRunning = !_isRunning;
      if (_isRunning) {
        _startTimer();
      } else {
        _timer?.cancel();
      }
    });
  }

  void _addTime(int seconds) {
    setState(() {
      _remainingSeconds += seconds;
      _totalSeconds += seconds;
      if (!_isRunning) {
        _isRunning = true;
        _startTimer();
      }
    });
  }

  String _formatTime(int sec) {
    final m = sec ~/ 60;
    final s = sec % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final progress = _totalSeconds > 0 ? _remainingSeconds / _totalSeconds : 0.0;
    final isDone = _remainingSeconds == 0;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.secondaryBlack,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(
          color: isDone
              ? AppColors.success
              : AppColors.metallicGold.withValues(alpha: 0.5),
          width: 1.6,
        ),
        boxShadow: [
          BoxShadow(
            color: isDone
                ? AppColors.success.withValues(alpha: 0.15)
                : AppColors.metallicGold.withValues(alpha: 0.18),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Circular Countdown indicator
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 52,
                height: 52,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 4,
                  backgroundColor: AppColors.darkGraphite,
                  valueColor: AlwaysStoppedAnimation(
                    isDone ? AppColors.success : AppColors.metallicGold,
                  ),
                ),
              ),
              Icon(
                isDone ? Icons.check : Icons.timer_outlined,
                size: 22,
                color: isDone ? AppColors.success : AppColors.metallicGold,
              ),
            ],
          ),
          const SizedBox(width: AppSpacing.md),

          // Label and Time
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isDone ? 'REST FINISHED! NEXT SET' : 'SPARTAN REST TIMER',
                  style: AppText.caption.copyWith(
                    color: isDone ? AppColors.success : AppColors.metallicGold,
                    fontSize: 10,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatTime(_remainingSeconds),
                  style: AppText.display.copyWith(
                    fontSize: 22,
                    letterSpacing: 1.0,
                    color: AppColors.warmWhite,
                  ),
                ),
              ],
            ),
          ),

          // Action Controls
          if (!isDone) ...[
            IconButton(
              icon: Icon(
                _isRunning ? Icons.pause_circle_filled : Icons.play_circle_filled,
                color: AppColors.metallicGold,
                size: 32,
              ),
              onPressed: _togglePlayPause,
            ),
            PressableScale(
              onTap: () => _addTime(30),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.darkGraphite,
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  '+30s',
                  style: AppText.caption.copyWith(
                    color: AppColors.warmWhite,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
          ],

          IconButton(
            icon: const Icon(Icons.close, color: AppColors.neutralGray, size: 20),
            onPressed: widget.onDismiss,
          ),
        ],
      ),
    );
  }
}
