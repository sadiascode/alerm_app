import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/alarm_model.dart';
import 'notification_service.dart';

class AlarmService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final NotificationService _notificationService = NotificationService();

  CollectionReference<Map<String, dynamic>> get _alarmsCollection {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }
    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('alarms');
  }

  Future<String> createAlarm({
    required String time,
    required List<int> activeDays,
    bool isOn = true,
  }) async {
    try {
      final alarmData = AlarmModel(
        time: time,
        activeDays: activeDays,
        isOn: isOn,
        createdAt: Timestamp.now(),
      );

      final docRef = await _alarmsCollection.add(alarmData.toFirestore());
      

      if (isOn) {
        final alarm = alarmData.copyWith(id: docRef.id);
        await _notificationService.scheduleAlarm(alarm);
      }
      
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create alarm: $e');
    }
  }

  Stream<List<AlarmModel>> getAlarms() {
    try {
      return _alarmsCollection
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => AlarmModel.fromFirestore(doc))
            .toList();
      });
    } catch (e) {
      throw Exception('Failed to get alarms: $e');
    }
  }

  Future<void> updateAlarm({
    required String alarmId,
    String? time,
    List<int>? activeDays,
    bool? isOn,
  }) async {
    try {
      final updates = <String, dynamic>{};
      
      if (time != null) updates['time'] = time;
      if (activeDays != null) updates['activeDays'] = activeDays;
      if (isOn != null) updates['isOn'] = isOn;

      await _alarmsCollection.doc(alarmId).update(updates);
    } catch (e) {
      throw Exception('Failed to update alarm: $e');
    }
  }

  Future<void> toggleAlarm(String alarmId, bool isOn) async {
    try {
      await _alarmsCollection.doc(alarmId).update({'isOn': isOn});
      

      if (isOn) {
        final alarm = await getAlarm(alarmId);
        if (alarm != null) {
          await _notificationService.scheduleAlarm(alarm);
        }
      } else {
        await _notificationService.cancelAlarm(alarmId);
      }
    } catch (e) {
      throw Exception('Failed to toggle alarm: $e');
    }
  }

  Future<void> deleteAlarm(String alarmId) async {
    try {

      await _notificationService.cancelAlarm(alarmId);
      await _alarmsCollection.doc(alarmId).delete();
    } catch (e) {
      throw Exception('Failed to delete alarm: $e');
    }
  }

  Future<AlarmModel?> getAlarm(String alarmId) async {
    try {
      final doc = await _alarmsCollection.doc(alarmId).get();
      if (doc.exists) {
        return AlarmModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get alarm: $e');
    }
  }
}
