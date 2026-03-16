import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { useAuth } from '../context/AuthContext';

const API_BASE_URL = 'http://localhost:5000/api';

export default function Dashboard() {
    const [activeTab, setActiveTab] = React.useState('taoDuLieu');
    const { user, logout } = useAuth();

    return (
        <div className="h-screen w-full flex flex-col bg-gray-100 overflow-hidden text-sm">
            {/* Header/Tab Bar */}
            <div className="bg-white border-b border-gray-300 flex items-center justify-between px-2 pt-2 gap-1 shrink-0">
                <div className="flex gap-1">
                    <button
                        onClick={() => setActiveTab('taoDuLieu')}
                        className={`px-6 py-2 border border-b-0 rounded-t-md font-medium transition-colors ${activeTab === 'taoDuLieu'
                            ? 'bg-[#e3f2fd] border-[#2196F3] text-[#1976D2] relative top-[1px] z-10'
                            : 'bg-gray-50 border-gray-300 text-gray-600 hover:bg-gray-100'
                            }`}
                    >
                        Tạo Dữ Liệu Đọc Số
                    </button>
                    <button
                        onClick={() => setActiveTab('lichDocSo')}
                        className={`px-6 py-2 border border-b-0 rounded-t-md font-medium transition-colors ${activeTab === 'lichDocSo'
                            ? 'bg-[#e3f2fd] border-[#2196F3] text-[#1976D2] relative top-[1px] z-10'
                            : 'bg-gray-50 border-gray-300 text-gray-600 hover:bg-gray-100'
                            }`}
                    >
                        Lịch Đọc Số
                    </button>
                    {user?.VaiTro === 'QuanLy' && (
                        <button
                            onClick={() => setActiveTab('taiKhoan')}
                            className={`px-6 py-2 border border-b-0 rounded-t-md font-medium transition-colors ${activeTab === 'taiKhoan'
                                ? 'bg-[#e3f2fd] border-[#2196F3] text-[#1976D2] relative top-[1px] z-10'
                                : 'bg-gray-50 border-gray-300 text-gray-600 hover:bg-gray-100'
                                }`}
                        >
                            Tài Khoản
                        </button>
                    )}
                </div>

                {/* User Profile & Logout */}
                <div className="flex items-center gap-4 pb-2 px-2">
                    <div className="text-right">
                        <p className="font-bold text-gray-800 leading-tight">{user?.HoTen || 'Quản lý'}</p>
                        <p className="text-xs text-gray-500">{user?.VaiTro}</p>
                    </div>
                    <button
                        onClick={logout}
                        className="text-white bg-red-500 hover:bg-red-600 px-3 py-1.5 rounded transition-colors"
                    >
                        Đăng xuất
                    </button>
                </div>
            </div>

            {/* Main Content Area */}
            <div className="flex-1 bg-white border border-gray-300 m-2 p-4 overflow-auto shadow-sm" style={{ borderColor: activeTab ? '#60a5fa' : '#d1d5db' }}>
                {activeTab === 'taoDuLieu' && <TaoDuLieuTab />}
                {activeTab === 'lichDocSo' && <LichDocSoTab />}
                {activeTab === 'taiKhoan' && user?.VaiTro === 'QuanLy' && <TaiKhoanTab />}
            </div>
        </div>
    );
}

// ==========================================
// TAB 3: TÀI KHOẢN (USER MANAGEMENT)
// ==========================================
function TaiKhoanTab() {
    const [users, setUsers] = useState([]);
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState('');
    const [success, setSuccess] = useState('');
    const [isEdit, setIsEdit] = useState(false);

    const [form, setForm] = useState({
        username: '',
        password: '',
        hoTen: '',
        vaiTro: 'NhanVien'
    });

    const fetchUsers = async () => {
        try {
            const response = await axios.get(`${API_BASE_URL}/Auth/users`);
            setUsers(response.data);
        } catch (err) {
            console.error("Failed to fetch users", err);
        }
    };

    useEffect(() => {
        fetchUsers();
    }, []);

    const handleChange = (e) => {
        setForm({ ...form, [e.target.name]: e.target.value });
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        setError('');
        setSuccess('');
        setLoading(true);

        try {
            if (isEdit) {
                // Sửa User (PUT)
                const payload = {
                    hoTen: form.hoTen,
                    vaiTro: form.vaiTro
                };
                if (form.password) payload.password = form.password; // Chỉ gửi pass nếu có nhập

                await axios.put(`${API_BASE_URL}/Auth/users/${form.username}`, payload);
                setSuccess('Cập nhật tài khoản thành công!');
            } else {
                // Tạo Mới (POST)
                if (!form.username || !form.password || !form.hoTen) {
                    setError('Vui lòng điền đủ thông tin bắt buộc.');
                    setLoading(false);
                    return;
                }
                const response = await axios.post(`${API_BASE_URL}/Auth/register`, {
                    username: form.username,
                    password: form.password,
                    hoTen: form.hoTen,
                    vaiTro: form.vaiTro
                });

                if (!response.data.Success) {
                    setError(response.data.Message);
                    setLoading(false);
                    return;
                }
                setSuccess('Tạo tài khoản mới thành công!');
            }
            fetchUsers();
            handleCancel(); // Reset form
        } catch (err) {
            console.error(err);
            setError('Lỗi kết nối khi lưu tài khoản.');
        } finally {
            setLoading(false);
        }
    };

    const handleEdit = (user) => {
        setIsEdit(true);
        setForm({
            username: user.username,
            password: '', // Không tải mật khẩu cũ hiển thị
            hoTen: user.hoTen,
            vaiTro: user.vaiTro || 'NhanVien'
        });
        setError('');
        setSuccess('');
    };

    const handleCancel = () => {
        setIsEdit(false);
        setForm({
            username: '',
            password: '',
            hoTen: '',
            vaiTro: 'NhanVien'
        });
    };

    return (
        <div className="flex flex-col h-full gap-4">
            <h2 className="text-lg font-bold text-[#2196F3] mb-2 border-b pb-2">Quản Lý Người Dùng</h2>

            <div className="flex gap-4 h-full">
                {/* Left: Form Tạo/Sửa */}
                <fieldset className="border border-gray-300 rounded-md p-4 w-80 shrink-0 h-fit bg-[#f1f8e9] border-[#c5e1a5]">
                    <legend className="px-2 text-[#7cb342] font-semibold bg-[#f1f8e9]">
                        {isEdit ? 'Sửa Tài Khoản' : 'Tạo Mới Tài Khoản'}
                    </legend>

                    {error && <div className="mb-3 text-red-600 text-xs font-medium">{error}</div>}
                    {success && <div className="mb-3 text-green-600 text-xs font-medium">{success}</div>}

                    <form className="flex flex-col gap-4" onSubmit={handleSubmit}>
                        <div>
                            <label className="block text-gray-700 mb-1">Tài khoản (Tên đăng nhập)</label>
                            <input
                                type="text"
                                name="username"
                                value={form.username}
                                onChange={handleChange}
                                readOnly={isEdit}
                                className={`w-full border border-gray-300 rounded px-3 py-1.5 focus:outline-none focus:border-[#8BC34A] ${isEdit ? 'bg-gray-100 text-gray-500' : 'bg-white'}`}
                                placeholder={isEdit ? '' : 'Dùng Số điện thoại'}
                            />
                        </div>
                        <div>
                            <label className="block text-gray-700 mb-1">Mật khẩu {isEdit && '(Bỏ trống nếu không đổi)'}</label>
                            <input
                                type="password"
                                name="password"
                                value={form.password}
                                onChange={handleChange}
                                className="w-full border border-gray-300 rounded px-3 py-1.5 focus:outline-none focus:border-[#8BC34A] bg-white"
                            />
                        </div>
                        <div>
                            <label className="block text-gray-700 mb-1">Họ và Tên</label>
                            <input
                                type="text"
                                name="hoTen"
                                value={form.hoTen}
                                onChange={handleChange}
                                className="w-full border border-gray-300 rounded px-3 py-1.5 focus:outline-none focus:border-[#8BC34A] bg-white"
                            />
                        </div>
                        <div>
                            <label className="block text-gray-700 mb-1">Vai Trò</label>
                            <select
                                name="vaiTro"
                                value={form.vaiTro}
                                onChange={handleChange}
                                className="w-full border border-gray-300 rounded px-3 py-1.5 focus:outline-none focus:border-[#8BC34A] bg-white"
                            >
                                <option value="NhanVien">Nhân Viên</option>
                                <option value="QuanLy">Quản Lý</option>
                            </select>
                        </div>
                        <div className="flex gap-2 mt-2">
                            {isEdit && (
                                <button type="button" onClick={handleCancel} className="bg-gray-400 hover:bg-gray-500 text-white px-3 py-2 rounded font-medium transition-colors">
                                    Hủy
                                </button>
                            )}
                            <button type="submit" disabled={loading} className={`flex-1 text-white py-2 rounded font-medium transition-colors ${loading ? 'bg-gray-400' : 'bg-[#8BC34A] hover:bg-[#7cb342]'}`}>
                                {isEdit ? 'Cập Nhật' : 'Lưu Tài Khoản'}
                            </button>
                        </div>
                    </form>
                </fieldset>

                {/* Right: Grid Danh sách */}
                <fieldset className="border border-gray-300 rounded-md p-0 flex-1 flex flex-col relative overflow-hidden">
                    <legend className="px-2 text-gray-600 font-medium ml-4 bg-white relative z-10 block w-fit">Danh Sách Tài Khoản ({users.length})</legend>
                    <div className="overflow-auto flex-1 mt-1 -mt-3 pt-3">
                        <table className="w-full text-left border-collapse whitespace-nowrap">
                            <thead className="bg-gray-100 sticky top-0 shadow-sm z-10 border-b border-t border-gray-300">
                                <tr>
                                    <th className="border-r border-gray-300 px-3 py-2 font-medium text-gray-700">Tài Khoản</th>
                                    <th className="border-r border-gray-300 px-3 py-2 font-medium text-gray-700">Họ Tên</th>
                                    <th className="border-r border-gray-300 px-3 py-2 font-medium text-gray-700 w-32 text-center">Vai Trò</th>
                                    <th className="px-3 py-2 font-medium text-gray-700 w-24 text-center">Thao Tác</th>
                                </tr>
                            </thead>
                            <tbody>
                                {users.map((u, idx) => (
                                    <tr key={idx} className="border-b border-gray-200 hover:bg-[#e3f2fd]">
                                        <td className="border-r border-gray-200 px-3 py-2">{u.username}</td>
                                        <td className="border-r border-gray-200 px-3 py-2">{u.hoTen}</td>
                                        <td className={`border-r border-gray-200 px-3 py-2 text-center font-medium ${u.vaiTro === 'QuanLy' ? 'text-[#2196F3]' : 'text-gray-600'}`}>
                                            {u.vaiTro === 'QuanLy' ? 'Quản Lý' : u.vaiTro === 'NhanVien' ? 'Nhân Viên' : u.vaiTro}
                                        </td>
                                        <td className="px-3 py-2 text-center">
                                            <button
                                                onClick={() => handleEdit(u)}
                                                className="text-[#2196F3] hover:underline text-sm font-medium"
                                            >
                                                Chỉnh Sửa
                                            </button>
                                        </td>
                                    </tr>
                                ))}
                                {users.length === 0 && !loading && (
                                    <tr>
                                        <td colSpan="4" className="text-center py-4 text-gray-500">Đang tải dữ liệu...</td>
                                    </tr>
                                )}
                            </tbody>
                        </table>
                    </div>
                </fieldset>
            </div>
        </div>
    );
}

// ==========================================
// TAB 1: TẠO DỮ LIỆU ĐỌC SỐ
// ==========================================
function TaoDuLieuTab() {
    const [kyDocs, setKyDocs] = useState([]);
    const [selectedKyDocId, setSelectedKyDocId] = useState('');
    const [data, setData] = useState([]);
    const [thongKe, setThongKe] = useState(null);
    const [loading, setLoading] = useState(false);
    const [selectedFile, setSelectedFile] = useState(null);
    const [uploading, setUploading] = useState(false);
    const [uploadMsg, setUploadMsg] = useState('');
    const fileInputRef = React.useRef(null);

    useEffect(() => {
        const fetchKys = async () => {
            try {
                const res = await axios.get(`${API_BASE_URL}/DocChiSo/kydoc`);
                setKyDocs(res.data);
                if (res.data.length > 0) {
                    setSelectedKyDocId(res.data[0].MaKyDoc || res.data[0].maKyDoc);
                }
            } catch (err) {
                console.error("Lỗi tải kỳ:", err);
            }
        };
        fetchKys();
    }, []);

    const handleXem = async () => {
        if (!selectedKyDocId) return;
        setLoading(true);
        setData([]);
        setThongKe(null);
        try {
            const [dataRes, thongKeRes] = await Promise.all([
                axios.get(`${API_BASE_URL}/DocChiSo/thongke-dot/${selectedKyDocId}`),
                axios.get(`${API_BASE_URL}/DocChiSo/thongke/${selectedKyDocId}`)
            ]);
            setData(dataRes.data);
            setThongKe(thongKeRes.data);
        } catch (err) {
            console.error("Lỗi tải dữ liệu đọc số:", err);
            alert("Lỗi tải dữ liệu!");
        } finally {
            setLoading(false);
        }
    };

    const handleChonFile = () => {
        fileInputRef.current?.click();
    };

    const handleFileChange = (e) => {
        const f = e.target.files[0];
        if (f) {
            setSelectedFile(f);
            setUploadMsg(`Đã chọn: ${f.name}`);
        }
    };

    const handleThemFile = async () => {
        if (!selectedFile) return alert('Vui lòng chọn file trước!');
        if (!selectedKyDocId) return alert('Vui lòng chọn kỳ đọc!');

        setUploading(true);
        setUploadMsg('');
        try {
            const formData = new FormData();
            formData.append('file', selectedFile);
            formData.append('maKyDoc', selectedKyDocId);
            const res = await axios.post(`${API_BASE_URL}/DocChiSo/upload-bien-dong`, formData, {
                headers: { 'Content-Type': 'multipart/form-data' }
            });
            setUploadMsg(`✅ ${res.data.message}`);
            setSelectedFile(null);
            if (fileInputRef.current) fileInputRef.current.value = '';
            // Tải lại dữ liệu sau khi import
            await handleXem();
        } catch (err) {
            const msg = err.response?.data || err.message;
            setUploadMsg(`❌ Lỗi: ${msg}`);
            console.error('Upload error:', err);
        } finally {
            setUploading(false);
        }
    };

    return (
        <div className="flex flex-col h-full gap-4">
            {/* Path selection section */}
            <input ref={fileInputRef} type="file" accept=".xlsx,.xls,.csv" className="hidden" onChange={handleFileChange} />
            <div className="flex items-center gap-3 w-full">
                <label className="font-medium text-gray-700 whitespace-nowrap w-24">Đường Dẫn:</label>
                <input
                    type="text"
                    value={selectedFile ? selectedFile.name : ''}
                    placeholder="Chưa chọn file..."
                    className="flex-1 border border-gray-300 rounded px-3 py-1.5 focus:outline-none focus:border-blue-500 bg-gray-50 text-gray-600"
                    readOnly
                />
                <button onClick={handleChonFile} className="bg-white border text-gray-700 px-4 py-1.5 rounded hover:bg-[#8BC34A] hover:text-white hover:border-[#8BC34A] shadow-sm transition-colors whitespace-nowrap border-[#8BC34A] font-medium text-[#7cb342]">
                    Chọn File Biến Động
                </button>
                <button
                    onClick={handleThemFile}
                    disabled={uploading || !selectedFile}
                    className={`px-4 py-1.5 rounded shadow-sm transition-colors whitespace-nowrap font-medium border ${uploading || !selectedFile
                        ? 'bg-gray-200 border-gray-300 text-gray-400 cursor-not-allowed'
                        : 'bg-[#2196F3] border-[#1e88e5] text-white hover:bg-[#1976D2]'
                        }`}
                >
                    {uploading ? 'Đang import...' : 'Thêm File Biến Động'}
                </button>
            </div>
            {uploadMsg && (
                <div className={`text-sm font-medium px-3 py-1.5 rounded ${uploadMsg.startsWith('✅') ? 'bg-green-50 text-green-700 border border-green-200' : 'bg-red-50 text-red-700 border border-red-200'
                    }`}>
                    {uploadMsg}
                </div>
            )}

            {/* Group Box: Thông Tin Hóa Đơn */}
            <fieldset className="border border-gray-300 rounded-md p-4 flex-1 flex flex-col gap-4 relative mt-2">
                <legend className="px-2 text-gray-600 font-medium ml-2 bg-white">Thông Tin Đồng Hồ Nước</legend>

                {/* Filters and Search */}
                <div className="flex items-center gap-4">
                    <div className="flex items-center gap-2">
                        <label className="text-gray-700">Theo Kỳ Đọc:</label>
                        <select
                            value={selectedKyDocId}
                            onChange={(e) => setSelectedKyDocId(e.target.value)}
                            className="border border-gray-300 rounded px-2 py-1.5 bg-white focus:outline-none focus:border-[#2196F3] min-w-[150px]"
                        >
                            {kyDocs.map(k => {
                                const kId = k.MaKyDoc || k.maKyDoc;
                                const kKy = k.Ky || k.ky;
                                const kNam = k.Nam || k.nam;
                                const kTen = k.TenKyDoc || k.tenKyDoc || `Tháng ${kKy}/${kNam}`;
                                return <option key={kId} value={kId}>{kTen}</option>;
                            })}
                        </select>
                    </div>

                    <button onClick={handleXem} className="bg-white border border-[#2196F3] text-[#2196F3] px-6 py-1.5 rounded hover:bg-[#e3f2fd] font-medium transition-colors shadow-sm ml-2">
                        {loading ? 'Đang tải...' : 'Xem Dữ Liệu'}
                    </button>

                    <div className="flex-1 ml-4 bg-gray-100 flex items-center px-4 rounded max-w-md h-9">
                        {thongKe && <span className="text-sm font-medium text-gray-600">Tổng Số: {thongKe.tongSo} | Đã Đọc: <span className="text-blue-600">{thongKe.daDoc}</span> | Chưa Đọc: <span className="text-red-500">{thongKe.chuaDoc}</span></span>}
                    </div>
                </div>

                {/* Data Grid */}
                <div className="flex-1 border border-gray-300 rounded overflow-hidden flex flex-col bg-white">
                    <div className="overflow-auto flex-1 h-0">
                        <table className="w-full text-left border-collapse whitespace-nowrap">
                            <thead className="bg-gray-100 sticky top-0 shadow-sm z-10 border-b border-gray-300">
                                <tr>
                                    <th className="w-6 border-r border-gray-300 bg-gray-200"></th>
                                    <th className="border-r border-gray-300 px-3 py-2 font-medium text-gray-700 w-16 text-center">Đợt</th>
                                    <th className="border-r border-gray-300 px-3 py-2 font-medium text-gray-700 w-28 text-right">Tổng HĐ Kỳ Trước</th>
                                    <th className="border-r border-gray-300 px-3 py-2 font-medium text-gray-700 w-24 text-right">Tổng BĐ</th>
                                    <th className="border-r border-gray-300 px-3 py-2 font-medium text-gray-700 w-24 text-right">Tổng TĐ</th>
                                    <th className="border-r border-gray-300 px-3 py-2 font-medium text-gray-700">Ngày Lập BĐ</th>
                                    <th className="border-r border-gray-300 px-3 py-2 font-medium text-gray-700">Ngày Lập TĐ</th>
                                    <th className="border-r border-gray-300 px-3 py-2 font-medium text-gray-700 w-24 text-center">Tạo Đợt</th>
                                    <th className="px-3 py-2 font-medium text-gray-700 w-24 text-center">Chỉ Số Nền</th>
                                </tr>
                            </thead>
                            <tbody>
                                {loading && (
                                    <tr><td colSpan="9" className="text-center py-6 text-gray-500">Đang tải...</td></tr>
                                )}
                                {data.map((row, index) => (
                                    <tr key={index} className={`border-b border-gray-200 hover:bg-[#e3f2fd] transition-colors cursor-pointer`}>
                                        <td className="border-r border-gray-200 bg-gray-100 text-center text-gray-400 text-xs w-6">{index === 0 ? '▶' : ''}</td>
                                        <td className="border-r border-gray-200 px-3 py-1.5 text-center font-bold text-[#2196F3]">{row.maDot}</td>
                                        <td className="border-r border-gray-200 px-3 py-1.5 text-right font-medium">{row.tongHDKyTruoc?.toLocaleString()}</td>
                                        <td className="border-r border-gray-200 px-3 py-1.5 text-right font-medium">{row.tongBD?.toLocaleString()}</td>
                                        <td className="border-r border-gray-200 px-3 py-1.5 text-right font-medium text-blue-600">{row.tongTD?.toLocaleString()}</td>
                                        <td className="border-r border-gray-200 px-3 py-1.5 text-gray-600 text-sm">{row.ngayLapBD ?? '-'}</td>
                                        <td className="border-r border-gray-200 px-3 py-1.5 text-gray-600 text-sm">{row.ngayLapTD ?? '-'}</td>
                                        <td className="border-r border-gray-200 px-3 py-1.5 text-center">
                                            <button className="text-xs bg-white border border-[#2196F3] text-[#2196F3] px-2 py-0.5 rounded hover:bg-[#e3f2fd] transition-colors">Tạo Đợt</button>
                                        </td>
                                        <td className="px-3 py-1.5 text-center">
                                            <button className="text-xs bg-white border border-[#8BC34A] text-[#7cb342] px-2 py-0.5 rounded hover:bg-[#f1f8e9] transition-colors">Kiểm Tra</button>
                                        </td>
                                    </tr>
                                ))}
                                {data.length === 0 && !loading && (
                                    <tr><td colSpan="9" className="text-center py-6 text-gray-500">Chưa có dữ liệu. Hãy chọn kỳ và nhấn "Xem Dữ Liệu".</td></tr>
                                )}
                            </tbody>
                        </table>
                    </div>

                    {/* Footer Totals */}
                    {thongKe && (
                        <div className="bg-gray-50 border-t border-gray-300 px-3 py-2 flex items-center font-bold text-sm gap-4">
                            <div className="w-6"></div>
                            <div className="w-16"></div>
                            <div className="w-28 text-right text-gray-700">{thongKe.tongSo?.toLocaleString()}</div>
                            <div className="w-24 text-right text-gray-700">{thongKe.tongSo?.toLocaleString()}</div>
                            <div className="w-24 text-right text-blue-600">{thongKe.tongSo?.toLocaleString()}</div>
                        </div>
                    )}
                </div>
            </fieldset>
        </div>
    );
}

// ==========================================
// TAB 2: LỊCH ĐỌC SỐ
// ==========================================
function LichDocSoTab() {
    const [dsKyList, setDsKyList] = useState([]);
    const [formData, setFormData] = useState({ id: null, ky: '', nam: new Date().getFullYear(), tuNgay: '', denNgay: '' });
    const [loading, setLoading] = useState(false);
    const [selectedKy, setSelectedKy] = useState(null);
    const [chiTietDot, setChiTietDot] = useState([]);
    const [dotLoading, setDotLoading] = useState(false);

    const fetchChiTietDot = async (maKyDoc) => {
        if (!maKyDoc) return;
        setDotLoading(true);
        try {
            const res = await axios.get(`${API_BASE_URL}/DocChiSo/dot/${maKyDoc}`);
            setChiTietDot(res.data);
        } catch (err) {
            console.error('Lỗi tải chi tiết đợt:', err);
            setChiTietDot([]);
        } finally {
            setDotLoading(false);
        }
    };

    const fetchKyDocs = async () => {
        setLoading(true);
        try {
            const response = await axios.get(`${API_BASE_URL}/DocChiSo/kydoc`);
            setDsKyList(response.data);
            if (response.data.length > 0) {
                handleSelect(response.data[0]);
            }
        } catch (error) {
            console.error("Lỗi khi tải danh sách kỳ đọc:", error);
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        fetchKyDocs();
    }, []);

    const handleSelect = (kyDoc) => {
        setSelectedKy(kyDoc);
        const id = kyDoc.MaKyDoc || kyDoc.maKyDoc;
        setFormData({
            id,
            ky: kyDoc.Ky || kyDoc.ky,
            nam: kyDoc.Nam || kyDoc.nam,
            tuNgay: kyDoc.TuNgay || kyDoc.tuNgay ? (kyDoc.TuNgay || kyDoc.tuNgay).substring(0, 10) : '',
            denNgay: kyDoc.DenNgay || kyDoc.denNgay ? (kyDoc.DenNgay || kyDoc.denNgay).substring(0, 10) : ''
        });
        fetchChiTietDot(id);
    };

    const handleAdd = async () => {
        if (!formData.ky || !formData.nam) return alert("Vui lòng nhập Kỳ và Năm");
        try {
            await axios.post(`${API_BASE_URL}/DocChiSo/kydoc`, {
                ky: parseInt(formData.ky),
                nam: parseInt(formData.nam),
                tuNgay: formData.tuNgay || null,
                denNgay: formData.denNgay || null
            });
            alert("Thêm kỳ đọc thành công!");
            setFormData({ id: null, ky: '', nam: new Date().getFullYear(), tuNgay: '', denNgay: '' });
            fetchKyDocs();
        } catch (error) {
            console.error(error);
            alert("Lỗi khi thêm: " + (error.response?.data || error.message));
        }
    };

    const handleUpdate = async () => {
        if (!formData.id) return alert("Vui lòng chọn một kỳ để sửa");
        try {
            await axios.put(`${API_BASE_URL}/DocChiSo/kydoc/${formData.id}`, {
                maKyDoc: formData.id,
                ky: parseInt(formData.ky),
                nam: parseInt(formData.nam),
                tuNgay: formData.tuNgay || null,
                denNgay: formData.denNgay || null
            });
            alert("Cập nhật kỳ đọc thành công!");
            fetchKyDocs();
        } catch (error) {
            console.error(error);
            alert("Lỗi khi cập nhật: " + (error.response?.data || error.message));
        }
    };

    const handleDelete = async () => {
        if (!formData.id) return alert("Vui lòng chọn một kỳ để xóa");
        if (!window.confirm("Bạn có chắc chắn muốn xóa kỳ đọc này? Toàn bộ dữ liệu đọc số trong kỳ này có thể bị ảnh hưởng.")) return;
        try {
            await axios.delete(`${API_BASE_URL}/DocChiSo/kydoc/${formData.id}`);
            alert("Xóa thành công!");
            setFormData({ id: null, ky: '', nam: new Date().getFullYear(), tuNgay: '', denNgay: '' });
            setChiTietDot([]);
            fetchKyDocs();
        } catch (error) {
            console.error(error);
            alert("Lỗi khi xóa: " + (error.response?.data || error.message));
        }
    };

    return (
        <div className="flex h-full gap-4">
            {/* Left Column */}
            <div className="flex flex-col gap-4 w-72 shrink-0">

                {/* Tao Ky Moi form */}
                <fieldset className="border border-gray-300 rounded-md p-3 relative bg-[#f1f8e9] border-[#c5e1a5]">
                    <legend className="px-2 text-[#7cb342] font-semibold ml-2 bg-[#f1f8e9]">Quản Lý Kỳ</legend>
                    <div className="flex flex-col gap-3">
                        <div className="flex items-center">
                            <label className="w-20 text-gray-700 font-medium">Kỳ</label>
                            <input type="number" value={formData.ky} onChange={e => setFormData({ ...formData, ky: e.target.value })} className="border border-gray-300 rounded px-2 py-1 w-20 outline-none focus:border-[#8BC34A]" />
                            <button onClick={handleAdd} className="flex-1 ml-2 bg-[#8BC34A] hover:bg-[#7cb342] text-white border border-[#7cb342] py-1 rounded font-medium transition-colors">Thêm</button>
                        </div>
                        <div className="flex items-center">
                            <label className="w-20 text-gray-700 font-medium">Năm</label>
                            <input type="number" value={formData.nam} onChange={e => setFormData({ ...formData, nam: e.target.value })} className="border border-gray-300 rounded px-2 py-1 w-20 outline-none focus:border-[#e53935]" />
                            <button onClick={handleDelete} className="flex-1 ml-2 bg-white text-red-500 hover:bg-red-50 border border-red-400 py-1 rounded font-medium transition-colors">Xóa</button>
                        </div>
                        <div className="flex items-center">
                            <label className="w-20 text-gray-700 font-medium">Từ Ngày</label>
                            <input type="date" value={formData.tuNgay} onChange={e => setFormData({ ...formData, tuNgay: e.target.value })} className="border border-gray-300 rounded px-2 py-1 w-32 text-xs outline-none focus:border-[#2196F3]" />
                            <button onClick={handleUpdate} className="flex-1 ml-2 bg-white text-[#2196F3] hover:bg-[#e3f2fd] border border-[#2196F3] py-1 rounded font-medium transition-colors">Sửa</button>
                        </div>
                        <div className="flex items-center">
                            <label className="w-20 text-gray-700 font-medium">Đến Ngày</label>
                            <input type="date" value={formData.denNgay} onChange={e => setFormData({ ...formData, denNgay: e.target.value })} className="border border-gray-300 rounded px-2 py-1 w-32 text-xs outline-none focus:border-[#2196F3]" />
                            <button onClick={() => setFormData({ id: null, ky: '', nam: new Date().getFullYear(), tuNgay: '', denNgay: '' })} className="flex-1 ml-2 bg-gray-100 text-gray-600 hover:bg-gray-200 border border-gray-300 py-1 rounded font-medium transition-colors">Mới</button>
                        </div>
                    </div>
                </fieldset>

                {/* Danh sach Ky */}
                <fieldset className="border border-gray-300 rounded-md p-0 flex-1 flex flex-col relative overflow-hidden h-0">
                    <legend className="px-2 text-gray-600 font-medium ml-4 bg-white relative z-10 block w-fit">Danh Sách Kỳ</legend>
                    <div className="overflow-auto flex-1 mt-1 -mt-3 pt-3">
                        <table className="w-full text-left border-collapse whitespace-nowrap">
                            <thead className="bg-gray-100 sticky top-0 shadow-sm z-10 border-b border-t border-gray-300">
                                <tr>
                                    <th className="w-6 border-r border-gray-300 bg-gray-200"></th>
                                    <th className="border-r border-gray-300 px-2 py-1.5 font-medium text-gray-700 w-12 text-center">Kỳ</th>
                                    <th className="border-r border-gray-300 px-2 py-1.5 font-medium text-gray-700 w-16 text-center">Năm</th>
                                    <th className="px-2 py-1.5 font-medium text-gray-700 text-center">Tên Kỳ</th>
                                </tr>
                            </thead>
                            <tbody>
                                {loading && <tr><td colSpan="4" className="text-center py-4 text-gray-500">Đang tải...</td></tr>}
                                {!loading && dsKyList.map((row) => {
                                    const rId = row.MaKyDoc || row.maKyDoc;
                                    const rKy = row.Ky || row.ky;
                                    const rNam = row.Nam || row.nam;
                                    const rTen = row.TenKyDoc || row.tenKyDoc || `Tháng ${rKy}/${rNam}`;
                                    const isSelected = (selectedKy?.MaKyDoc || selectedKy?.maKyDoc) === rId;
                                    return (
                                        <tr key={rId} onClick={() => handleSelect(row)} className={`border-b border-gray-200 cursor-pointer ${isSelected ? 'bg-[#2196F3] text-white' : 'hover:bg-[#e3f2fd] text-gray-800'}`}>
                                            <td className={`border-r bg-gray-100 text-center text-xs ${isSelected ? 'text-[#2196F3]' : 'text-transparent'}`}>▶</td>
                                            <td className={`border-r px-2 py-1 text-center ${isSelected ? 'border-[#1976D2]' : 'border-gray-200'}`}>{rKy}</td>
                                            <td className={`border-r px-2 py-1 text-center ${isSelected ? 'border-[#1976D2]' : 'border-gray-200'}`}>{rNam}</td>
                                            <td className={`px-2 py-1 text-center ${isSelected ? 'border-[#1976D2]' : 'border-gray-200'}`}>{rTen}</td>
                                        </tr>
                                    );
                                })}
                            </tbody>
                        </table>
                    </div>
                </fieldset>

            </div>

            {/* Right Column (Chi tiet Dot) */}
            <fieldset className="border border-gray-300 rounded-md p-0 flex-1 flex flex-col relative overflow-hidden">
                <legend className="px-2 text-gray-600 font-medium ml-4 bg-white relative z-10 block w-fit">Chi Tiết 15 Đợt Trong Kỳ</legend>
                <div className="overflow-auto flex-1 mt-1 -mt-3 pt-3">
                    <table className="w-full text-left border-collapse whitespace-nowrap">
                        <thead className="bg-gray-100 sticky top-0 shadow-sm z-10 border-b border-t border-gray-300">
                            <tr>
                                <th className="w-8 border-r border-gray-300 bg-gray-200"></th>
                                <th className="border-r border-gray-300 px-3 py-2 font-medium text-gray-700 w-16 text-center">Đợt</th>
                                <th className="border-r border-gray-300 px-3 py-2 font-medium text-gray-700">Ngày Đọc</th>
                                <th className="border-r border-gray-300 px-3 py-2 font-medium text-gray-700 leading-tight">Ngày Kiểm<br />Soát</th>
                                <th className="border-r border-gray-300 px-3 py-2 font-medium text-gray-700 leading-tight">Ngày Chuyển<br />Listing</th>
                                <th className="border-r border-gray-300 px-3 py-2 font-medium text-gray-700 leading-tight">Ngày Thu<br />Tiền</th>
                                <th className="px-3 py-2 font-medium text-gray-700 leading-tight text-center">Kiểm Tra Ngày<br />Đọc</th>
                            </tr>
                        </thead>
                        <tbody>
                            {dotLoading && (
                                <tr><td colSpan="7" className="text-center py-4 text-gray-500">Đang tải...</td></tr>
                            )}
                            {!dotLoading && chiTietDot.length === 0 && (
                                <tr><td colSpan="7" className="text-center py-4 text-gray-400">Chọn một kỳ để xem chi tiết đợt</td></tr>
                            )}
                            {!dotLoading && chiTietDot.map((row, idx) => (
                                <tr key={idx} className="border-b border-gray-200 hover:bg-[#e3f2fd] transition-colors">
                                    <td className="border-r border-gray-200 bg-gray-100 text-center text-gray-400 text-xs"></td>
                                    <td className="border-r border-gray-200 px-3 py-1.5 text-center font-medium">{row.dot}</td>
                                    <td className="border-r border-gray-200 px-3 py-1.5 text-gray-700">{row.ngayDoc}</td>
                                    <td className="border-r border-gray-200 px-3 py-1.5 text-gray-700">{row.ngayKiemSoat}</td>
                                    <td className="border-r border-gray-200 px-3 py-1.5 text-gray-700">{row.ngayChuyenListing}</td>
                                    <td className="border-r border-gray-200 px-3 py-1.5 text-gray-700">{row.ngayThuTien}</td>
                                    <td className="p-1 px-3 text-center">
                                        <input type="checkbox" defaultChecked={row.kiemTraNgayDoc} className="w-4 h-4 text-[#2196F3] rounded cursor-pointer accent-[#2196F3]" />
                                    </td>
                                </tr>
                            ))}
                        </tbody>
                    </table>
                </div>
            </fieldset>

        </div>
    );
}
