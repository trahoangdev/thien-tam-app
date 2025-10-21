# Buddhist Readings API - Backend

Backend API cho ứng dụng Thiền Tâm, cung cấp bài đọc Phật giáo theo ngày.

## Công nghệ

- **Node.js** + **TypeScript**
- **Express.js** - Web framework
- **MongoDB** + **Mongoose** - Database
- **date-fns** - Xử lý múi giờ Asia/Ho_Chi_Minh

## Cài đặt

```bash
# Cài đặt dependencies
npm install

# Cấu hình .env (đã có sẵn)
# PORT=4000
# MONGO_URI=mongodb://localhost:27017/buddhist_readings
# TZ=Asia/Ho_Chi_Minh
```

## Chạy ứng dụng

```bash
# Khởi động MongoDB (nếu local)
mongod

# Seed dữ liệu mẫu
npm run seed

# Development mode
npm run dev

# Build
npm run build

# Production mode
npm start
```

## API Endpoints

### 1. Lấy bài đọc hôm nay
```
GET /readings/today
```

### 2. Lấy bài đọc theo ngày
```
GET /readings/2025-10-21
```

### 3. Tìm kiếm và lọc
```
GET /readings?query=chánh niệm&topic=chinh-niem&page=1&limit=10
```

### 4. Lấy danh sách theo tháng
```
GET /readings/month/2025-10
```

### 5. Lấy bài ngẫu nhiên
```
GET /readings/random
```

### 6. Health check
```
GET /healthz
```

## Cấu trúc dự án

```
src/
  ├── app.ts              # Express app config
  ├── server.ts           # Server entry point
  ├── config/
  │   └── env.ts          # Environment config
  ├── db/
  │   └── index.ts        # Database connection
  ├── models/
  │   └── Reading.ts      # Reading model
  ├── routes/
  │   └── readings.ts     # Reading routes
  ├── middlewares/
  │   └── error.ts        # Error handler
  ├── utils/
  │   └── date.ts         # Date utilities
  └── seed/
      └── seed.ts         # Database seeder
```

## Testing

```bash
# Test endpoints
curl http://localhost:4000/healthz
curl http://localhost:4000/readings/today
```

## Triển khai

Có thể deploy lên:
- **Railway**
- **Render**
- **Heroku**
- **VPS**

Nhớ cập nhật biến môi trường `MONGO_URI` với MongoDB Atlas hoặc database production.

