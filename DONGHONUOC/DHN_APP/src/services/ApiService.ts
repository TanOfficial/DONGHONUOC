console.log('🚀 API SERVICE LOADED');
import axios from 'axios';
import AsyncStorage from '@react-native-async-storage/async-storage';

// In a real app, this would be in a .env file
// 10.0.2.2 = address emulator uses to reach host machine's localhost
// Using detected local IP for physical device (iPhone/Android) connectivity
const DEFAULT_IP = '192.168.1.144';
const PORT = '5000';
const TIMEOUT_MS = 10000; // 10 seconds

class ApiService {
    private static instance: ApiService;
    private baseUrl: string = `http://${DEFAULT_IP}:${PORT}/api`;
    private currentUsername: string | null = null;

    private constructor() {
        this.loadBaseUrl();
    }

    public static getInstance(): ApiService {
        if (!ApiService.instance) {
            ApiService.instance = new ApiService();
        }
        return ApiService.instance;
    }

    private async loadBaseUrl() {
        const savedUrlOrIp = await AsyncStorage.getItem('server_ip');
        if (savedUrlOrIp) {
            if (savedUrlOrIp.startsWith('http')) {
                this.baseUrl = savedUrlOrIp.endsWith('/') ? `${savedUrlOrIp}api` : `${savedUrlOrIp}/api`;
            } else {
                this.baseUrl = `http://${savedUrlOrIp}:${PORT}/api`;
            }
        }
        console.log('🌐 API BaseURL:', this.baseUrl);
    }

    public async setBaseUrl(value: string) {
        if (value) {
            if (value.startsWith('http')) {
                this.baseUrl = value.endsWith('/') ? `${value}api` : `${value}/api`;
            } else {
                this.baseUrl = `http://${value}:${PORT}/api`;
            }
            await AsyncStorage.setItem('server_ip', value);
        }
    }

    public setUsername(username: string | null) {
        this.currentUsername = username;
    }

    // ====== AUTH ======

    public async dangNhap(username: string, pass: string) {
        try {
            const response = await axios.post(`${this.baseUrl}/auth/login`, {
                Username: username,
                Password: pass
            }, { timeout: TIMEOUT_MS });

            if (response.status === 200 && response.data.Success) {
                this.currentUsername = username;
                return {
                    username: response.data.Username || response.data.username,
                    fullname: response.data.HoTen || response.data.hoTen,
                    vaiTro: response.data.VaiTro || response.data.vaiTro,
                    avatar: response.data.Avatar || response.data.avatar,
                };
            }
            return null;
        } catch (e: any) {
            if (e.code === 'ECONNABORTED') {
                console.error('❌ Login timeout - API không phản hồi!');
            } else {
                console.error('❌ Lỗi đăng nhập:', e.message);
            }
            return null;
        }
    }

    public async dangKy(username: string, pass: string, fullname: string) {
        try {
            const response = await axios.post(`${this.baseUrl}/auth/register`, {
                Username: username,
                Password: pass,
                HoTen: fullname
            }, { timeout: TIMEOUT_MS });
            return response.status === 200 && response.data.Success;
        } catch (e) {
            console.error('❌ Lỗi đăng ký:', e);
            return false;
        }
    }

    public async updateAvatar(username: string, base64Image: string) {
        try {
            const response = await axios.post(`${this.baseUrl}/auth/avatar`, {
                Username: username,
                AvatarBase64: base64Image
            });
            return response.status === 200;
        } catch (e) {
            console.error('❌ Lỗi cập nhật avatar:', e);
            return false;
        }
    }

    // ====== KHÁCH HÀNG ======

    public async demTongKhach() {
        try {
            const response = await axios.get(`${this.baseUrl}/khachhang/count`);
            return typeof response.data === 'number' ? response.data : parseInt(response.data) || 0;
        } catch (e) {
            console.error('❌ Lỗi đếm khách:', e);
            return 0;
        }
    }

    // ====== ĐỌC CHỈ SỐ ======

    public async layFiltersTheoKy(maKyDoc: number) {
        if (!maKyDoc || maKyDoc <= 0) return { dots: [], mays: [] };
        try {
            const url = `${this.baseUrl}/docchiso/filters/${maKyDoc}`;
            const response = await axios.get(url);
            if (response.status === 200) {
                return response.data;
            }
            return { dots: [], mays: [] };
        } catch (e) {
            console.warn('⚠️ Lỗi tải filters:', e);
            return { dots: [], mays: [] };
        }
    }

    public async layDanhSachDocSo(maKyDoc: number, pageNumber = 1, pageSize = 50, search = '', trangThai?: number, dot = '', may = '') {
        if (!maKyDoc || maKyDoc <= 0) {
            console.warn('⚠️ layDanhSachDocSo: maKyDoc is invalid:', maKyDoc);
            return [];
        }
        try {
            let url = `${this.baseUrl}/docchiso/ky/${maKyDoc}?pageNumber=${pageNumber}&pageSize=${pageSize}`;
            if (search) url += `&search=${encodeURIComponent(search)}`;
            if (trangThai !== undefined) url += `&trangThai=${trangThai}`;
            if (dot) url += `&maLoTrinh=${encodeURIComponent(dot)}`;
            if (may) url += `&may=${encodeURIComponent(may)}`;

            console.log('🌐 Calling API:', url);
            const response = await axios.get(url);
            if (response.status === 200) {
                return response.data.map((item: any) => this.convertDocSoItem(item));
            }
            return [];
        } catch (e: any) {
            if (e.response) {
                console.error('❌ Lỗi API (400?):', e.response.status, e.response.data);
            } else {
                console.error('❌ Lỗi lấy danh sách đọc số:', e.message || e);
            }
            return [];
        }
    }

    public async layToanBoDanhSachDocSo(maKyDoc: number, maLoTrinh?: string, may?: string) {
        if (!maKyDoc || maKyDoc <= 0) {
            console.warn('⚠️ layToanBoDanhSachDocSo: maKyDoc is invalid:', maKyDoc);
            return [];
        }
        try {
            let url = `${this.baseUrl}/docchiso/ky/${maKyDoc}?pageSize=0`;
            if (maLoTrinh) url += `&maLoTrinh=${encodeURIComponent(maLoTrinh)}`;
            if (may) url += `&may=${encodeURIComponent(may)}`;

            console.log('🌐 Calling Full Download API:', url);
            const response = await axios.get(url);
            if (response.status === 200) {
                return response.data.map((item: any) => this.convertDocSoItem(item));
            }
            return [];
        } catch (e) {
            console.error('❌ Lỗi tải toàn bộ danh sách:', e);
            return [];
        }
    }

    public async timKiemToAnBo(q: string, pageNumber = 1, pageSize = 50) {
        try {
            const url = `${this.baseUrl}/docchiso/search?q=${encodeURIComponent(q)}&pageNumber=${pageNumber}&pageSize=${pageSize}`;
            const response = await axios.get(url);
            if (response.status === 200) {
                return response.data.map((item: any) => this.convertDocSoItem(item));
            }
            return [];
        } catch (e) {
            console.error('❌ Lỗi tìm kiếm:', e);
            return [];
        }
    }

    public async ghiChiSo(maDanhBo: string, maKyDoc: number, chiSoMoi: number, code = '40', ghiChu = '', hinhAnhBase64?: string) {
        const payload = {
            MaDanhBo: maDanhBo,
            MaKyDoc: maKyDoc,
            ChiSoMoi: chiSoMoi,
            MaCode: code,
            GhiChu: ghiChu,
            NguoiDoc: this.currentUsername,
            HinhAnh: hinhAnhBase64
        };
        const url = `${this.baseUrl}/docchiso/ghi`;
        console.log(`🌐 [POST] ${url}`, payload);

        try {
            const response = await axios.post(url, payload);
            console.log(`✅ [POST] ${url} Success:`, response.status);
            return response.status === 200;
        } catch (e: any) {
            if (e.response) {
                console.error(`❌ Lỗi ghi chỉ số (${e.response.status}):`, e.response.data);
            } else {
                console.error('❌ Lỗi ghi chỉ số:', e.message || e);
            }
            return false;
        }
    }

    public async huyDocSo(maDanhBo: string, maKyDoc: number) {
        try {
            const response = await axios.put(`${this.baseUrl}/docchiso/reset`, {
                MaDanhBo: maDanhBo,
                MaKyDoc: maKyDoc
            });
            return response.status === 200;
        } catch (e) {
            console.error('❌ Lỗi hủy đọc số:', e);
            return false;
        }
    }

    public async capNhatCode(maDanhBo: string, maKyDoc: number, code: string) {
        try {
            await axios.put(`${this.baseUrl}/docchiso/code`, {
                MaDanhBo: maDanhBo,
                MaKyDoc: maKyDoc,
                MaCode: code
            });
        } catch (e) {
            console.error('❌ Lỗi cập nhật code:', e);
        }
    }

    public async capNhatGhiChu(maDanhBo: string, maKyDoc: number, ghiChu: string) {
        try {
            await axios.put(`${this.baseUrl}/docchiso/note`, {
                MaDanhBo: maDanhBo,
                MaKyDoc: maKyDoc,
                GhiChu: ghiChu
            });
        } catch (e) {
            console.error('❌ Lỗi cập nhật ghi chú:', e);
        }
    }

    public async capNhatHinhAnh(maDanhBo: string, maKyDoc: number, hinhAnhBase64: string) {
        try {
            await axios.put(`${this.baseUrl}/docchiso/image`, {
                MaDanhBo: maDanhBo,
                MaKyDoc: maKyDoc,
                HinhAnh: hinhAnhBase64
            });
        } catch (e) {
            console.error('❌ Lỗi cập nhật hình ảnh:', e);
        }
    }

    public async layLichSuDoc(maDanhBo: string, limit = 3) {
        try {
            const response = await axios.get(`${this.baseUrl}/docchiso/lichsu/${maDanhBo}?limit=${limit}`);
            if (response.status === 200) {
                return response.data.map((item: any) => ({
                    ky: item.Ky || item.ky,
                    nam: item.Nam || item.nam,
                    chi_so: item.ChiSo || item.chiSo || 0,
                    tieu_thu: item.TieuThu || item.tieuThu || 0,
                    chi_so_cu: item.ChiSoCu ?? item.chiSoCu ?? '--',
                    code: item.MaCode || item.maCode || '40',
                    ngay_doc: item.NgayDoc || item.ngayDoc,
                    ngay_bd: item.TuNgay || item.tuNgay ? new Date(item.TuNgay || item.tuNgay).toLocaleDateString('en-GB') : '--',
                    ngay_kt: item.DenNgay || item.denNgay ? new Date(item.DenNgay || item.denNgay).toLocaleDateString('en-GB') : '--'
                }));
            }
            return [];
        } catch (e) {
            console.error('❌ Lỗi lấy lịch sử:', e);
            return [];
        }
    }

    public async layLichSuDocBulk(maDanhBos: string[], limit = 3) {
        try {
            if (!maDanhBos || maDanhBos.length === 0) return {};
            const response = await axios.post(`${this.baseUrl}/docchiso/lichsu/bulk?limit=${limit}`, maDanhBos);
            if (response.status === 200) {
                const result: { [key: string]: any[] } = {};
                Object.keys(response.data).forEach(mdb => {
                    result[mdb] = response.data[mdb].map((item: any) => ({
                        ky: item.Ky || item.ky,
                        nam: item.Nam || item.nam,
                        chi_so: item.ChiSo || item.chiSo || 0,
                        tieu_thu: item.TieuThu || item.tieuThu || 0,
                        chi_so_cu: item.ChiSoCu ?? item.chiSoCu ?? '--',
                        code: item.MaCode || item.maCode || '40',
                        ngay_doc: item.NgayDoc || item.ngayDoc,
                        ngay_bd: item.TuNgay || item.tuNgay ? new Date(item.TuNgay || item.tuNgay).toLocaleDateString('en-GB') : '--',
                        ngay_kt: item.DenNgay || item.denNgay ? new Date(item.DenNgay || item.denNgay).toLocaleDateString('en-GB') : '--'
                    }));
                });
                return result;
            }
            return {};
        } catch (e) {
            console.error('❌ Lỗi lấy lịch sử bulk:', e);
            return {};
        }
    }

    public async layDanhSachKyDoc() {
        try {
            const response = await axios.get(`${this.baseUrl}/docchiso/kydoc`);
            return response.data;
        } catch (e) {
            console.error('❌ Lỗi lấy kỳ đọc:', e);
            return [];
        }
    }

    public async layDanhSachDot(maKyDoc: number) {
        if (!maKyDoc || maKyDoc <= 0) return [];
        try {
            const response = await axios.get(`${this.baseUrl}/docchiso/thongke-dot/${maKyDoc}`);
            if (response.status === 200 && Array.isArray(response.data)) {
                // Thống kê-đợt trả về List<ThongKeDotResponse> { maDot: string, ... }
                return response.data.map((d: any) => d.MaDot || d.maDot).filter(d => !!d);
            }
            return [];
        } catch (e) {
            console.error('❌ Lỗi lấy danh sách đợt:', e);
            return [];
        }
    }

    public async thongKe(maKyDoc: number) {
        try {
            const response = await axios.get(`${this.baseUrl}/docchiso/thongke/${maKyDoc}`);
            return response.data;
        } catch (e) {
            console.error('❌ Lỗi thống kê:', e);
            return null;
        }
    }

    public async docSoTuDongHo(imageUri: string) {
        // Build FormData
        let formData = new FormData();
        formData.append('file', {
            uri: imageUri,
            name: 'photo.jpg',
            type: 'image/jpeg',
        } as any);

        // We use the same IP as DEFAULT_IP, but port 8000 for the Python AI server.
        // Or you can extract the IP from this.baseUrl if it's dynamic.
        const ipMatch = this.baseUrl.match(/\/\/([0-9\.]+):/);
        const serverIp = ipMatch ? ipMatch[1] : DEFAULT_IP;
        
        try {
            const response = await fetch(`http://${serverIp}:8001/api/doc-so-moi`, {
                method: 'POST',
                body: formData,
            });
            const responseJson = await response.json();
            
            if (responseJson.success) {
                return { success: true, result: responseJson.result };
            } else {
                return { success: false, message: responseJson.message };
            }
        } catch (error) {
            console.error('AI Server Error:', error);
            return { success: false, message: 'Không thể kết nối với Server AI (Kiểm tra lại IP hoặc WiFi)' };
        }
    }

    private convertDocSoItem(item: any) {
        return {
            ma_danh_bo: item.MaDanhBo || item.maDanhBo,
            ten_kh: item.HoTen || item.hoTen,
            dia_chi: item.DiaChi || item.diaChi,
            dia_chi_dhn: item.DiaChiDHN || item.diaChiDHN,
            ma_lo_trinh: item.MaLoTrinh || item.maLoTrinh,
            dot: item.Dot || item.dot,
            may: item.May || item.may,
            nam: item.Nam || item.nam,
            ky: item.Ky || item.ky,
            hieu: item.Hieu || item.hieu,
            co: item.Co || item.co,
            so_than: item.SoThan || item.soThan,
            vi_tri: item.ViTri || item.viTri,
            sdt: item.SoDienThoai || item.soDienThoai,
            gb: item.GB || item.gb,
            dm: item.DM || item.dm,
            dmhn: item.DMHN || item.dmhn,
            doc_chi_so_id: item.DocChiSoId ?? item.docChiSoId,
            ma_ky_doc: item.MaKyDoc ?? item.maKyDoc,
            chi_so_cu: item.ChiSoCu ?? item.chiSoCu ?? 0,
            chi_so_moi: item.ChiSoMoi ?? item.chiSoMoi,
            tieu_thu_cu: item.TieuThuCu ?? item.tieuThuCu ?? 0,
            tieu_thu: item.TieuThu ?? item.tieuThu ?? 0,
            code_cu: item.CodeCu || item.codeCu || '40',
            code: item.MaCode || item.maCode || '40',
            tbtt: item.TBTT ?? item.tbtt ?? 0,
            trang_thai: item.TrangThai ?? item.trangThai ?? 0,
            ghi_chu: item.GhiChu || item.ghiChu,
            ghi_chu_kh: item.GhiChuKH || item.ghiChuKH,
            hinh_anh: item.HinhAnh || item.hinhAnh,
            tien_nuoc: item.TienNuoc ?? item.tienNuoc ?? 0,
            thue_gtgt: item.ThueGTGT ?? item.thueGTGT ?? 0,
            phivmt: item.Phivmt ?? item.phivmt ?? 0,
            thue_tdvtn: item.ThueTDVTN ?? item.thueTDVTN ?? 0,
            tong_cong: item.TongCong ?? item.tongCong ?? 0,
            ngay_bd: item.TuNgay || item.tuNgay ? new Date(item.TuNgay || item.tuNgay).toLocaleDateString('en-GB') : '--',
            ngay_kt: item.DenNgay || item.denNgay ? new Date(item.DenNgay || item.denNgay).toLocaleDateString('en-GB') : '--'
        };
    }
}

export default ApiService.getInstance();
