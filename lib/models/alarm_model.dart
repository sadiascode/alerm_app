import 'package:cloud_firestore/cloud_firestore.dart';

class AlarmModel {
  final String? id;
  final String time;
  final List<int> activeDays;
  final bool isOn;
  final Timestamp createdAt;

  const AlarmModel({
    this.id,
    required this.time,
    required this.activeDays,
    required this.isOn,
    required this.createdAt,
  });

  factory AlarmModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AlarmModel(
      id: doc.id,
      time: data['time'] ?? '',
      activeDays: List<int>.from(data['activeDays'] ?? []),
      isOn: data['isOn'] ?? true,
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'time': time,
      'activeDays': activeDays,
      'isOn': isOn,
      'createdAt': createdAt,
    };
  }

  AlarmModel copyWith({
    String? id,
    String? time,
    List<int>? activeDays,
    bool? isOn,
    Timestamp? createdAt,
  }) {
    return AlarmModel(
      id: id ?? this.id,
      time: time ?? this.time,
      activeDays: activeDays ?? this.activeDays,
      isOn: isOn ?? this.isOn,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'AlarmModel(id: $id, time: $time, activeDays: $activeDays, isOn: $isOn, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AlarmModel &&
        other.id == id &&
        other.time == time &&
        other.activeDays == activeDays &&
        other.isOn == isOn &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        time.hashCode ^
        activeDays.hashCode ^
        isOn.hashCode ^
        createdAt.hashCode;
  }
}
