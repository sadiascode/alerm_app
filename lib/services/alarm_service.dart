import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/alarm_model.dart';
import 'notification_services.dart';

class AlarmService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final NotificationServices _notificationServices = NotificationServices();

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
        await _notificationServices.scheduleAlarm(alarm);
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
      
      // Reschedule alarm if time, activeDays, or isOn changed
      if (time != null || activeDays != null || isOn != null) {
        final alarm = await getAlarm(alarmId);
        if (alarm != null && alarm.isOn) {
          await _notificationServices.scheduleAlarm(alarm);
          debugPrint('Alarm rescheduled after update: $alarmId');
        }
      }
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
          await _notificationServices.scheduleAlarm(alarm);
        }
      } else {
        await _notificationServices.cancelAlarm(alarmId);
      }
    } catch (e) {
      throw Exception('Failed to toggle alarm: $e');
    }
  }

  Future<void> deleteAlarm(String alarmId) async {
    try {

      await _notificationServices.cancelAlarm(alarmId);
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

  Future<void> deleteAllAlarms() async {
    try {
      // Get all alarms
      final snapshot = await _alarmsCollection.get();
      print('Found ${snapshot.docs.length} alarms to delete');
      
      if (snapshot.docs.isEmpty) {
        print('No alarms to delete');
        return;
      }
      
      // Cancel all notifications first
      await _notificationServices.cancelAllAlarms();
      print('All notifications cancelled');
      
      // Use batch delete for all documents at once
      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        print('Adding to batch: ${doc.id}');
        batch.delete(doc.reference);
      }
      
      // Commit all deletions at once
      await batch.commit();
      print('All alarms deleted successfully via batch');
      
    } catch (e) {
      print('Error deleting all alarms: $e');
      throw Exception('Failed to delete all alarms: $e');
    }
  }
}
