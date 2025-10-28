import 'package:flutter/material.dart';
import '../../data/sleep_mode_models.dart';
import '../../data/sleep_mode_service.dart';

/// Sleep Mode Widget - Thiết kế theo phong cách Phật giáo
/// Màu sắc: Vàng đồng, nâu gỗ, trắng ngà
class SleepModeWidget extends StatefulWidget {
  final SleepModeService sleepModeService;

  const SleepModeWidget({super.key, required this.sleepModeService});

  @override
  State<SleepModeWidget> createState() => _SleepModeWidgetState();
}

class _SleepModeWidgetState extends State<SleepModeWidget> {
  late SleepModeSettings _settings;

  // Phật giáo color palette - Improved contrast
  static const Color _goldenBronze = Color(0xFFE8B75F); // Vàng đồng sáng hơn
  static const Color _darkWood = Color(0xFF3D2F1F); // Nâu gỗ tối hơn cho contrast
  static const Color _lightWood = Color(0xFF6B5742); // Nâu gỗ
  static const Color _ivory = Color(0xFFFFF9E6); // Trắng ngà sáng hơn
  static const Color _lotus = Color(0xFFFFD4D4); // Hồng sen sáng
  static const Color _bamboo = Color(0xFF90B887); // Xanh tre sáng

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
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_darkWood, _lightWood.withOpacity(0.9)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: const AssetImage('assets/images/wood_texture.png'),
              fit: BoxFit.cover,
              opacity: 0.05,
              onError: (_, __) {}, // Graceful fallback if image not found
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header với trang trí sen vàng
                _buildHeader(isActive, service.state),
                const SizedBox(height: 24),

                if (!isActive) ...[
                  // Settings khi chưa bật
                  _buildSettings(),
                  const SizedBox(height: 24),
                  _buildStartButton(),
                ] else ...[
                  // Controls khi đang chạy
                  _buildActiveControls(service),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isActive, SleepModeState state) {
    return Column(
      children: [
        Row(
          children: [
            // Icon sen vàng thay vì nightlight
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _goldenBronze.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Text(
                '🪷', // Lotus emoji
                style: TextStyle(fontSize: 24),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Chế độ ngủ',
                    style: TextStyle(
                      color: _ivory,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    'An lạc tâm thần',
                    style: TextStyle(
                      color: _goldenBronze.withOpacity(0.9),
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            if (isActive) _buildStatusChip(state),
          ],
        ),
        // Divider trang trí
        Container(
          margin: const EdgeInsets.only(top: 16),
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                _goldenBronze.withOpacity(0.5),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(SleepModeState state) {
    String label;
    String emoji;
    Color color;

    switch (state) {
      case SleepModeState.preparing:
        label = 'Chuẩn bị';
        emoji = '🕉️';
        color = _goldenBronze;
        break;
      case SleepModeState.playing:
        label = 'Đang phát';
        emoji = '🧘';
        color = _bamboo;
        break;
      case SleepModeState.fadingOut:
        label = 'Giảm âm';
        emoji = '🌙';
        color = _lotus;
        break;
      case SleepModeState.ringingBell:
        label = 'Chuông';
        emoji = '🔔';
        color = _goldenBronze;
        break;
      default:
        label = 'Dừng';
        emoji = '✨';
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.5), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: _ivory,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timer slider với thiết kế sen
        _buildTimerSlider(),
        const SizedBox(height: 20),

        // Fade out toggle
        _buildToggle(
          'Giảm âm lượng dần',
          '🌅',
          _settings.fadeOut,
          (value) => setState(() {
            _settings = _settings.copyWith(fadeOut: value);
          }),
        ),
        const SizedBox(height: 16),

        // Gentle bell toggle
        _buildToggle(
          'Chuông nhẹ khi kết thúc',
          '🔔',
          _settings.gentleBell,
          (value) => setState(() {
            _settings = _settings.copyWith(gentleBell: value);
          }),
        ),
        const SizedBox(height: 20),

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
            Row(
              children: [
                Text('⏱️', style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
              Text(
                'Thời gian',
                style: TextStyle(
                  color: _ivory,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: _goldenBronze.withOpacity(0.25),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _goldenBronze.withOpacity(0.6),
                  width: 1.5,
                ),
              ),
              child: Text(
                '${_settings.autoStopMinutes} phút',
                style: TextStyle(
                  color: _ivory,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: _goldenBronze,
            inactiveTrackColor: _goldenBronze.withOpacity(0.2),
            thumbColor: _ivory,
            overlayColor: _goldenBronze.withOpacity(0.2),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
          ),
          child: Slider(
            value: _settings.autoStopMinutes.toDouble(),
            min: 5,
            max: 120,
            divisions: 23,
            onChanged: (value) {
              setState(() {
                _settings = _settings.copyWith(autoStopMinutes: value.toInt());
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildToggle(
    String label,
    String emoji,
    bool value,
    Function(bool) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: value
            ? _goldenBronze.withOpacity(0.15)
            : _darkWood.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value ? _goldenBronze.withOpacity(0.6) : _lightWood.withOpacity(0.3),
          width: value ? 2 : 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: _ivory,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            ],
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: _goldenBronze,
            activeTrackColor: _goldenBronze.withOpacity(0.5),
            inactiveThumbColor: _ivory.withOpacity(0.5),
            inactiveTrackColor: _darkWood.withOpacity(0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundSoundSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
          Row(
            children: [
              Text('🎵', style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
            Text(
              'Âm thanh nền',
              style: TextStyle(
                color: _ivory,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            ],
          ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
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
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          colors: [
                            _goldenBronze.withOpacity(0.3),
                            _goldenBronze.withOpacity(0.1),
                          ],
                        )
                      : null,
                  color: isSelected ? null : _darkWood.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? _goldenBronze : _ivory.withOpacity(0.1),
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: _goldenBronze.withOpacity(0.3),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _getSoundEmoji(sound),
                      style: TextStyle(
                        fontSize: 18,
                        shadows: isSelected
                            ? [
                                Shadow(
                                  color: _goldenBronze.withOpacity(0.5),
                                  blurRadius: 4,
                                ),
                              ]
                            : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _getSoundLabel(sound),
                      style: TextStyle(
                        color: isSelected
                            ? _goldenBronze
                            : _ivory.withOpacity(0.95),
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w600,
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

  Widget _buildStartButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_goldenBronze, _goldenBronze.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _goldenBronze.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            widget.sleepModeService.start(_settings);
          },
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('🪷', style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 12),
                Text(
                  'Bắt đầu chế độ ngủ',
                  style: TextStyle(
                    color: _ivory,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActiveControls(SleepModeService service) {
    final remainingMinutes = service.remainingSeconds ~/ 60;
    final remainingSeconds = service.remainingSeconds % 60;
    final progress =
        service.remainingSeconds / (service.settings.autoStopMinutes * 60);

    return Column(
      children: [
        // Countdown timer với thiết kế mandala
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                _goldenBronze.withOpacity(0.3),
                _darkWood.withOpacity(0.1),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: _goldenBronze.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Progress circle
              SizedBox(
                width: 140,
                height: 140,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 6,
                  backgroundColor: _darkWood.withOpacity(0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(_goldenBronze),
                ),
              ),
              // Time display
              Column(
                children: [
                  Text('🕉️', style: const TextStyle(fontSize: 28)),
                  const SizedBox(height: 8),
                  Text(
                    '${remainingMinutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      color: _ivory,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  Text(
                    'phút',
                    style: TextStyle(
                      color: _goldenBronze,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // Volume indicator
        if (service.currentVolume < 1.0) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('🔉', style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Text(
                'Âm lượng: ${(service.currentVolume * 100).toInt()}%',
                style: TextStyle(
                  color: _ivory.withOpacity(0.9),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],

        // Control button - Dừng
        _buildControlButton(
          icon: '⏹️',
          label: 'Dừng chế độ ngủ',
          onTap: service.stop,
          isDestructive: true,
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required String icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        color: isDestructive
            ? Colors.red.withOpacity(0.2)
            : _darkWood.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDestructive
              ? Colors.red.withOpacity(0.5)
              : _goldenBronze.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(icon, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: isDestructive ? Colors.red.shade300 : _ivory,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getSoundEmoji(BackgroundSound sound) {
    switch (sound) {
      case BackgroundSound.silence:
        return '🤫';
      case BackgroundSound.rain:
        return '🌧️';
      case BackgroundSound.temple:
        return '🛕';
      case BackgroundSound.nature:
        return '🍃';
    }
  }

  String _getSoundLabel(BackgroundSound sound) {
    switch (sound) {
      case BackgroundSound.silence:
        return 'Im lặng';
      case BackgroundSound.rain:
        return 'Tiếng mưa';
      case BackgroundSound.temple:
        return 'Tiếng chuông chùa';
      case BackgroundSound.nature:
        return 'Thiên nhiên';
    }
  }
}
