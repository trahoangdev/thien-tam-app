# 📄 Cloudinary PDF Setup Guide

## ⚠️ Vấn đề

PDF không hiển thị được trong app vì:
1. Backend upload PDF với `resource_type: 'raw'` → tạo URL `/raw/upload/` → không view được
2. Cloudinary FREE account mặc định **BLOCK** việc delivery PDF files

## ✅ Giải pháp

### **Bước 1: Enable PDF Delivery trong Cloudinary** (BẮT BUỘC)

1. **Login vào Cloudinary Dashboard**: https://cloudinary.com/console
2. **Vào Settings → Security**
3. **Tìm mục "Allowed file formats"** hoặc **"PDF and ZIP files delivery"**
4. **Enable/Check** option:
   - ✅ **Allow PDF and ZIP files to be delivered**
   - Hoặc: **Add `pdf` to allowed formats**

5. **Save changes**

### **Bước 2: Verify Upload Settings**

Backend đã được cập nhật để:
- Upload PDF với `resource_type: 'image'` (thay vì `'raw'`)
- Cloudinary sẽ tự động detect PDF format
- Generate URL dạng `/image/upload/` thay vì `/raw/upload/`
- PDF viewer có thể đọc được URL này

### **Bước 3: Test Upload Mới**

1. **Xóa PDF cũ** (đã upload với `resource_type: 'raw'`)
2. **Upload lại PDF** qua Admin Panel
3. **Kiểm tra URL** trong database:
   - ✅ Đúng: `https://res.cloudinary.com/.../image/upload/.../file.pdf`
   - ❌ Sai: `https://res.cloudinary.com/.../raw/upload/.../file.pdf`

## 🔍 Debug Checklist

### **Backend Logs**
Khi upload PDF, check console:
```
[CLOUDINARY] PDF upload result:
- Resource type: image (for PDF viewing)
- Secure URL: https://res.cloudinary.com/.../image/upload/...
```

### **Frontend Logs**
Khi mở PDF viewer, check console:
```
[PdfViewer] Book title: ...
[PdfViewer] Original URL: https://res.cloudinary.com/.../image/upload/...
[PdfViewer] Using direct URL: ...
[PdfViewer] Document loaded successfully!
```

### **Nếu vẫn lỗi "There was an error opening this document"**

Có thể do:
1. ❌ **Cloudinary Security Settings chưa enable PDF delivery**
   → Check lại Bước 1
   
2. ❌ **URL vẫn dạng `/raw/upload/`**
   → Upload lại PDF với backend mới
   
3. ❌ **Cloudinary FREE plan limitations**
   → Upgrade plan hoặc contact Cloudinary support

4. ❌ **Network/CORS issues**
   → Check network connectivity
   → Try on different network

## 📚 References

- [Cloudinary PDF Upload & Delivery](https://support.cloudinary.com/hc/en-us/articles/20970529312146-How-to-Upload-Manage-and-Deliver-PDF-Files)
- [Syncfusion PDF Viewer for Flutter](https://help.syncfusion.com/flutter/pdf-viewer/overview)
- [Cloudinary Security Settings](https://cloudinary.com/documentation/control_access_to_media)

## 💡 Alternative Solution (if still not working)

Nếu Cloudinary FREE plan không support PDF viewing, có thể:
1. **Download PDF to local storage** rồi view từ local file
2. **Dùng Cloudinary Transformation** để convert PDF → images
3. **Sử dụng dịch vụ khác** như Firebase Storage, AWS S3
4. **Upgrade Cloudinary plan** để unlock full PDF support

