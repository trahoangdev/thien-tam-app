# 🎨 Bảng Màu Thiền Tâm - Phong Cách Phật Giáo Nhẹ Nhàng

## Triết lý thiết kế
Màu sắc **mộc mạc, thanh tịnh, dịu mắt** như giấy cổ/parchment, tránh trắng chói gây mỏi mắt.

---

## Light Mode (Chế độ Sáng)

### Màu Chính
- **Primary**: `#B8956A` - Vàng gỗ nhạt (Camel/Wood)
- **Secondary**: `#A67C52` - Nâu đồng (Bronze Brown)

### Màu Nền
- **Background**: `#EBE4D5` - Be sáng như giấy cổ (Parchment Beige)
- **Surface**: `#F4EFE4` - Kem nhạt (Soft Cream)
- **Card**: `#FAF6ED` - Kem nhạt hơn (Lighter Cream)
- **Card Border**: `#E0D5C7` - Viền nhẹ (Light Border)

### Màu Text
- **Body Text**: `#3D3429` - Nâu đậm, dễ đọc (Dark Brown)
- **Body Large**: `#4A3F35` - Nâu trung (Medium Brown)
- **Body Medium**: `#5A4F45` - Nâu nhạt (Light Brown)

### Đặc điểm
- ✅ **Không trắng chói** - Sử dụng tông be/kem
- ✅ **Dễ chịu cho mắt** - Giảm blue light, tông ấm
- ✅ **Contrast vừa phải** - Text nâu đậm trên nền be
- ✅ **Shadow nhẹ** - Elevation 0.5, opacity 0.02

---

## Dark Mode (Chế độ Tối)

### Màu Chính
- **Primary**: `#D4B896` - Vàng gỗ sáng hơn (Light Wood)
- **Secondary**: `#C19A6B` - Vàng camel (Camel)

### Màu Nền
- **Background**: `#1A1410` - Nâu đen (Dark Brown)
- **Surface**: `#2C2416` - Nâu đất (Earth Brown)

---

## So sánh với Bảng Màu Cũ

| Element | Màu Cũ (Chói) | Màu Mới (Dịu) |
|---------|---------------|---------------|
| Background | `#FFFBF0` (Trắng ngà chói) | `#EBE4D5` (Be giấy cổ) |
| Surface | `#FFF8E7` (Trắng kem chói) | `#F4EFE4` (Kem nhạt) |
| Card | `#FFFFFF` (Trắng tinh) | `#FAF6ED` (Kem nhạt) |
| Primary | `#D4A574` (Vàng chói) | `#B8956A` (Vàng nhạt) |
| Text | `Colors.black87` | `#3D3429` (Nâu đậm) |
| Shadow Opacity | 0.03 | 0.02 |
| Elevation | 1.0 | 0.5 |

---

## Tham khảo
- **Phong cách**: Giấy cổ/Parchment, Vàng gỗ Phật giáo
- **Cảm hứng**: Sách Phật giáo cổ, tông màu thiền định
- **Ưu điểm**: Giảm mỏi mắt, dễ đọc lâu, thanh tịnh

---

## Sử dụng

```dart
// Primary color
Theme.of(context).colorScheme.primary  // #B8956A

// Background
Theme.of(context).colorScheme.background  // #EBE4D5

// Card/Surface
Theme.of(context).colorScheme.surface  // #F4EFE4

// Text (auto sử dụng từ bodyLarge)
Theme.of(context).textTheme.bodyLarge  // color: #4A3F35
```

---

_Cập nhật: ${DateTime.now().toString().split('.')[0]}_

