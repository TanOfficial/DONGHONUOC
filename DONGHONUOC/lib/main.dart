import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image/image.dart' as img; // Đảm bảo đã chạy: flutter pub add image
import 'db_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(
    home: LoginScreen(), 
    debugShowCheckedModeBanner: false,
  ));
}

// ======================= MÀN HÌNH 1: ĐĂNG NHẬP / ĐĂNG KÝ =======================
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vui lòng nhập đủ thông tin!")));
      return;
    }

    if (_isLogin) {
      var user = await DatabaseHelper().dangNhap(u, p);
      if (user != null) {
        Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (context) => DashboardScreen(fullname: user['fullname'])
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Sai tài khoản hoặc mật khẩu!")));
      }
    } else {
      if (_nameController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vui lòng nhập Họ Tên!")));
        return;
      }
      bool kq = await DatabaseHelper().dangKy(u, p, _nameController.text);
      if (kq) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đăng ký thành công! Hãy đăng nhập.")));
        setState(() => _isLogin = true); 
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Tài khoản này đã tồn tại!")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Phần Header màu xanh
            Container(
              height: 320,
              decoration: const BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(50), bottomRight: Radius.circular(50)),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // LOGO CÔNG TY
                    Container(
                      width: 100,
                      height: 100,
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/logo.png', 
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.water_drop, size: 60, color: Colors.blue),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text("TÂN HÒA WATER", style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                    const Text("Tân Hòa xin chào bạn", style: TextStyle(color: Colors.white70, fontSize: 16)),
                  ],
                ),
              ),
            ),
            // Form Nhập liệu
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                children: [
                  Text(_isLogin ? "ĐĂNG NHẬP" : "ĐĂNG KÝ", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue)),
                  const SizedBox(height: 30),
                  TextField(controller: _userController, decoration: const InputDecoration(labelText: "Tài khoản", prefixIcon: Icon(Icons.person), border: OutlineInputBorder())),
                  const SizedBox(height: 15),
                  TextField(controller: _passController, obscureText: true, decoration: const InputDecoration(labelText: "Mật khẩu", prefixIcon: Icon(Icons.lock), border: OutlineInputBorder())),
                  if (!_isLogin) ...[
                    const SizedBox(height: 15),
                    TextField(controller: _nameController, decoration: const InputDecoration(labelText: "Họ và Tên của bạn", prefixIcon: Icon(Icons.badge), border: OutlineInputBorder())),
                  ],
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      onPressed: _xuLy,
                      child: Text(_isLogin ? "VÀO HỆ THỐNG" : "HOÀN TẤT ĐĂNG KÝ", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _isLogin = !_isLogin),
                    child: Text(_isLogin ? "Chưa có tài khoản? Đăng ký ngay" : "Đã có tài khoản? Đăng nhập"),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

// ======================= MÀN HÌNH 2: DASHBOARD (TRANG CHỦ) =======================
class DashboardScreen extends StatelessWidget {
  final String fullname;
  const DashboardScreen({super.key, required this.fullname});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Trang Chủ"), 
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 30),
          Text("Xin chào", style: TextStyle(fontSize: 20, color: Colors.green[700])),
          Text(fullname, style: TextStyle(fontSize: 28, color: Colors.green[800], fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          
          // AVATAR NGƯỜI DÙNG
          Center(
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black12)]),
              child: CircleAvatar(
                radius: 55, 
                backgroundColor: Colors.blue[50],
                child: ClipOval(
                  child: Image.asset(
                    'assets/user_avatar.png', 
                    width: 110, height: 110, fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, size: 60, color: Colors.blue),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text("Nhân viên ghi nước", style: TextStyle(color: Colors.grey, fontSize: 16)),
          
          const SizedBox(height: 50),
          
          // NÚT CHỨC NĂNG CHÍNH
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildMenuButton(context, "Đọc Số", 'assets/icon_nuoc.png', Colors.blue, () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const DanhSachKHScreen()));
              }),
              const SizedBox(width: 25),
              _buildMenuButton(context, "Quản Lý", 'assets/icon_quanly.png', Colors.orange, () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Tính năng đang phát triển")));
              }),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, String title, String assetPath, Color fallbackColor, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 150, height: 160,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              assetPath, width: 70, height: 70,
              errorBuilder: (context, error, stackTrace) => Icon(Icons.apps, size: 50, color: fallbackColor),
            ),
            const SizedBox(height: 15),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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

  @override
  void initState() {
    super.initState();
    _taiDuLieu();
  }

  Future<void> _taiDuLieu() async {
    final data = await DatabaseHelper().layDanhSachKH();
    setState(() => _danhSachKH = data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Danh Sách Khách Hàng"), backgroundColor: Colors.blue),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await DatabaseHelper().taoDuLieuMau();
          _taiDuLieu();
        },
        label: const Text("Tải dữ liệu"), icon: const Icon(Icons.sync),
      ),
      body: _danhSachKH.isEmpty 
        ? const Center(child: Text("Bấm nút Nạp dữ liệu để bắt đầu"))
        : ListView.builder(
            itemCount: _danhSachKH.length,
            itemBuilder: (context, index) {
              final kh = _danhSachKH[index];
              final daDoc = kh['trang_thai'] == 1;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: Icon(daDoc ? Icons.check_circle : Icons.radio_button_unchecked, color: daDoc ? Colors.green : Colors.grey),
                  title: Text(kh['ten_kh'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("CSC: ${kh['chi_so_cu']} - CS Mới: ${kh['chi_so_moi']}"),
                  trailing: daDoc ? const Text("Xong", style: TextStyle(color: Colors.green)) : ElevatedButton(
                    onPressed: () async {
                      await Navigator.push(context, MaterialPageRoute(builder: (context) => CameraScreen(khachHang: kh)));
                      _taiDuLieu();
                    },
                    child: const Text("Đọc số"),
                  ),
                ),
              );
            },
          ),
    );
  }
}

// ======================= MÀN HÌNH 4: CAMERA & OCR (BẢN FULL MÀN HÌNH) =======================
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
      _controller = CameraController(cameras.first, ResolutionPreset.high, enableAudio: false);
      await _controller!.initialize();
      if (mounted) setState(() {});
    }
  }

  // HÀM CẮT ẢNH: Chỉ lấy vùng trung tâm khung hình để AI không đọc nhầm số bên ngoài
  Future<File?> _cropImage(String path) async {
    final bytes = await File(path).readAsBytes();
    img.Image? src = img.decodeImage(bytes);
    if (src == null) return null;

    // Tính toán vùng cắt (Khung hình chữ nhật giữa ảnh)
    int cropW = (src.width * 0.7).toInt(); 
    int cropH = (src.height * 0.15).toInt();
    int x = (src.width - cropW) ~/ 2;
    int y = (src.height - cropH) ~/ 2;

    img.Image cropped = img.copyCrop(src, x: x, y: y, width: cropW, height: cropH);
    final croppedFile = File(path.replaceAll('.jpg', '_crop.jpg'));
    await croppedFile.writeAsBytes(img.encodeJpg(cropped));
    return croppedFile;
  }

  String _cleanText(String raw) {
  // 1. Chuyển các chữ cái hay nhầm thành số
  String cleaned = raw.toUpperCase()
      .replaceAll('O', '0')
      .replaceAll('I', '1')
      .replaceAll('S', '5')
      .replaceAll('G', '6');
  
  // 2. Chỉ lấy các dãy số có độ dài từ 3-6 ký tự (phù hợp với đồng hồ nước)
  RegExp exp = RegExp(r'\d{3,6}');
  Iterable<RegExpMatch> matches = exp.allMatches(cleaned);
  
  if (matches.isNotEmpty) {
    return matches.first.group(0)!; // Lấy dãy số đầu tiên nó tìm thấy
  }
  return ""; 
}

  Future<void> _chupVaXuLy() async {
    if (_isBusy || _controller == null) return;
    setState(() => _isBusy = true);
    try {
      final photo = await _controller!.takePicture();
      
      // BƯỚC CẮT ẢNH: Quan trọng nhất để tránh đọc nhầm "ISO 4064"
      File? croppedFile = await _cropImage(photo.path);
      
      final inputImage = InputImage.fromFilePath(croppedFile?.path ?? photo.path);
      final recognizedText = await _textRecognizer.processImage(inputImage);
      
      String result = _cleanText(recognizedText.text);
      _hienXacNhan(int.tryParse(result) ?? 0, photo.path);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
    } finally {
      setState(() => _isBusy = false);
    }
  }

  void _hienXacNhan(int soMoi, String path) {
    final txt = TextEditingController(text: soMoi == 0 ? "" : soMoi.toString());
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      builder: (c) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(c).viewInsets.bottom, top: 20, left: 20, right: 20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text("XÁC NHẬN CHỈ SỐ", style: TextStyle(fontWeight: FontWeight.bold)),
          TextField(controller: txt, keyboardType: TextInputType.number, textAlign: TextAlign.center, style: const TextStyle(fontSize: 35, color: Colors.red)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              await DatabaseHelper().capNhatChiSo(widget.khachHang['ma_danh_bo'], int.parse(txt.text), path);
              Navigator.pop(context); Navigator.pop(context);
            }, 
            child: const Text("LƯU KẾT QUẢ")
          ),
          const SizedBox(height: 20),
        ]),
      ),
    );
  }

  @override
  void dispose() { _controller?.dispose(); _textRecognizer.close(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    
    // Xử lý tràn màn hình
    final size = MediaQuery.of(context).size;
    var scale = size.aspectRatio * _controller!.value.aspectRatio;
    if (scale < 1) scale = 1 / scale;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(children: [
        Transform.scale(scale: scale, child: Center(child: CameraPreview(_controller!))),
        
        // Lớp phủ tối mờ xung quanh khung ngắm
        ColorFiltered(
          colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.6), BlendMode.srcOut),
          child: Stack(children: [
            Container(decoration: const BoxDecoration(color: Colors.transparent, backgroundBlendMode: BlendMode.clear)),
            Align(alignment: Alignment.center, child: Container(width: 300, height: 120, decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(10)))),
          ]),
        ),
        
        // Khung ngắm
        Align(alignment: Alignment.center, child: Container(width: 300, height: 120, decoration: BoxDecoration(border: Border.all(color: Colors.greenAccent, width: 3), borderRadius: BorderRadius.circular(10)))),
        
        // Nút chụp
        Positioned(bottom: 50, left: 0, right: 0, child: Center(
          child: GestureDetector(
            onTap: _chupVaXuLy,
            child: Container(
              height: 80, width: 80,
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 4)),
              child: Center(child: _isBusy ? const CircularProgressIndicator() : const Icon(Icons.camera_alt, color: Colors.white, size: 40)),
            ),
          ),
        )),
        Positioned(top: 40, left: 10, child: IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context))),
      ]),
    );
  }
}