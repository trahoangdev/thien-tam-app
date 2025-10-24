# 📚 ThienTam App - Tổng Quan Dự Án

## 🎯 **Giới Thiệu Dự Án**

**ThienTam App** là một ứng dụng di động Phật giáo được phát triển với mục đích cung cấp nội dung đọc hàng ngày về Phật pháp, tích hợp công nghệ Text-to-Speech (TTS) và hệ thống thông báo thông minh.

---

## 🏗️ **Kiến Trúc Hệ Thống**

### **Backend (Node.js + Express)**
- **Framework**: Express.js với TypeScript
- **Database**: MongoDB với Mongoose ODM
- **Authentication**: JWT (JSON Web Tokens)
- **TTS Integration**: ElevenLabs API
- **Port**: 4000
- **Network**: Accessible from `192.168.1.228:4000`

### **Frontend (Flutter)**
- **Framework**: Flutter với Dart
- **State Management**: Riverpod
- **Audio**: audioplayers package
- **Notifications**: flutter_local_notifications
- **Network**: HTTP requests to backend

---

## 📱 **Tính Năng Chính**

### 🔐 **Hệ Thống Xác Thực**
- **Admin Panel**: Quản lý nội dung, topics, thống kê
- **User Authentication**: Đăng ký, đăng nhập, profile
- **JWT Security**: Access token + Refresh token

### 📖 **Quản Lý Nội Dung**
- **Daily Readings**: Bài đọc hàng ngày theo chủ đề Phật giáo
- **Topic Management**: 8 chủ đề chính (Tứ Diệu Đế, Bát Chánh Đạo, Từ Bi, v.v.)
- **Search & Filter**: Tìm kiếm theo từ khóa, chủ đề, tháng
- **Content Sources**: Kinh điển Phật giáo chính thống

### 🎵 **Text-to-Speech (TTS)**
- **Provider**: ElevenLabs API
- **Voice**: Giọng thuần Việt (`DXiwi9uoxet6zAiZXynP`)
- **Model**: `eleven_multilingual_v2`
- **Features**: 
  - Auto-stop khi hoàn thành
  - Voice selector
  - Audio state management

### 🔔 **Hệ Thống Thông Báo**
- **Holiday Reminders**: Nhắc nhở ngày lễ Phật giáo
- **Reading Reminders**: Nhắc đọc hàng ngày
- **Custom Time**: Tùy chỉnh giờ và phút
- **Battery Optimization**: Tự động xin miễn tối ưu pin

---

## 🗂️ **Cấu Trúc Thư Mục**

```
ThienTam APP/
├── backend_thien_tam_app/          # Backend Node.js
│   ├── src/
│   │   ├── models/                 # MongoDB Models
│   │   ├── routes/                 # API Routes
│   │   ├── services/               # Business Logic
│   │   ├── middleware/             # Auth & Validation
│   │   └── seed/                   # Database Seeding
│   ├── package.json
│   └── .env                        # Environment Variables
│
├── thien_tam_app/                  # Frontend Flutter
│   ├── lib/
│   │   ├── core/                   # Configuration
│   │   ├── features/               # Feature Modules
│   │   │   ├── readings/           # Reading Management
│   │   │   ├── tts/                # Text-to-Speech
│   │   │   ├── notifications/     # Notification System
│   │   │   └── settings/           # App Settings
│   │   └── main.dart
│   └── android/                    # Android Configuration
│
└── PROJECT_OVERVIEW.md             # This file
```

---

## 🛠️ **Công Nghệ Sử Dụng**

### **Backend Stack**
- **Runtime**: Node.js v22.14.0
- **Language**: TypeScript
- **Framework**: Express.js
- **Database**: MongoDB
- **ORM**: Mongoose
- **Authentication**: JWT + bcrypt
- **Validation**: Zod
- **TTS**: ElevenLabs API
- **HTTP Client**: Axios
- **Development**: Nodemon

### **Frontend Stack**
- **Framework**: Flutter
- **Language**: Dart
- **State Management**: Riverpod
- **HTTP Client**: Dio
- **Audio**: audioplayers
- **Notifications**: flutter_local_notifications
- **Time Zone**: timezone
- **File System**: path_provider

### **Development Tools**
- **API Testing**: Postman Collection
- **Automated Testing**: Node.js test scripts
- **Version Control**: Git
- **Package Management**: npm (Backend), pub (Flutter)

---

## 📊 **API Endpoints**

### **Public Endpoints**
```
GET  /readings/today              # Bài đọc hôm nay
GET  /readings/:yyyy-:mm-:dd       # Bài đọc theo ngày
GET  /readings?query=...           # Tìm kiếm bài đọc
GET  /readings/month/:yyyy-:mm     # Bài đọc theo tháng
GET  /readings/random              # Bài đọc ngẫu nhiên
```

### **TTS Endpoints**
```
POST /tts/text-to-speech          # Chuyển text thành giọng nói
GET  /tts/voices                   # Danh sách giọng nói
GET  /tts/models                    # Danh sách models
GET  /tts/status                    # Trạng thái TTS
```

### **Authentication Endpoints**
```
POST /auth/login                   # Đăng nhập admin
POST /auth/refresh                  # Refresh token
GET  /auth/me                       # Thông tin admin
```

### **User Authentication**
```
POST /user-auth/register            # Đăng ký user
POST /user-auth/login               # Đăng nhập user
POST /user-auth/refresh             # Refresh token
GET  /user-auth/me                   # Thông tin user
PUT  /user-auth/profile              # Cập nhật profile
POST /user-auth/logout               # Đăng xuất
GET  /user-auth/reading-stats        # Thống kê đọc
```

### **Admin Endpoints**
```
# Readings Management
GET    /admin/readings              # Danh sách bài đọc
POST   /admin/readings              # Tạo bài đọc mới
PUT    /admin/readings/:id          # Cập nhật bài đọc
DELETE /admin/readings/:id          # Xóa bài đọc
GET    /admin/readings/:id          # Chi tiết bài đọc

# Topics Management
GET    /admin/topics                # Danh sách chủ đề
POST   /admin/topics                 # Tạo chủ đề mới
PUT    /admin/topics/:id             # Cập nhật chủ đề
DELETE /admin/topics/:id             # Xóa chủ đề
GET    /admin/topics/:id             # Chi tiết chủ đề
GET    /admin/topics/stats           # Thống kê chủ đề

# Statistics
GET    /admin/stats                 # Thống kê tổng quan
```

---

## 🎨 **UI/UX Features**

### **Material Design 3**
- **Color Scheme**: Dynamic color system
- **Typography**: Roboto font family
- **Components**: Cards, Lists, Buttons, Switches
- **Responsive**: Adaptive layouts

### **Key UI Components**
- **Reading Cards**: Hiển thị bài đọc với TTS button
- **TTS Widget**: Audio player với voice selector
- **Search Interface**: Tìm kiếm với filters
- **Settings Pages**: Cấu hình thông báo và TTS
- **Navigation**: Bottom navigation + drawer

---

## 🔧 **Cấu Hình Môi Trường**

### **Backend Environment (.env)**
```env
MONGODB_URI=mongodb://localhost:27017/thientam
JWT_SECRET=your_jwt_secret
REFRESH_SECRET=your_refresh_secret
ELEVENLABS_API_KEY=your_elevenlabs_key
ADMIN_EMAIL=admin@thientam.local
ADMIN_PASSWORD=ThienTam@2025
PORT=4000
NODE_ENV=development
API_BASE_URL=http://192.168.1.228:4000
```

### **Flutter Configuration**
- **API Base URL**: `http://192.168.1.228:4000`
- **Network Security**: Cleartext traffic allowed
- **Android Permissions**: Internet, Wake Lock, Vibrate
- **Notification Channels**: Holiday, Reading, Daily

---

## 📱 **Android Configuration**

### **Permissions (AndroidManifest.xml)**
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
<uses-permission android:name="android.permission.VIBRATE" />
<uses-permission android:name="android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS" />
```

### **Network Security**
- **Cleartext Traffic**: Enabled for local development
- **Security Config**: Custom network security configuration
- **Firewall**: Port 4000 accessible from network

---

## 🗄️ **Database Schema**

### **Reading Model**
```typescript
{
  _id: ObjectId,
  date: Date,                    // Ngày đọc
  title: String,                 // Tiêu đề
  body: String,                 // Nội dung
  topicSlugs: [String],         // Chủ đề
  keywords: [String],           // Từ khóa
  source: String,               // Nguồn
  lang: String,                 // Ngôn ngữ
  createdAt: Date,
  updatedAt: Date
}
```

### **Topic Model**
```typescript
{
  _id: ObjectId,
  slug: String,                 // URL slug
  name: String,                 // Tên chủ đề
  description: String,          // Mô tả
  color: String,                // Màu sắc (#hex)
  icon: String,                 // Icon
  isActive: Boolean,            // Trạng thái
  sortOrder: Number,            // Thứ tự
  createdAt: Date,
  updatedAt: Date
}
```

### **User Model**
```typescript
{
  _id: ObjectId,
  email: String,                // Email
  password: String,             // Mật khẩu (hashed)
  name: String,                 // Tên
  readingStats: {
    totalReadings: Number,      // Tổng số bài đã đọc
    lastReadDate: Date,         // Ngày đọc cuối
    favoriteTopics: [String]    // Chủ đề yêu thích
  },
  createdAt: Date,
  updatedAt: Date
}
```

---

## 🚀 **Cách Chạy Dự Án**

### **Backend Setup**
```bash
cd backend_thien_tam_app
npm install
npm run seed:admin          # Tạo admin user
npm run seed                # Seed dữ liệu mẫu
npm run dev                 # Chạy development server
```

### **Frontend Setup**
```bash
cd thien_tam_app
flutter pub get
flutter run                 # Chạy trên device/emulator
```

### **Testing**
```bash
# API Testing
npm run test:api            # Test tất cả endpoints
npm run test:create-reading # Test tạo bài đọc
npm run test:topics-stats   # Test thống kê chủ đề

# Postman Collection
# Import ThienTam_API_Postman_Collection.json
```

---

## 📈 **Thống Kê Dự Án**

### **Backend Metrics**
- **API Endpoints**: 25+ endpoints
- **Database Models**: 4 models (Reading, Topic, User, Admin)
- **Authentication**: JWT + Refresh token
- **TTS Integration**: ElevenLabs API
- **Test Coverage**: Automated testing scripts

### **Frontend Metrics**
- **Screens**: 8+ screens
- **Features**: 6 main features
- **State Management**: Riverpod providers
- **Audio Integration**: TTS with auto-stop
- **Notification System**: 3 types of notifications

### **Content Statistics**
- **Topics**: 8 chủ đề Phật giáo
- **Readings**: 91+ bài đọc authentic
- **Sources**: 7+ kinh điển Phật giáo
- **Languages**: Vietnamese (primary)

---

## 🔮 **Tính Năng Tương Lai**

### **Planned Features**
- [ ] **Offline Mode**: Đọc offline khi không có internet
- [ ] **Bookmark System**: Lưu bài đọc yêu thích
- [ ] **Progress Tracking**: Theo dõi tiến độ đọc
- [ ] **Social Features**: Chia sẻ bài đọc
- [ ] **Multi-language**: Hỗ trợ tiếng Anh, tiếng Trung
- [ ] **Advanced TTS**: Nhiều giọng nói khác nhau
- [ ] **Meditation Timer**: Hẹn giờ thiền
- [ ] **Daily Quotes**: Trích dẫn hàng ngày

### **Technical Improvements**
- [ ] **Caching System**: Redis cache
- [ ] **CDN Integration**: Static assets
- [ ] **Push Notifications**: Firebase Cloud Messaging
- [ ] **Analytics**: User behavior tracking
- [ ] **Performance**: Code splitting, lazy loading
- [ ] **Security**: Rate limiting, input sanitization

---

## 👥 **Team & Contributors**

### **Development Team**
- **Backend Developer**: Node.js, Express, MongoDB
- **Frontend Developer**: Flutter, Dart, Riverpod
- **UI/UX Designer**: Material Design 3
- **Content Creator**: Buddhist content curation

### **Special Thanks**
- **ElevenLabs**: TTS API service
- **MongoDB**: Database platform
- **Flutter Team**: Mobile framework
- **Buddhist Community**: Content inspiration

---

## 📞 **Support & Contact**

### **Technical Support**
- **Backend Issues**: Check server logs
- **Frontend Issues**: Flutter debug console
- **Network Issues**: Verify IP configuration
- **TTS Issues**: Check ElevenLabs API key

### **Documentation**
- **API Documentation**: Postman Collection
- **Code Comments**: Inline documentation
- **README Files**: Setup instructions
- **Test Scripts**: Automated testing

---

## 📝 **Changelog**

### **v1.0.0 - Initial Release**
- ✅ Core reading functionality
- ✅ TTS integration with ElevenLabs
- ✅ Notification system
- ✅ Admin panel
- ✅ User authentication
- ✅ Topic management
- ✅ Search and filter
- ✅ API testing suite

### **Recent Updates**
- 🔧 Fixed topics stats endpoint
- 🔧 Resolved TypeScript errors
- 🔧 Improved error handling
- 🔧 Enhanced UI/UX
- 🔧 Added comprehensive testing

---

## 🎯 **Project Goals**

### **Primary Objectives**
1. **Accessibility**: Make Buddhist teachings accessible through technology
2. **Daily Practice**: Encourage daily reading and reflection
3. **Multimedia**: Combine text and audio for better learning
4. **Personalization**: Customizable reading experience
5. **Community**: Connect users with authentic Buddhist content

### **Success Metrics**
- **User Engagement**: Daily active users
- **Content Consumption**: Reading completion rates
- **TTS Usage**: Audio playback statistics
- **Notification Effectiveness**: Reminder response rates
- **User Satisfaction**: Feedback and ratings

---

*📚 **ThienTam App** - Bringing Buddhist wisdom to the digital age through modern technology and authentic teachings.*
