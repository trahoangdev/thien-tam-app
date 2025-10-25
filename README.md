# 🕉️ Thiền Tâm - Buddhist Readings App

A full-stack Flutter application for daily Buddhist readings with Express.js backend and MongoDB database.

## 📱 Features

### User App (Flutter)
- ✅ **Daily Readings** - Authentic Buddhist content with proper citations
- ✅ **Calendar View** - Browse readings by month
- ✅ **Search** - Find readings by keywords and topics
- ✅ **Bookmarks** - Save favorite readings
- ✅ **Reading History** - Track recently read articles
- ✅ **Dark Mode** - Beautiful Buddhist-themed UI
- ✅ **Offline Support** - Cache for offline reading
- ✅ **Daily Notifications** - Gentle reminders at 7:00 AM
- ✅ **404 Error Page** - Buddhist-themed error handling

### Admin Panel (Flutter)
- ✅ **Authentication** - JWT-based secure login
- ✅ **Reading Management** - CRUD operations for readings
- ✅ **Topic Management** - Manage Buddhist topics with colors/icons
- ✅ **Dashboard** - Statistics and quick actions
- ✅ **Real-time Updates** - Auto-refresh after changes
- ✅ **Search & Filter** - Advanced content management
- ✅ **Pagination** - Efficient data handling

### Backend (Express.js + MongoDB)
- ✅ **RESTful API** - Clean and well-documented endpoints
- ✅ **JWT Authentication** - Secure admin access
- ✅ **RBAC** - Role-based access control (ADMIN/EDITOR)
- ✅ **Rate Limiting** - Protection against abuse
- ✅ **Text Search** - Full-text search capabilities
- ✅ **Multiple Readings per Day** - Support for multiple readings
- ✅ **Authentic Content** - Real Buddhist texts with proper citations

## 🏗️ Architecture

```
📁 Project Structure
├── 📱 thien_tam_app/              # Flutter Frontend
│   ├── lib/
│   │   ├── features/
│   │   │   ├── readings/          # User app features
│   │   │   └── admin/             # Admin panel features
│   │   └── core/                  # Shared utilities
│   └── android/                   # Android configuration
│
├── 🖥️ backend_thien_tam_app/     # Express.js Backend
│   ├── src/
│   │   ├── models/                # MongoDB schemas
│   │   ├── routes/                # API endpoints
│   │   ├── middlewares/           # Auth & validation
│   │   └── utils/                 # Helper functions
│   └── seed/                      # Database seeding
│
└── 📋 scripts/                    # Setup & deployment
```

## 🚀 Quick Start

### Prerequisites
- **Node.js** 18+ and npm
- **Flutter** 3.9+ and Dart 3.0+
- **MongoDB** (local or Atlas)
- **Git**

### 1. Clone Repository
```bash
git clone https://github.com/yourusername/thien-tam-app.git
cd thien-tam-app
```

### 2. Backend Setup
```bash
cd backend_thien_tam_app
npm install
npm run seed          # Seed authentic Buddhist data
npm run dev           # Start development server
```

### 3. Frontend Setup
```bash
cd thien_tam_app
flutter pub get
flutter run           # Start Flutter app
```

### 4. Access Points
- **User App**: Flutter app on device/emulator
- **Admin Panel**: Access via Settings → Admin Panel
- **API**: http://localhost:4000/api
- **Health Check**: http://localhost:4000/healthz

## 📚 Authentic Content

The app features authentic Buddhist content from traditional sources:

### 📖 Sources Included
- **Kinh Chuyển Pháp Luân** (Dhammacakkappavattana Sutta)
- **Kinh Từ Bi** (Metta Sutta)
- **Kinh Niệm Xứ** (Satipatthana Sutta)
- **Kinh Vô Thường** (Anicca Sutta)
- **Kinh Nghiệp** (Kamma Sutta)
- **Kinh Giải Thoát** (Vimutti Sutta)
- **Kinh Pháp Cú** (Dhammapada)

### 🏷️ Topics Covered
- **Tứ Diệu Đế** - Four Noble Truths
- **Bát Chánh Đạo** - Eightfold Path
- **Từ Bi** - Loving-kindness
- **Chính Niệm** - Mindfulness
- **Vô Thường** - Impermanence
- **Nhân Quả** - Cause and Effect
- **Giải Thoát** - Liberation
- **Kinh Điển** - Buddhist Scriptures

## 🛠️ Technology Stack

### Frontend (Flutter)
- **Flutter** 3.9+ - Cross-platform framework
- **Riverpod** - State management
- **Dio** - HTTP client
- **Hive** - Local storage & caching
- **Intl** - Internationalization
- **Share Plus** - Content sharing

### Backend (Node.js)
- **Express.js** - Web framework
- **MongoDB** + **Mongoose** - Database & ODM
- **JWT** - Authentication
- **Bcrypt** - Password hashing
- **Zod** - Data validation
- **TypeScript** - Type safety
- **Helmet** - Security headers
- **Rate Limiting** - API protection

### Database
- **MongoDB** - NoSQL database
- **Text Indexing** - Full-text search
- **Aggregation** - Complex queries

## 🔐 Security Features

- ✅ **JWT Authentication** - Secure token-based auth
- ✅ **Password Hashing** - Bcrypt with salt rounds
- ✅ **Rate Limiting** - Prevent API abuse
- ✅ **Input Validation** - Zod schema validation
- ✅ **Security Headers** - Helmet.js protection
- ✅ **CORS Configuration** - Controlled cross-origin access
- ✅ **Environment Variables** - Secure config management

## 📱 Screenshots

### User App
- **Today Page** - Daily reading with Buddhist theme
- **Calendar View** - Monthly reading overview
- **Search** - Find content by keywords
- **Detail Page** - Full reading with source citations
- **404 Page** - Buddhist-themed error handling

### Admin Panel
- **Dashboard** - Statistics and quick actions
- **Reading Management** - CRUD operations
- **Topic Management** - Color-coded topics
- **Login** - Secure authentication

## 🚀 Deployment

### Backend Deployment
```bash
# Production build
npm run build
npm start

# Environment variables
MONGODB_URI=mongodb://your-mongodb-uri
JWT_SECRET=your-jwt-secret
PORT=4000
```

### Flutter Deployment
```bash
# Android APK
flutter build apk --release

# Android App Bundle (Play Store)
flutter build appbundle --release

# iOS (requires macOS)
flutter build ios --release
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Buddhist Community** - For authentic teachings and guidance
- **Flutter Team** - For the amazing framework
- **Express.js Community** - For robust backend tools
- **MongoDB** - For flexible database solutions

## 📞 Support

For support, email support@thientam.app or create an issue on GitHub.

---

**May this app bring peace and wisdom to all beings. 🙏**

## 🔗 Links

- **Live Demo**: [Coming Soon]
- **Documentation**: [Wiki](https://github.com/trahoangdev/thien-tam-app/wiki)
- **Issues**: [GitHub Issues](https://github.com/trahoangdev/thien-tam-app/issues)
- **Discussions**: [GitHub Discussions](https://github.com/trahoangdev/thien-tam-app/discussions)