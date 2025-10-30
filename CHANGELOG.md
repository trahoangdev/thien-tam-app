# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.3.1] - 2025-10-28

### Changed
- Fixed 404 error when adding books from URL (cloudinaryUrl → pdfUrl)
- Fixed BookCategory type error in Books Library
- Added "Người dịch" (translator) field for books
- Improved error handling throughout the app
- Enhanced UI/UX with better color contrast and readability

### Added
- Auto-detect API URL for emulator vs physical device
- Debug logging for troubleshooting network issues
- Unified configuration for all environments

## [1.3.0] - 2025-10-28

### Added
- **Sleep Mode - Chế độ ngủ thiền định**
  - Timer tự động dừng (5-120 phút)
  - 4 âm thanh ambient thiền định (Mưa, Chùa, Thiên nhiên, Im lặng)
  - Fade out âm lượng tự động trong 2 phút cuối
  - Chuông nhẹ khi kết thúc (gentle bell)
  - Real-time volume control slider
  - Countdown timer với Mandala-style design
  - UI theo phong cách Phật giáo (vàng đồng, nâu gỗ, sen)
  - Tích hợp vào Reading Detail Page

### Changed
- Buddhist-themed color palette (Golden Bronze, Dark Wood, Ivory)
- Improved color contrast for better readability
- Lotus icon 🪷 and Om symbol 🕉️
- Smooth animations and transitions
- Volume slider với visual feedback

## [1.2.0] - 2025-10-25

### Added
- **Books Library - Thư viện Kinh Sách PDF**
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

- **Backend Enhancements**
  - Book model với MongoDB text indexing
  - Cloudinary integration cho PDF storage
  - Multi-file upload (PDF + cover image)
  - Advanced filtering và pagination
  - Book categories management
  - Reorder categories functionality

### Fixed
- Fixed Syncfusion PDF viewer MissingPluginException
- Added device_info_plus dependency
- Fixed Books Library layout và padding
- Cloudinary PDF delivery configuration
- Better error handling cho PDF loading

## [1.1.0] - 2025-10-25

### Added
- **User Management trong Admin Panel**
  - Tạo user mới với validation đầy đủ
  - Sửa thông tin user (tên, email, mật khẩu)
  - Khóa/mở khóa tài khoản
  - Xóa user
  - Tìm kiếm và phân trang

- **Audio Management cải tiến**
  - Upload audio từ file (với file picker)
  - Upload audio từ URL Cloudinary (tránh lag trên máy ảo)
  - Toggle giữa 2 chế độ upload
  - CRUD đầy đủ cho audio

### Changed
- Cải thiện UX với thông báo lỗi thân thiện hơn
- Speed Dial FAB menu gọn gàng
- File picker permissions cho Android
- Custom error handling

### Removed
- Loại bỏ Premium/VIP tiers
- Chỉ còn 2 user roles: Guest và User

## [1.0.0] - 2025-10-20

### Added
- **Core Features**
  - Daily readings with authentic Buddhist content
  - Calendar view to browse readings by month
  - Search functionality with keywords and topics
  - Bookmark favorite readings
  - Reading history tracking
  - Dark mode with Buddhist-themed UI
  - Offline support with caching
  - Daily notifications at 7:00 AM
  - 404 error page with Buddhist theme

- **Admin Panel**
  - JWT-based secure authentication
  - Reading management (CRUD)
  - Topic management with colors/icons
  - Dashboard with statistics
  - Real-time updates
  - Advanced search & filtering
  - Pagination support

- **AI Features**
  - Text-to-Speech with ElevenLabs
  - Chatbot with Google Gemini AI
  - Voice selection for TTS

- **Audio Library**
  - Upload and manage Buddhist audio files
  - Categories and tags
  - Full-text search
  - Audio player with loop, seek, duration tracking
  - Statistics tracking

- **Authentication**
  - User registration and login
  - JWT token-based authentication
  - Password hashing with bcrypt
  - Role-based access control (ADMIN/EDITOR/USER/GUEST)
  - Secure token storage

- **Backend**
  - Express.js RESTful API
  - MongoDB database with Mongoose
  - Swagger API documentation
  - Rate limiting
  - Helmet security headers
  - Input validation with Zod
  - Error handling middleware

- **Frontend**
  - Flutter 3.x with Material Design 3
  - Riverpod state management
  - Hive local storage
  - Dio HTTP client
  - GoRouter navigation
  - Markdown rendering
  - Internationalization support

## [0.9.0] - Pre-release

### Added
- Initial project setup
- Basic reading functionality
- Admin login
- Database seeding with authentic Buddhist content

---

## Version History

- **1.3.1** (Current) - Bug fixes and improvements
- **1.3.0** - Sleep mode and ambient sounds
- **1.2.0** - Books Library with PDF viewer
- **1.1.0** - User management and improved admin features
- **1.0.0** - Initial stable release
- **0.9.0** - Pre-release beta

## Upgrade Notes

### From 1.2.0 to 1.3.1
- No breaking changes
- Recommended to update backend dependencies
- Clear app cache if experiencing issues

### From 1.1.0 to 1.2.0
- Added new dependencies: device_info_plus, syncfusion_flutter_pdfviewer
- Run `flutter pub get` after update

### From 1.0.0 to 1.1.0
- Simplified user roles (removed Premium/VIP)
- All existing users migrated to USER role
- Backward compatible

## Support

For issues or questions, please visit:
- GitHub Issues: https://github.com/trahoangdev/thien-tam-app/issues
- Documentation: https://github.com/trahoangdev/thien-tam-app/wiki

