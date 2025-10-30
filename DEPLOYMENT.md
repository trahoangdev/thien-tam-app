# Deployment Guide - Thiền Tâm App

This document provides comprehensive instructions for deploying the Thiền Tâm App to various platforms.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Backend Deployment](#backend-deployment)
- [Frontend Deployment](#frontend-deployment)
- [Database Setup](#database-setup)
- [Environment Variables](#environment-variables)
- [Platform-Specific Deployment](#platform-specific-deployment)
- [Troubleshooting](#troubleshooting)

---

## Prerequisites

### Required Accounts
- [ ] MongoDB Atlas account (or local MongoDB)
- [ ] Cloudinary account (for audio/PDF storage)
- [ ] ElevenLabs API key (for TTS)
- [ ] Google Gemini API key (for chatbot)
- [ ] Domain name (optional, for production)

### Required Tools
- Node.js 18+ installed locally
- Flutter 3.9+ installed locally
- Git
- Command line access

---

## Backend Deployment

### Option 1: Railway (Recommended)

1. **Create Railway Account**
   - Visit [railway.app](https://railway.app)
   - Sign up with GitHub

2. **Create New Project**
   ```bash
   # Clone repository
   git clone https://github.com/trahoangdev/thien-tam-app.git
   cd thien-tam-app
   ```

3. **Deploy Backend**
   - Click "New Project" → "Deploy from GitHub repo"
   - Select the repository
   - Add MongoDB database service
   - Set root directory to `backend_thien_tam_app`

4. **Configure Environment Variables**
   ```
   MONGO_URI=<mongodb-connection-string>
   JWT_SECRET=<your-secret-key>
   REFRESH_SECRET=<your-refresh-secret>
   PORT=4000
   NODE_ENV=production
   ELEVENLABS_API_KEY=<your-key>
   GOOGLE_GEMINI_API_KEY=<your-key>
   CLOUDINARY_CLOUD_NAME=<your-cloud-name>
   CLOUDINARY_API_KEY=<your-key>
   CLOUDINARY_API_SECRET=<your-secret>
   ```

5. **Build Command**
   ```bash
   npm run build
   ```

6. **Start Command**
   ```bash
   npm start
   ```

### Option 2: Render

1. **Create Account**
   - Visit [render.com](https://render.com)
   - Sign up with GitHub

2. **Create Web Service**
   - New → Web Service
   - Connect GitHub repository
   - Root directory: `backend_thien_tam_app`

3. **Configure**
   ```yaml
   Build Command: npm install && npm run build
   Start Command: npm start
   ```

4. **Add Environment Variables** (same as Railway)

### Option 3: VPS (Ubuntu)

1. **SSH into Server**
   ```bash
   ssh user@your-server-ip
   ```

2. **Install Node.js**
   ```bash
   curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
   sudo apt-get install -y nodejs
   ```

3. **Install MongoDB**
   ```bash
   sudo apt-get install -y mongodb
   sudo systemctl start mongodb
   sudo systemctl enable mongodb
   ```

4. **Clone Repository**
   ```bash
   git clone https://github.com/trahoangdev/thien-tam-app.git
   cd thien-tam-app/backend_thien_tam_app
   ```

5. **Install Dependencies**
   ```bash
   npm install
   npm run build
   ```

6. **Setup PM2**
   ```bash
   sudo npm install -g pm2
   pm2 start dist/server.js --name thien-tam-api
   pm2 save
   pm2 startup
   ```

7. **Setup Nginx**
   ```nginx
   server {
       listen 80;
       server_name your-domain.com;

       location / {
           proxy_pass http://localhost:4000;
           proxy_http_version 1.1;
           proxy_set_header Upgrade $http_upgrade;
           proxy_set_header Connection 'upgrade';
           proxy_set_header Host $host;
           proxy_cache_bypass $http_upgrade;
       }
   }
   ```

---

## Frontend Deployment

### Android APK

1. **Build Release APK**
   ```bash
   cd thien_tam_app
   flutter build apk --release
   ```

2. **APK Location**
   ```
   build/app/outputs/flutter-apk/app-release.apk
   ```

3. **Upload to Google Play**
   - Visit [Google Play Console](https://play.google.com/console)
   - Create app listing
   - Upload APK
   - Complete store listing

### Android App Bundle (Recommended for Play Store)

1. **Build App Bundle**
   ```bash
   flutter build appbundle --release
   ```

2. **Bundle Location**
   ```
   build/app/outputs/bundle/release/app-release.aab
   ```

3. **Upload to Google Play**
   - Same process as APK
   - Use "Internal Testing" for beta testing

### iOS Deployment (Requires macOS)

1. **Open Xcode Project**
   ```bash
   cd thien_tam_app
   open ios/Runner.xcworkspace
   ```

2. **Configure Signing**
   - Select development team
   - Create provisioning profile

3. **Build Archive**
   - Product → Archive
   - Upload to App Store Connect

4. **Submit for Review**
   - Visit [App Store Connect](https://appstoreconnect.apple.com)
   - Complete app listing
   - Submit for review

---

## Database Setup

### MongoDB Atlas (Cloud)

1. **Create Cluster**
   - Visit [MongoDB Atlas](https://www.mongodb.com/cloud/atlas)
   - Create free M0 cluster
   - Choose cloud provider and region

2. **Configure Network Access**
   - Add IP address or `0.0.0.0/0` for all IPs

3. **Create Database User**
   - Database Access → Add New User
   - Set username and password
   - Grant "Atlas Admin" role

4. **Get Connection String**
   ```
   mongodb+srv://<username>:<password>@cluster0.xxxxx.mongodb.net/thientam
   ```

### Local MongoDB

1. **Install MongoDB**
   ```bash
   # macOS
   brew install mongodb-community

   # Linux
   sudo apt-get install -y mongodb

   # Windows
   # Download installer from mongodb.com
   ```

2. **Start MongoDB**
   ```bash
   mongod --dbpath /path/to/data
   ```

3. **Connection String**
   ```
   mongodb://localhost:27017/thientam
   ```

### Seed Database

```bash
cd backend_thien_tam_app
npm run seed
npm run seed:admin
npm run seed:books
```

---

## Environment Variables

### Backend (.env)

```env
# Database
MONGO_URI=mongodb+srv://user:pass@cluster.mongodb.net/thientam

# JWT
JWT_SECRET=your-super-secret-jwt-key-here-change-this
REFRESH_SECRET=your-super-secret-refresh-key-here

# Server
PORT=4000
NODE_ENV=production

# API Keys
ELEVENLABS_API_KEY=your-elevenlabs-api-key
GOOGLE_GEMINI_API_KEY=your-gemini-api-key

# Cloudinary
CLOUDINARY_CLOUD_NAME=your-cloud-name
CLOUDINARY_API_KEY=your-api-key
CLOUDINARY_API_SECRET=your-api-secret

# Admin Account (for initial setup)
ADMIN_EMAIL=admin@thientam.local
ADMIN_PASSWORD=your-secure-password
```

### Frontend (lib/core/config.dart)

Update API base URL in `lib/core/config.dart`:

```dart
static String get apiBaseUrl {
  const String apiUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://your-backend-url.com',
  );
  return apiUrl;
}
```

Or use flutter run with environment:
```bash
flutter run --dart-define=API_BASE_URL=https://your-backend-url.com
```

---

## Platform-Specific Deployment

### GitHub Pages (Documentation)

```bash
git checkout --orphan gh-pages
git add -A
git commit -m "docs: Initial documentation"
git push origin gh-pages
```

### Docker Deployment

1. **Create Dockerfile** (already in project)
2. **Build Image**
   ```bash
   docker build -t thien-tam-api ./backend_thien_tam_app
   ```
3. **Run Container**
   ```bash
   docker run -p 4000:4000 --env-file .env thien-tam-api
   ```

---

## Troubleshooting

### Backend Issues

**Problem**: Cannot connect to MongoDB
```bash
# Check MongoDB connection
mongosh "your-connection-string"
```

**Problem**: CORS errors
- Check CORS configuration in app.ts
- Add frontend domain to allowed origins

**Problem**: JWT token expired
- Check token expiration settings
- Implement token refresh mechanism

### Frontend Issues

**Problem**: White screen on app launch
- Check API base URL configuration
- Verify backend is running
- Check console for errors

**Problem**: Build fails
```bash
# Clean build
flutter clean
flutter pub get
flutter build apk --release
```

**Problem**: Network request failed
- Check internet permission in AndroidManifest.xml
- Verify backend URL is correct
- Test with emulator (10.0.2.2:4000)

---

## Security Checklist

- [ ] Use strong JWT secrets (min 32 characters)
- [ ] Enable HTTPS for production
- [ ] Set up rate limiting
- [ ] Configure CORS properly
- [ ] Use environment variables for secrets
- [ ] Enable MongoDB authentication
- [ ] Regular security updates
- [ ] Monitor logs for suspicious activity

---

## Post-Deployment

### Verification

1. **Test API Endpoints**
   ```bash
   curl https://your-api.com/healthz
   ```

2. **Test Admin Login**
   - Log in with seeded admin credentials
   - Verify dashboard loads

3. **Test User Features**
   - Register new user
   - View readings
   - Test search and bookmarks

### Monitoring

- Set up error logging (Sentry, LogRocket)
- Monitor API response times
- Track user analytics (Firebase, Mixpanel)
- Set up uptime monitoring (UptimeRobot, Pingdom)

---

## Maintenance

### Regular Tasks

- Update dependencies monthly
- Backup database weekly
- Review logs daily
- Security patches as needed

### Backups

```bash
# MongoDB backup
mongodump --uri="your-connection-string" --out=/backup

# Restore
mongorestore --uri="your-connection-string" /backup
```

---

## Support

For deployment issues:
- Check [GitHub Issues](https://github.com/trahoangdev/thien-tam-app/issues)
- Review [Documentation Wiki](https://github.com/trahoangdev/thien-tam-app/wiki)
- Email: support@thientam.app

---

**Last Updated**: October 28, 2025
**Version**: 1.3.1

