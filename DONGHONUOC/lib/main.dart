import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image/image.dart' as img;
import 'db_helper.dart';
import 'api_service.dart';
import 'logger.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

final api = ApiService();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(const MaterialApp(
    home: LoginScreen(),
    debugShowCheckedModeBanner: false,
  ));
}

// ======================= MÀN HÌNH 1: ĐĂNG NHẬP =======================
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLogin = true;
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  final _nameController = TextEditingController();

  Future<void> _xuLy() async {
    String u = _userController.text;
    String p = _passController.text;

    if (u.isEmpty || p.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Vui lòng nhập đủ thông tin!")));
      return;
    }

    if (_isLogin) {
      var user = await api.dangNhap(u, p);
      if (user != null) {
        if (!mounted) return;
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => DashboardScreen(
                    fullname: user['fullname'] ?? user['username'])));
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Sai tài khoản hoặc mật khẩu!")));
      }
    } else {
      if (_nameController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Vui lòng nhập Họ Tên!")));
        return;
      }
      bool success = await api.dangKy(u, p, _nameController.text);
      if (!mounted) return;
      if (success) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Đăng ký thành công!")));
        setState(() => _isLogin = true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Tên đăng nhập đã tồn tại!")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue,
                ),
                child:
                    const Icon(Icons.water_drop, size: 60, color: Colors.white),
              ),
              const SizedBox(height: 24),
              const Text("ĐĂNG NHẬP",
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5)),
              const SizedBox(height: 40),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: TextField(
                  controller: _userController,
                  decoration: InputDecoration(
                    hintText: "Tên đăng nhập",
                    prefixIcon:
                        Icon(Icons.person_outline, color: Colors.grey[600]),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: TextField(
                  controller: _passController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: "Mật khẩu",
                    prefixIcon:
                        Icon(Icons.lock_outline, color: Colors.grey[600]),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
              ),
              if (!_isLogin) ...[
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: "Họ và tên",
                      prefixIcon:
                          Icon(Icons.badge_outlined, color: Colors.grey[600]),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _xuLy,
                  icon: const Icon(Icons.water_drop, color: Colors.white),
                  label: Text(_isLogin ? "ĐĂNG NHẬP" : "ĐĂNG KÝ",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2196F3),
                    elevation: 2,
                    shadowColor: Colors.blue.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => setState(() => _isLogin = !_isLogin),
                child: Text(
                  _isLogin
                      ? "Chưa có tài khoản? Đăng ký"
                      : "Đã có tài khoản? Đăng nhập",
                  style: TextStyle(color: Colors.blue[700]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ======================= MÀN HÌNH 2: DASHBOARD =======================
class DashboardScreen extends StatefulWidget {
  final String fullname;
  const DashboardScreen({super.key, required this.fullname});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _totalCustomers = 0;
  String? _avatarPath;

  @override
  void initState() {
    super.initState();
    _loadStats();
    _loadAvatar();
  }

  Future<void> _loadAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _avatarPath = prefs.getString('avatar_path');
    });
  }

  Future<void> _saveAvatar(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('avatar_path', path);
    setState(() {
      _avatarPath = path;
    });
  }

  Future<void> _pickAvatarPhoto() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chọn ảnh đại diện'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF2196F3)),
              title: const Text('Chụp ảnh'),
              onTap: () => Navigator.pop(context, 'camera'),
            ),
            ListTile(
              leading:
                  const Icon(Icons.photo_library, color: Color(0xFF2196F3)),
              title: const Text('Chọn từ thư viện'),
              onTap: () => Navigator.pop(context, 'gallery'),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: result == 'camera' ? ImageSource.camera : ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image != null) {
        await _saveAvatar(image.path);
      }
    }
  }

  Future<void> _loadStats() async {
    final total = await api.demTongKhach();
    setState(() => _totalCustomers = total);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Đọc Số"),
        backgroundColor: const Color(0xFF5C6BC0),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // Hiển thị dialog xác nhận đăng xuất
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Đăng xuất'),
                  content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Hủy'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2196F3),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Đăng xuất'),
                    ),
                  ],
                ),
              );

              // Nếu user xác nhận đăng xuất
              if (confirm == true) {
                if (!context.mounted) return;

                // Hiển thị thông báo đăng xuất thành công
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã đăng xuất thành công!'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );

                // Chờ 1 giây để user thấy notification
                await Future.delayed(const Duration(milliseconds: 800));

                if (!context.mounted) return;

                // Navigate về màn hình đăng nhập
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (c) => const LoginScreen()),
                );
              }
            },
          )
        ],
      ),
      body: Container(
        color: Colors.white,
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Greeting
              const Text("Xin chào",
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF8BC34A))),
              Text(widget.fullname,
                  style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF8BC34A))),
              const SizedBox(height: 24),
              // Avatar with camera icon
              GestureDetector(
                onTap: _pickAvatarPhoto,
                child: Stack(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2196F3),
                        shape: BoxShape.circle,
                      ),
                      child:
                          _avatarPath != null && File(_avatarPath!).existsSync()
                              ? ClipOval(
                                  child: Image.file(
                                    File(_avatarPath!),
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : const Icon(Icons.water_drop,
                                  size: 60, color: Colors.white),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: const Color(0xFF2196F3), width: 2),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 20,
                          color: Color(0xFF2196F3),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              // Menu Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildMenuButton(
                    "Đọc Số",
                    'assets/icon_nuoc.png',
                    Colors.blue[700]!,
                    () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (c) => const DanhSachKHScreen())),
                  ),
                  const SizedBox(width: 24),
                  _buildMenuButton(
                    "Quản Lý",
                    'assets/icon_quanly.png',
                    Colors.orange[700]!,
                    () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Chức năng đang được phát triển"))),
                  ),
                ],
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text("Tổng số khách hàng: $_totalCustomers",
                    style: TextStyle(fontSize: 14, color: Colors.grey[600])),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(
      String title, String assetPath, Color fallbackColor, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 140,
        height: 140,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              assetPath,
              height: 70,
              width: 70,
              errorBuilder: (context, error, stack) => Icon(
                  title == "Đọc Số" ? Icons.water_drop : Icons.bar_chart,
                  size: 70,
                  color: fallbackColor),
            ),
            const SizedBox(height: 8),
            Text(title,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800])),
          ],
        ),
      ),
    );
  }
}

// ======================= MÀN HÌNH 3: DANH SÁCH KHÁCH HÀNG =======================
class DanhSachKHScreen extends StatefulWidget {
  const DanhSachKHScreen({super.key});

  @override
  State<DanhSachKHScreen> createState() => _DanhSachKHScreenState();
}

class _DanhSachKHScreenState extends State<DanhSachKHScreen> {
  List<Map<String, dynamic>> _danhSachKH = [];
  List<Map<String, dynamic>> _filteredList = [];
  // int? _currentMaKyDoc; // Removed unused field

  final TextEditingController _searchController = TextEditingController();
  bool _showSearch = false;

  String _filterType = "Tất cả";
  String _sortType = "MLT";

  final List<String> _filters = [
    "Tất cả",
    "Chưa Đọc",
    "Đã Đọc",
    "F",
    "6",
    "Bất Thường Tăng",
    "Bất Thường Giảm",
    "Chủ Báo",
    "Chưa Gửi TB",
    "MLT Giảm",
    "10%",
    "20%",
    "30%",
    "40%",
    "50%"
  ];

  final List<String> _sorts = ["MLT", "Thời Gian Tăng", "Thời Gian Giảm"];

  @override
  void initState() {
    super.initState();
    _taiDuLieu();
    _searchController.addListener(() {
      _applyFilter();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _taiDuLieu() async {
    try {
      // 1. Lấy danh sách kỳ đọc
      final kyDocList = await api.layDanhSachKyDoc();

      if (kyDocList.isNotEmpty) {
        // Duyệt qua các kỳ đọc để tìm kỳ có dữ liệu
        for (var ky in kyDocList) {
          final maKy = ky['MaKyDoc'] as int?;
          if (maKy == null) continue;

          print('🔍 Checking KyDoc: $maKy');
          final data = await api.layDanhSachDocSo(maKy);

          if (data.isNotEmpty) {
            print('✅ Found data in KyDoc: $maKy (${data.length} records)');
            setState(() {
              _danhSachKH = data;
              _filteredList = List.from(data);
            });
            return;
          }
        }
      }

      // 3. Fallback: Nếu không tìm thấy kỳ nào có dữ liệu, lấy danh sách khách hàng
      print('⚠️ No data found in any KyDoc, loading from KhachHang table');
      final data = await api.layDanhSach();

      // Inject MaKyDoc từ kỳ mới nhất để có thể lưu dữ liệu
      if (kyDocList.isNotEmpty) {
        final latestMaKy = kyDocList.first['MaKyDoc'] as int?;
        if (latestMaKy != null) {
          print(
              '💉 Injecting MaKyDoc=$latestMaKy into ${data.length} fallback items');
          for (var item in data) {
            item['ma_ky_doc'] = latestMaKy;
          }
        }
      }

      setState(() {
        _danhSachKH = data;
        _filteredList = List.from(data);
      });
    } catch (e) {
      print('❌ Lỗi tải dữ liệu: $e');
      final data = await api.layDanhSach();
      setState(() {
        _danhSachKH = data;
        _filteredList = List.from(data);
      });
    }
  }

  void _showFilterSortDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String tempFilter = _filterType;
        String tempSort = _sortType;
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text("Lọc & Sắp xếp"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: tempFilter,
                    decoration: const InputDecoration(labelText: "Lọc"),
                    items: _filters
                        .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                        .toList(),
                    onChanged: (v) => setStateDialog(() => tempFilter = v!),
                  ),
                  DropdownButtonFormField<String>(
                    value: tempSort,
                    decoration: const InputDecoration(labelText: "Sắp xếp"),
                    items: _sorts
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (v) => setStateDialog(() => tempSort = v!),
                  ),
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Hủy")),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _filterType = tempFilter;
                      _sortType = tempSort;
                    });
                    _applyFilter();
                    Navigator.pop(context);
                  },
                  child: const Text("Áp dụng"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _applyFilter() async {
    final query = _searchController.text.toLowerCase();
    List<Map<String, dynamic>> temp = List.from(_danhSachKH);

    // 1. Search
    if (query.isNotEmpty) {
      temp = temp.where((kh) {
        final tenKH = (kh['ten_kh'] ?? '').toString().toLowerCase();
        final maDB = (kh['ma_danh_bo'] ?? '').toString().toLowerCase();
        final diaChi = (kh['dia_chi'] ?? '').toString().toLowerCase();
        final mlt = (kh['ma_lo_trinh'] ?? '').toString().toLowerCase();
        return tenKH.contains(query) ||
            maDB.contains(query) ||
            diaChi.contains(query) ||
            mlt.contains(query);
      }).toList();
    }

    // 2. Filter
    if (_filterType == "Chưa Đọc") {
      temp = temp.where((kh) => kh['trang_thai'] == 0).toList();
    } else if (_filterType == "Đã Đọc") {
      temp = temp.where((kh) => kh['trang_thai'] == 1).toList();
    } else if (_filterType == "F") {
      temp = temp.where((kh) => kh['code'] == 'F').toList();
    } else if (_filterType == "6") {
      temp = temp.where((kh) => kh['code'] == '6').toList();
    } else if (_filterType == "Bất Thường Tăng") {
      List<Map<String, dynamic>> filtered = [];
      for (var kh in temp) {
        final batThuong = await _tinhBatThuongLocal(kh);
        if (batThuong == 'tang') filtered.add(kh);
      }
      temp = filtered;
    } else if (_filterType == "Bất Thường Giảm") {
      List<Map<String, dynamic>> filtered = [];
      for (var kh in temp) {
        final batThuong = await DatabaseHelper().tinhBatThuong(kh);
        if (batThuong == 'giam') filtered.add(kh);
      }
      temp = filtered;
    } else if (_filterType == "Chủ Báo") {
      temp = temp.where((kh) {
        final ghiChu = (kh['ghi_chu'] ?? '').toString().toLowerCase();
        return ghiChu.contains('chủ báo') || ghiChu.contains('chu bao');
      }).toList();
    } else if (_filterType == "Chưa Gửi TB") {
      temp = temp.where((kh) {
        final tbtt = kh['tbtt'];
        return tbtt != null && tbtt > 0;
      }).toList();
    } else if (_filterType == "MLT Giảm") {
      temp.sort((b, a) {
        String mltA = (a['ma_lo_trinh'] ?? '').toString();
        String mltB = (b['ma_lo_trinh'] ?? '').toString();
        return mltA.compareTo(mltB);
      });
    } else if (_filterType.contains("%")) {
      final percentage = int.tryParse(_filterType.replaceAll("%", "")) ?? 0;
      temp = await _filterByPercentage(temp, percentage);
    }

    // 3. Sort
    if (_sortType == "Thời Gian Tăng") {
      temp.sort(
          (a, b) => (a['ngay_thay'] ?? '').compareTo(b['ngay_thay'] ?? ''));
    } else if (_sortType == "Thời Gian Giảm") {
      temp.sort(
          (b, a) => (a['ngay_thay'] ?? '').compareTo(b['ngay_thay'] ?? ''));
    } else if (_sortType == "MLT") {
      temp.sort((a, b) {
        String mltA = (a['ma_lo_trinh'] ?? '').toString();
        String mltB = (b['ma_lo_trinh'] ?? '').toString();
        if (mltA.isEmpty && mltB.isEmpty) {
          return (a['ma_danh_bo'] ?? '').compareTo(b['ma_danh_bo'] ?? '');
        }
        return mltA.compareTo(mltB);
      });
    }

    setState(() => _filteredList = temp);
  }

  Future<List<Map<String, dynamic>>> _filterByPercentage(
      List<Map<String, dynamic>> list, int percentage) async {
    List<Map<String, dynamic>> filtered = [];
    for (var kh in list) {
      final history = await api.layLichSuDoc(kh['ma_danh_bo'], limit: 1);
      if (history.isEmpty) continue;

      final chiSoCu = (kh['chi_so_cu'] as int?) ?? 0;
      final chiSoMoi = (kh['chi_so_moi'] as int?) ?? 0;
      final tieuThuKyTruoc = history.first['tieu_thu'] as int? ?? 0;
      final tieuThuHienTai = chiSoMoi - chiSoCu;

      if (tieuThuKyTruoc > 0) {
        final phanTramTang =
            ((tieuThuHienTai - tieuThuKyTruoc) / tieuThuKyTruoc * 100).abs();
        if (phanTramTang >= percentage) {
          filtered.add(kh);
        }
      }
    }
    return filtered;
  }

  /// Tính bất thường tiêu thụ (local, gọi API lấy lịch sử)
  Future<String?> _tinhBatThuongLocal(Map<String, dynamic> kh) async {
    try {
      final chiSoCu = (kh['chi_so_cu'] as int?) ?? 0;
      final chiSoMoi = (kh['chi_so_moi'] as int?) ?? 0;
      if (chiSoMoi <= 0 || chiSoMoi <= chiSoCu) return null;

      final tieuThuHienTai = chiSoMoi - chiSoCu;
      final history = await api.layLichSuDoc(kh['ma_danh_bo'], limit: 3);
      if (history.isEmpty) return null;

      double tongTieuThu = 0;
      int count = 0;
      for (var item in history) {
        final tt = (item['TieuThu'] ?? item['tieu_thu'] ?? 0);
        final ttInt = tt is int ? tt : int.tryParse(tt.toString()) ?? 0;
        if (ttInt > 0) {
          tongTieuThu += ttInt;
          count++;
        }
      }
      if (count == 0) return null;

      final trungBinh = tongTieuThu / count;
      if (tieuThuHienTai > trungBinh * 1.5) return 'tang';
      if (tieuThuHienTai < trungBinh * 0.5) return 'giam';
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> _importData() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
        if (!mounted) return;
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Xác nhận'),
            content: const Text(
                'Import sẽ XÓA toàn bộ dữ liệu cũ. Bạn có chắc chắn?'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Hủy')),
              ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Đồng ý')),
            ],
          ),
        );

        if (confirm == true) {
          if (!mounted) return;
          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (c) => const Center(child: CircularProgressIndicator()));

          await DatabaseHelper().xoaToanBoKhachHang();
          final count = await DatabaseHelper().importFromCSV(filePath);
          // TODO: Chuyển sang API import khi server hỗ trợ

          if (!mounted) return;
          Navigator.pop(context);
          _taiDuLieu();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('✅ Import thành công $count khách hàng!')));
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('❌ Lỗi import: $e')));
    }
  }

  Future<void> _exportData() async {
    try {
      final filePath = await DatabaseHelper().exportToCSV();
      // TODO: Chuyển sang API export khi server hỗ trợ
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ Export thành công!\n$filePath')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('❌ Lỗi export: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final daDocCount = _filteredList.where((k) => k['trang_thai'] == 1).length;
    final chuaDocCount = _filteredList.length - daDocCount;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Danh Sách Khách Hàng"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_showSearch ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _showSearch = !_showSearch;
                if (!_showSearch) _searchController.clear();
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterSortDialog,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'import') _importData();
              if (value == 'export') _exportData();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'import', child: Text('Import CSV')),
              const PopupMenuItem(value: 'export', child: Text('Export CSV')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          if (_showSearch)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(8),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                    hintText: "Tìm tên, mã, địa chỉ...",
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder()),
              ),
            ),
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.blue[50],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text("Tổng: ${_filteredList.length}",
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text("Đã đọc: $daDocCount",
                    style: const TextStyle(color: Colors.green)),
                Text("Chưa đọc: $chuaDocCount",
                    style: const TextStyle(color: Colors.red)),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredList.length,
              itemBuilder: (context, index) {
                final kh = _filteredList[index];
                final trangThai = kh['trang_thai'] == 1;

                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: trangThai
                        ? BorderSide.none
                        : const BorderSide(color: Colors.orange, width: 1.5),
                  ),
                  color: trangThai ? Colors.white : const Color(0xFFFFF8E1),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: trangThai ? Colors.green : Colors.orange,
                      child: Icon(trangThai ? Icons.check : Icons.schedule,
                          color: Colors.white),
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(kh['ten_kh'] ?? '',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        if (!trangThai)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text('Chưa đọc',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold)),
                          ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            "Mã: ${kh['ma_danh_bo']} | MLT: ${kh['ma_lo_trinh'] ?? ''}"),
                        Text(kh['dia_chi'] ?? ''),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("CS: ${kh['chi_so_cu'] ?? 0}"),
                        if (trangThai)
                          Text("→ ${kh['chi_so_moi'] ?? 0}",
                              style: const TextStyle(color: Colors.green)),
                      ],
                    ),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (c) => GhiNuocScreen(
                            danhSachKH: _filteredList,
                            initialIndex: index,
                          ),
                        ),
                      );
                      _taiDuLieu();
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ======================= MÀN HÌNH 4: CAMERA =======================
class CameraScreen extends StatefulWidget {
  final Map<String, dynamic> khachHang;
  const CameraScreen({super.key, required this.khachHang});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  late TextRecognizer _textRecognizer;
  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
    _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    _khoiTaoCamera();
  }

  Future<void> _khoiTaoCamera() async {
    await Permission.camera.request();
    final cameras = await availableCameras();
    if (cameras.isNotEmpty) {
      _controller = CameraController(cameras.first, ResolutionPreset.high,
          enableAudio: false);
      await _controller!.initialize();
      if (mounted) setState(() {});
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _textRecognizer.close();
    super.dispose();
  }

  Future<void> _chupVaXuLy() async {
    if (_controller == null || !_controller!.value.isInitialized || _isBusy) {
      return;
    }

    setState(() => _isBusy = true);

    try {
      final image = await _controller!.takePicture();
      final croppedFile = await _cropImage(image.path);

      if (croppedFile == null) {
        setState(() => _isBusy = false);
        return;
      }

      final inputImage = InputImage.fromFile(croppedFile);
      final RecognizedText recognizedText =
          await _textRecognizer.processImage(inputImage);

      String rawText = recognizedText.text;
      String cleaned = _cleanText(rawText);

      if (!mounted) return;

      if (cleaned.isNotEmpty) {
        Navigator.pop(context, {
          'chiSo': int.tryParse(cleaned),
          'imagePath': croppedFile.path,
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Không nhận diện được số!")));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Lỗi: $e")));
    } finally {
      setState(() => _isBusy = false);
    }
  }

  Future<File?> _cropImage(String path) async {
    final bytes = await File(path).readAsBytes();
    img.Image? src = img.decodeImage(bytes);
    if (src == null) return null;

    final int cropH = (src.height * 0.4).toInt();
    final int cropW = (src.width * 0.6).toInt();
    final int x = (src.width - cropW) ~/ 2;
    final int y = (src.height - cropH) ~/ 2;

    img.Image cropped =
        img.copyCrop(src, x: x, y: y, width: cropW, height: cropH);

    final croppedPath = path.replaceAll('.jpg', '_cropped.jpg');
    final croppedFile = File(croppedPath);
    await croppedFile.writeAsBytes(img.encodeJpg(cropped));

    return croppedFile;
  }

  String _cleanText(String raw) {
    String cleaned = raw
        .toUpperCase()
        .replaceAll('O', '0')
        .replaceAll('I', '1')
        .replaceAll('S', '5')
        .replaceAll('G', '6');

    RegExp exp = RegExp(r'\d{3,6}');
    Iterable<RegExpMatch> matches = exp.allMatches(cleaned);

    if (matches.isNotEmpty) {
      return matches.first.group(0)!;
    }
    return "";
  }

  Future<void> _chonAnhTuThuVien() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    setState(() => _isBusy = true);

    try {
      final croppedFile = await _cropImage(image.path);
      if (croppedFile == null) {
        setState(() => _isBusy = false);
        return;
      }

      final inputImage = InputImage.fromFile(croppedFile);
      final RecognizedText recognizedText =
          await _textRecognizer.processImage(inputImage);

      String rawText = recognizedText.text;
      String cleaned = _cleanText(rawText);

      if (!mounted) return;

      if (cleaned.isNotEmpty) {
        Navigator.pop(context, int.tryParse(cleaned));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Không nhận diện được số!")));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Lỗi: $e")));
    } finally {
      setState(() => _isBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(children: [
        Positioned.fill(child: CameraPreview(_controller!)),
        Positioned(
          bottom: 40,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                onPressed: _chonAnhTuThuVien,
                icon: const Icon(Icons.photo_library,
                    color: Colors.white, size: 40),
                style: IconButton.styleFrom(
                    backgroundColor: Colors.black54,
                    padding: const EdgeInsets.all(12)),
              ),
              const SizedBox(width: 40),
              GestureDetector(
                onTap: _chupVaXuLy,
                child: Container(
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4)),
                  child: Center(
                      child: _isBusy
                          ? const CircularProgressIndicator()
                          : const Icon(Icons.camera_alt,
                              color: Colors.white, size: 40)),
                ),
              ),
              const SizedBox(width: 80),
            ],
          ),
        ),
        Positioned(
            top: 40,
            left: 10,
            child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context))),
      ]),
    );
  }
}

// ======================= MÀN HÌNH 5: GHI CHỈ SỐ =======================
class GhiNuocScreen extends StatefulWidget {
  final List<Map<String, dynamic>> danhSachKH;
  final int initialIndex;

  const GhiNuocScreen(
      {super.key, required this.danhSachKH, required this.initialIndex});

  @override
  State<GhiNuocScreen> createState() => _GhiNuocScreenState();
}

class _GhiNuocScreenState extends State<GhiNuocScreen> {
  List<Map<String, dynamic>> _history = [];
  late int _currentIndex;
  late List<Map<String, dynamic>> _danhSachKH;
  final TextEditingController _csMoiController = TextEditingController();
  final TextEditingController _ghiChuController = TextEditingController();
  int _tieuThu = 0;
  String _selectedCode = '40';
  bool _filterShowRead = false;
  String? _capturedImagePath; // Đường dẫn ảnh đồng hồ đã chụp

  @override
  void initState() {
    super.initState();
    _danhSachKH =
        widget.danhSachKH.map((e) => Map<String, dynamic>.from(e)).toList();
    _currentIndex = widget.initialIndex;
    _csMoiController.addListener(_calculateTieuThu);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDataForCurrentIndex();
    });
  }

  @override
  void dispose() {
    _csMoiController.removeListener(_calculateTieuThu);
    _csMoiController.dispose();
    _ghiChuController.dispose();
    super.dispose();
  }

  void _calculateTieuThu() {
    final csMoi = int.tryParse(_csMoiController.text);
    final kh = _danhSachKH[_currentIndex];
    final csCu = kh['chi_so_cu'] ?? 0;

    if (csMoi != null) {
      setState(() {
        _tieuThu = (csMoi > csCu ? csMoi - csCu : 0).toInt();
        if (_history.length > 2) {
          _history[2]['cs'] = csMoi.toString();
          _history[2]['tt'] = _tieuThu.toString();
        }
      });
    } else {
      setState(() {
        _tieuThu = 0;
        if (_history.length > 2) {
          _history[2]['cs'] = '';
          _history[2]['tt'] = '';
        }
      });
    }
  }

  // Biến kiểm soát request async để tránh race condition
  int _loadingRequestId = 0;

  void _loadDataForCurrentIndex() async {
    if (_currentIndex < 0 || _currentIndex >= _danhSachKH.length) return;

    // Increment Request ID: Đánh dấu request mới nhất
    _loadingRequestId++;
    final int myRequestId = _loadingRequestId;

    final kh = _danhSachKH[_currentIndex];

    // Reset state first to avoid stale data
    setState(() {
      _capturedImagePath = null;
      _history = []; // Clear history temporarily while loading

      // Load saved values or defaults
      _selectedCode = kh['code']?.toString() ?? '40';
      if (kh['ghi_chu'] != null) {
        _ghiChuController.text = kh['ghi_chu'].toString();
      } else {
        _ghiChuController.clear();
      }

      // Handle ChiSoMoi
      if (kh['chi_so_moi'] != null &&
          (kh['chi_so_moi'] is int
              ? kh['chi_so_moi'] > 0
              : int.tryParse(kh['chi_so_moi'].toString()) != null)) {
        _csMoiController.text = kh['chi_so_moi'].toString();
      } else {
        _csMoiController.clear();
      }

      // Recalculate TieuThu immediately using existing data in local list
      // Do NOT set _tieuThu = 0 here to avoid flickering
      _calculateTieuThu();
    });

    try {
      final lichSu = await api.layLichSuDoc(kh['ma_danh_bo'], limit: 3);
      if (!mounted || _loadingRequestId != myRequestId) return;

      setState(() {
        if (lichSu.isEmpty) {
          _history = [
            {'code': '--', 'cs': '--', 'tt': '--'},
            {'code': '--', 'cs': '--', 'tt': '--'},
            {'code': '--', 'cs': '--', 'tt': '--'},
          ];
        } else {
          _history = lichSu.map<Map<String, dynamic>>((item) {
            return {
              'code': item['code']?.toString() ?? '40',
              'cs': item['chi_so'].toString(),
              'tt': item['tieu_thu'].toString(),
            };
          }).toList();

          while (_history.length < 3) {
            _history.add({'code': '--', 'cs': '--', 'tt': '--'});
          }
        }

        // --- FALLBACK LOGIC CHO CHỈ SỐ CŨ ---
        // Nếu ChiSoCu đang là 0, thử lấy từ lịch sử gần nhất
        int currentCsCu = int.tryParse(kh['chi_so_cu'].toString()) ?? 0;
        if (currentCsCu == 0 && lichSu.isNotEmpty) {
          // Lấy chỉ số của kỳ mới nhất trong lịch sử làm chỉ số cũ
          final latestHistory = lichSu.first;
          final historyCs =
              int.tryParse(latestHistory['chi_so'].toString()) ?? 0;
          if (historyCs > 0) {
            kh['chi_so_cu'] = historyCs; // Cập nhật vào model local (tạm thời)
            print("🛠️ Auto-fixed ChiSoCu for ${kh['ma_danh_bo']}: $historyCs");
          }
        }

        // Tính lại tiêu thụ sau khi (có thể) đã fix ChiSoCu
        _calculateTieuThu();
      });
    } catch (e) {
      print('Error loading history: $e');
    }
  }

  void _navigatePrevious() {
    if (_currentIndex > 0) {
      _saveCurrentTemp();
      int newIndex = _currentIndex - 1;
      if (_filterShowRead) {
        while (newIndex >= 0 && _danhSachKH[newIndex]['trang_thai'] == 1) {
          newIndex--;
        }
      }
      if (newIndex >= 0) {
        setState(() => _currentIndex = newIndex);
        _loadDataForCurrentIndex();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Không còn khách hàng chưa đọc phía trước!")));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Đây là khách hàng đầu tiên!")));
    }
  }

  void _navigateNext() {
    if (_currentIndex < _danhSachKH.length - 1) {
      _saveCurrentTemp();
      int newIndex = _currentIndex + 1;
      if (_filterShowRead) {
        while (newIndex < _danhSachKH.length &&
            _danhSachKH[newIndex]['trang_thai'] == 1) {
          newIndex++;
        }
      }
      if (newIndex < _danhSachKH.length) {
        setState(() => _currentIndex = newIndex);
        _loadDataForCurrentIndex();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Không còn khách hàng chưa đọc phía sau!")));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Đây là khách hàng cuối cùng!")));
    }
  }

  void _saveCurrentTemp() {
    final soMoi = int.tryParse(_csMoiController.text);
    if (soMoi != null) {
      _danhSachKH[_currentIndex]['chi_so_moi'] = soMoi;
      _danhSachKH[_currentIndex]['ghi_chu'] = _ghiChuController.text;
      _danhSachKH[_currentIndex]['code'] = _selectedCode;
    }
  }

  Future<void> _luuChiSo() async {
    final soMoi = int.tryParse(_csMoiController.text);
    if (soMoi == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Chỉ số không hợp lệ")));
      return;
    }

    final khCurrent = _danhSachKH[_currentIndex];

    // Gọi API ghi chỉ số (kết hợp cập nhật + lưu lịch sử)
    final maKyDoc = khCurrent['ma_ky_doc'] ?? 0;

    final success = await api.ghiChiSo(
      khCurrent['ma_danh_bo'],
      maKyDoc is int ? maKyDoc : int.tryParse(maKyDoc.toString()) ?? 0,
      soMoi,
      code: _selectedCode,
      ghiChu: _ghiChuController.text,
    );

    if (!mounted) return;

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Lỗi lưu chỉ số! Kiểm tra lại API (Kỳ: $maKyDoc)",
              style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Đã lưu chỉ số!", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green));

    setState(() {
      khCurrent['chi_so_moi'] = soMoi;
      khCurrent['trang_thai'] = 1;
      khCurrent['ghi_chu'] = _ghiChuController.text;
      khCurrent['code'] = _selectedCode;
    });

    _navigateNext();
  }

  Future<Map<String, dynamic>?> _pickImageFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return null;

    if (!mounted) return null;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Đang xử lý ảnh...")));

    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

    try {
      final croppedFile = await _cropImage(image.path);
      if (croppedFile == null) return null;

      final inputImage = InputImage.fromFile(croppedFile);
      final RecognizedText recognizedText =
          await textRecognizer.processImage(inputImage);

      String rawText = recognizedText.text;
      String cleaned = _cleanText(rawText);

      if (cleaned.isNotEmpty) {
        return {'chiSo': int.tryParse(cleaned), 'imagePath': croppedFile.path};
      } else {
        if (!mounted) return null;
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Không nhận diện được số!")));
        return null;
      }
    } catch (e) {
      if (!mounted) return null;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Lỗi: $e")));
      return null;
    } finally {
      textRecognizer.close();
    }
  }

  Future<File?> _cropImage(String path) async {
    final bytes = await File(path).readAsBytes();
    img.Image? src = img.decodeImage(bytes);
    if (src == null) return null;

    final int cropH = (src.height * 0.4).toInt();
    final int cropW = (src.width * 0.6).toInt();
    final int x = (src.width - cropW) ~/ 2;
    final int y = (src.height - cropH) ~/ 2;

    img.Image cropped =
        img.copyCrop(src, x: x, y: y, width: cropW, height: cropH);

    final croppedPath = path.replaceAll('.jpg', '_cropped.jpg');
    final croppedFile = File(croppedPath);
    await croppedFile.writeAsBytes(img.encodeJpg(cropped));

    return croppedFile;
  }

  String _cleanText(String raw) {
    String cleaned = raw
        .toUpperCase()
        .replaceAll('O', '0')
        .replaceAll('I', '1')
        .replaceAll('S', '5')
        .replaceAll('G', '6');

    RegExp exp = RegExp(r'\d{3,6}');
    Iterable<RegExpMatch> matches = exp.allMatches(cleaned);

    if (matches.isNotEmpty) {
      return matches.first.group(0)!;
    }
    return "";
  }

  @override
  Widget build(BuildContext context) {
    final kh = _danhSachKH[_currentIndex];
    print(
        "DEBUG GHI NUOC: Index $_currentIndex - KH: ${kh['ma_danh_bo']} - CS Cu: ${kh['chi_so_cu']} - TieuThu: $_tieuThu");
    const blueColor = Color(0xFF2196F3);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Ghi Chỉ Số Nước"),
        backgroundColor: blueColor,
        foregroundColor: Colors.white,
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.05, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
            )),
            child: FadeTransition(opacity: animation, child: child),
          );
        },
        child: Container(
          key: ValueKey<int>(_currentIndex),
          color: Colors.white,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Customer Info - Enhanced Layout
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(fontSize: 14),
                              children: [
                                TextSpan(
                                    text: 'MLT: ',
                                    style: TextStyle(
                                        color: Colors.grey[800],
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600)),
                                TextSpan(
                                    text: kh['ma_lo_trinh'] ?? '',
                                    style: const TextStyle(
                                        color: Color(0xFF2196F3),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                Checkbox(
                                  value: _filterShowRead,
                                  onChanged: (value) {
                                    setState(() {
                                      _filterShowRead = value ?? false;
                                    });
                                  },
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  visualDensity: VisualDensity.compact,
                                ),
                                const Text('Lọc Đã Đọc',
                                    style: TextStyle(fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(fontSize: 14),
                          children: [
                            TextSpan(
                                text: 'Danh Bộ: ',
                                style: TextStyle(
                                    color: Colors.grey[800],
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600)),
                            TextSpan(
                                text: kh['ma_danh_bo'],
                                style: const TextStyle(
                                    color: Color(0xFF2196F3),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22)),
                            TextSpan(
                                text: '  VT:',
                                style: TextStyle(
                                    color: Colors.grey[800],
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text('Hiệu: ',
                              style: TextStyle(
                                  color: Colors.grey[800],
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600)),
                          Text(kh['ten_kh'] ?? '',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          const Spacer(),
                          Text('Cỡ: ',
                              style: TextStyle(
                                  color: Colors.grey[800],
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600)),
                          const Text('15',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text('Địa Chỉ: ',
                              style: TextStyle(
                                  color: Colors.grey[800],
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600)),
                          Expanded(
                            child: Text(kh['dia_chi'] ?? '',
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text('Địa Chỉ DHN: ',
                              style: TextStyle(
                                  color: Colors.grey[800],
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600)),
                          Expanded(
                            child: Text(kh['dia_chi'] ?? '',
                                style: const TextStyle(
                                    color: Color(0xFF2196F3),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text('Họ Tên: ',
                              style: TextStyle(
                                  color: Colors.grey[800],
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600)),
                          Expanded(
                            child: Text((kh['ten_kh'] ?? '').toUpperCase(),
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text('Ghi Chú: ',
                              style: TextStyle(
                                  color: Colors.grey[800],
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600)),
                          Expanded(
                            child: Text(kh['ghi_chu'] ?? 'kè 68 dinh liet',
                                style: const TextStyle(
                                    fontSize: 14, fontStyle: FontStyle.italic)),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      // Tình Trạng
                      Row(
                        children: [
                          const Text('Tình Trạng',
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Stats Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatBox("CS Cũ",
                              (kh['chi_so_cu'] ?? 0).toString(), Colors.blue),
                          _buildStatBox(
                              "Tiêu thụ", _tieuThu.toString(), Colors.orange),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // History Table
                      Table(
                        border: TableBorder.all(
                            color: Colors.grey[400]!, width: 1.5),
                        columnWidths: const {
                          0: FlexColumnWidth(1.2),
                          1: FlexColumnWidth(1),
                          2: FlexColumnWidth(1),
                          3: FlexColumnWidth(1),
                        },
                        children: [
                          TableRow(children: [
                            _buildCell("Code", isHeader: true),
                            ..._history.map((e) => _buildCell(e['code'] ?? '',
                                bg: _getColorForIndex(_history.indexOf(e))))
                          ]),
                          TableRow(children: [
                            _buildCell("Chỉ số", isHeader: true),
                            ..._history.map((e) => _buildCell(e['cs'] ?? '',
                                bg: _getColorForIndex(_history.indexOf(e))))
                          ]),
                          TableRow(children: [
                            _buildCell("Tiêu thụ", isHeader: true),
                            ..._history.map((e) => _buildCell(e['tt'] ?? '',
                                bg: _getColorForIndex(_history.indexOf(e))))
                          ]),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Code Dropdown + Input
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Code",
                                  style: TextStyle(
                                      color: Colors.grey[700],
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[300]!),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _selectedCode,
                                    isDense: true,
                                    items: const [
                                      DropdownMenuItem(
                                          value: '40',
                                          child: Text('40',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight:
                                                      FontWeight.bold))),
                                      DropdownMenuItem(
                                          value: 'F',
                                          child: Text('F',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.red))),
                                      DropdownMenuItem(
                                          value: '6',
                                          child: Text('6',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.orange))),
                                      DropdownMenuItem(
                                          value: '10',
                                          child: Text('10',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight:
                                                      FontWeight.bold))),
                                      DropdownMenuItem(
                                          value: '20',
                                          child: Text('20',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight:
                                                      FontWeight.bold))),
                                    ],
                                    onChanged: (v) {
                                      setState(() => _selectedCode = v!);
                                      final currentKh =
                                          _danhSachKH[_currentIndex];
                                      final kyDoc = currentKh['ma_ky_doc'] ?? 0;
                                      api.capNhatCode(
                                          currentKh['ma_danh_bo'],
                                          kyDoc is int
                                              ? kyDoc
                                              : int.tryParse(
                                                      kyDoc.toString()) ??
                                                  0,
                                          v!);
                                    },
                                  ),
                                ),
                              ),
                              Text(
                                  _selectedCode == '40'
                                      ? "ĐH bình\nthường"
                                      : _selectedCode == 'F'
                                          ? "ĐH hỏng"
                                          : _selectedCode == '6'
                                              ? "Khóa nước"
                                              : _selectedCode == '10'
                                                  ? "ĐH ngược"
                                                  : _selectedCode == '20'
                                                      ? "Nhà trống"
                                                      : "",
                                  style: TextStyle(
                                      color: Colors.grey[500],
                                      fontStyle: FontStyle.italic)),
                            ],
                          ),
                          const SizedBox(width: 20),
                          SizedBox(
                            width: 200,
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Text("CSM",
                                        style: TextStyle(
                                            color: Colors.grey[700],
                                            fontWeight: FontWeight.bold)),
                                    const Spacer(),
                                    InkWell(
                                      onTap: () async {
                                        // Dialog chọn Camera hoặc Gallery
                                        final choice = await showDialog<String>(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text('Chọn nguồn ảnh'),
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                ListTile(
                                                  leading: const Icon(
                                                      Icons.camera_alt,
                                                      color: Color(0xFF2196F3)),
                                                  title: const Text('Chụp ảnh'),
                                                  onTap: () => Navigator.pop(
                                                      context, 'camera'),
                                                ),
                                                ListTile(
                                                  leading: const Icon(
                                                      Icons.photo_library,
                                                      color: Color(0xFF2196F3)),
                                                  title: const Text(
                                                      'Chọn từ thư viện'),
                                                  onTap: () => Navigator.pop(
                                                      context, 'gallery'),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );

                                        if (choice == null) return;

                                        Map<String, dynamic>? result;
                                        if (choice == 'camera') {
                                          result = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (c) => CameraScreen(
                                                    khachHang: kh)),
                                          );
                                        } else {
                                          result =
                                              await _pickImageFromGallery();
                                        }

                                        if (result != null) {
                                          setState(() {
                                            final chiSo = result!['chiSo'];
                                            if (chiSo != null) {
                                              _csMoiController.text =
                                                  chiSo.toString();
                                              kh['chi_so_moi'] = chiSo;
                                              kh['trang_thai'] = 1;
                                            }
                                            _capturedImagePath =
                                                result['imagePath'];
                                          });
                                        }
                                      },
                                      child: Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: const Icon(Icons.camera_alt,
                                            color: Colors.black54, size: 28),
                                      ),
                                    ),
                                    // === KHUNG XEM ẢNH ĐÃ CHỤP ===
                                    if (_capturedImagePath != null)
                                      GestureDetector(
                                        onTap: () {
                                          // Xem ảnh toàn màn hình
                                          showDialog(
                                            context: context,
                                            builder: (ctx) => Dialog(
                                              backgroundColor: Colors.black,
                                              insetPadding:
                                                  const EdgeInsets.all(10),
                                              child: Stack(
                                                children: [
                                                  Center(
                                                    child: InteractiveViewer(
                                                      child: Image.file(
                                                        File(
                                                            _capturedImagePath!),
                                                        fit: BoxFit.contain,
                                                      ),
                                                    ),
                                                  ),
                                                  Positioned(
                                                    top: 8,
                                                    right: 8,
                                                    child: IconButton(
                                                      icon: const Icon(
                                                          Icons.close,
                                                          color: Colors.white,
                                                          size: 30),
                                                      onPressed: () =>
                                                          Navigator.pop(ctx),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          width: 80,
                                          height: 80,
                                          margin:
                                              const EdgeInsets.only(left: 10),
                                          child: Stack(
                                            clipBehavior: Clip.none,
                                            children: [
                                              Container(
                                                width: 80,
                                                height: 80,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  border: Border.all(
                                                      color: Colors.green,
                                                      width: 2),
                                                ),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  child: Image.file(
                                                    File(_capturedImagePath!),
                                                    fit: BoxFit.cover,
                                                    width: 80,
                                                    height: 80,
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                top: -8,
                                                right: -8,
                                                child: GestureDetector(
                                                  onTap: () {
                                                    setState(() =>
                                                        _capturedImagePath =
                                                            null);
                                                  },
                                                  child: Container(
                                                    width: 26,
                                                    height: 26,
                                                    decoration:
                                                        const BoxDecoration(
                                                      color: Colors.red,
                                                      shape: BoxShape.circle,
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black26,
                                                          blurRadius: 3,
                                                        ),
                                                      ],
                                                    ),
                                                    child: const Icon(
                                                        Icons.close,
                                                        size: 16,
                                                        color: Colors.white),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                TextField(
                                  controller: _csMoiController,
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold),
                                  decoration: const InputDecoration(
                                    border: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.pinkAccent,
                                            width: 3)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                height: 60,
                decoration: BoxDecoration(
                    color: Colors.grey[200],
                    border:
                        const Border(top: BorderSide(color: Colors.black12))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildBottomIcon(
                        Icons.arrow_back_ios, "Trước", _navigatePrevious),
                    _buildBottomIcon(
                        Icons.arrow_forward_ios, "Sau", _navigateNext),
                    _buildBottomIcon(Icons.share, "PC", () async {
                      try {
                        final filePath = await DatabaseHelper().exportToCSV();
                        // TODO: Chuyển sang API export khi server hỗ trợ
                        await Share.shareXFiles([XFile(filePath)],
                            text: 'Dữ liệu đọc số đồng hồ nước');
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("✅ Đã chia sẻ dữ liệu!"),
                                backgroundColor: Colors.green));
                      } catch (e) {
                        await AppLogger()
                            .error('Lỗi export/share: $e', context: 'EXPORT');
                        if (!mounted) return;
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text("❌ Lỗi: $e")));
                      }
                    }, color: Colors.teal),
                    _buildBottomIcon(Icons.edit_note, "Ghi Chú", () {
                      _ghiChuController.text = kh['ghi_chu'] ?? '';
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Ghi Chú"),
                          content: TextField(
                            controller: _ghiChuController,
                            decoration: const InputDecoration(
                                hintText: "Nhập ghi chú...",
                                border: OutlineInputBorder()),
                            maxLines: 3,
                          ),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("Đóng")),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  kh['ghi_chu'] = _ghiChuController.text;
                                });
                                Navigator.pop(context);
                              },
                              child: const Text("Lưu"),
                            )
                          ],
                        ),
                      );
                    }, color: Colors.amber[800]),
                    _buildBottomIcon(Icons.print, "In", () async {
                      try {
                        final receipt = "===== HÓA ĐƠN NƯỚC =====\n" +
                            "Khách hàng: ${kh['ten_kh']}\n" +
                            "Địa chỉ: ${kh['dia_chi']}\n" +
                            "Mã ĐB: ${kh['ma_danh_bo']}\n" +
                            "----------------------------\n" +
                            "Chỉ số cũ: ${kh['chi_so_cu']}\n" +
                            "Chỉ số mới: ${kh['chi_so_moi']}\n" +
                            "Tiêu thụ: ${(kh['chi_so_moi'] ?? 0) - (kh['chi_so_cu'] ?? 0)} m³\n" +
                            "========================";

                        await Share.share(receipt);

                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("✅ Đã tạo hóa đơn!"),
                                backgroundColor: Colors.green));
                      } catch (e) {
                        await AppLogger()
                            .error('Lỗi tạo hóa đơn: $e', context: 'PRINT');
                        if (!mounted) return;
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text("❌ Lỗi: $e")));
                      }
                    }, color: Colors.purple),
                    _buildBottomIcon(Icons.save, "Lưu", _luuChiSo,
                        color: Colors.blue[800]),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Color _getColorForIndex(int index) {
    switch (index) {
      case 0:
        return const Color(0xFFEF9A9A);
      case 1:
        return const Color(0xFF90CAF9);
      case 2:
        return const Color(0xFFE6EE9C);
      default:
        return Colors.transparent;
    }
  }

  Widget _buildStatBox(String label, String value, Color color) {
    return Container(
      width: 110,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3))),
      child: Column(
        children: [
          Text(label,
              style: TextStyle(
                  color: color, fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  color: color, fontWeight: FontWeight.bold, fontSize: 20)),
        ],
      ),
    );
  }

  Widget _buildCell(String text,
      {Color? bg, Alignment align = Alignment.center, bool isHeader = false}) {
    return Container(
      height: 50,
      alignment: align,
      color: bg ?? Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(text,
          style: TextStyle(
              fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
              fontSize: isHeader ? 14 : 18,
              color: isHeader ? Colors.grey[700] : Colors.black87)),
    );
  }

  Widget _buildBottomIcon(IconData icon, String label, VoidCallback? onTap,
      {Color? color}) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color ?? Colors.grey[700], size: 24),
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  color: color ?? Colors.grey[700],
                  fontWeight: FontWeight.bold))
        ],
      ),
    );
  }
}
