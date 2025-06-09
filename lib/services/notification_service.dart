import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();
  
  static NotificationService get instance => _instance;
  
  static bool _isInitialized = false;
  static BuildContext? _context;

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      _isInitialized = true;
      
      if (kDebugMode) {
        debugPrint('✅ Mock notification service initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to initialize notifications: $e');
      }
    }
  }

  // Set context for showing snackbars
  static void setContext(BuildContext context) {
    _context = context;
  }

  void _showMockNotification({
    required String title,
    required String body,
    String? payload,
  }) {
    if (_context != null) {
      ScaffoldMessenger.of(_context!).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(body),
            ],
          ),
          backgroundColor: Colors.blue[600],
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
    
    if (kDebugMode) {
      debugPrint('🔔 Notification: $title - $body');
    }
  }

  Future<void> showExerciseCompleted(String exerciseName) async {
    const List<String> motivationalMessages = [
      '🎉 Great job! Keep up the momentum!',
      '💪 You\'re getting stronger!',
      '🌟 Another step towards your goals!',
      '🔥 You\'re on fire today!',
      '✨ Awesome work! Stay consistent!',
    ];

    final message = motivationalMessages[
        DateTime.now().millisecond % motivationalMessages.length
    ];

    _showMockNotification(
      title: 'Exercise Completed! 🏋️‍♂️',
      body: '$exerciseName - $message',
      payload: 'exercise_completed_$exerciseName',
    );
  }

  Future<void> showWorkoutReminder() async {
    _showMockNotification(
      title: 'Workout Time! ⏰',
      body: 'Don\'t forget your fitness routine today. Your body will thank you!',
      payload: 'workout_reminder',
    );
  }

  Future<void> showFavoriteAdded(String exerciseName) async {
    _showMockNotification(
      title: 'Added to Favorites! ❤️',
      body: '$exerciseName is now in your favorites list',
      payload: 'favorite_added_$exerciseName',
    );
  }

  Future<void> showMilestoneNotification(int exerciseCount) async {
    String message;
    String emoji;

    if (exerciseCount == 1) {
      message = 'First exercise completed! Great start!';
      emoji = '🌱';
    } else if (exerciseCount == 5) {
      message = '5 exercises done! You\'re building momentum!';
      emoji = '🚀';
    } else if (exerciseCount == 10) {
      message = '10 exercises completed! You\'re on fire!';
      emoji = '🔥';
    } else if (exerciseCount % 25 == 0) {
      message = '$exerciseCount exercises! You\'re a fitness champion!';
      emoji = '🏆';
    } else if (exerciseCount % 10 == 0) {
      message = '$exerciseCount exercises completed! Keep going!';
      emoji = '💪';
    } else {
      return; // No notification for other numbers
    }

    _showMockNotification(
      title: 'Milestone Achieved! $emoji',
      body: message,
      payload: 'milestone_$exerciseCount',
    );
  }
}