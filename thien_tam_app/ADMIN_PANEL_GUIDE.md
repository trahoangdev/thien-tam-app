# 🎛️ Admin Panel - Hướng dẫn sử dụng

## Tổng quan

Admin Panel là giao diện quản lý nội dung cho ứng dụng Thiền Tâm, cho phép admin **CRUD** (Create, Read, Update, Delete) bài đọc một cách trực quan và dễ dàng.

## ✅ Đã hoàn thành

### 📦 **Models & Data Layer**
- ✅ `AdminUser` - Model người dùng admin
- ✅ `AuthResponse` - Response từ login API
- ✅ `LoginRequest` - Request body cho login
- ✅ `ReadingCreateRequest` - Request tạo bài đọc mới
- ✅ `ReadingUpdateRequest` - Request cập nhật bài đọc
- ✅ `AdminApiClient` - HTTP client với auth token support

### 🎯 **Providers (State Management)**
- ✅ `authNotifierProvider` - Quản lý auth state (login/logout)
- ✅ `isAuthenticatedProvider` - Check trạng thái đăng nhập
- ✅ `adminReadingsProvider` - Fetch danh sách readings (có pagination)
- ✅ `adminReadingByIdProvider` - Fetch chi tiết 1 reading
- ✅ `adminStatsProvider` - Lấy thống kê
- ✅ `adminReadingsCrudProvider` - CRUD operations (create, update, delete)

### 🎨 **UI Pages**
- ✅ `AdminLoginPage` - Màn hình đăng nhập admin
- ✅ `AdminHomePage` - Dashboard với thống kê và quick actions
- ✅ `AdminReadingsListPage` - Danh sách bài đọc với pagination & search
- ✅ `AdminReadingFormPage` - Form tạo/sửa bài đọc (dual mode)

### 🔗 **Navigation**
- ✅ Routes được thêm vào `main.dart`:
  - `/admin/login` - Đăng nhập
  - `/admin/home` - Dashboard
  - `/admin/readings` - Danh sách bài đọc
  - `/admin/readings/create` - Tạo bài mới
- ✅ Entry point từ Settings page (icon Admin Panel)

## 🚀 Cách sử dụng

### 1. **Truy cập Admin Panel**

Từ app chính:
```
Settings (Cài Đặt) → Admin Panel → Login
```

### 2. **Đăng nhập**

Credentials (như đã seed ở backend):
- **Email:** `admin@thientam.local`
- **Password:** `ThienTam@2025`

### 3. **Dashboard (Home)**

Sau khi đăng nhập thành công, bạn sẽ thấy:
- **Thống kê:**
  - Tổng số bài đọc
  - Số lượng topics
- **Quick Actions:**
  - Quản lý bài đọc
  - Tạo bài mới
  - Thống kê

### 4. **Quản lý bài đọc**

#### **Xem danh sách:**
- Tất cả bài đọc hiển thị dạng list với pagination
- Mỗi trang: 20 bài
- Có search bar để tìm kiếm

#### **Tạo bài mới:**
1. Click FAB "Tạo bài mới" hoặc "+" button
2. Điền form:
   - **Ngày:** Chọn từ date picker
   - **Tiêu đề:** (Required)
   - **Nội dung:** (Required, multiline)
   - **Topics:** Ngăn cách bởi dấu phẩy (ví dụ: `chinh-niem, tu-bi`)
   - **Keywords:** Ngăn cách bởi dấu phẩy
   - **Nguồn:** Mặc định "Admin"
3. Click "Tạo bài đọc"
4. Thông báo thành công → Quay về danh sách

#### **Sửa bài:**
1. Click icon ✏️ (Edit) hoặc click vào card
2. Form hiển thị dữ liệu hiện tại
3. ⚠️ **Không thể đổi ngày** khi sửa
4. Chỉnh sửa nội dung cần thiết
5. Click "Cập nhật"

#### **Xóa bài:**
1. Click icon 🗑️ (Delete)
2. Xác nhận dialog
3. Bài đọc bị xóa vĩnh viễn

### 5. **Đăng xuất**

Click icon Logout ở AppBar → Xác nhận → Quay về login page

## 🔐 Security Features

- ✅ **JWT Authentication:** Token được lưu trong Hive (persistent)
- ✅ **Auto token refresh:** Sử dụng refresh token khi access token hết hạn
- ✅ **Protected routes:** Tất cả admin endpoints yêu cầu auth
- ✅ **Role-based access:** Hỗ trợ ADMIN và EDITOR roles
- ✅ **Auto logout:** Khi token hết hạn hoặc invalid

## 📱 Responsive Design

Admin panel được thiết kế responsive, hoạt động tốt trên:
- ✅ Mobile (portrait/landscape)
- ✅ Tablet
- ✅ Desktop/Web

## 🎨 UI/UX Features

- ✅ **Material Design 3:** Theo theme của app chính
- ✅ **Dark mode support:** Tự động theo system theme
- ✅ **Loading states:** CircularProgressIndicator khi fetch data
- ✅ **Error handling:** Hiển thị lỗi rõ ràng với retry option
- ✅ **Success feedback:** SnackBar thông báo sau mỗi action
- ✅ **Confirmation dialogs:** Trước khi xóa hoặc logout
- ✅ **Form validation:** Check required fields

## 📊 API Integration

### Base URL
```dart
http://localhost:4000
```

### Endpoints đã tích hợp:
- ✅ `POST /auth/login` - Login
- ✅ `POST /auth/refresh` - Refresh token
- ✅ `GET /auth/me` - Get current user
- ✅ `GET /admin/readings` - List readings (pagination, search, filter)
- ✅ `GET /admin/readings/:id` - Get single reading
- ✅ `POST /admin/readings` - Create reading
- ✅ `PUT /admin/readings/:id` - Update reading
- ✅ `DELETE /admin/readings/:id` - Delete reading
- ✅ `GET /admin/stats` - Get statistics

## 🧪 Testing Guide

### Kiểm tra tính năng:

#### 1. **Authentication Flow**
```
1. Mở app → Settings → Admin Panel
2. Nhập email/password sai → Kiểm tra error message
3. Nhập đúng credentials → Navigate to Dashboard
4. Logout → Quay về login page
5. Login lại → Token được restore (không cần login lại nếu chưa logout)
```

#### 2. **CRUD Operations**
```
1. Tạo bài mới:
   - Chọn ngày hôm nay
   - Nhập tiêu đề và nội dung
   - Submit → Check trong list

2. Sửa bài:
   - Click Edit trên bài vừa tạo
   - Sửa title
   - Save → Check title đã thay đổi

3. Xóa bài:
   - Click Delete
   - Confirm
   - Check bài đã biến mất khỏi list
```

#### 3. **Pagination & Search**
```
1. Scroll qua các trang (nếu có > 20 bài)
2. Search một từ khóa
3. Kiểm tra kết quả hiển thị đúng
```

#### 4. **Error Handling**
```
1. Tắt backend server
2. Thử create/update/delete
3. Kiểm tra error message hiển thị
4. Retry button hoạt động

5. Bật lại server
6. Retry → Should work
```

## 📝 Development Notes

### Cấu trúc thư mục:
```
thien_tam_app/lib/features/admin/
├── data/
│   ├── models/
│   │   ├── admin_user.dart
│   │   ├── auth_response.dart
│   │   ├── login_request.dart
│   │   ├── reading_create_request.dart
│   │   └── reading_update_request.dart
│   └── admin_api_client.dart
└── presentation/
    ├── providers/
    │   ├── admin_providers.dart
    │   └── admin_readings_providers.dart
    └── pages/
        ├── admin_login_page.dart
        ├── admin_home_page.dart
        ├── admin_readings_list_page.dart
        └── admin_reading_form_page.dart
```

### Dependencies sử dụng:
- `flutter_riverpod` - State management
- `dio` - HTTP client
- `hive` - Local storage cho token
- `intl` - Date formatting

## 🚧 Future Enhancements (Optional)

### Tính năng có thể thêm:
- [ ] **Bulk operations:** Select multiple + delete all
- [ ] **Image upload:** Cho phép thêm ảnh vào bài đọc
- [ ] **Rich text editor:** WYSIWYG editor thay vì plain text
- [ ] **Draft system:** Lưu nháp trước khi publish
- [ ] **Version history:** Track changes của mỗi bài
- [ ] **User management:** CRUD users (ADMIN only)
- [ ] **Analytics:** Chi tiết hơn về views, bookmarks
- [ ] **Export/Import:** Backup/restore dữ liệu
- [ ] **Scheduled posts:** Đặt lịch publish
- [ ] **Multi-language support:** Bài đọc đa ngôn ngữ

## 🐛 Troubleshooting

### Lỗi thường gặp:

**1. "Network error" khi login:**
- Kiểm tra backend server đang chạy (`npm run dev`)
- Kiểm tra base URL trong `admin_api_client.dart`

**2. "Token không hợp lệ":**
- Logout và login lại
- Kiểm tra JWT_SECRET trong backend .env

**3. "Không tải được danh sách":**
- Kiểm tra seeded data: `npm run seed`
- Kiểm tra network logs trong dev tools

## ✅ Status

**Admin Panel: COMPLETED & READY TO USE** 🎉

- ✅ Authentication: Working
- ✅ CRUD Operations: Working
- ✅ Pagination: Working
- ✅ Search: Working  
- ✅ Error Handling: Working
- ✅ State Management: Working
- ✅ UI/UX: Polished

---

**Last updated:** October 21, 2025  
**Version:** 1.0.0

