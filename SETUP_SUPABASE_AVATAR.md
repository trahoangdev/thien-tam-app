# 🔧 Hướng dẫn Setup Supabase cho Avatar Upload

## Bước 1: Tạo Storage Bucket

1. Vào **Supabase Dashboard** → **Storage**
2. Click **"New bucket"**
3. Tên bucket: `avatars`
4. **Quan trọng**: Chọn **Public bucket** (bật toggle "Public bucket")
5. Click **"Create bucket"**

---

## Bước 2: Setup Row Level Security (RLS) Policies

Vào **SQL Editor** trong Supabase và chạy các lệnh sau:

### 2.1. Tạo policy cho SELECT (đọc file)

```sql
-- Allow anyone to read files from avatars bucket
CREATE POLICY "Avatar images are publicly accessible" ON storage.objects
FOR SELECT
TO public
USING (bucket_id = 'avatars');
```

### 2.2. Tạo policy cho INSERT (upload file)

```sql
-- Allow authenticated users to upload their own avatars
CREATE POLICY "Users can upload their own avatars" ON storage.objects
FOR INSERT
TO public
WITH CHECK (bucket_id = 'avatars' AND (storage.foldername(name))[1] = 'users');
```

### 2.3. Tạo policy cho UPDATE (cập nhật file)

```sql
-- Allow users to update their own avatars
CREATE POLICY "Users can update their own avatars" ON storage.objects
FOR UPDATE
TO public
USING (bucket_id = 'avatars' AND (storage.foldername(name))[1] = 'users');
```

### 2.4. Tạo policy cho DELETE (xóa file)

```sql
-- Allow users to delete their own avatars
CREATE POLICY "Users can delete their own avatars" ON storage.objects
FOR DELETE
TO public
USING (bucket_id = 'avatars' AND (storage.foldername(name))[1] = 'users');
```

---

## Bước 3: Kiểm tra Settings

Vào **Storage** → **Settings** → **Policies** và đảm bảo:

- ✅ **Enable RLS**: Bật
- ✅ Bucket `avatars` đã có 4 policies như trên

---

## Bước 4: Test Upload

1. Chạy app: `flutter run`
2. Vào **Settings** → Click vào avatar → Chọn ảnh
3. Upload sẽ thành công! ✅

---

## 🔍 Troubleshooting

### Lỗi: "new row violates row-level security policy"

**Nguyên nhân**: Policies chưa được tạo đúng

**Giải pháp**:
1. Kiểm tra lại bucket có tên là `avatars` (không thừa `s`)
2. Kiểm tra bucket có **Public** không
3. Chạy lại tất cả các SQL policies ở trên
4. Reload app

### Lỗi: "bucket not found"

**Nguyên nhân**: Bucket chưa được tạo

**Giải pháp**: Tạo lại bucket `avatars` trong Storage

### Lỗi: "invalid URL"

**Nguyên nhân**: URL Supabase sai

**Giải pháp**: Kiểm tra `AppConfig.supabaseUrl` trong code

---

## 📝 Alternative: Nếu vẫn lỗi, dùng cách này

Nếu policies phức tạp quá, bạn có thể tạm thời **disable RLS** cho bucket avatars:

```sql
-- TẠM THỜI - Development only
-- Disable RLS for avatars bucket
CREATE POLICY "Disable RLS for avatars" ON storage.objects
FOR ALL
TO public
USING (bucket_id = 'avatars')
WITH CHECK (bucket_id = 'avatars');
```

**⚠️ Cảnh báo**: Cách này cho phép mọi người upload/xóa avatars. Chỉ dùng cho development!

---

## ✅ Production Setup

Khi deploy production, nên chuyển sang authentication-based policies:

```sql
-- Production: Only authenticated users
CREATE POLICY "Authenticated users can upload avatars" ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'avatars' AND (storage.foldername(name))[1] = 'users');

-- Production: Users can only update their own files
CREATE POLICY "Users can update own avatars" ON storage.objects
FOR UPDATE
TO authenticated
USING (bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[2]);
```

**Note**: Cần integrate Supabase Auth vào app cho production.

---

## 🔗 Useful Links

- Supabase Storage Docs: https://supabase.com/docs/guides/storage
- RLS Policies: https://supabase.com/docs/guides/auth/row-level-security
- Storage API: https://supabase.com/docs/reference/javascript/storage

---

**Chúc bạn thành công! 🙏**

