import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

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
    // Tôi đổi tên DB thành _v3 để máy nó tự tạo lại bảng mới có chứa user
    String path = join(await getDatabasesPath(), 'tanhoa_water_v3.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // 1. Tạo bảng Khách Hàng (Như cũ)
        await db.execute('''
          CREATE TABLE khach_hang(
            ma_danh_bo TEXT PRIMARY KEY,
            ten_kh TEXT,
            dia_chi TEXT,
            chi_so_cu INTEGER,
            chi_so_moi INTEGER DEFAULT 0,
            hinh_anh TEXT,
            trang_thai INTEGER DEFAULT 0 
          )
        ''');

        // 2. Tạo bảng Users (Mới thêm) -> Để lưu tài khoản đăng nhập
        await db.execute('''
          CREATE TABLE users(
            username TEXT PRIMARY KEY,
            password TEXT,
            fullname TEXT
          )
        ''');
      },
    );
  }

  // --- PHẦN MỚI: QUẢN LÝ TÀI KHOẢN (LOGIN/REGISTER) ---

  // Hàm Đăng ký tài khoản mới
  Future<bool> dangKy(String user, String pass, String name) async {
    final db = await database;
    try {
      await db.insert('users', {
        'username': user, 
        'password': pass, 
        'fullname': name
      });
      return true; // Đăng ký thành công
    } catch (e) {
      return false; // Lỗi (thường là do trùng tên đăng nhập)
    }
  }

  // Hàm Đăng nhập
  Future<Map<String, dynamic>?> dangNhap(String user, String pass) async {
    final db = await database;
    List<Map<String, dynamic>> res = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [user, pass],
    );

    if (res.isNotEmpty) {
      return res.first; // Trả về thông tin user tìm thấy
    }
    return null; // Không tìm thấy (sai MK hoặc TK)
  }

  // --- PHẦN CŨ: QUẢN LÝ ĐỌC SỐ (GIỮ NGUYÊN) ---

  // Chức năng 1: Giả lập nạp dữ liệu từ PC xuống Mobile
  Future<void> taoDuLieuMau() async {
    final db = await database;
    await db.delete('khach_hang'); // Xóa cũ làm lại
    
    var dataMau = [
      {'ma_danh_bo': 'DB001', 'ten_kh': 'Nguyễn Văn An', 'dia_chi': '123 Âu Cơ, TB', 'chi_so_cu': 1500},
      {'ma_danh_bo': 'DB002', 'ten_kh': 'Trần Thị Bích', 'dia_chi': '45 Lạc Long Quân', 'chi_so_cu': 215},
      {'ma_danh_bo': 'DB003', 'ten_kh': 'Lê Văn Cường', 'dia_chi': '12 Hẻm 68 Đồng Đen', 'chi_so_cu': 89},
    ];

    for (var kh in dataMau) {
      await db.insert('khach_hang', kh);
    }
  }

  // Chức năng 2: Lấy danh sách khách hàng
  Future<List<Map<String, dynamic>>> layDanhSachKH() async {
    final db = await database;
    return await db.query('khach_hang', orderBy: 'trang_thai ASC, ma_danh_bo ASC');
  }

  // Chức năng 3: Lưu kết quả sau khi chụp
  Future<void> capNhatChiSo(String maDB, int soMoi, String pathAnh) async {
    final db = await database;
    await db.update(
      'khach_hang',
      {'chi_so_moi': soMoi, 'hinh_anh': pathAnh, 'trang_thai': 1},
      where: 'ma_danh_bo = ?',
      whereArgs: [maDB],
    );
  }
}