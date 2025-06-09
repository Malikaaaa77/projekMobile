class ExerciseModel {
  final String id; // Add this missing property
  final String name;
  final List<String> targetMuscles;
  final List<String> secondaryMuscles;
  final List<String> bodyParts;
  final List<String> equipments;
  final String gifUrl;
  final List<String> instructions;

  ExerciseModel({
    required this.id, // Add this
    required this.name,
    required this.targetMuscles,
    required this.secondaryMuscles,
    required this.bodyParts,
    required this.equipments,
    required this.gifUrl,
    required this.instructions,
  });
  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseModel(
      id: json['exerciseId']?.toString() ?? json['id']?.toString() ?? '', // Handle both exerciseId and id
      name: json['name'] ?? '',
      targetMuscles: _parseStringList(json['targetMuscles'] ?? json['target']),
      secondaryMuscles: _parseStringList(json['secondaryMuscles']),
      bodyParts: _parseStringList(json['bodyParts'] ?? json['bodyPart']),
      equipments: _parseStringList(json['equipments'] ?? json['equipment']),
      gifUrl: json['gifUrl'] ?? '',
      instructions: _parseStringList(json['instructions']),
    );
  }

  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    if (value is String) {
      return [value];
    }
    return [];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id, // Add this
      'name': name,
      'target': targetMuscles,
      'secondaryMuscles': secondaryMuscles,
      'bodyPart': bodyParts,
      'equipment': equipments,
      'gifUrl': gifUrl,
      'instructions': instructions,
    };
  }

  @override
  String toString() {
    return 'ExerciseModel(id: $id, name: $name, targetMuscles: $targetMuscles)';
  }
}