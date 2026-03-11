import 'dart:convert';
import 'dart:io';
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
  static String _baseUrl = 'http://192.168.1.106:5000/api';

  void setBaseUrl(String ip) {
    if (ip.isNotEmpty) {
      _baseUrl = 'http://$ip:5000/api';
    }
  }

  String get currentIp {
    try {
      final uri = Uri.parse(_baseUrl);
      return uri.host;
    } catch (e) {
      return '192.168.1.106';
    }
  }

  String? _currentUsername;

  void setUsername(String? username) {
    _currentUsername = username;
  }

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
            'username': data['Username'] ?? data['username'],
            'fullname': data['HoTen'] ?? data['hoTen'],
            'vaiTro': data['VaiTro'] ?? data['vaiTro'],
            'avatar': data['Avatar'] ?? data['avatar'], // Thêm avatar
          };
        }
      }
      return null;
    } catch (e) {
      print('❌ Lỗi đăng nhập: $e');
      return null;
    }
  }

  /// Cập nhật Avatar
  Future<bool> updateAvatar(String username, String base64Image) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/avatar'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'Username': username,
          'AvatarBase64': base64Image,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('❌ Lỗi cập nhật avatar: $e');
      return false;
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

  /// Lấy danh sách đọc số theo kỳ (Phân trang thực tế từ UI)
  Future<List<Map<String, dynamic>>> layDanhSachDocSo(int maKyDoc,
      {int? trangThai,
      String? search,
      int pageNumber = 1,
      int pageSize = 50}) async {
    try {
      var url = '$_baseUrl/docchiso/ky/$maKyDoc';
      var params = <String>['pageNumber=$pageNumber', 'pageSize=$pageSize'];
      if (trangThai != null) params.add('trangThai=$trangThai');
      if (search != null && search.isNotEmpty) {
        params.add('search=${Uri.encodeComponent(search)}');
      }
      url += '?${params.join('&')}';

      print('🌐 GET $url');
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print('🌐 DocChiSo parsed: ${data.length} items (Trang $pageNumber)');
        return data.map((item) => _convertDocSoItem(item)).toList();
      } else {
        print('🌐 DocChiSo failed: ${response.body}');
        return [];
      }
    } catch (e) {
      print('❌ Lỗi lấy danh sách đọc số: $e');
      return [];
    }
  }

  /// Tìm khách hàng theo Mã Danh Bộ hoặc Địa Chỉ trên TOÀN BỘ kỳ đọc (không lọc theo kỳ)
  Future<List<Map<String, dynamic>>> timKiemToAnBo(String q,
      {int pageNumber = 1, int pageSize = 50}) async {
    try {
      final url =
          '$_baseUrl/docchiso/search?q=${Uri.encodeComponent(q)}&pageNumber=$pageNumber&pageSize=$pageSize';
      print('🔍 Tìm kiếm toàn bộ: $url');
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print('🔍 Kết quả: ${data.length} người');
        return data.map((item) => _convertDocSoItem(item)).toList();
      }
      return [];
    } catch (e) {
      print('❌ Lỗi tìm kiếm: $e');
      return [];
    }
  }

  /// Ghi chỉ số nước (Upload ảnh dạng Base64)
  Future<bool> ghiChiSo(String maDanhBo, int maKyDoc, int chiSoMoi,
      {String code = '40', String ghiChu = '', String? imagePath}) async {
    try {
      final url = '$_baseUrl/docchiso/ghi';

      String? base64Image;
      if (imagePath != null && imagePath.isNotEmpty) {
        final file = File(imagePath);
        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          base64Image = base64Encode(bytes);
          print('📸 Đã chuyển ảnh sang Base64 (${base64Image.length} chars)');
        }
      }

      final body = jsonEncode({
        'MaDanhBo': maDanhBo,
        'MaKyDoc': maKyDoc,
        'ChiSoMoi': chiSoMoi,
        'MaCode': code,
        'GhiChu': ghiChu,
        'NguoiDoc': _currentUsername,
        // Gửi ảnh dạng Base64 nếu có
        if (base64Image != null) 'HinhAnh': base64Image,
      });

      print('🌐 POST $url');
      // print('📦 Body: $body'); // Comment out to avoid spamming console with huge string

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

  /// Cập nhật ghi chú
  Future<void> capNhatGhiChu(
      String maDanhBo, int maKyDoc, String ghiChu) async {
    try {
      await http.put(
        Uri.parse('$_baseUrl/docchiso/note'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'MaDanhBo': maDanhBo,
          'MaKyDoc': maKyDoc,
          'GhiChu': ghiChu,
        }),
      );
    } catch (e) {
      print('❌ Lỗi cập nhật ghi chú: $e');
    }
  }

  /// Cập nhật hình ảnh (gửi Base64)
  Future<void> capNhatHinhAnh(
      String maDanhBo, int maKyDoc, String imagePath) async {
    try {
      String? base64Image;
      final file = File(imagePath);
      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        base64Image = base64Encode(bytes);
      }

      if (base64Image == null) return;

      await http.put(
        Uri.parse('$_baseUrl/docchiso/image'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'MaDanhBo': maDanhBo,
          'MaKyDoc': maKyDoc,
          'HinhAnh': base64Image,
        }),
      );
      print('📸 Đã cập nhật ảnh lên server');
    } catch (e) {
      print('❌ Lỗi cập nhật hình ảnh: $e');
    }
  }

  /// Hủy đọc số (Reset trạng thái)
  Future<bool> huyDocSo(String maDanhBo, int maKyDoc) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/docchiso/reset'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'MaDanhBo': maDanhBo,
          'MaKyDoc': maKyDoc,
        }),
      );

      if (response.statusCode == 200) {
        print('✅ Hủy đọc số thành công: $maDanhBo');
        return true;
      } else {
        print('❌ Lỗi hủy đọc số: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Lỗi ngoại lệ hủy đọc số: $e');
      return false;
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
                  'ky': item['Ky'] ?? item['ky'],
                  'nam': item['Nam'] ?? item['nam'],
                  'chi_so': item['ChiSo'] ?? item['chiSo'] ?? 0,
                  'tieu_thu': item['TieuThu'] ?? item['tieuThu'] ?? 0,
                  'code': item['MaCode'] ?? item['maCode'] ?? '40',
                  'ngay_doc': item['NgayDoc'] ?? item['ngayDoc'],
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
      'ma_danh_bo': item['MaDanhBo'] ?? item['maDanhBo'],
      'ten_kh': item['HoTen'] ?? item['hoTen'],
      'dia_chi': item['DiaChi'] ?? item['diaChi'],
      'chi_so_cu': item['ChiSo'] ?? item['chiSo'] ?? 0,
      'chi_so_moi': item['ChiSo'] ?? item['chiSo'] ?? 0,
      'trang_thai': 0,
      'ma_lo_trinh': item['MaLoTrinh'] ?? item['maLoTrinh'],
      'hieu': item['Hieu'] ?? item['hieu'],
      'co': item['Co'] ?? item['co'],
      'so_than': item['SoThan'] ?? item['soThan'],
      'vi_tri': item['ViTri'] ?? item['viTri'],
      'gb': item['GB'] ?? item['gb'],
      'dm': item['DM'] ?? item['dm'],
      'dmhn': item['DMHN'] ?? item['dmhn'],
      'sdt': item['SoDienThoai'] ?? item['soDienThoai'],
      'ghi_chu': item['GhiChu'] ?? item['ghiChu'],
    };
  }

  /// Convert DocSoItem response thành format tương thích
  Map<String, dynamic> _convertDocSoItem(Map<String, dynamic> item) {
    return {
      'ma_danh_bo': item['MaDanhBo'] ?? item['maDanhBo'],
      'ten_kh': item['HoTen'] ?? item['hoTen'],
      'dia_chi': item['DiaChi'] ?? item['diaChi'],
      'dia_chi_dhn': item['DiaChiDHN'] ?? item['diaChiDHN'],
      'ma_lo_trinh': item['MaLoTrinh'] ?? item['maLoTrinh'],
      'hieu': item['Hieu'] ?? item['hieu'],
      'co': item['Co'] ?? item['co'],
      'so_than': item['SoThan'] ?? item['soThan'],
      'vi_tri': item['ViTri'] ?? item['viTri'],
      'sdt': item['SoDienThoai'] ?? item['soDienThoai'],
      'gb': item['GB'] ?? item['gb'],
      'dm': item['DM'] ?? item['dm'],
      'dmhn': item['DMHN'] ?? item['dmhn'],
      'doc_chi_so_id': item['DocChiSoId'] ?? item['docChiSoId'],
      'ma_ky_doc': item['MaKyDoc'] ?? item['maKyDoc'],
      'chi_so_cu': item['ChiSoCu'] ?? item['chiSoCu'] ?? 0,
      'chi_so_moi': item['ChiSoMoi'] ?? item['chiSoMoi'],
      'tieu_thu': item['TieuThu'] ?? item['tieuThu'] ?? 0,
      'code': item['MaCode'] ?? item['maCode'] ?? '40',
      'tbtt': item['TBTT'] ?? item['tbtt'] ?? 0,
      'trang_thai': item['TrangThai'] ?? item['trangThai'] ?? 0,
      'ghi_chu': item['GhiChu'] ?? item['ghiChu'],
      'tinh_trang': item['TinhTrang'] ?? item['tinhTrang'],
      'hinh_anh': item['HinhAnh'] ?? item['hinhAnh'],
    };
  }
}
