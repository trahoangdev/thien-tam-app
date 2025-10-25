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
| 3 | **User (Người dùng)** | CRUD tài khoản người dùng thường | `User.ts` | `/user-auth`, `/admin/users` | Register Page + Admin Panel |
| 4 | **AdminUser (Quản trị viên)** | CRUD tài khoản admin với roles | `AdminUser.ts` | `/admin`, `/auth` | Admin Login |
| 5 | **Audio (Thư viện âm thanh)** | CRUD audio Phật giáo với Cloudinary | `Audio.ts` | `/audio` | Admin Panel + Audio Library |
| 6 | **Book (Kinh sách PDF)** | CRUD kinh sách Phật giáo với PDF viewer | `Book.ts` | `/books` | Admin Panel + Books Library |

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

**Tổng: 31 chức năng nâng cao**

---

## 📊 TỔNG KẾT

| Loại chức năng | Số lượng |
|----------------|----------|
| Chức năng cơ bản | 15 |
| CRUD | 6 |
| Chức năng nâng cao | 31 |
| **TỔNG CỘNG** | **52 chức năng** |

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
| **Content Manager** | CRUD Readings, Topics, Audio, Books |
| **User Manager** | CRUD Users (tạo, sửa, xóa, khóa tài khoản) |
| **Super Admin** | Full system access + Quản lý admin users |

### Ghi chú
- Hệ thống đã loại bỏ các tier Premium/VIP để đơn giản hóa
- Tất cả user đăng ký đều có quyền truy cập đầy đủ các tính năng
- Admin có thể tạo user mới và quản lý trạng thái tài khoản

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

### 3. 📚 Books Library (NEW!)
- Upload PDF kinh sách từ file hoặc URL Cloudinary
- Quản lý kinh sách Phật giáo từ Admin Panel
- PDF viewer trực tuyến (Syncfusion)
- Phân loại theo category, tags, language
- Tìm kiếm full-text
- Upload cover image cho sách
- Thống kê lượt xem và tải xuống
- Zoom, navigation, page jump trong PDF viewer

### 4. 📅 Buddhist Calendar
- Lịch âm dương chính xác
- Hiển thị ngày lễ Phật giáo
- Tích hợp với bài đọc hàng ngày

### 5. 📊 Reading Analytics
- Theo dõi số bài đọc
- Thời gian đọc
- Chuỗi ngày liên tiếp
- Lịch sử chi tiết

### 6. 🎨 Customization
- Dark/Light mode
- Font size adjustment
- Line height adjustment
- Notification preferences

---

## 🆕 CẬP NHẬT GẦN ĐÂY

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
- **Version:** 1.2.0
- **Last Updated:** October 25, 2025

---

## 📈 THỐNG KÊ DỰ ÁN

- **Tổng số chức năng:** 52
- **Backend Routes:** 9 main routes
- **Database Models:** 6 models
- **Frontend Features:** 7 feature modules
- **Lines of Code:** ~20,000+ (Backend + Frontend)
- **API Endpoints:** 60+ endpoints
- **Development Time:** 3+ months

---

**Được phát triển với ❤️ bởi ThienTam Team**

