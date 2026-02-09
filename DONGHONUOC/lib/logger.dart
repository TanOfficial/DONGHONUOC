import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

/// Logger class để ghi lại các thao tác, lỗi và sự kiện trong app
class AppLogger {
  static final AppLogger _instance = AppLogger._internal();
  factory AppLogger() => _instance;

  AppLogger._internal();

  File? _logFile;
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

  /// Khởi tạo file log
  Future<void> init() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final logDir = Directory('${directory.path}/logs');

      // Tạo thư mục logs nếu chưa có
      if (!await logDir.exists()) {
        await logDir.create(recursive: true);
      }

      // Tạo file log với tên theo ngày
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      _logFile = File('${logDir.path}/app_log_$today.txt');

      // Ghi header cho session mới
      await _writeToFile('\n${'=' * 60}');
      await _writeToFile(
          '📱 App khởi động: ${_dateFormat.format(DateTime.now())}');
      await _writeToFile('=' * 60);
    } catch (e) {
      print('❌ Không thể khởi tạo logger: $e');
    }
  }

  /// Ghi nội dung vào file log
  Future<void> _writeToFile(String content) async {
    if (_logFile != null) {
      try {
        await _logFile!.writeAsString('$content\n', mode: FileMode.append);
      } catch (e) {
        print('❌ Không thể ghi log: $e');
      }
    }
  }

  /// Ghi log INFO (thông tin chung)
  Future<void> info(String message, {String? context}) async {
    final timestamp = _dateFormat.format(DateTime.now());
    final contextStr = context != null ? '[$context] ' : '';
    final logLine = '[$timestamp] ℹ️ INFO: $contextStr$message';
    print(logLine); // In ra console
    await _writeToFile(logLine);
  }

  /// Ghi log ERROR (lỗi)
  Future<void> error(String message,
      {String? context, dynamic error, StackTrace? stackTrace}) async {
    final timestamp = _dateFormat.format(DateTime.now());
    final contextStr = context != null ? '[$context] ' : '';
    final logLine = '[$timestamp] ❌ ERROR: $contextStr$message';

    print(logLine); // In ra console
    await _writeToFile(logLine);

    if (error != null) {
      await _writeToFile('   └─ Chi tiết: $error');
    }

    if (stackTrace != null) {
      await _writeToFile('   └─ Stack trace:');
      await _writeToFile(stackTrace.toString());
    }
  }

  /// Ghi log WARNING (cảnh báo)
  Future<void> warning(String message, {String? context}) async {
    final timestamp = _dateFormat.format(DateTime.now());
    final contextStr = context != null ? '[$context] ' : '';
    final logLine = '[$timestamp] ⚠️ WARNING: $contextStr$message';
    print(logLine);
    await _writeToFile(logLine);
  }

  /// Ghi log SUCCESS (thành công)
  Future<void> success(String message, {String? context}) async {
    final timestamp = _dateFormat.format(DateTime.now());
    final contextStr = context != null ? '[$context] ' : '';
    final logLine = '[$timestamp] ✅ SUCCESS: $contextStr$message';
    print(logLine);
    await _writeToFile(logLine);
  }

  /// Ghi log action của user
  Future<void> userAction(String action, {Map<String, dynamic>? data}) async {
    final timestamp = _dateFormat.format(DateTime.now());
    final dataStr = data != null ? ' | Data: $data' : '';
    final logLine = '[$timestamp] 👤 USER: $action$dataStr';
    print(logLine);
    await _writeToFile(logLine);
  }

  /// Lấy nội dung log file hiện tại
  Future<String?> getLogContent() async {
    if (_logFile != null && await _logFile!.exists()) {
      return await _logFile!.readAsString();
    }
    return null;
  }

  /// Xóa log file cũ (giữ lại 7 ngày gần nhất)
  Future<void> cleanOldLogs() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final logDir = Directory('${directory.path}/logs');

      if (await logDir.exists()) {
        final files = logDir.listSync();
        final now = DateTime.now();

        for (var file in files) {
          if (file is File && file.path.endsWith('.txt')) {
            final stat = await file.stat();
            final age = now.difference(stat.modified).inDays;

            if (age > 7) {
              await file.delete();
              print('🗑️ Đã xóa log file cũ: ${file.path}');
            }
          }
        }
      }
    } catch (e) {
      print('❌ Không thể xóa log cũ: $e');
    }
  }
}
