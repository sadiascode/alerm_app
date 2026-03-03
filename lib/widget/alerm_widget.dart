import 'package:alerm/widget/alerm_popup.dart';
import 'package:flutter/material.dart';
import '../../services/alarm_service.dart';
import '../../models/alarm_model.dart';

class AlermWidget extends StatefulWidget {
  final AlarmModel alarm;
  
  const AlermWidget({super.key, required this.alarm});

  @override
  State<AlermWidget> createState() => _AlermWidgetState();
}

class _AlermWidgetState extends State<AlermWidget>
    with SingleTickerProviderStateMixin {
  final AlarmService _alarmService = AlarmService();
  
  bool _isOn = true;
  double _dragX = 0;
  bool _isDragging = false;

  static const double _trackWidth = 52.0;
  static const double _thumbSize = 24.0;
  static const double _maxDrag = _trackWidth - _thumbSize - 4;

  late AnimationController _animController;
  late Animation<double> _thumbAnim;

  final List<String> _days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  @override
  void initState() {
    super.initState();
    _isOn = widget.alarm.isOn;
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
      value: _isOn ? 1.0 : 0.0,
    );
    _thumbAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _toggle() async {
    setState(() => _isOn = !_isOn);
    if (_isOn) {
      _animController.forward();
    } else {
      _animController.reverse();
    }

    try {
      await _alarmService.toggleAlarm(widget.alarm.id!, _isOn);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to toggle alarm: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isOn = !_isOn);
        if (_isOn) {
          _animController.forward();
        } else {
          _animController.reverse();
        }
      }
    }
  }

  void _deleteAlarm() async {
    try {
      await _alarmService.deleteAlarm(widget.alarm.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Alarm deleted successfully'),
            backgroundColor: Color(0xFFD96FE8),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete alarm: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _onDragStart(DragStartDetails d) {
    setState(() => _isDragging = true);
  }

  void _onDragUpdate(DragUpdateDetails d) {
    setState(() {
      _dragX += d.delta.dx;
      _dragX = _dragX.clamp(-_maxDrag, _maxDrag);
    });
  }

  void _onDragEnd(DragEndDetails d) {
    final threshold = _maxDrag / 2;
    bool newState;
    if (_dragX > threshold) {
      newState = true;
    } else if (_dragX < -threshold) {
      newState = false;
    } else {
      newState = _isOn;
    }
    setState(() {
      _isDragging = false;
      _dragX = 0;
      _isOn = newState;
    });
    if (_isOn) {
      _animController.forward();
    } else {
      _animController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF252542),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onLongPress: _deleteAlarm,
              child: Text(
                widget.alarm.time,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w300,
                  color: _isOn ? Colors.white : Colors.white38,
                  letterSpacing: 1.5,
                ),
              ),
            ),
      
      
            Row(
              children: List.generate(_days.length, (i) {
                final isActive = widget.alarm.activeDays.contains(i);
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Text(
                    _days[i],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                      isActive ? FontWeight.w600 : FontWeight.w400,
                      color: isActive
                          ? const Color(0xFFB8A4E8)
                          : Colors.white24,
                      letterSpacing: 0.5,
                    ),
                  ),
                );
              }),
            ),
      
      
            GestureDetector(
              onTap: _toggle,
              onHorizontalDragStart: _onDragStart,
              onHorizontalDragUpdate: _onDragUpdate,
              onHorizontalDragEnd: _onDragEnd,
              child: AnimatedBuilder(
                animation: _thumbAnim,
                builder: (context, _) {
                  final t = _isDragging
                      ? ((_dragX / _maxDrag).clamp(-1.0, 1.0) * 0.5 + 0.5)
                      .clamp(0.0, 1.0)
                      : _thumbAnim.value;
      
                  final trackColor = Color.lerp(
                    Colors.white12,
                    const Color(0xFFB47FE8),
                    t,
                  )!;
      
                  final thumbOffset =
                  _isDragging ? _dragX : (_maxDrag * _thumbAnim.value);
      
                  return Container(
                    width: _trackWidth,
                    height: 30,
                    decoration: BoxDecoration(
                      color: trackColor,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        AnimatedContainer(
                          duration: _isDragging
                              ? Duration.zero
                              : const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                          margin: EdgeInsets.only(
                            left: 3 + thumbOffset.clamp(0.0, _maxDrag),
                          ),
                          width: _thumbSize,
                          height: _thumbSize,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
    );
  }
}