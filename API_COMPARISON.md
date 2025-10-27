# So sánh API Routes - Frontend vs Backend

## ✅ Tình trạng: ĐỒNG BỘ

### 📍 Backend Base URL

- **Backend đang chạy**: `http://localhost:4000`
- **Frontend config**:
  - Emulator: `http://10.0.2.2:4000` (Android)
  - Physical Device: `http://192.168.1.228:4000`
  - Web: `http://localhost:4000`

---

## 🔍 Chi tiết API Routes

### 1. **TTS (Text-to-Speech)** ✅

| Frontend                   | Backend                    | Status  |
| -------------------------- | -------------------------- | ------- |
| `POST /tts/text-to-speech` | `POST /tts/text-to-speech` | ✅ Đúng |
| `GET /tts/voices`          | `GET /tts/voices`          | ✅ Đúng |
| `GET /tts/models`          | `GET /tts/models`          | ✅ Đúng |
| `GET /tts/status`          | `GET /tts/status`          | ✅ Đúng |

**File:** `tts_service.dart` → Backend routes: `/tts`

---

### 2. **Chat (Gemini AI)** ✅

| Frontend           | Backend            | Status  |
| ------------------ | ------------------ | ------- |
| `POST /chat/ask`   | `POST /chat/ask`   | ✅ Đúng |
| `GET /chat/status` | `GET /chat/status` | ✅ Đúng |

**File:** `chat_service.dart` → Backend routes: `/chat`

---

### 3. **Books** ✅

| Frontend                   | Backend                    | Status  |
| -------------------------- | -------------------------- | ------- |
| `GET /books`               | `GET /books`               | ✅ Đúng |
| `GET /books/:id`           | `GET /books/:id`           | ✅ Đúng |
| `GET /books/popular`       | `GET /books/popular`       | ✅ Đúng |
| `POST /books/:id/download` | `POST /books/:id/download` | ✅ Đúng |
| `POST /books/:id/view`     | `POST /books/:id/view`     | ✅ Đúng |

**File:** `book_service.dart` → Backend routes: `/books`

---

### 4. **Book Categories** ✅

| Frontend                                | Backend                         | Status  |
| --------------------------------------- | ------------------------------- | ------- |
| `GET /book-categories`                  | `GET /book-categories`          | ✅ Đúng |
| `GET /book-categories/:id`              | `GET /book-categories/:id`      | ✅ Đúng |
| `POST /book-categories` (Admin)         | `POST /book-categories`         | ✅ Đúng |
| `PUT /book-categories/:id` (Admin)      | `PUT /book-categories/:id`      | ✅ Đúng |
| `DELETE /book-categories/:id` (Admin)   | `DELETE /book-categories/:id`   | ✅ Đúng |
| `POST /book-categories/reorder` (Admin) | `POST /book-categories/reorder` | ✅ Đúng |

**File:** `book_category_service.dart` → Backend routes: `/book-categories`

---

### 5. **Audio** ✅

| Frontend                | Backend                 | Status  |
| ----------------------- | ----------------------- | ------- |
| `GET /audio`            | `GET /audio`            | ✅ Đúng |
| `GET /audio/:id`        | `GET /audio/:id`        | ✅ Đúng |
| `GET /audio/categories` | `GET /audio/categories` | ✅ Đúng |
| `GET /audio/popular`    | `GET /audio/popular`    | ✅ Đúng |
| `POST /audio/:id/play`  | `POST /audio/:id/play`  | ✅ Đúng |

**File:** `audio_service.dart` → Backend routes: `/audio`

---

### 6. **User Auth** ✅

| Frontend                        | Backend                         | Status  |
| ------------------------------- | ------------------------------- | ------- |
| `POST /user-auth/register`      | `POST /user-auth/register`      | ✅ Đúng |
| `POST /user-auth/login`         | `POST /user-auth/login`         | ✅ Đúng |
| `POST /user-auth/refresh`       | `POST /user-auth/refresh`       | ✅ Đúng |
| `GET /user-auth/me`             | `GET /user-auth/me`             | ✅ Đúng |
| `PUT /user-auth/profile`        | `PUT /user-auth/profile`        | ✅ Đúng |
| `POST /user-auth/logout`        | `POST /user-auth/logout`        | ✅ Đúng |
| `POST /user-auth/reading-stats` | `POST /user-auth/reading-stats` | ✅ Đúng |

**File:** `user_auth_api_client.dart` → Backend routes: `/user-auth`

---

### 7. **Admin Auth** ✅

| Frontend             | Backend              | Status  |
| -------------------- | -------------------- | ------- |
| `POST /auth/login`   | `POST /auth/login`   | ✅ Đúng |
| `POST /auth/refresh` | `POST /auth/refresh` | ✅ Đúng |
| `GET /auth/me`       | `GET /auth/me`       | ✅ Đúng |
| `POST /auth/logout`  | `POST /auth/logout`  | ✅ Đúng |

**File:** `admin_api_client.dart` → Backend routes: `/auth`

---

### 8. **Readings** ✅

| Frontend                       | Backend                    | Status  |
| ------------------------------ | -------------------------- | ------- |
| `GET /readings`                | `GET /readings`            | ✅ Đúng |
| `GET /readings/:id`            | `GET /readings/:id`        | ✅ Đúng |
| `GET /readings/date/:date`     | `GET /readings/date/:date` | ✅ Đúng |
| `POST /readings` (Admin)       | `POST /readings`           | ✅ Đúng |
| `PUT /readings/:id` (Admin)    | `PUT /readings/:id`        | ✅ Đúng |
| `DELETE /readings/:id` (Admin) | `DELETE /readings/:id`     | ✅ Đúng |

**Backend routes:** `/readings`

---

### 9. **Topics** ✅

| Frontend                     | Backend                      | Status  |
| ---------------------------- | ---------------------------- | ------- |
| `GET /admin/topics`          | `GET /admin/topics`          | ✅ Đúng |
| `POST /admin/topics`         | `POST /admin/topics`         | ✅ Đúng |
| `PUT /admin/topics/:slug`    | `PUT /admin/topics/:slug`    | ✅ Đúng |
| `DELETE /admin/topics/:slug` | `DELETE /admin/topics/:slug` | ✅ Đúng |

**File:** `topic_api_client.dart` → Backend routes: `/admin/topics`

---

## ⚠️ Vấn đề cần chú ý

### 1. **Sự không nhất quán về config**

**Có 2 config khác nhau:**

```dart
// AppConfig (config.dart) - Tự động detect platform
apiBaseUrl = 'http://10.0.2.2:4000' (Android Emulator)
apiBaseUrl = 'http://192.168.1.228:4000' (Physical Device)

// Env (env.dart) - Hardcoded
apiBaseUrl = 'http://10.0.2.2:4000'
```

**Files đang dùng `AppConfig`:** ✅ (Khuyên dùng)

- `tts_service.dart`
- `chat_service.dart`
- `user_auth_api_client.dart`
- `admin_api_client.dart`
- `topic_api_client.dart`

**Files đang dùng `Env`:** ⚠️ (Nên chuyển sang AppConfig)

- `book_service.dart`
- `book_category_service.dart`
- `user_api_client.dart`

---

## 🎯 Khuyến nghị

### 1. **Thống nhất dùng `AppConfig.apiBaseUrl`**

Sửa các file đang dùng `Env.apiBaseUrl`:

```dart
// book_service.dart
- baseUrl: Env.apiBaseUrl
+ baseUrl: AppConfig.apiBaseUrl

// book_category_service.dart
- baseUrl: Env.apiBaseUrl
+ baseUrl: AppConfig.apiBaseUrl

// user_api_client.dart (admin)
- baseUrl: Env.apiBaseUrl
+ baseUrl: AppConfig.apiBaseUrl
```

### 2. **Xóa file `env.dart`**

Sau khi chuyển hết sang `AppConfig`, có thể xóa `env.dart` để tránh nhầm lẫn.

---

## ✅ Kết luận

**Tất cả API routes đều ĐÚNG và ĐỒNG BỘ!** 🎉

- ✅ Backend routes: `/tts`, `/chat`, `/books`, `/book-categories`, `/audio`, `/user-auth`, `/auth`, `/readings`, `/admin/topics`
- ✅ Frontend gọi đúng tất cả endpoints
- ✅ Không có API nào bị sai hoặc thiếu

**Chỉ cần:** Thống nhất dùng `AppConfig.apiBaseUrl` thay vì `Env.apiBaseUrl` để tự động detect platform (emulator/physical device/web).
