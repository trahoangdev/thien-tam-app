class LunarCalendarService {
  // Bảng chuyển đổi âm lịch sang dương lịch (2020-2030)
  // Format: 'YYYY-MM-DD': [lunarMonth, lunarDay, isLeapMonth]
  static const Map<String, List<int>> lunarToSolarMap = {
    // 2024
    '2024-01-01': [12, 1, 0], // Tết Nguyên Đán
    '2024-01-15': [12, 15, 0], // Rằm tháng Chạp
    '2024-02-10': [1, 1, 0], // Tết Nguyên Đán
    '2024-02-24': [1, 15, 0], // Rằm tháng Giêng
    '2024-03-10': [2, 1, 0],
    '2024-03-24': [2, 15, 0], // Rằm tháng Hai
    '2024-04-09': [3, 1, 0],
    '2024-04-23': [3, 15, 0], // Rằm tháng Ba
    '2024-05-08': [4, 1, 0],
    '2024-05-15': [4, 8, 0], // Lễ Phật Đản
    '2024-05-23': [4, 15, 0], // Rằm tháng Tư
    '2024-06-07': [5, 1, 0],
    '2024-06-21': [5, 15, 0], // Rằm tháng Năm
    '2024-07-06': [6, 1, 0],
    '2024-07-20': [6, 15, 0], // Rằm tháng Sáu
    '2024-08-05': [7, 1, 0],
    '2024-08-19': [7, 15, 0], // Rằm tháng Bảy - Vu Lan
    '2024-09-03': [8, 1, 0],
    '2024-09-17': [8, 15, 0], // Rằm tháng Tám - Tết Trung Thu
    '2024-10-02': [9, 1, 0],
    '2024-10-11': [9, 9, 0], // Lễ Phật Đản
    '2024-10-16': [9, 15, 0], // Rằm tháng Chín
    '2024-10-31': [10, 1, 0],
    '2024-11-15': [10, 15, 0], // Rằm tháng Mười
    '2024-11-30': [11, 1, 0],
    '2024-12-14': [11, 15, 0], // Rằm tháng Mười Một
    '2024-12-29': [12, 1, 0],
    '2024-12-31': [12, 3, 0], // Gần cuối năm
    // 2025
    '2025-01-29': [1, 1, 0], // Tết Nguyên Đán
    '2025-02-12': [1, 15, 0], // Rằm tháng Giêng
    '2025-02-27': [2, 1, 0],
    '2025-03-13': [2, 15, 0], // Rằm tháng Hai
    '2025-03-28': [3, 1, 0],
    '2025-04-12': [3, 15, 0], // Rằm tháng Ba
    '2025-04-27': [4, 1, 0],
    '2025-05-05': [4, 8, 0], // Lễ Phật Đản
    '2025-05-12': [4, 15, 0], // Rằm tháng Tư
    '2025-05-27': [5, 1, 0],
    '2025-06-10': [5, 15, 0], // Rằm tháng Năm
    '2025-06-25': [6, 1, 0],
    '2025-07-10': [6, 15, 0], // Rằm tháng Sáu
    '2025-07-25': [7, 1, 0],
    '2025-08-08': [7, 15, 0], // Rằm tháng Bảy - Vu Lan
    '2025-08-23': [8, 1, 0],
    '2025-09-06': [8, 15, 0], // Rằm tháng Tám - Tết Trung Thu
    '2025-09-21': [9, 1, 0],
    '2025-09-30': [9, 9, 0], // Lễ Phật Đản
    '2025-10-05': [9, 15, 0], // Rằm tháng Chín
    '2025-10-20': [10, 1, 0],
    '2025-11-04': [10, 15, 0], // Rằm tháng Mười
    '2025-11-19': [11, 1, 0],
    '2025-12-03': [11, 15, 0], // Rằm tháng Mười Một
    '2025-12-18': [12, 1, 0],
    '2025-12-31': [12, 14, 0], // Gần cuối năm
  };

  // Chuyển đổi âm lịch sang dương lịch
  static DateTime? lunarToSolar(
    int lunarYear,
    int lunarMonth,
    int lunarDay, {
    bool isLeapMonth = false,
  }) {
    // Tìm ngày dương lịch tương ứng gần nhất
    for (final entry in lunarToSolarMap.entries) {
      final solarDate = DateTime.parse(entry.key);
      final lunarData = entry.value;

      if (lunarData[0] == lunarMonth && lunarData[1] == lunarDay) {
        return solarDate;
      }
    }

    // Nếu không tìm thấy, tính toán gần đúng
    return _approximateLunarToSolar(lunarYear, lunarMonth, lunarDay);
  }

  // Chuyển đổi dương lịch sang âm lịch
  static LunarDate? solarToLunar(DateTime solarDate) {
    final dateKey =
        '${solarDate.year}-${solarDate.month.toString().padLeft(2, '0')}-${solarDate.day.toString().padLeft(2, '0')}';

    if (lunarToSolarMap.containsKey(dateKey)) {
      final lunarData = lunarToSolarMap[dateKey]!;
      return LunarDate(
        year: solarDate.year,
        month: lunarData[0],
        day: lunarData[1],
        isLeapMonth: lunarData[2] == 1,
      );
    }

    // Nếu không tìm thấy, tính toán gần đúng
    return _approximateSolarToLunar(solarDate);
  }

  // Tính toán gần đúng âm lịch sang dương lịch
  static DateTime _approximateLunarToSolar(
    int lunarYear,
    int lunarMonth,
    int lunarDay,
  ) {
    // Công thức tính toán gần đúng
    // Mỗi tháng âm lịch ≈ 29.5 ngày
    final daysFromNewYear = (lunarMonth - 1) * 29.5 + (lunarDay - 1);
    final baseDate = DateTime(lunarYear, 1, 1);
    return baseDate.add(Duration(days: daysFromNewYear.round()));
  }

  // Tính toán gần đúng dương lịch sang âm lịch
  static LunarDate _approximateSolarToLunar(DateTime solarDate) {
    final yearStart = DateTime(solarDate.year, 1, 1);
    final daysFromYearStart = solarDate.difference(yearStart).inDays;

    // Tính tháng và ngày âm lịch
    final lunarMonth = (daysFromYearStart / 29.5).floor() + 1;
    final lunarDay = (daysFromYearStart % 29.5).round() + 1;

    return LunarDate(
      year: solarDate.year,
      month: lunarMonth.clamp(1, 12),
      day: lunarDay.clamp(1, 30),
      isLeapMonth: false,
    );
  }

  // Kiểm tra xem ngày có phải là ngày rằm không
  static bool isFullMoonDay(DateTime solarDate) {
    final lunarDate = solarToLunar(solarDate);
    return lunarDate?.day == 15;
  }

  // Lấy tên tháng âm lịch
  static String getLunarMonthName(int month) {
    const monthNames = [
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
    return monthNames[month - 1];
  }

  // Lấy tên ngày âm lịch
  static String getLunarDayName(int day) {
    if (day == 1) return 'Mồng 1';
    if (day == 15) return 'Rằm';
    if (day < 10) return 'Mồng $day';
    return '$day';
  }
}

class LunarDate {
  final int year;
  final int month;
  final int day;
  final bool isLeapMonth;

  const LunarDate({
    required this.year,
    required this.month,
    required this.day,
    required this.isLeapMonth,
  });

  @override
  String toString() {
    final monthName = LunarCalendarService.getLunarMonthName(month);
    final dayName = LunarCalendarService.getLunarDayName(day);
    final leapText = isLeapMonth ? ' (nhuận)' : '';
    return '$dayName $monthName$leapText';
  }
}
