import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'logger.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Update v7: Thêm bảng lịch sử, code tracking, và tình trạng
    String path = join(await getDatabasesPath(), 'tanhoa_water_v7.db');
    return await openDatabase(
      path,
      version: 7,
      onCreate: (db, version) async {
        // 1. Tạo bảng Khách Hàng
        await db.execute('''
          CREATE TABLE khach_hang(
            ma_danh_bo TEXT PRIMARY KEY,
            ten_kh TEXT,
            dia_chi TEXT,
            chi_so_cu INTEGER,
            chi_so_moi INTEGER DEFAULT 0,
            hinh_anh TEXT,
            trang_thai INTEGER DEFAULT 0,
            ma_lo_trinh TEXT,
            hieu TEXT,
            co TEXT,
            so_than TEXT,
            vi_tri TEXT,
            ngay_thay TEXT,
            gb INTEGER,
            dm INTEGER,
            dmhn INTEGER,
            tbtt INTEGER,
            ghi_chu TEXT,
            sdt TEXT,
            code TEXT DEFAULT '40',
            tinh_trang TEXT
          )
        ''');

        // 2. Tạo bảng Users
        await db.execute('''
          CREATE TABLE users(
            username TEXT PRIMARY KEY,
            password TEXT,
            fullname TEXT
          )
        ''');

        // 3. Tạo bảng Lịch Sử Đọc
        await db.execute('''
          CREATE TABLE lich_su_doc(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            ma_danh_bo TEXT,
            ky INTEGER,
            nam INTEGER,
            chi_so INTEGER,
            tieu_thu INTEGER,
            ngay_doc TEXT,
            code TEXT,
            FOREIGN KEY (ma_danh_bo) REFERENCES khach_hang(ma_danh_bo)
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 7) {
          // Migration từ v6 sang v7
          await db.execute(
              'ALTER TABLE khach_hang ADD COLUMN code TEXT DEFAULT "40"');
          await db.execute('ALTER TABLE khach_hang ADD COLUMN tinh_trang TEXT');

          // Tạo bảng lịch sử
          await db.execute('''
            CREATE TABLE IF NOT EXISTS lich_su_doc(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              ma_danh_bo TEXT,
              ky INTEGER,
              nam INTEGER,
              chi_so INTEGER,
              tieu_thu INTEGER,
              ngay_doc TEXT,
              code TEXT,
              FOREIGN KEY (ma_danh_bo) REFERENCES khach_hang(ma_danh_bo)
            )
          ''');
        }
      },
    );
  }

  // ====== AUTH ======
  Future<Map<String, dynamic>?> dangNhap(
      String username, String password) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  Future<bool> dangKy(String username, String password, String fullname) async {
    final db = await database;
    try {
      await db.insert('users', {
        'username': username,
        'password': password,
        'fullname': fullname,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  // ====== KHÁCH HÀNG ======
  Future<List<Map<String, dynamic>>> layDanhSach() async {
    final db = await database;
    return await db.query('khach_hang',
        orderBy: 'ma_lo_trinh ASC, ma_danh_bo ASC');
  }

  Future<void> capNhatChiSo(String maDB, int chiSoMoi, String hinhAnh,
      {String ghiChu = '', String code = '40'}) async {
    final db = await database;
    await db.update(
      'khach_hang',
      {
        'chi_so_moi': chiSoMoi,
        'trang_thai': 1,
        'hinh_anh': hinhAnh,
        'ghi_chu': ghiChu,
        'code': code,
      },
      where: 'ma_danh_bo = ?',
      whereArgs: [maDB],
    );
  }

  // ====== IMPORT/EXPORT ======
  Future<int> demTongKhach() async {
    final db = await database;
    final result =
        await db.rawQuery('SELECT COUNT(*) as count FROM khach_hang');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<void> xoaToanBoKhachHang() async {
    final db = await database;
    await db.delete('khach_hang');
    await AppLogger().info('Đã xóa toàn bộ khách hàng', context: 'DB');
  }

  Future<int> importFromCSV(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('File không tồn tại');
    }

    final input = await file.readAsString();
    final fields = const CsvToListConverter().convert(input);

    if (fields.isEmpty) return 0;

    final db = await database;
    int count = 0;

    for (int i = 1; i < fields.length; i++) {
      final row = fields[i];
      if (row.length >= 4) {
        try {
          await db.insert(
            'khach_hang',
            {
              'ma_danh_bo': row[0].toString(),
              'ten_kh': row[1].toString(),
              'dia_chi': row[2].toString(),
              'chi_so_cu': int.tryParse(row[3].toString()) ?? 0,
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
          count++;
        } catch (e) {
          await AppLogger().error('Lỗi import dòng $i: $e', context: 'IMPORT');
        }
      }
    }

    await AppLogger()
        .info('Import thành công $count khách hàng', context: 'IMPORT');
    return count;
  }

  Future<String> exportToCSV() async {
    final db = await database;
    final data = await db.query(
      'khach_hang',
      where: 'trang_thai = ?',
      whereArgs: [1],
      orderBy: 'ma_lo_trinh ASC, ma_danh_bo ASC',
    );

    if (data.isEmpty) {
      throw Exception('Không có dữ liệu để export');
    }

    List<List<dynamic>> rows = [];
    rows.add(
        ['Mã ĐB', 'Tên KH', 'Địa chỉ', 'CS Cũ', 'CS Mới', 'Tiêu thụ', 'MLT']);

    for (var kh in data) {
      final chiSoCu = kh['chi_so_cu'] as int? ?? 0;
      final chiSoMoi = kh['chi_so_moi'] as int? ?? 0;
      final tieuThu = chiSoMoi - chiSoCu;

      rows.add([
        kh['ma_danh_bo'],
        kh['ten_kh'],
        kh['dia_chi'],
        chiSoCu,
        chiSoMoi,
        tieuThu,
        kh['ma_lo_trinh']
      ]);
    }

    String csv = const ListToCsvConverter().convert(rows);

    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filePath = '${directory.path}/export_$timestamp.csv';

    final file = File(filePath);
    await file.writeAsString(csv);

    await AppLogger().info('Export thành công: $filePath', context: 'EXPORT');
    return filePath;
  }

  // ====== LỊCH SỬ (ADDED) ======

  /// Lấy lịch sử đọc của khách hàng (N kỳ gần nhất)
  Future<List<Map<String, dynamic>>> layLichSuDoc(String maDB,
      {int limit = 3}) async {
    final db = await database;
    return await db.query(
      'lich_su_doc',
      where: 'ma_danh_bo = ?',
      whereArgs: [maDB],
      orderBy: 'nam DESC, ky DESC',
      limit: limit,
    );
  }

  /// Lưu lịch sử khi đọc số
  Future<void> luuLichSu(String maDB, int ky, int nam, int chiSo, int tieuThu,
      {String code = '40'}) async {
    final db = await database;
    await db.insert('lich_su_doc', {
      'ma_danh_bo': maDB,
      'ky': ky,
      'nam': nam,
      'chi_so': chiSo,
      'tieu_thu': tieuThu,
      'ngay_doc': DateTime.now().toIso8601String(),
      'code': code,
    });
  }

  /// Tính toán phát hiện bất thường (tăng/giảm đột ngột)
  Future<String?> tinhBatThuong(Map<String, dynamic> khachHang) async {
    final maDB = khachHang['ma_danh_bo'];
    final chiSoMoi = khachHang['chi_so_moi'] ?? 0;
    final chiSoCu = khachHang['chi_so_cu'] ?? 0;
    final tieuThuHienTai = chiSoMoi - chiSoCu;

    if (tieuThuHienTai <= 0) return null;

    final lichSu = await layLichSuDoc(maDB, limit: 3);
    if (lichSu.isEmpty) return null;

    final tongTieuThu =
        lichSu.fold<int>(0, (sum, item) => sum + (item['tieu_thu'] as int));
    final trungBinh = tongTieuThu / lichSu.length;

    if (tieuThuHienTai > trungBinh * 1.5) {
      return 'tang';
    }
    if (tieuThuHienTai < trungBinh * 0.5) {
      return 'giam';
    }

    return null;
  }

  /// Cập nhật code cho khách hàng
  Future<void> capNhatCode(String maDB, String code) async {
    final db = await database;
    await db.update(
      'khach_hang',
      {'code': code},
      where: 'ma_danh_bo = ?',
      whereArgs: [maDB],
    );
  }

  /// Đặt lại trạng thái cục bộ của một khách hàng về Chưa Đọc
  Future<void> resetTrangThaiLocal(String maDB) async {
    final db = await database;
    await db.update(
      'khach_hang',
      {
        'trang_thai': 0,
        'chi_so_moi': 0,
        'hinh_anh': null,
      },
      where: 'ma_danh_bo = ?',
      whereArgs: [maDB.toString().trim()],
    );
    await AppLogger()
        .info('Đã reset trạng thái cục bộ KH: $maDB', context: 'DB');
  }
}
