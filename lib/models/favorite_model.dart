class FavoriteModel {
  final int? id;
  final int userId;
  final String exerciseName;
  final String exerciseType;
  final String muscle;
  final String equipment;
  final String difficulty;
  final String instructions;
  final DateTime addedAt;

  FavoriteModel({
    this.id,
    required this.userId,
    required this.exerciseName,
    required this.exerciseType,
    required this.muscle,
    required this.equipment,
    required this.difficulty,
    required this.instructions,
    required this.addedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'exerciseName': exerciseName,
      'exerciseType': exerciseType,
      'muscle': muscle,
      'equipment': equipment,
      'difficulty': difficulty,
      'instructions': instructions,
      'addedAt': addedAt.millisecondsSinceEpoch,
    };
  }

  factory FavoriteModel.fromMap(Map<String, dynamic> map) {
    return FavoriteModel(
      id: map['id']?.toInt(),
      userId: map['userId']?.toInt() ?? 0,
      exerciseName: map['exerciseName'] ?? '',
      exerciseType: map['exerciseType'] ?? '',
      muscle: map['muscle'] ?? '',
      equipment: map['equipment'] ?? '',
      difficulty: map['difficulty'] ?? '',
      instructions: map['instructions'] ?? '',
      addedAt: DateTime.fromMillisecondsSinceEpoch(map['addedAt'] ?? 0),
    );
  }

  FavoriteModel copyWith({
    int? id,
    int? userId,
    String? exerciseName,
    String? exerciseType,
    String? muscle,
    String? equipment,
    String? difficulty,
    String? instructions,
    DateTime? addedAt,
  }) {
    return FavoriteModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      exerciseName: exerciseName ?? this.exerciseName,
      exerciseType: exerciseType ?? this.exerciseType,
      muscle: muscle ?? this.muscle,
      equipment: equipment ?? this.equipment,
      difficulty: difficulty ?? this.difficulty,
      instructions: instructions ?? this.instructions,
      addedAt: addedAt ?? this.addedAt,
    );
  }
}