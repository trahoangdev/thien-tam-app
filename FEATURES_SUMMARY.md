# 📋 BẢNG TỔNG HỢP CHỨC NĂNG DỰ ÁN THIỀN TÂM APP

## 🟢 NHÓM CHỨC NĂNG CƠ BẢN

| STT | Chức năng | Mô tả |
|-----|-----------|-------|
| 1 | **Đăng nhập/Đăng ký** | Xác thực người dùng (User Auth) với JWT token |
| 2 | **Đăng nhập Admin** | Xác thực quản trị viên với role-based access |
| 3 | **Chế độ khách** | Cho phép xem bài đọc không cần đăng nhập |
| 4 | **Splash Screen** | Màn hình chào mừng khi khởi động app |
| 5 | **Welcome/Onboarding** | Giới thiệu tính năng cho người dùng mới |
| 6 | **Xem bài đọc hôm nay** | Hiển thị bài đọc Phật giáo theo ngày |
| 7 | **Xem chi tiết bài đọc** | Đọc nội dung đầy đủ với định dạng đẹp |
| 8 | **Lịch Phật giáo** | Xem lịch âm dương, ngày lễ Phật giáo |
| 9 | **Tìm kiếm bài đọc** | Tìm kiếm theo tiêu đề, nội dung, chủ đề |
| 10 | **Đánh dấu yêu thích** | Bookmark bài đọc để đọc lại sau |
| 11 | **Lịch sử đọc** | Theo dõi các bài đã đọc |
| 12 | **Thống kê đọc bài** | Số bài đọc, thời gian, chuỗi ngày |
| 13 | **Cài đặt giao diện** | Chế độ sáng/tối, kích thước chữ, khoảng cách dòng |
| 14 | **Thông báo nhắc nhở** | Nhắc nhở đọc kinh, ngày lễ Phật giáo |
| 15 | **Đăng xuất** | Đăng xuất tài khoản |

**Tổng: 15 chức năng cơ bản**

---

## 🔵 NHÓM CHỨC NĂNG CRUD

| STT | Chức năng | Mô tả | Model | Routes | Frontend |
|-----|-----------|-------|-------|--------|----------|
| 1 | **Reading (Bài đọc)** | CRUD bài đọc Phật giáo hàng ngày | `Reading.ts` | `/readings`, `/admin/readings` | Admin Panel |
| 2 | **Topic (Chủ đề)** | CRUD chủ đề/danh mục bài đọc | `Topic.ts` | `/topics` | Admin Panel |
| 3 | **User (Unified)** | CRUD tài khoản với role-based access (USER/ADMIN) | `User.ts` | `/user-auth`, `/admin/users`, `/auth` | Register Page + Admin Panel + Admin Login |
| 4 | **Audio (Thư viện âm thanh)** | CRUD audio Phật giáo với Cloudinary | `Audio.ts` | `/audio` | Admin Panel + Audio Library |
| 5 | **Book (Kinh sách PDF)** | CRUD kinh sách Phật giáo với PDF viewer | `Book.ts` | `/books` | Admin Panel + Books Library |
| 6 | **BookCategory (Danh mục sách)** | CRUD danh mục cho thư viện kinh sách | `BookCategory.ts` | `/book-categories` | Admin Panel + Books Library |

**Tổng: 6 bảng CRUD**

---

## 🟣 NHÓM CHỨC NĂNG NÂNG CAO

| STT | Chức năng | Mô tả | Công nghệ |
|-----|-----------|-------|-----------|
| 1 | **Text to Speech (ElevenLabs)** | Chuyển đổi bài đọc thành giọng nói AI | ElevenLabs API (eleven_flash_v2_5) |
| 2 | **ChatbotAI (Gemini)** | Trò chuyện với Thiền Sư AI | Google Gemini 2.5 Flash/Pro |
| 3 | **Thư viện Audio Phật giáo** | Nghe audio, phân loại, tìm kiếm, thống kê | Cloudinary + MongoDB |
| 4 | **Audio Player với Loop** | Phát audio với chức năng lặp lại | Flutter AudioPlayers |
| 5 | **Cloudinary Integration** | Lưu trữ và quản lý audio trên cloud | Cloudinary SDK |
| 6 | **Audio Upload from URL** | Upload audio bằng URL Cloudinary (tránh lag) | Custom API Endpoint |
| 7 | **User Management (Admin)** | CRUD người dùng từ Admin Panel | Express + Flutter Admin UI |
| 8 | **Audio Management (Admin)** | CRUD audio từ Admin Panel với file picker | Multer + Cloudinary + Flutter |
| 9 | **Role-based Access Control** | Phân quyền chi tiết (Guest, User, Admin) | Custom Permission System |
| 10 | **Admin Panel** | Quản lý toàn bộ nội dung và người dùng | Flutter + Express |
| 11 | **Admin Statistics** | Thống kê tổng quan hệ thống | MongoDB Aggregation |
| 12 | **Multiple Readings per Day** | Hỗ trợ nhiều bài đọc trong cùng một ngày | Custom Logic |
| 13 | **Buddhist Calendar Widget** | Widget lịch âm với ngày lễ Phật giáo | Custom Calendar Service |
| 14 | **Lunar Calendar Service** | Tính toán lịch âm chính xác | Vietnamese Lunar Calendar Algorithm |
| 15 | **Reading Stats Tracking** | Theo dõi chi tiết thói quen đọc | Hive Local Storage |
| 16 | **Cache Management** | Quản lý cache để tối ưu hiệu suất | Hive + Memory Cache |
| 17 | **Developer Mode** | Chế độ nhà phát triển để truy cập admin | Feature Flag |
| 18 | **Voice Selection (TTS)** | Chọn giọng đọc cho Text-to-Speech | ElevenLabs Voices |
| 19 | **Markdown Rendering** | Hiển thị markdown trong chat AI | flutter_markdown |
| 20 | **Speed Dial FAB Menu** | Menu FAB gọn gàng với animation | Custom Flutter Widget |
| 21 | **Permission System** | Hệ thống phân quyền linh hoạt | Riverpod Providers |
| 22 | **Swagger API Documentation** | Tài liệu API đầy đủ | swagger-jsdoc + swagger-ui-express |
| 23 | **JWT Authentication** | Bảo mật với JSON Web Token | jsonwebtoken + bcryptjs |
| 24 | **Network Security Config** | Cấu hình bảo mật mạng cho Android | network_security_config.xml |
| 25 | **File Picker Integration** | Chọn file audio từ thiết bị | file_picker package |
| 26 | **Custom Error Messages** | Thông báo lỗi thân thiện cho người dùng | Custom Error Handling |
| 27 | **PDF Viewer (Syncfusion)** | Xem PDF trực tuyến từ Cloudinary | syncfusion_flutter_pdfviewer |
| 28 | **Books Library** | Thư viện kinh sách Phật giáo với PDF | Cloudinary + MongoDB |
| 29 | **Book Management (Admin)** | CRUD kinh sách PDF từ Admin Panel | Multer + Cloudinary + Flutter |
| 30 | **PDF Upload from URL** | Upload PDF bằng URL Cloudinary (tránh lag) | Custom API Endpoint |
| 31 | **Book Categories & Search** | Phân loại và tìm kiếm kinh sách | Full-text Search + Filters |
| 32 | **Book Category Management** | CRUD danh mục sách với icon, color, order | Custom Admin UI |
| 33 | **Dynamic Category Filtering** | Lọc kinh sách theo danh mục động | Riverpod State Management |
| 34 | **Sleep Mode** | Chế độ ngủ với timer, fade out, ambient sounds | AudioPlayers + ChangeNotifier |
| 35 | **Ambient Background Sounds** | Âm thanh nền (mưa, chùa, thiên nhiên) cho thiền định | Asset Audio Files |
| 36 | **Auto-Stop Timer** | Tự động dừng audio sau thời gian cài đặt | Dart Timer |
| 37 | **Volume Fade Out** | Giảm âm lượng dần trước khi dừng | Progressive Volume Control |
| 38 | **Real-time Volume Control** | Điều chỉnh âm lượng nền khi đang phát | Slider + Audio Service |

**Tổng: 38 chức năng nâng cao**

---

## 📊 TỔNG KẾT

| Loại chức năng | Số lượng |
|----------------|----------|
| Chức năng cơ bản | 15 |
| CRUD | 6 |
| Chức năng nâng cao | 38 |
| **TỔNG CỘNG** | **59 chức năng** |

---

## 🎯 CÔNG NGHỆ SỬ DỤNG

### Backend
- **Runtime:** Node.js v18+
- **Framework:** Express.js
- **Language:** TypeScript
- **Database:** MongoDB + Mongoose
- **Authentication:** JWT (jsonwebtoken)
- **Password Hashing:** bcryptjs
- **File Upload:** Multer
- **Cloud Storage:** Cloudinary
- **AI Services:** 
  - ElevenLabs API (Text-to-Speech)
  - Google Gemini AI (Chatbot)
- **API Documentation:** Swagger (swagger-jsdoc, swagger-ui-express)
- **Validation:** Zod
- **Environment:** dotenv
- **CORS:** cors

### Frontend
- **Framework:** Flutter 3.x
- **Language:** Dart
- **State Management:** Riverpod
- **Local Storage:** Hive
- **HTTP Client:** Dio
- **Audio Playback:** audioplayers
- **Markdown Rendering:** flutter_markdown
- **PDF Viewer:** syncfusion_flutter_pdfviewer
- **Device Info:** device_info_plus
- **Date Formatting:** intl
- **URL Launcher:** url_launcher
- **File Picker:** file_picker
- **Design System:** Material Design 3

### DevOps & Tools
- **Version Control:** Git
- **API Testing:** PowerShell scripts, Swagger UI
- **Code Quality:** TypeScript ESLint, Dart Analyzer
- **Package Managers:** npm (backend), pub (frontend)

---

## 📁 CẤU TRÚC DỰ ÁN

```
ThienTam APP/
├── backend_thien_tam_app/          # Backend API
│   ├── src/
│   │   ├── models/                 # Mongoose schemas (6 models)
│   │   ├── routes/                 # API routes (9 routes)
│   │   ├── controllers/            # Business logic
│   │   ├── services/               # External services (ElevenLabs, Gemini, Cloudinary)
│   │   ├── middlewares/            # Auth, upload, error handling
│   │   ├── config/                 # Configuration (Swagger, Cloudinary)
│   │   └── seed/                   # Database seeding
│   └── dist/                       # Compiled JavaScript
│
├── thien_tam_app/                  # Flutter Frontend
│   ├── lib/
│   │   ├── features/               # Feature modules
│   │   │   ├── readings/           # Bài đọc (Today, Calendar, Detail, Search, Bookmarks, History)
│   │   │   ├── auth/               # Authentication (Login, Register, Splash, Welcome)
│   │   │   ├── admin/              # Admin Panel (CRUD, Stats, User/Audio/Book Management)
│   │   │   ├── audio/              # Audio Library (Player, Library, Upload)
│   │   │   ├── books/              # Books Library (PDF Viewer, Detail, Search)
│   │   │   ├── chat/               # Zen Master Chat (Gemini AI)
│   │   │   ├── tts/                # Text-to-Speech
│   │   │   └── notifications/      # Notification settings
│   │   ├── core/                   # Core utilities (Config, Settings, Providers)
│   │   └── main.dart               # App entry point
│   └── android/                    # Android configuration (Permissions, Network Security)
│
├── REFERENCES.md                   # Project references
├── FEATURES_SUMMARY.md             # This file
└── README.md                       # Project documentation
```

---

## 🔐 HỆ THỐNG PHÂN QUYỀN

### User Roles (Đã đơn giản hóa)
| Role | Quyền hạn |
|------|-----------|
| **Guest** | Xem bài đọc, xem lịch (không cần đăng nhập) |
| **User** | Guest + Bookmark + Lịch sử + TTS + Thống kê + Chat AI + Audio Library + Books Library |

### Admin Roles
| Role | Quyền hạn |
|------|-----------|
| **ADMIN** | Full system access: CRUD Readings, Topics, Audio, Books, Users |

### Ghi chú
- **Unified User Model:** Đã merge AdminUser vào User với field `role: 'USER' | 'ADMIN'`
- Hệ thống đã loại bỏ các tier Premium/VIP để đơn giản hóa
- Tất cả user đăng ký đều có role `USER` với quyền truy cập đầy đủ các tính năng
- Admin có role `ADMIN` và có thể quản lý toàn bộ hệ thống
- Chỉ còn 2 roles: USER và ADMIN (đã bỏ Editor, Super Admin)

---

## 📱 TÍNH NĂNG NỔI BẬT

### 1. 🤖 AI Integration
- **Thiền Sư AI:** Chatbot thông minh với Gemini 2.5, hỗ trợ markdown
- **Text-to-Speech:** Chuyển đổi bài đọc thành giọng nói tự nhiên với ElevenLabs

### 2. 🎵 Audio Library
- Upload audio từ file hoặc URL Cloudinary
- Quản lý audio Phật giáo từ Admin Panel
- Phân loại theo category, tags
- Tìm kiếm full-text
- Audio player với loop, seek, duration tracking
- Thống kê lượt nghe

### 3. 🌙 Sleep Mode (NEW!)
- Timer tự động dừng với countdown (5-120 phút)
- 4 âm thanh ambient thiền định (Mưa, Chùa, Thiên nhiên, Im lặng)
- Fade out âm lượng tự động trong 2 phút cuối
- Chuông nhẹ báo kết thúc
- Volume control slider real-time
- Buddhist-themed UI với Lotus 🪷 và Om 🕉️
- Mandala-style circular progress timer

### 4. 📚 Books Library
- Upload PDF kinh sách từ file hoặc URL Cloudinary
- Quản lý kinh sách Phật giáo từ Admin Panel
- PDF viewer trực tuyến (Syncfusion)
- Phân loại theo category, tags, language
- Tìm kiếm full-text
- Upload cover image cho sách
- Thống kê lượt xem và tải xuống
- Zoom, navigation, page jump trong PDF viewer

### 5. 📅 Buddhist Calendar
- Lịch âm dương chính xác
- Hiển thị ngày lễ Phật giáo
- Tích hợp với bài đọc hàng ngày

### 6. 📊 Reading Analytics
- Theo dõi số bài đọc
- Thời gian đọc
- Chuỗi ngày liên tiếp
- Lịch sử chi tiết

### 7. 🎨 Customization
- Dark/Light mode
- Font size adjustment
- Line height adjustment
- Notification preferences

---

## 🆕 CẬP NHẬT GẦN ĐÂY

### Version 1.3.0 (October 28, 2025) - Sleep Mode & Improvements
- ✅ **Sleep Mode - Chế độ ngủ thiền định**
  - Timer tự động dừng (5-120 phút)
  - Âm thanh nền ambient: Mưa 🌧️, Chùa 🛕, Thiên nhiên 🍃, Im lặng 🤫
  - Fade out âm lượng dần trong 2 phút cuối
  - Chuông nhẹ khi kết thúc (gentle bell)
  - Real-time volume control slider
  - Countdown timer với Mandala-style design
  - UI theo phong cách Phật giáo (vàng đồng, nâu gỗ, sen)
  - Tích hợp vào Reading Detail Page

- ✅ **UI/UX Enhancements**
  - Buddhist-themed color palette (Golden Bronze, Dark Wood, Ivory)
  - Improved color contrast for better readability
  - Lotus icon 🪷 and Om symbol 🕉️
  - Smooth animations and transitions
  - Volume slider với visual feedback

- ✅ **Auto-detect API URL**
  - Tự động phát hiện emulator vs physical device
  - Hỗ trợ cả Android và iOS
  - Unified configuration cho tất cả môi trường
  - Debug logging để troubleshoot

- ✅ **Bug Fixes**
  - Fixed 404 error khi thêm sách từ URL (cloudinaryUrl → pdfUrl)
  - Fixed BookCategory type error trong Books Library
  - Thêm field "Người dịch" (translator) cho sách
  - Improved error handling

### Version 1.2.0 (October 25, 2025) - Books Library
- ✅ **Books Library - Thư viện Kinh Sách PDF**
  - CRUD đầy đủ cho kinh sách từ Admin Panel
  - Upload PDF từ file hoặc URL Cloudinary
  - Upload cover image cho sách
  - PDF viewer trực tuyến với Syncfusion
  - Zoom, navigation, page jump trong PDF
  - Phân loại: Kinh điển, Luận giải, Tiểu sử, Thực hành, Pháp thoại, Lịch sử, Triết học
  - Hỗ trợ đa ngôn ngữ: Việt, Anh, Trung, Pali, Sanskrit
  - Tìm kiếm full-text theo title, author, description, tags
  - Thống kê lượt xem và tải xuống
  - Grid view responsive với book cards đẹp mắt

- ✅ **Backend Enhancements**
  - Book model với MongoDB text indexing
  - Cloudinary integration cho PDF storage
  - PDF upload với resource_type: 'image' (fix compatibility)
  - Multi-file upload (PDF + cover image)
  - Advanced filtering và pagination

- ✅ **Fix & Improvements**
  - Fixed Syncfusion PDF viewer MissingPluginException
  - Added device_info_plus dependency
  - Fixed Books Library layout và padding
  - Cloudinary PDF delivery configuration
  - Better error handling cho PDF loading

### Version 1.1.0 (October 25, 2025)
- ✅ **User Management trong Admin Panel**
  - Tạo user mới với validation đầy đủ
  - Sửa thông tin user (tên, email, mật khẩu)
  - Khóa/mở khóa tài khoản
  - Xóa user
  - Tìm kiếm và phân trang

- ✅ **Audio Management cải tiến**
  - Upload audio từ file (với file picker)
  - Upload audio từ URL Cloudinary (tránh lag trên máy ảo)
  - Toggle giữa 2 chế độ upload
  - CRUD đầy đủ cho audio

- ✅ **Cải thiện UX**
  - Thông báo lỗi thân thiện hơn khi đăng ký email trùng
  - Speed Dial FAB menu gọn gàng
  - File picker permissions cho Android
  - Custom error handling

- ✅ **Đơn giản hóa hệ thống**
  - Loại bỏ Premium/VIP tiers
  - Chỉ còn 2 user roles: Guest và User
  - Tất cả user đều có full access

---

## 🚀 ROADMAP (Tương lai)

- [ ] Offline mode (đọc bài khi không có mạng)
- [ ] Social sharing (chia sẻ bài đọc)
- [ ] Community features (bình luận, thảo luận)
- [ ] Video library (thêm video Phật giáo)
- [ ] Meditation timer (đồng hồ thiền định)
- [ ] Daily quotes (câu nói hay hàng ngày)
- [ ] Push notifications (thông báo đẩy)
- [ ] Multi-language support (đa ngôn ngữ)
- [ ] Export/Import user data
- [ ] Bulk operations trong Admin Panel

---

## 📞 LIÊN HỆ

- **GitHub:** https://github.com/trahoangdev/thien-tam-app
- **Version:** 1.3.1
- **Last Updated:** October 28, 2025

---

## 📈 THỐNG KÊ DỰ ÁN

- **Tổng số chức năng:** 59
- **Backend Routes:** 9 main routes
- **Database Models:** 6 models (Reading, Topic, User, Audio, Book, BookCategory)
- **Frontend Features:** 8 feature modules (Readings, Auth, Admin, Audio, Books, Chat, TTS, Notifications)
- **Lines of Code:** ~25,000+ (Backend + Frontend)
- **API Endpoints:** 70+ endpoints
- **Development Time:** 3+ months
- **Ambient Sound Assets:** 4 files (Rain, Temple, Nature, Bell) - ~17 MB total

---

**Được phát triển với ❤️ bởi ThienTam Team**

