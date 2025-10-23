import 'package:flutter/material.dart';

// Enum cho loại ngày lễ
enum HolidayType {
  major('Đại lễ', Colors.red, Icons.star),
  traditional('Truyền thống', Colors.orange, Icons.home),
  buddhist('Phật giáo', Colors.blue, Icons.temple_buddhist);

  const HolidayType(this.displayName, this.color, this.icon);

  final String displayName;
  final Color color;
  final IconData icon;
}

// Class đại diện cho ngày lễ Phật giáo
class BuddhistHoliday {
  final int day;
  final String name;
  final String description;
  final HolidayType type;

  const BuddhistHoliday(this.day, this.name, this.description, this.type);

  Color getColor() => type.color;
  IconData getIcon() => type.icon;
}

class BuddhistCalendarService {
  // Ngày lễ Phật giáo quan trọng (âm lịch) - Cập nhật theo tong_hop_ngay_le.md
  static final Map<String, List<BuddhistHoliday>> buddhistHolidays = {
    '1': [
      BuddhistHoliday(
        1,
        'Tết Nguyên Đán',
        'Tết cổ truyền Việt Nam - Cúng đầu năm',
        HolidayType.major,
      ),
      BuddhistHoliday(
        8,
        'Ngày Bát Quan Trai',
        'Giới tu cư sĩ tại gia, thực hành 8 giới trong 1 ngày đêm',
        HolidayType.buddhist,
      ),
      BuddhistHoliday(
        15,
        'Rằm Tháng Giêng (Nguyên Tiêu)',
        'Cầu an, tạ ơn chư Phật, mở đầu năm tu học',
        HolidayType.major,
      ),
    ],
    '2': [
      BuddhistHoliday(
        1,
        'Mùng Một tháng Hai',
        'Ngày chay, phát nguyện thiện lành đầu tháng',
        HolidayType.buddhist,
      ),
      BuddhistHoliday(
        8,
        'Kỷ niệm Đức Phật Thích Ca thành đạo',
        'Đạt giác ngộ dưới cội Bồ đề',
        HolidayType.major,
      ),
      BuddhistHoliday(
        8,
        'Ngày Bát Quan Trai',
        'Giới tu cư sĩ tại gia, thực hành 8 giới trong 1 ngày đêm',
        HolidayType.buddhist,
      ),
      BuddhistHoliday(
        15,
        'Ngày Đức Phật nhập Niết-bàn',
        'Tưởng niệm sự viên tịch của Đức Thế Tôn',
        HolidayType.major,
      ),
      BuddhistHoliday(
        19,
        'Vía Bồ Tát Quán Thế Âm đản sinh',
        'Tưởng nhớ tâm từ bi cứu khổ',
        HolidayType.major,
      ),
      BuddhistHoliday(
        21,
        'Vía Bồ Tát Phổ Hiền',
        'Biểu trưng hạnh nguyện, hành động',
        HolidayType.major,
      ),
    ],
    '3': [
      BuddhistHoliday(
        1,
        'Mùng Một tháng Ba',
        'Ngày chay, phát nguyện thiện lành đầu tháng',
        HolidayType.buddhist,
      ),
      BuddhistHoliday(
        8,
        'Ngày Bát Quan Trai',
        'Giới tu cư sĩ tại gia, thực hành 8 giới trong 1 ngày đêm',
        HolidayType.buddhist,
      ),
      BuddhistHoliday(
        15,
        'Rằm tháng Ba',
        'Ngày sám hối, tụng giới, cúng dường chư Phật',
        HolidayType.buddhist,
      ),
      BuddhistHoliday(
        16,
        'Vía Bồ Tát Chuẩn Đề',
        'Cầu trí tuệ, diệt chướng',
        HolidayType.major,
      ),
    ],
    '4': [
      BuddhistHoliday(
        1,
        'Mùng Một tháng Tư',
        'Ngày chay, phát nguyện thiện lành đầu tháng',
        HolidayType.buddhist,
      ),
      BuddhistHoliday(
        8,
        'Phật Đản (Vesak)',
        'Kỷ niệm Đức Phật Thích Ca Mâu Ni đản sinh',
        HolidayType.major,
      ),
      BuddhistHoliday(
        8,
        'Ngày Bát Quan Trai',
        'Giới tu cư sĩ tại gia, thực hành 8 giới trong 1 ngày đêm',
        HolidayType.buddhist,
      ),
      BuddhistHoliday(
        15,
        'Rằm tháng Tư',
        'Kỷ niệm Phật thành đạo theo truyền thống Nam truyền',
        HolidayType.major,
      ),
    ],
    '5': [
      BuddhistHoliday(
        1,
        'Mùng Một tháng Năm',
        'Ngày chay, phát nguyện thiện lành đầu tháng',
        HolidayType.buddhist,
      ),
      BuddhistHoliday(
        8,
        'Ngày Bát Quan Trai',
        'Giới tu cư sĩ tại gia, thực hành 8 giới trong 1 ngày đêm',
        HolidayType.buddhist,
      ),
      BuddhistHoliday(
        15,
        'Rằm tháng Năm',
        'Ngày sám hối, tụng giới, cúng dường chư Phật',
        HolidayType.buddhist,
      ),
    ],
    '6': [
      BuddhistHoliday(
        1,
        'Mùng Một tháng Sáu',
        'Ngày chay, phát nguyện thiện lành đầu tháng',
        HolidayType.buddhist,
      ),
      BuddhistHoliday(
        3,
        'Vía Bồ Tát Đại Thế Chí',
        'Biểu trưng cho trí tuệ quang minh',
        HolidayType.major,
      ),
      BuddhistHoliday(
        8,
        'Ngày Bát Quan Trai',
        'Giới tu cư sĩ tại gia, thực hành 8 giới trong 1 ngày đêm',
        HolidayType.buddhist,
      ),
      BuddhistHoliday(
        15,
        'Rằm tháng Sáu',
        'Ngày sám hối, tụng giới, cúng dường chư Phật',
        HolidayType.buddhist,
      ),
      BuddhistHoliday(
        19,
        'Vía Bồ Tát Quán Thế Âm thành đạo',
        'Nhắc nhở thực hành hạnh từ bi',
        HolidayType.major,
      ),
    ],
    '7': [
      BuddhistHoliday(
        1,
        'Mùng Một tháng Bảy',
        'Ngày chay, phát nguyện thiện lành đầu tháng',
        HolidayType.buddhist,
      ),
      BuddhistHoliday(
        8,
        'Ngày Bát Quan Trai',
        'Giới tu cư sĩ tại gia, thực hành 8 giới trong 1 ngày đêm',
        HolidayType.buddhist,
      ),
      BuddhistHoliday(
        13,
        'Vía Đại Đức Tăng',
        'Tưởng niệm chư Tăng, chuẩn bị Vu Lan',
        HolidayType.major,
      ),
      BuddhistHoliday(
        15,
        'Vu Lan Báo Hiếu',
        'Cầu siêu cha mẹ, tri ân tổ tiên, gắn với Tôn giả Mục Kiền Liên',
        HolidayType.major,
      ),
      BuddhistHoliday(
        30,
        'Hạ tự - Mãn hạ',
        'Kết thúc an cư kiết hạ',
        HolidayType.major,
      ),
    ],
    '8': [
      BuddhistHoliday(
        1,
        'Mùng Một tháng Tám',
        'Ngày chay, phát nguyện thiện lành đầu tháng',
        HolidayType.buddhist,
      ),
      BuddhistHoliday(
        8,
        'Ngày Bát Quan Trai',
        'Giới tu cư sĩ tại gia, thực hành 8 giới trong 1 ngày đêm',
        HolidayType.buddhist,
      ),
      BuddhistHoliday(
        15,
        'Rằm tháng Tám',
        'Ngày sám hối, tụng giới, cúng dường chư Phật',
        HolidayType.buddhist,
      ),
      BuddhistHoliday(
        30,
        'Vía Địa Tạng Bồ Tát',
        'Cứu độ chúng sinh nơi địa ngục, báo hiếu cha mẹ',
        HolidayType.major,
      ),
    ],
    '9': [
      BuddhistHoliday(
        1,
        'Mùng Một tháng Chín',
        'Ngày chay, phát nguyện thiện lành đầu tháng',
        HolidayType.buddhist,
      ),
      BuddhistHoliday(
        8,
        'Ngày Bát Quan Trai',
        'Giới tu cư sĩ tại gia, thực hành 8 giới trong 1 ngày đêm',
        HolidayType.buddhist,
      ),
      BuddhistHoliday(
        15,
        'Rằm tháng Chín',
        'Ngày sám hối, tụng giới, cúng dường chư Phật',
        HolidayType.buddhist,
      ),
      BuddhistHoliday(
        19,
        'Vía Quán Thế Âm xuất gia',
        'Gợi nhắc tinh tấn tu học',
        HolidayType.major,
      ),
      BuddhistHoliday(
        30,
        'Hạ Nguyên',
        'Lễ tạ pháp, hồi hướng công đức',
        HolidayType.major,
      ),
    ],
    '10': [
      BuddhistHoliday(
        1,
        'Mùng Một tháng Mười',
        'Ngày chay, phát nguyện thiện lành đầu tháng',
        HolidayType.buddhist,
      ),
      BuddhistHoliday(
        8,
        'Ngày Bát Quan Trai',
        'Giới tu cư sĩ tại gia, thực hành 8 giới trong 1 ngày đêm',
        HolidayType.buddhist,
      ),
      BuddhistHoliday(
        15,
        'Rằm tháng Mười (Tết Hạ Nguyên)',
        'Kết thúc mùa an cư, tạ pháp, hồi hướng công đức',
        HolidayType.major,
      ),
    ],
    '11': [
      BuddhistHoliday(
        1,
        'Mùng Một tháng Mười Một',
        'Ngày chay, phát nguyện thiện lành đầu tháng',
        HolidayType.buddhist,
      ),
      BuddhistHoliday(
        8,
        'Ngày Bát Quan Trai',
        'Giới tu cư sĩ tại gia, thực hành 8 giới trong 1 ngày đêm',
        HolidayType.buddhist,
      ),
      BuddhistHoliday(
        15,
        'Rằm tháng Mười Một',
        'Ngày sám hối, tụng giới, cúng dường chư Phật',
        HolidayType.buddhist,
      ),
      BuddhistHoliday(
        17,
        'Lễ Tổ Sư Đạt Ma',
        'Kỷ niệm Tổ sư sáng lập Thiền tông Trung Hoa',
        HolidayType.major,
      ),
    ],
    '12': [
      BuddhistHoliday(
        1,
        'Mùng Một tháng Chạp',
        'Ngày chay, phát nguyện thiện lành đầu tháng',
        HolidayType.buddhist,
      ),
      BuddhistHoliday(
        8,
        'Phật thành đạo (theo Bắc truyền)',
        'Đức Phật chứng ngộ dưới cây Bồ đề',
        HolidayType.major,
      ),
      BuddhistHoliday(
        8,
        'Ngày Bát Quan Trai',
        'Giới tu cư sĩ tại gia, thực hành 8 giới trong 1 ngày đêm',
        HolidayType.buddhist,
      ),
      BuddhistHoliday(
        15,
        'Rằm tháng Chạp',
        'Ngày sám hối, tụng giới, cúng dường chư Phật',
        HolidayType.buddhist,
      ),
      BuddhistHoliday(
        23,
        'Cúng Ông Táo',
        'Tổng kết năm, cầu bình an',
        HolidayType.traditional,
      ),
      BuddhistHoliday(
        30,
        'Tất Niên - Cúng Giao Thừa',
        'Tạ ơn, chuẩn bị năm mới',
        HolidayType.traditional,
      ),
    ],
  };

  // Ngày lễ dương lịch
  static final Map<String, List<BuddhistHoliday>> solarHolidays = {
    '1': [
      BuddhistHoliday(
        1,
        'Tết Dương Lịch',
        'Năm mới theo dương lịch',
        HolidayType.traditional,
      ),
    ],
    '5': [
      BuddhistHoliday(
        15,
        'Lễ Phật Đản (UNESCO)',
        'Ngày Phật Đản được UNESCO công nhận',
        HolidayType.major,
      ),
    ],
    '12': [
      BuddhistHoliday(
        25,
        'Giáng Sinh',
        'Lễ Giáng Sinh',
        HolidayType.traditional,
      ),
    ],
  };

  // Lấy tên ngày âm lịch
  static String getLunarDayName(int day) {
    const dayNames = [
      '',
      'Mùng Một',
      'Mùng Hai',
      'Mùng Ba',
      'Mùng Bốn',
      'Mùng Năm',
      'Mùng Sáu',
      'Mùng Bảy',
      'Mùng Tám',
      'Mùng Chín',
      'Mùng Mười',
      'Mười Một',
      'Mười Hai',
      'Mười Ba',
      'Mười Bốn',
      'Rằm',
      'Mười Sáu',
      'Mười Bảy',
      'Mười Tám',
      'Mười Chín',
      'Hai Mươi',
      'Hai Mốt',
      'Hai Hai',
      'Hai Ba',
      'Hai Tư',
      'Hai Lăm',
      'Hai Sáu',
      'Hai Bảy',
      'Hai Tám',
      'Hai Chín',
      'Ba Mươi',
    ];

    if (day >= 1 && day <= 30) {
      return dayNames[day];
    }
    return 'Ngày $day';
  }

  // Lấy ngày lễ cho tháng cụ thể
  static List<BuddhistHoliday> getHolidaysForMonth(int month) {
    final monthKey = month.toString();
    return buddhistHolidays[monthKey] ?? [];
  }

  // Lấy ngày lễ cho ngày cụ thể trong tháng
  static List<BuddhistHoliday> getHolidaysForDay(int month, int day) {
    final holidays = getHolidaysForMonth(month);
    return holidays.where((holiday) => holiday.day == day).toList();
  }

  // Lấy ngày lễ dương lịch cho tháng cụ thể
  static List<BuddhistHoliday> getSolarHolidaysForMonth(int month) {
    final monthKey = month.toString();
    return solarHolidays[monthKey] ?? [];
  }

  // Lấy ngày lễ dương lịch cho ngày cụ thể trong tháng
  static List<BuddhistHoliday> getSolarHolidaysForDay(int month, int day) {
    final holidays = getSolarHolidaysForMonth(month);
    return holidays.where((holiday) => holiday.day == day).toList();
  }

  // Kiểm tra xem có phải ngày rằm không
  static bool isFullMoonDay(int day) {
    return day == 15;
  }

  // Lấy tên tháng âm lịch
  static String getLunarMonthName(int month) {
    const monthNames = [
      '',
      'Tháng Giêng',
      'Tháng Hai',
      'Tháng Ba',
      'Tháng Tư',
      'Tháng Năm',
      'Tháng Sáu',
      'Tháng Bảy',
      'Tháng Tám',
      'Tháng Chín',
      'Tháng Mười',
      'Tháng Mười Một',
      'Tháng Chạp',
    ];

    if (month >= 1 && month <= 12) {
      return monthNames[month];
    }
    return 'Tháng $month';
  }
}
