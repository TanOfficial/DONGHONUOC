import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service kết nối Flutter App với ASP.NET Core API
/// Thay thế DatabaseHelper (SQLite) bằng HTTP calls
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // ⚠️ THAY ĐỔI IP NÀY THÀNH IP MÁY TÍNH CỦA BẠN
  // Chạy `ipconfig` trong CMD để lấy IPv4 Address
  // Ví dụ: 192.168.1.100
  static const String _baseUrl = 'http://192.168.1.91:5000/api';

  String? _currentUsername;

  // ====== AUTH ======

  /// Đăng nhập
  Future<Map<String, dynamic>?> dangNhap(
      String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'Username': username, 'Password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['Success'] == true) {
          _currentUsername = username;
          return {
            'username': data['Username'],
            'fullname': data['HoTen'],
            'vaiTro': data['VaiTro'],
          };
        }
      }
      return null;
    } catch (e) {
      print('❌ Lỗi đăng nhập: $e');
      return null;
    }
  }

  /// Đăng ký
  Future<bool> dangKy(String username, String password, String fullname) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'Username': username,
          'Password': password,
          'HoTen': fullname,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['Success'] == true;
      }
      return false;
    } catch (e) {
      print('❌ Lỗi đăng ký: $e');
      return false;
    }
  }

  // ====== KHÁCH HÀNG ======

  /// Lấy danh sách khách hàng
  Future<List<Map<String, dynamic>>> layDanhSach({String? search}) async {
    try {
      var url = '$_baseUrl/khachhang';
      if (search != null && search.isNotEmpty) {
        url += '?search=${Uri.encodeComponent(search)}';
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => _convertKhachHang(item)).toList();
      }
      return [];
    } catch (e) {
      print('❌ Lỗi lấy danh sách: $e');
      return [];
    }
  }

  /// Đếm tổng khách hàng
  Future<int> demTongKhach() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/khachhang/count'));
      if (response.statusCode == 200) {
        return int.tryParse(response.body) ?? 0;
      }
      return 0;
    } catch (e) {
      print('❌ Lỗi đếm khách: $e');
      return 0;
    }
  }

  // ====== ĐỌC CHỈ SỐ ======

  /// Lấy danh sách đọc số theo kỳ
  Future<List<Map<String, dynamic>>> layDanhSachDocSo(int maKyDoc,
      {int? trangThai, String? search}) async {
    try {
      var url = '$_baseUrl/docchiso/ky/$maKyDoc';
      var params = <String>[];
      if (trangThai != null) params.add('trangThai=$trangThai');
      if (search != null && search.isNotEmpty) {
        params.add('search=${Uri.encodeComponent(search)}');
      }
      if (params.isNotEmpty) url += '?${params.join('&')}';

      print('🌐 GET $url');
      final response = await http.get(Uri.parse(url));
      print(
          '🌐 Status: ${response.statusCode}, Body length: ${response.body.length}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print('🌐 DocChiSo parsed: ${data.length} items');
        return data.map((item) => _convertDocSoItem(item)).toList();
      }
      print('🌐 DocChiSo failed: ${response.body}');
      return [];
    } catch (e) {
      print('❌ Lỗi lấy danh sách đọc số: $e');
      return [];
    }
  }

  /// Ghi chỉ số nước
  Future<bool> ghiChiSo(String maDanhBo, int maKyDoc, int chiSoMoi,
      {String code = '40', String ghiChu = ''}) async {
    try {
      final url = '$_baseUrl/docchiso/ghi';
      final body = jsonEncode({
        'MaDanhBo': maDanhBo,
        'MaKyDoc': maKyDoc,
        'ChiSoMoi': chiSoMoi,
        'MaCode': code,
        'GhiChu': ghiChu,
        'NguoiDoc': _currentUsername,
      });

      print('🌐 POST $url');
      print('📦 Body: $body');

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      print('🌐 Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return true;
      } else {
        print('❌ Lỗi ghi chỉ số (Server): ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Lỗi ghi chỉ số (Client): $e');
      return false;
    }
  }

  /// Cập nhật code
  Future<void> capNhatCode(String maDanhBo, int maKyDoc, String code) async {
    try {
      await http.put(
        Uri.parse('$_baseUrl/docchiso/code'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'MaDanhBo': maDanhBo,
          'MaKyDoc': maKyDoc,
          'MaCode': code,
        }),
      );
    } catch (e) {
      print('❌ Lỗi cập nhật code: $e');
    }
  }

  /// Lấy lịch sử đọc số
  Future<List<Map<String, dynamic>>> layLichSuDoc(String maDanhBo,
      {int limit = 3}) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/docchiso/lichsu/$maDanhBo?limit=$limit'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data
            .map((item) => <String, dynamic>{
                  'ky': item['Ky'],
                  'nam': item['Nam'],
                  'chi_so': item['ChiSo'] ?? 0,
                  'tieu_thu': item['TieuThu'] ?? 0,
                  'code': item['MaCode'] ?? '40',
                  'ngay_doc': item['NgayDoc'],
                })
            .toList();
      }
      return [];
    } catch (e) {
      print('❌ Lỗi lấy lịch sử: $e');
      return [];
    }
  }

  /// Lấy danh sách kỳ đọc
  Future<List<Map<String, dynamic>>> layDanhSachKyDoc() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/docchiso/kydoc'));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => Map<String, dynamic>.from(item)).toList();
      }
      return [];
    } catch (e) {
      print('❌ Lỗi lấy kỳ đọc: $e');
      return [];
    }
  }

  /// Thống kê kỳ đọc
  Future<Map<String, dynamic>?> thongKe(int maKyDoc) async {
    try {
      final response =
          await http.get(Uri.parse('$_baseUrl/docchiso/thongke/$maKyDoc'));

      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      print('❌ Lỗi thống kê: $e');
      return null;
    }
  }

  // ====== HELPER ======

  /// Convert API response thành format tương thích với code cũ
  Map<String, dynamic> _convertKhachHang(Map<String, dynamic> item) {
    return {
      'ma_danh_bo': item['MaDanhBo'],
      'ten_kh': item['HoTen'],
      'dia_chi': item['DiaChi'],
      'chi_so_cu': item['ChiSo'] ?? 0, // Fallback: Use base ChiSo
      'chi_so_moi': item['ChiSo'] ?? 0, // Fallback: New index starts at base
      'trang_thai': 0,
      'ma_lo_trinh': item['MaLoTrinh'],
      'hieu': item['Hieu'],
      'co': item['Co'],
      'so_than': item['SoThan'],
      'vi_tri': item['ViTri'],
      'gb': item['GB'],
      'dm': item['DM'],
      'dmhn': item['DMHN'],
      'sdt': item['SoDienThoai'],
      'ghi_chu': item['GhiChu'],
    };
  }

  /// Convert DocSoItem response thành format tương thích
  Map<String, dynamic> _convertDocSoItem(Map<String, dynamic> item) {
    return {
      'ma_danh_bo': item['MaDanhBo'],
      'ten_kh': item['HoTen'],
      'dia_chi': item['DiaChi'],
      'dia_chi_dhn': item['DiaChiDHN'],
      'ma_lo_trinh': item['MaLoTrinh'],
      'hieu': item['Hieu'],
      'co': item['Co'],
      'so_than': item['SoThan'],
      'vi_tri': item['ViTri'],
      'sdt': item['SoDienThoai'],
      'gb': item['GB'],
      'dm': item['DM'],
      'dmhn': item['DMHN'],
      'doc_chi_so_id': item['DocChiSoId'],
      'ma_ky_doc': item['MaKyDoc'],
      'chi_so_cu': item['ChiSoCu'] ?? 0,
      'chi_so_moi': item['ChiSoMoi'] ?? 0,
      'tieu_thu': item['TieuThu'] ?? 0,
      'code': item['MaCode'] ?? '40',
      'tbtt': item['TBTT'] ?? 0,
      'trang_thai': item['TrangThai'] ?? 0,
      'ghi_chu': item['GhiChu'],
      'tinh_trang': item['TinhTrang'],
      'hinh_anh': item['HinhAnh'],
    };
  }
}
