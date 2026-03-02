import 'package:flutter/material.dart';

class AlermPopup extends StatefulWidget {
  const AlermPopup({super.key});

  @override
  State<AlermPopup> createState() => _AlermPopupState();
}

class _AlermPopupState extends State<AlermPopup> {
  int hour = 3;
  int minute = 50;
  bool isAm = true;

  bool alarmSound = true;
  bool vibrate = true;
  bool snooze = false;

  final List<bool> activeDays = [true, false, true, false, false, true, true];
  final List<String> dayLabels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
  final List<String> dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  static const Color bgColor = Color(0xFF0D0F1A);
  static const Color sheetColor = Color(0xFF161827);
  static const Color accentColor = Color(0xFFD96FE8);
  static const Color dimColor = Color(0xFF3A3D55);
  static const Color subTextColor = Color(0xFF555770);
  static const Color labelColor = Color(0xFF8889A8);

  String get daysLabel {
    final active = <String>[];
    for (int i = 0; i < 7; i++) {
      if (activeDays[i]) active.add(dayNames[i]);
    }
    return active.isEmpty ? 'Never' : active.join(', ');
  }

  int get finalHour24 {
    int finalHour = hour;
    if (!isAm && hour != 12) {
      finalHour += 12;
    } else if (isAm && hour == 12) {
      finalHour = 0;
    }
    return finalHour;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(child: _buildTimePicker()),
            ),
            _buildBottomSheet(),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildScrollColumn(
          value: hour == 0 ? 12 : hour,
          max: 12,
          onChanged: (v) => setState(() => hour = v),
        ),
        const Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: Text(
            ':',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 52,
              color: accentColor,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        _buildScrollColumn(
          value: minute,
          max: 60,
          onChanged: (v) => setState(() => minute = v),
        ),
        const SizedBox(width: 16),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => setState(() => isAm = true),
              child: Text(
                "AM",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isAm ? accentColor : dimColor,
                ),
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => setState(() => isAm = false),
              child: Text(
                "PM",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: !isAm ? accentColor : dimColor,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildScrollColumn({
    required int value,
    required int max,
    required ValueChanged<int> onChanged,
  }) {
    final prev = (value - 1 <= 0) ? max : value - 1;
    final next = (value + 1 > max) ? 1 : value + 1;

    return GestureDetector(
      onVerticalDragEnd: (details) {
        if (details.primaryVelocity! < 0) {
          onChanged(next);
        } else if (details.primaryVelocity! > 0) {
          onChanged(prev);
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => onChanged(prev),
            child: Text(
              prev.toString().padLeft(2, '0'),
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 28,
                color: dimColor,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value.toString().padLeft(2, '0'),
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 52,
              color: accentColor,
              fontWeight: FontWeight.w400,
              shadows: [
                Shadow(color: Color(0x66D96FE8), blurRadius: 20),
              ],
            ),
          ),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () => onChanged(next),
            child: Text(
              next.toString().padLeft(2, '0'),
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 28,
                color: dimColor,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSheet() {
    return Container(
      decoration: const BoxDecoration(
        color: sheetColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            daysLabel,
            style: const TextStyle(color: labelColor, fontSize: 13),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (i) {
              return GestureDetector(
                onTap: () => setState(() => activeDays[i] = !activeDays[i]),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: activeDays[i] ? accentColor : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      dayLabels[i],
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: activeDays[i] ? accentColor : labelColor,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: labelColor, fontSize: 16),
                ),
              ),
              TextButton(
                onPressed: () {
                  debugPrint(
                      "Saved Time: ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} ${isAm ? "AM" : "PM"} (24h: $finalHour24)");
                  Navigator.pop(context);
                },
                child: const Text(
                  'Save',
                  style: TextStyle(color: accentColor, fontSize: 16),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}