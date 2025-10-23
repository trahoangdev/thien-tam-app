import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../core/config.dart';

class TTSRequest {
  final String text;
  final String? voiceId;
  final String? modelId;
  final TTSVoiceSettings? voiceSettings;

  TTSRequest({
    required this.text,
    this.voiceId,
    this.modelId,
    this.voiceSettings,
  });

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      if (voiceId != null) 'voiceId': voiceId,
      if (modelId != null) 'modelId': modelId,
      if (voiceSettings != null) 'voiceSettings': voiceSettings!.toJson(),
    };
  }
}

class TTSVoiceSettings {
  final double? stability;
  final double? similarityBoost;
  final double? style;
  final bool? useSpeakerBoost;

  TTSVoiceSettings({
    this.stability,
    this.similarityBoost,
    this.style,
    this.useSpeakerBoost,
  });

  Map<String, dynamic> toJson() {
    return {
      if (stability != null) 'stability': stability,
      if (similarityBoost != null) 'similarityBoost': similarityBoost,
      if (style != null) 'style': style,
      if (useSpeakerBoost != null) 'useSpeakerBoost': useSpeakerBoost,
    };
  }
}

class TTSVoice {
  final String voiceId;
  final String name;
  final String category;
  final String description;
  final Map<String, dynamic> labels;

  TTSVoice({
    required this.voiceId,
    required this.name,
    required this.category,
    required this.description,
    required this.labels,
  });

  factory TTSVoice.fromJson(Map<String, dynamic> json) {
    return TTSVoice(
      voiceId: json['voice_id'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      labels: Map<String, dynamic>.from(json['labels'] ?? {}),
    );
  }
}

class TTSModel {
  final String modelId;
  final String name;
  final String description;
  final bool canBeFinetuned;
  final bool canDoTextToSpeech;
  final bool canDoVoiceConversion;
  final List<String> languages;

  TTSModel({
    required this.modelId,
    required this.name,
    required this.description,
    required this.canBeFinetuned,
    required this.canDoTextToSpeech,
    required this.canDoVoiceConversion,
    required this.languages,
  });

  factory TTSModel.fromJson(Map<String, dynamic> json) {
    return TTSModel(
      modelId: json['model_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      canBeFinetuned: json['can_be_finetuned'] ?? false,
      canDoTextToSpeech: json['can_do_text_to_speech'] ?? false,
      canDoVoiceConversion: json['can_do_voice_conversion'] ?? false,
      languages: List<String>.from(json['languages'] ?? []),
    );
  }
}

class TTSService {
  static final TTSService _instance = TTSService._internal();
  factory TTSService() => _instance;
  TTSService._internal();

  // Vietnamese voice - thuần Việt với phát âm chuẩn
  static const Map<String, String> vietnameseVoices = {
    'vietnamese':
        'DXiwi9uoxet6zAiZXynP', // Voice thuần Việt - phát âm chuẩn, có accent tiếng Việt
  };

  static const String defaultVietnameseVoice =
      'vietnamese'; // Voice thuần Việt - phát âm chuẩn

  // Default Vietnamese voice settings optimized for Buddhist content
  static TTSVoiceSettings get defaultVietnameseSettings => TTSVoiceSettings(
    stability: 0.6, // Stable voice for Buddhist readings
    similarityBoost: 0.7, // Clear pronunciation
    style: 0.0,
    useSpeakerBoost: true,
  );

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60),
    ),
  );

  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentAudioPath;
  bool _isPlaying = false;
  bool _isPaused = false;

  // Callback for audio completion
  Function()? _onAudioComplete;

  // Getters for audio state
  bool get isPlaying => _isPlaying;
  bool get isPaused => _isPaused;
  String? get currentAudioPath => _currentAudioPath;

  // Initialize audio player
  Future<void> initialize() async {
    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      _isPlaying = state == PlayerState.playing;
      _isPaused = state == PlayerState.paused;
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      _isPlaying = false;
      _isPaused = false;
      _currentAudioPath = null;

      // Call completion callback if set
      _onAudioComplete?.call();
    });
  }

  // Set callback for audio completion
  void setOnAudioComplete(Function()? callback) {
    _onAudioComplete = callback;
  }

  // Convert text to speech
  Future<String?> textToSpeech(TTSRequest request) async {
    try {
      final response = await _dio.post(
        '/tts/text-to-speech',
        data: request.toJson(),
        options: Options(
          responseType: ResponseType.bytes,
          headers: {'Accept': 'audio/mpeg'},
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        // Save audio to temporary file
        final tempDir = await getTemporaryDirectory();
        final fileName = 'tts_${DateTime.now().millisecondsSinceEpoch}.mp3';
        final filePath = '${tempDir.path}/$fileName';

        final file = File(filePath);
        await file.writeAsBytes(response.data as Uint8List);

        return filePath;
      }

      return null;
    } catch (e) {
      print('TTS Error: $e');
      return null;
    }
  }

  // Play audio from file path
  Future<bool> playAudio(String filePath) async {
    try {
      await _audioPlayer.play(DeviceFileSource(filePath));
      _currentAudioPath = filePath;
      return true;
    } catch (e) {
      print('Play audio error: $e');
      return false;
    }
  }

  // Pause audio
  Future<void> pauseAudio() async {
    try {
      await _audioPlayer.pause();
    } catch (e) {
      print('Pause audio error: $e');
    }
  }

  // Resume audio
  Future<void> resumeAudio() async {
    try {
      await _audioPlayer.resume();
    } catch (e) {
      print('Resume audio error: $e');
    }
  }

  // Stop audio
  Future<void> stopAudio() async {
    try {
      await _audioPlayer.stop();
      _isPlaying = false;
      _isPaused = false;
      _currentAudioPath = null;
    } catch (e) {
      print('Stop audio error: $e');
    }
  }

  // Get available voices
  Future<List<TTSVoice>> getVoices() async {
    try {
      final response = await _dio.get('/tts/voices');

      if (response.statusCode == 200) {
        final voices = (response.data['voices'] as List)
            .map((voice) => TTSVoice.fromJson(voice))
            .toList();
        return voices;
      }

      return [];
    } catch (e) {
      print('Get voices error: $e');
      return [];
    }
  }

  // Get available models
  Future<List<TTSModel>> getModels() async {
    try {
      final response = await _dio.get('/tts/models');

      if (response.statusCode == 200) {
        final models = (response.data['models'] as List)
            .map((model) => TTSModel.fromJson(model))
            .toList();
        return models;
      }

      return [];
    } catch (e) {
      print('Get models error: $e');
      return [];
    }
  }

  // Check TTS service status
  Future<bool> checkServiceStatus() async {
    try {
      final response = await _dio.get('/tts/status');

      if (response.statusCode == 200) {
        return response.data['configured'] == true;
      }

      return false;
    } catch (e) {
      print('Check TTS status error: $e');
      return false;
    }
  }

  // Clean up resources
  Future<void> dispose() async {
    await _audioPlayer.dispose();
  }
}
