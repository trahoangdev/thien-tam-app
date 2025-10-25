# 🎤 TTS Voice Selection Update

## 📋 Tổng Quan

Update hệ thống Text-to-Speech để hỗ trợ **chọn giọng đọc** cho người dùng, với 2 giọng tiếng Việt: **Giọng nữ** (mặc định) và **Giọng nam**.

---

## 🎯 Mục Tiêu

1. ✅ Thêm voice ID nữ mới vào backend
2. ✅ Tạo API endpoint để lấy danh sách voices
3. ✅ Lưu voice preference vào settings
4. ✅ UI để chọn voice trong Settings page
5. ✅ Tự động sử dụng voice đã chọn khi TTS

---

## 🔧 Backend Changes

### **1. ElevenLabs Service** (`src/services/elevenlabsService.ts`)

#### **Voice IDs**
```typescript
public readonly voices = {
  MALE_DEFAULT: 'DXiwi9uoxet6zAiZXynP',    // Male Vietnamese voice
  FEMALE_CALM: 'DvG3I1kDzdBY3u4EzYh6',     // Female Vietnamese voice (calm, gentle)
};
```

#### **Default Voice Changed**
- **Before:** Male voice (`DXiwi9uoxet6zAiZXynP`)
- **After:** Female voice (`DvG3I1kDzdBY3u4EzYh6`)
- **Reason:** Giọng nữ nhẹ nhàng phù hợp hơn cho bài đọc Phật giáo

#### **New Method: `getAvailableVoices()`**
```typescript
getAvailableVoices() {
  return [
    {
      id: this.voices.FEMALE_CALM,
      name: 'Giọng nữ nhẹ nhàng',
      description: 'Giọng nữ trầm, ấm áp, phù hợp cho bài đọc Phật giáo',
      gender: 'female',
      isDefault: true,
    },
    {
      id: this.voices.MALE_DEFAULT,
      name: 'Giọng nam chuẩn',
      description: 'Giọng nam tiếng Việt chuẩn',
      gender: 'male',
      isDefault: false,
    },
  ];
}
```

### **2. TTS Routes** (`src/routes/tts.ts`)

#### **New Endpoint: GET `/tts/voices`**
```typescript
/**
 * @swagger
 * /tts/voices:
 *   get:
 *     summary: Get available voice options
 *     description: Get list of available Vietnamese voices for TTS
 *     tags: [Text-to-Speech]
 *     responses:
 *       200:
 *         description: List of available voices
 */
r.get('/voices', async (req, res) => {
  const voices = elevenLabsService.getAvailableVoices();
  res.json({ voices });
});
```

#### **Response Example**
```json
{
  "voices": [
    {
      "id": "DvG3I1kDzdBY3u4EzYh6",
      "name": "Giọng nữ nhẹ nhàng",
      "description": "Giọng nữ trầm, ấm áp, phù hợp cho bài đọc Phật giáo",
      "gender": "female",
      "isDefault": true
    },
    {
      "id": "DXiwi9uoxet6zAiZXynP",
      "name": "Giọng nam chuẩn",
      "description": "Giọng nam tiếng Việt chuẩn",
      "gender": "male",
      "isDefault": false
    }
  ]
}
```

---

## 📱 Frontend Changes

### **1. Data Models** (`lib/features/tts/data/tts_service.dart`)

#### **New Model: `AppVoice`**
```dart
class AppVoice {
  final String id;
  final String name;
  final String description;
  final String gender;
  final bool isDefault;

  AppVoice({
    required this.id,
    required this.name,
    required this.description,
    required this.gender,
    required this.isDefault,
  });

  factory AppVoice.fromJson(Map<String, dynamic> json) {
    return AppVoice(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      gender: json['gender'] ?? 'female',
      isDefault: json['isDefault'] ?? false,
    );
  }

  // Helper to get icon based on gender
  String get genderIcon => gender == 'female' ? '👩' : '👨';
}
```

#### **New Method: `getAppVoices()`**
```dart
Future<List<AppVoice>> getAppVoices() async {
  try {
    final response = await _dio.get('/tts/voices');
    if (response.statusCode == 200) {
      final voices = (response.data['voices'] as List)
          .map((voice) => AppVoice.fromJson(voice))
          .toList();
      return voices;
    }
    return [];
  } catch (e) {
    print('Get app voices error: $e');
    return [];
  }
}
```

### **2. Settings Storage** (`lib/core/settings_service.dart`)

```dart
// TTS Voice (default: female calm voice)
String getTTSVoiceId() {
  return _box.get('tts_voice_id', defaultValue: 'DvG3I1kDzdBY3u4EzYh6');
}

Future<void> setTTSVoiceId(String voiceId) async {
  await _box.put('tts_voice_id', voiceId);
}
```

### **3. Riverpod Providers** (`lib/core/settings_providers.dart`)

```dart
// TTS Voice ID provider
final ttsVoiceIdProvider = StateProvider<String>((ref) {
  return ref.read(settingsServiceProvider).getTTSVoiceId();
});
```

### **4. Voice Selector Widget** (NEW!)

**File:** `lib/features/tts/presentation/widgets/voice_selector_widget.dart`

#### **Features:**
- ✅ Hiển thị voice hiện tại với icon (👩 nữ / 👨 nam)
- ✅ Card info với name, description, gender
- ✅ Badge "Mặc định" cho default voice
- ✅ Bottom sheet để chọn voice
- ✅ Visual feedback khi chọn (checkmark)
- ✅ Auto save vào settings khi chọn
- ✅ Loading & error states

#### **UI Preview:**
```
┌─────────────────────────────────────┐
│ 🎤 Giọng đọc                        │
│ Giọng nữ nhẹ nhàng         [Thay đổi]│
├─────────────────────────────────────┤
│ ┌───────────────────────────────┐   │
│ │ 👩  Giọng nữ nhẹ nhàng  [Mặc định]│
│ │     Giọng nữ trầm, ấm áp...   │   │
│ └───────────────────────────────┘   │
└─────────────────────────────────────┘
```

#### **Bottom Sheet:**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   🎤  Chọn giọng đọc
────────────────────────────────────
⚫ 👩  Giọng nữ nhẹ nhàng [Mặc định] ✓
   Giọng nữ trầm, ấm áp, phù hợp
   cho bài đọc Phật giáo
   
⚪ 👨  Giọng nam chuẩn
   Giọng nam tiếng Việt chuẩn
────────────────────────────────────
```

### **5. Settings Page Integration**

**File:** `lib/features/readings/presentation/pages/settings_page.dart`

```dart
// Added import
import '../../../tts/presentation/widgets/voice_selector_widget.dart';

// Added section after Line Height
_SectionHeader(title: 'Giọng Đọc'),
const VoiceSelectorWidget(),
```

### **6. TTS Provider Update**

**File:** `lib/features/tts/presentation/providers/tts_providers.dart`

```dart
// Get selected voice from settings
final selectedVoiceId = _ref.read(ttsVoiceIdProvider);

// Use in TTS request
final request = TTSRequest(
  text: text,
  voiceId: voiceId ?? selectedVoiceId, // Auto use selected voice
  voiceSettings: TTSService.defaultVietnameseSettings,
);
```

### **7. TTS Widget Fix**

**File:** `lib/features/tts/presentation/widgets/tts_widget.dart`

- ✅ Removed unused import
- ✅ Simplified VoiceSelectorWidget usage
- ✅ No props needed (widget manages its own state)

---

## 🧪 Testing

### **Backend Test**

```powershell
# Get available voices
curl http://localhost:4000/tts/voices

# Test TTS with female voice (default)
curl -X POST http://localhost:4000/tts/text-to-speech \
  -H "Content-Type: application/json" \
  -d '{"text":"Nam mô Bổn Sư Thích Ca Mâu Ni Phật"}' \
  --output female-voice.mp3

# Test TTS with male voice
curl -X POST http://localhost:4000/tts/text-to-speech \
  -H "Content-Type: application/json" \
  -d '{"text":"Nam mô Bổn Sư Thích Ca Mâu Ni Phật","voiceId":"DXiwi9uoxet6zAiZXynP"}' \
  --output male-voice.mp3
```

### **Frontend Test**

1. **Hot reload** Flutter app
2. **Mở Settings** → Scroll xuống "Giọng Đọc"
3. **Xem voice hiện tại** (mặc định: Giọng nữ nhẹ nhàng)
4. **Tap "Thay đổi"** → Bottom sheet hiện ra
5. **Chọn voice khác** → Tự động lưu
6. **Test TTS** → Đọc một bài để nghe thử

---

## 📊 File Changes Summary

### **Backend (3 files)**
- ✅ `src/services/elevenlabsService.ts` - Added voices object & getAvailableVoices()
- ✅ `src/routes/tts.ts` - Added GET /tts/voices endpoint
- ✅ Updated Swagger documentation

### **Frontend (7 files)**
- ✅ `lib/features/tts/data/tts_service.dart` - Added AppVoice model & getAppVoices()
- ✅ `lib/core/settings_service.dart` - Added getTTSVoiceId() & setTTSVoiceId()
- ✅ `lib/core/settings_providers.dart` - Added ttsVoiceIdProvider
- ✅ `lib/features/tts/presentation/widgets/voice_selector_widget.dart` - **NEW FILE**
- ✅ `lib/features/readings/presentation/pages/settings_page.dart` - Added voice section
- ✅ `lib/features/tts/presentation/providers/tts_providers.dart` - Use selected voice
- ✅ `lib/features/tts/presentation/widgets/tts_widget.dart` - Fixed import & props

---

## 🎨 User Experience

### **Before:**
- ❌ Hardcoded male voice
- ❌ No option to change voice
- ❌ Not optimized for Buddhist readings

### **After:**
- ✅ Default female voice (calm, gentle)
- ✅ User can choose voice in Settings
- ✅ Voice preference persists across sessions
- ✅ Easy-to-use voice selector with visual feedback
- ✅ Optimized for Buddhist content

---

## 🚀 How to Use

### **For Users:**
1. Open app → Settings (⚙️)
2. Scroll to "Giọng Đọc" section
3. Tap "Thay đổi" to see voice options
4. Select preferred voice
5. Go to any reading and use TTS
6. Voice selection is remembered

### **For Developers:**
```dart
// Get current voice ID
final voiceId = ref.read(ttsVoiceIdProvider);

// Change voice programmatically
ref.read(ttsVoiceIdProvider.notifier).state = 'DXiwi9uoxet6zAiZXynP';
await ref.read(settingsServiceProvider).setTTSVoiceId('DXiwi9uoxet6zAiZXynP');

// Use TTS with selected voice (automatic)
ref.read(audioPlayerStateProvider.notifier).speakText("Nam mô...");

// Or override with specific voice
ref.read(audioPlayerStateProvider.notifier).speakText(
  "Nam mô...", 
  voiceId: 'DXiwi9uoxet6zAiZXynP',
);
```

---

## 📝 Notes

- Voice preference is stored in Hive local storage
- Default voice is female (`DvG3I1kDzdBY3u4EzYh6`)
- Voice change takes effect immediately on next TTS request
- Both voices support Vietnamese language with proper pronunciation
- Voice settings are user-specific and persist across app restarts

---

## 🔄 Migration

**No migration needed!** Users will automatically get:
- Female voice as default
- Option to change in Settings
- Existing TTS functionality continues to work

---

## ✅ Checklist

- [x] Backend: Add voice IDs to service
- [x] Backend: Create GET /tts/voices endpoint
- [x] Backend: Update Swagger docs
- [x] Frontend: Create AppVoice model
- [x] Frontend: Add voice storage in settings
- [x] Frontend: Create VoiceSelectorWidget
- [x] Frontend: Integrate into Settings page
- [x] Frontend: Update TTS provider to use selected voice
- [x] Frontend: Fix linter errors
- [x] Testing: Verify both voices work
- [x] Documentation: Update this file

---

**Updated:** October 25, 2025  
**Version:** 1.2.1  
**Status:** ✅ Complete and tested

