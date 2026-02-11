import 'dart:io';
import 'dart:convert';
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
import 'ui_helper.dart';

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
      UIHelper.showCustomSnackBar(context,
          message: "Vui lòng nhập đầy đủ thông tin!", isError: true);
      return;
    }

    if (_isLogin) {
      var user = await api.dangNhap(u, p);
      if (user != null) {
        if (!mounted) return;

        // Save user info
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('username', user['username']);
        await prefs.setString('fullname', user['fullname']);
        if (user['avatar'] != null) {
          await prefs.setString('avatar_data', user['avatar']);
        }

        UIHelper.showCustomSnackBar(context,
            message: "Đăng nhập thành công!", isSuccess: true);
        await Future.delayed(const Duration(milliseconds: 500));
        if (!mounted) return;
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => DashboardScreen(
                    fullname: user['fullname'] ?? user['username'])));
      } else {
        if (!mounted) return;
        UIHelper.showCustomSnackBar(context,
            message: "Sai tài khoản hoặc mật khẩu!", isError: true);
      }
    } else {
      if (_nameController.text.isEmpty) {
        UIHelper.showCustomSnackBar(context,
            message: "Vui lòng nhập Họ và Tên!", isError: true);
        return;
      }
      bool success = await api.dangKy(u, p, _nameController.text);
      if (!mounted) return;
      if (success) {
        UIHelper.showCustomSnackBar(context,
            message: "Đăng ký thành công! Vui lòng đăng nhập.",
            isSuccess: true);
        setState(() => _isLogin = true);
      } else {
        UIHelper.showCustomSnackBar(context,
            message: "Tên đăng nhập đã tồn tại!", isError: true);
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
      _avatarPath = prefs.getString('avatar_data');
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
        // 1. Convert to Base64
        final bytes = await File(image.path).readAsBytes();
        final base64Image = base64Encode(bytes);

        // 2. Upload API
        final username =
            (await SharedPreferences.getInstance()).getString('username') ?? '';

        UIHelper.showCustomSnackBar(context,
            message: "Đang cập nhật avatar...", isSuccess: true);

        final success = await api.updateAvatar(username, base64Image);

        if (success) {
          // 3. Save to Prefs
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('avatar_data', base64Image);

          setState(() {
            _avatarPath = base64Image;
          });

          if (mounted) {
            UIHelper.showCustomSnackBar(context,
                message: "Cập nhật avatar thành công!", isSuccess: true);
          }
        } else {
          if (mounted) {
            UIHelper.showCustomSnackBar(context,
                message: "Lỗi cập nhật avatar!", isError: true);
          }
        }
      }
    }
  }

  Widget _buildAvatarWidget(String? pathOrBase64) {
    if (pathOrBase64 == null || pathOrBase64.isEmpty) {
      return const Icon(Icons.person, size: 60, color: Colors.white);
    }

    // 1. Check if valid file path
    final file = File(pathOrBase64);
    if (file.existsSync()) {
      return ClipOval(
        child: Image.file(
          file,
          fit: BoxFit.cover,
          width: 120,
          height: 120,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.person, size: 60, color: Colors.white),
        ),
      );
    }

    // 2. Try Base64
    try {
      String cleanBase64 = pathOrBase64;
      if (cleanBase64.contains(',')) {
        cleanBase64 = cleanBase64.split(',').last;
      }
      final bytes = base64Decode(cleanBase64);
      return ClipOval(
        child: Image.memory(
          bytes,
          fit: BoxFit.cover,
          width: 120,
          height: 120,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.person, size: 60, color: Colors.white),
        ),
      );
    } catch (e) {
      return const Icon(Icons.person, size: 60, color: Colors.white);
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
              final confirm = await UIHelper.showCustomDialog<bool>(
                context: context,
                title: 'Đăng xuất',
                content: 'Bạn có chắc chắn muốn đăng xuất?',
                icon: Icons.logout,
                iconColor: Colors.orange,
                confirmText: 'Đăng xuất',
                onConfirm: () => Navigator.pop(context, true),
                cancelText: 'Hủy',
              );

              // Nếu user xác nhận đăng xuất
              if (confirm == true) {
                if (!context.mounted) return;

                // Hiển thị thông báo đăng xuất thành công
                UIHelper.showCustomSnackBar(context,
                    message: 'Đã đăng xuất thành công!', isSuccess: true);

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
                      child: _buildAvatarWidget(_avatarPath),
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
                    () => UIHelper.showCustomSnackBar(context,
                        message: "Chức năng đang được phát triển",
                        isError: false),
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
  int _filterStatus = 0; // 0: Tất cả, 1: Chưa Đọc, 2: Đã Đọc

  final List<String> _filters = [
    "Tất cả",
    // "Chưa Đọc", // Removed
    // "Đã Đọc",   // Removed
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
      // 0. Chuẩn bị dữ liệu local để merge (giữ hình ảnh/trạng thái offline)
      final localData = await DatabaseHelper().layDanhSach();
      final Map<String, Map<String, dynamic>> localMap = {
        for (var item in localData) item['ma_danh_bo'].toString(): item
      };

      List<Map<String, dynamic>> finalData = [];

      // 1. Lấy danh sách kỳ đọc từ API
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
            finalData = data;
            break; // Found data, stop searching
          }
        }
      }

      // 2. Fallback: Nếu API không có dữ liệu đọc số, lấy danh sách khách hàng gốc
      if (finalData.isEmpty) {
        print('⚠️ No data found in any KyDoc, loading from KhachHang table');
        finalData = await api.layDanhSach();
        // Inject MaKyDoc từ kỳ mới nhất
        if (kyDocList.isNotEmpty) {
          final latestMaKy = kyDocList.first['MaKyDoc'] as int?;
          if (latestMaKy != null) {
            for (var item in finalData) {
              item['ma_ky_doc'] = latestMaKy;
            }
          }
        }
      }

      // 3. MERGE LOCAL DATA (Quan trọng: Khôi phục hình ảnh/trạng thái đã lưu offline)
      if (finalData.isNotEmpty) {
        print(
            '🔄 Merging local data (${localMap.length} records) into API result...');
        for (var item in finalData) {
          // Ensure strict string comparison and trim
          final mdb = (item['ma_danh_bo']?.toString() ?? '').trim();

          if (localMap.containsKey(mdb)) {
            final local = localMap[mdb]!;

            // DEBUG: Check specific customer
            if (item['hinh_anh'] == null && local['hinh_anh'] != null) {
              print(
                  '📸 Restoring image for $mdb from local DB: ${local['hinh_anh']}');
            }

            // Nếu local có hình ảnh, ghi đè vào data hiển thị
            if (local['hinh_anh'] != null &&
                local['hinh_anh'].toString().isNotEmpty) {
              item['hinh_anh'] = local['hinh_anh'];
              item['imagePath'] =
                  local['hinh_anh']; // Đảm bảo tương thích cả 2 key

              // Nếu trạng thái local là đã đọc (1), cập nhật luôn
              if (local['trang_thai'] == 1) {
                item['trang_thai'] = 1;
                item['chi_so_moi'] = local['chi_so_moi'];
                item['code'] = local['code'];
              }
            }
          }
        }
      }

      setState(() {
        _danhSachKH = finalData;
      });
      _applyFilter();
    } catch (e) {
      print('❌ Lỗi tải dữ liệu: $e');
      // Fallback hoàn toàn về local nếu lỗi mạng
      final localData = await DatabaseHelper().layDanhSach();
      setState(() {
        _danhSachKH = localData;
        _filteredList = List.from(localData);
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

    // 2. Filter by Status (Toggle)
    if (_filterStatus == 1) {
      temp = temp.where((kh) => kh['trang_thai'] == 0).toList();
    } else if (_filterStatus == 2) {
      temp = temp.where((kh) => kh['trang_thai'] == 1).toList();
    }

    // 3. Filter by Type (Dropdown)
    if (_filterType == "F") {
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

  Widget _buildFilterButton(String label, int value, Color color) {
    final bool isSelected = _filterStatus == value;
    return InkWell(
      onTap: () {
        setState(() => _filterStatus = value);
        _applyFilter();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
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
          // Filter Toggle Row
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: Colors.grey[100],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildFilterButton("Tất cả", 0, Colors.blue),
                const SizedBox(width: 8),
                _buildFilterButton("Chưa đọc", 1, Colors.red),
                const SizedBox(width: 8),
                _buildFilterButton("Đã đọc", 2, Colors.green),
              ],
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
                    leading: InkWell(
                      onTap: () async {
                        final maKyDoc = kh['ma_ky_doc'] is int
                            ? kh['ma_ky_doc']
                            : int.tryParse(kh['ma_ky_doc'].toString()) ?? 0;

                        if (trangThai) {
                          // Xác nhận hủy đọc số
                          final confirm = await UIHelper.showCustomDialog(
                            context: context,
                            title: 'Xác nhận',
                            content:
                                'Bạn có muốn hủy trạng thái ĐÃ ĐỌC của khách hàng này?',
                            confirmText: 'Đồng ý',
                            cancelText: 'Bỏ qua',
                            icon: Icons.help_outline,
                            iconColor: Colors.orange,
                          );

                          if (confirm == true) {
                            final success =
                                await api.huyDocSo(kh['ma_danh_bo'], maKyDoc);
                            if (success) {
                              final mdb = kh['ma_danh_bo'].toString();
                              await DatabaseHelper().resetTrangThaiLocal(mdb);

                              setState(() {
                                kh['trang_thai'] = 0;
                                kh['chi_so_moi'] = kh['chi_so_cu'];
                                kh['tieu_thu'] = 0;
                              });
                              UIHelper.showCustomSnackBar(context,
                                  message: "Đã đặt lại trạng thái!",
                                  isSuccess: true);
                              _taiDuLieu();
                            } else {
                              UIHelper.showCustomSnackBar(context,
                                  message: "Lỗi hủy đọc số!", isError: true);
                            }
                          }
                        } else {
                          // Quick mark as read
                          final confirmRead = await UIHelper.showCustomDialog(
                            context: context,
                            title: 'Xác nhận Đã Đọc',
                            content:
                                'Bạn có muốn đánh dấu khách hàng này là ĐÃ ĐỌC?\n(Chỉ số mới sẽ được gán bằng Chỉ số cũ: ${kh['chi_so_cu']})',
                            confirmText: 'Đồng ý',
                            cancelText: 'Bỏ qua',
                            icon: Icons.check_circle,
                            iconColor: Colors.green,
                          );

                          if (confirmRead == true) {
                            final success = await api.ghiChiSo(
                              kh['ma_danh_bo'],
                              maKyDoc,
                              kh['chi_so_cu'] ?? 0,
                              code: kh['code'] ?? '40',
                              ghiChu: kh['ghi_chu'] ?? '',
                            );
                            if (success) {
                              setState(() {
                                kh['trang_thai'] = 1;
                                kh['chi_so_moi'] = kh['chi_so_cu'];
                                kh['tieu_thu'] = 0;
                              });
                              UIHelper.showCustomSnackBar(context,
                                  message: "✅ Đã đánh dấu Đã đọc thành công!",
                                  isSuccess: true);

                              await DatabaseHelper().capNhatChiSo(
                                kh['ma_danh_bo'],
                                kh['chi_so_cu'] ?? 0,
                                '',
                                ghiChu: kh['ghi_chu'] ?? '',
                                code: kh['code'] ?? '40',
                              );
                              _taiDuLieu();
                            } else {
                              print('❌ Lỗi Quick Mark (Server): $success');
                              UIHelper.showCustomSnackBar(context,
                                  message:
                                      "❌ Lỗi lưu trạng thái! Vui lòng kiểm tra kết nối.",
                                  isError: true);
                            }
                          }
                        }
                      },
                      child: CircleAvatar(
                        backgroundColor:
                            trangThai ? Colors.green : Colors.orange,
                        child: Icon(trangThai ? Icons.check : Icons.schedule,
                            color: Colors.white),
                      ),
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
    if (Platform.isAndroid || Platform.isIOS) {
      _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    }
    _khoiTaoCamera();
  }

  Future<void> _khoiTaoCamera() async {
    if (Platform.isAndroid || Platform.isIOS) {
      await Permission.camera.request();
    }
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
    if (Platform.isAndroid || Platform.isIOS) {
      _textRecognizer.close();
    }
    super.dispose();
  }

  Future<void> _chupVaXuLy() async {
    if (_controller == null || !_controller!.value.isInitialized || _isBusy) {
      return;
    }

    setState(() => _isBusy = true);

    try {
      final image = await _controller!.takePicture();
      // Skip cropping on Windows for now or implement a different cropper if needed
      // But keeping it consistent.
      final croppedFile = await _cropImage(image.path);

      if (croppedFile == null) {
        setState(() => _isBusy = false);
        return;
      }

      // Skip OCR on Windows
      if (!Platform.isAndroid && !Platform.isIOS) {
        if (!mounted) return;
        Navigator.pop(context, {
          'chiSo': null,
          'imagePath': croppedFile.path,
        });
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
        UIHelper.showCustomSnackBar(context,
            message: "Không nhận diện được số!", isError: true);
      }
    } catch (e) {
      if (!mounted) return;
      UIHelper.showCustomSnackBar(context, message: "Lỗi: $e", isError: true);
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
        UIHelper.showCustomSnackBar(context,
            message: "Không nhận diện được số!", isError: true);
      }
    } catch (e) {
      if (!mounted) return;
      UIHelper.showCustomSnackBar(context, message: "Lỗi: $e", isError: true);
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

    _loadUserSession();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDataForCurrentIndex();
    });
  }

  Future<void> _loadUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username');
    api.setUsername(username);
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
      _capturedImagePath =
          kh['imagePath'] ?? kh['hinh_anh']; // Load image (check both keys)

      // Ensure empty string is treated as null
      if (_capturedImagePath != null && _capturedImagePath!.isEmpty) {
        _capturedImagePath = null;
      }
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
        UIHelper.showCustomSnackBar(context,
            message: "Không còn khách hàng chưa đọc phía trước!",
            isError: false);
      }
    } else {
      UIHelper.showCustomSnackBar(context,
          message: "Đây là khách hàng đầu tiên!", isError: false);
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
        UIHelper.showCustomSnackBar(context,
            message: "Không còn khách hàng chưa đọc phía sau!", isError: false);
      }
    } else {
      UIHelper.showCustomSnackBar(context,
          message: "Đây là khách hàng cuối cùng!", isError: false);
    }
  }

  void _saveCurrentTemp() {
    final soMoi = int.tryParse(_csMoiController.text);
    if (soMoi != null) {
      _danhSachKH[_currentIndex]['chi_so_moi'] = soMoi;
      _danhSachKH[_currentIndex]['ghi_chu'] = _ghiChuController.text;
      _danhSachKH[_currentIndex]['code'] = _selectedCode;
      // Mark as read locally so filter works even if not saved to API yet
      _danhSachKH[_currentIndex]['trang_thai'] = 1;
    }
  }

  Future<void> _luuChiSo(
      {bool silent = false, bool useOldIndex = false}) async {
    final khCurrent = _danhSachKH[_currentIndex];
    int? soMoi;

    if (useOldIndex) {
      soMoi = khCurrent['chi_so_cu'] ?? 0;
      // Also update controller for visual feedback
      _csMoiController.text = soMoi.toString();
    } else {
      soMoi = int.tryParse(_csMoiController.text);
    }

    if (soMoi == null) {
      if (!silent) {
        // Quick Mark as Read prompt if field is empty
        final confirmQuick = await UIHelper.showCustomDialog(
          context: context,
          title: 'Ghi nhanh',
          content:
              'Bạn chưa nhập chỉ số mới. Bạn có muốn đánh dấu ĐÃ ĐỌC với chỉ số cũ (${khCurrent['chi_so_cu'] ?? 0}) không?',
          confirmText: 'Đồng ý',
          cancelText: 'Bỏ qua',
          icon: Icons.flash_on,
          iconColor: Colors.orange,
        );
        if (confirmQuick == true) {
          print('⚡ Triggering Quick Mark as Read (Use Old Index)');
          return _luuChiSo(useOldIndex: true);
        }
      }
      return;
    }

    // Gọi API ghi chỉ số (kết hợp cập nhật + lưu lịch sử)
    final maKyDoc = khCurrent['ma_ky_doc'] ?? 0;

    final success = await api.ghiChiSo(
      khCurrent['ma_danh_bo'],
      maKyDoc is int ? maKyDoc : int.tryParse(maKyDoc.toString()) ?? 0,
      soMoi,
      code: _selectedCode,
      ghiChu: _ghiChuController.text,
      imagePath: _capturedImagePath, // Pass image path to API for upload
    );

    if (!mounted) return;
    if (!success) {
      UIHelper.showCustomSnackBar(context,
          message: "❌ Lỗi lưu Server! Chỉ đã lưu Offline.", isError: true);
    } else {
      if (!silent) {
        UIHelper.showCustomSnackBar(context,
            message: useOldIndex
                ? "✅ Đã đánh dấu Đã đọc (Ghi nhanh)!"
                : "✅ Đã lưu chỉ số lên Server!",
            isSuccess: true);
      }
    }

    // Always save to local DB (including image path)
    await DatabaseHelper().capNhatChiSo(
      khCurrent['ma_danh_bo'],
      soMoi,
      _capturedImagePath ?? '',
      ghiChu: _ghiChuController.text,
      code: _selectedCode,
    );

    setState(() {
      khCurrent['chi_so_moi'] = soMoi;
      khCurrent['trang_thai'] = 1;
      khCurrent['ghi_chu'] = _ghiChuController.text;
      khCurrent['code'] = _selectedCode;
      // Persist image path locally so it doesn't disappear
      if (_capturedImagePath != null) {
        khCurrent['imagePath'] = _capturedImagePath;
      }
    });

    // _navigateNext(); // REMOVED as per user request
  }

  Future<Map<String, dynamic>?> _pickImageFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return null;

    if (!mounted) return null;
    UIHelper.showCustomSnackBar(context,
        message: "Đang xử lý ảnh...", isSuccess: true);

    // Skip OCR on Windows
    if (!Platform.isAndroid && !Platform.isIOS) {
      // On Windows, just return the image path without OCR
      return {'chiSo': null, 'imagePath': image.path};
    }

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
        UIHelper.showCustomSnackBar(context,
            message: "Không nhận diện được số!", isError: true);
        return null;
      }
    } catch (e) {
      if (!mounted) return null;
      UIHelper.showCustomSnackBar(context, message: "Lỗi: $e", isError: true);
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
                      // Ghi Chú - Improved UI
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(
                              0xFFFFF3E0), // Light orange background
                          borderRadius: BorderRadius.circular(8),
                          border:
                              Border.all(color: Colors.orange.withOpacity(0.3)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.note_alt_outlined,
                                size: 20, color: Colors.orange),
                            const SizedBox(width: 8),
                            Expanded(
                              child: InkWell(
                                onTap: _showNoteEditDialog,
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: Colors.amber.withOpacity(0.3)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.edit_note,
                                              size: 16, color: Colors.orange),
                                          const SizedBox(width: 4),
                                          const Text("Ghi Chú:",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.orange,
                                                  fontSize: 13)),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        (kh['ghi_chu'] != null &&
                                                kh['ghi_chu']
                                                    .toString()
                                                    .trim()
                                                    .isNotEmpty)
                                            ? kh['ghi_chu'].toString()
                                            : "Chưa có ghi chú (Chạm để sửa)",
                                        style: TextStyle(
                                            fontStyle: FontStyle.italic,
                                            color: (kh['ghi_chu'] != null &&
                                                    kh['ghi_chu']
                                                        .toString()
                                                        .trim()
                                                        .isNotEmpty)
                                                ? Colors.black87
                                                : Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
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
                                        // Dialog chọn Camera hoặc Gallery using UIHelper
                                        final choice = await UIHelper
                                            .showOptionDialog<String>(
                                          context: context,
                                          title: 'Chọn nguồn ảnh',
                                          options: [
                                            {
                                              'label': 'Chụp ảnh',
                                              'icon': Icons.camera_alt,
                                              'value': 'camera',
                                              'color': Colors.blue
                                            },
                                            {
                                              'label': 'Chọn từ thư viện',
                                              'icon': Icons.photo_library,
                                              'value': 'gallery',
                                              'color': Colors.green
                                            },
                                          ],
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
                                          // 1. Update UI State
                                          setState(() {
                                            final chiSo = result!['chiSo'];
                                            if (chiSo != null) {
                                              _csMoiController.text =
                                                  chiSo.toString();
                                            }
                                            // Always update image path if result is returned
                                            if (result['imagePath'] != null) {
                                              _capturedImagePath =
                                                  result['imagePath'];
                                              // Save immediately to model so it persists if setState is called elsewhere
                                              kh['imagePath'] =
                                                  result['imagePath'];
                                            }
                                          });

                                          // 2. Async Auto-save (outside setState)
                                          if (result['imagePath'] != null) {
                                            final maKyDoc = kh['ma_ky_doc']
                                                    is int
                                                ? kh['ma_ky_doc']
                                                : int.tryParse(kh['ma_ky_doc']
                                                        .toString()) ??
                                                    0;
                                            await api.capNhatHinhAnh(
                                                kh['ma_danh_bo'],
                                                maKyDoc,
                                                result['imagePath']);
                                          }
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
                                                      child: _buildImageWidget(
                                                          _capturedImagePath!,
                                                          BoxFit.contain),
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
                                                  child: _buildImageWidget(
                                                      _capturedImagePath!,
                                                      BoxFit.cover),
                                                ),
                                              ),
                                              Positioned(
                                                top: -8,
                                                right: -8,
                                                child: GestureDetector(
                                                  onTap: () async {
                                                    setState(() =>
                                                        _capturedImagePath =
                                                            null);

                                                    // Auto-save: delete image on server (send empty string)
                                                    final kh = _danhSachKH[
                                                        _currentIndex];
                                                    final maKyDoc = kh[
                                                            'ma_ky_doc'] is int
                                                        ? kh['ma_ky_doc']
                                                        : int.tryParse(kh[
                                                                    'ma_ky_doc']
                                                                .toString()) ??
                                                            0;
                                                    // Pass empty string to clear
                                                    await api.capNhatHinhAnh(
                                                        kh['ma_danh_bo'],
                                                        maKyDoc,
                                                        "");
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
                                  // Auto-save on submit/editing complete
                                  onEditingComplete: () =>
                                      _luuChiSo(silent: true),
                                  onSubmitted: (val) => _luuChiSo(silent: true),
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
                        UIHelper.showCustomSnackBar(context,
                            message: "✅ Đã chia sẻ dữ liệu!", isSuccess: true);
                      } catch (e) {
                        await AppLogger()
                            .error('Lỗi export/share: $e', context: 'EXPORT');
                        if (!mounted) return;
                        UIHelper.showCustomSnackBar(context,
                            message: "❌ Lỗi: $e", isError: true);
                      }
                    }, color: Colors.teal),
                    _buildBottomIcon(
                        Icons.edit_note, "Ghi Chú", _showNoteEditDialog,
                        color: Colors.amber[800]),
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
                        UIHelper.showCustomSnackBar(context,
                            message: "✅ Đã tạo hóa đơn!", isSuccess: true);
                      } catch (e) {
                        await AppLogger()
                            .error('Lỗi tạo hóa đơn: $e', context: 'PRINT');
                        if (!mounted) return;
                        UIHelper.showCustomSnackBar(context,
                            message: "❌ Lỗi: $e", isError: true);
                      }
                    }, color: Colors.purple),
                    _buildBottomIcon(Icons.check_circle, "Đã đọc",
                        () => _luuChiSo(useOldIndex: true),
                        color: Colors.green),
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

  Future<void> _showNoteEditDialog() async {
    final kh = _danhSachKH[_currentIndex];
    final note = await UIHelper.showInputDialog(
      context: context,
      title: "Ghi Chú KH",
      initialValue: kh['ghi_chu'] ?? '',
      hintText: "Nhập ghi chú mới...",
      confirmText: "Lưu",
      cancelText: "Hủy",
    );
    if (note != null) {
      setState(() {
        kh['ghi_chu'] = note;
        _ghiChuController.text = note;
      });

      // Auto-save note to server
      final maKyDoc = kh['ma_ky_doc'] is int
          ? kh['ma_ky_doc']
          : int.tryParse(kh['ma_ky_doc'].toString()) ?? 0;
      await api.capNhatGhiChu(kh['ma_danh_bo'], maKyDoc, note);
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

  Widget _buildImageWidget(String pathOrBase64, BoxFit fit) {
    // 1. Check if it's a valid file path
    final file = File(pathOrBase64);
    if (file.existsSync()) {
      return Image.file(
        file,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return const Center(
              child: Icon(Icons.broken_image, color: Colors.grey));
        },
      );
    }

    // 2. Try Base64
    try {
      // Remove any potential header like "data:image/jpeg;base64," if present
      String cleanBase64 = pathOrBase64;
      if (cleanBase64.contains(',')) {
        cleanBase64 = cleanBase64.split(',').last;
      }

      final bytes = base64Decode(cleanBase64);
      return Image.memory(
        bytes,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return const Center(
              child: Icon(Icons.broken_image, color: Colors.grey));
        },
      );
    } catch (e) {
      return const Center(child: Icon(Icons.error, color: Colors.red));
    }
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
