import 'package:flutter/material.dart';
import '../../data/sleep_mode_models.dart';
import '../../data/sleep_mode_service.dart';

/// Sleep Mode Widget
/// Giao diện điều khiển chế độ ngủ
class SleepModeWidget extends StatefulWidget {
  final SleepModeService sleepModeService;

  const SleepModeWidget({super.key, required this.sleepModeService});

  @override
  State<SleepModeWidget> createState() => _SleepModeWidgetState();
}

class _SleepModeWidgetState extends State<SleepModeWidget> {
  late SleepModeSettings _settings;

  @override
  void initState() {
    super.initState();
    _settings = widget.sleepModeService.settings;
    widget.sleepModeService.addListener(_onServiceUpdate);
  }

  @override
  void dispose() {
    widget.sleepModeService.removeListener(_onServiceUpdate);
    super.dispose();
  }

  void _onServiceUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final service = widget.sleepModeService;
    final isActive = service.state != SleepModeState.inactive;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.indigo.shade900, Colors.purple.shade900],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              const Icon(Icons.nightlight_round, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              const Text(
                'Chế độ ngủ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (isActive) _buildStatusChip(service.state),
            ],
          ),

          const SizedBox(height: 20),

          if (!isActive) ...[
            // Settings khi chưa bật
            _buildSettings(),
            const SizedBox(height: 20),
            _buildStartButton(),
          ] else ...[
            // Controls khi đang chạy
            _buildActiveControls(service),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusChip(SleepModeState state) {
    String label;
    Color color;

    switch (state) {
      case SleepModeState.preparing:
        label = 'Đang chuẩn bị...';
        color = Colors.orange;
        break;
      case SleepModeState.playing:
        label = 'Đang phát';
        color = Colors.green;
        break;
      case SleepModeState.fadingOut:
        label = 'Đang giảm âm';
        color = Colors.blue;
        break;
      case SleepModeState.ringingBell:
        label = 'Chuông kết thúc';
        color = Colors.purple;
        break;
      default:
        label = 'Đã dừng';
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timer slider
        _buildTimerSlider(),
        const SizedBox(height: 16),

        // Fade out toggle
        _buildToggle(
          'Giảm âm lượng dần',
          _settings.fadeOut,
          (value) => setState(() {
            _settings = _settings.copyWith(fadeOut: value);
          }),
        ),
        const SizedBox(height: 12),

        // Gentle bell toggle
        _buildToggle(
          'Chuông nhẹ khi kết thúc',
          _settings.gentleBell,
          (value) => setState(() {
            _settings = _settings.copyWith(gentleBell: value);
          }),
        ),
        const SizedBox(height: 16),

        // Background sound selector
        _buildBackgroundSoundSelector(),
      ],
    );
  }

  Widget _buildTimerSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Thời gian',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            Text(
              '${_settings.autoStopMinutes} phút',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Slider(
          value: _settings.autoStopMinutes.toDouble(),
          min: 5,
          max: 120,
          divisions: 23,
          activeColor: Colors.white,
          inactiveColor: Colors.white24,
          onChanged: (value) {
            setState(() {
              _settings = _settings.copyWith(autoStopMinutes: value.toInt());
            });
          },
        ),
      ],
    );
  }

  Widget _buildToggle(String label, bool value, Function(bool) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.white,
          activeTrackColor: Colors.white38,
        ),
      ],
    );
  }

  Widget _buildBackgroundSoundSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Âm thanh nền',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: BackgroundSound.values.map((sound) {
            final isSelected = _settings.backgroundSound == sound;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _settings = _settings.copyWith(backgroundSound: sound);
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.white12,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? Colors.white : Colors.white24,
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getSoundIcon(sound),
                      color: isSelected
                          ? Colors.indigo.shade900
                          : Colors.white70,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      sound.displayName,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.indigo.shade900
                            : Colors.white,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  IconData _getSoundIcon(BackgroundSound sound) {
    switch (sound) {
      case BackgroundSound.rain:
        return Icons.water_drop;
      case BackgroundSound.temple:
        return Icons.temple_buddhist;
      case BackgroundSound.nature:
        return Icons.nature;
      case BackgroundSound.silence:
        return Icons.volume_off;
    }
  }

  Widget _buildStartButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          widget.sleepModeService.start(_settings);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.indigo.shade900,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bedtime, size: 20),
            SizedBox(width: 8),
            Text(
              'Bắt đầu chế độ ngủ',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveControls(SleepModeService service) {
    return Column(
      children: [
        // Timer display
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white12,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Text(
                _formatTime(service.remainingSeconds),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'còn lại',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Volume control
        if (service.state == SleepModeState.playing ||
            service.state == SleepModeState.fadingOut) ...[
          Row(
            children: [
              const Icon(Icons.volume_down, color: Colors.white70),
              Expanded(
                child: Slider(
                  value: service.currentVolume,
                  min: 0,
                  max: 1,
                  activeColor: Colors.white,
                  inactiveColor: Colors.white24,
                  onChanged: (value) {
                    service.setVolume(value);
                  },
                ),
              ),
              const Icon(Icons.volume_up, color: Colors.white70),
            ],
          ),
          const SizedBox(height: 16),
        ],

        // Time adjustment buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildTimeButton('-5', () => service.reduceTime(5)),
            _buildTimeButton('+5', () => service.addTime(5)),
            _buildTimeButton('+15', () => service.addTime(15)),
          ],
        ),

        const SizedBox(height: 16),

        // Stop button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              service.stop();
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white, width: 2),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.stop_circle_outlined, size: 20),
                SizedBox(width: 8),
                Text(
                  'Dừng chế độ ngủ',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeButton(String label, VoidCallback onPressed) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: Colors.white60),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}
