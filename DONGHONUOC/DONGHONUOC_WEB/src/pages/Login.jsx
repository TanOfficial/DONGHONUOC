import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import axios from 'axios';
import { useAuth } from '../context/AuthContext';

const API_BASE_URL = 'http://localhost:5000/api';

export default function Login() {
    const [username, setUsername] = useState('');
    const [password, setPassword] = useState('');
    const [error, setError] = useState('');
    const [loading, setLoading] = useState(false);

    const { login } = useAuth();
    const navigate = useNavigate();

    const handleLogin = async (e) => {
        e.preventDefault();
        setError('');
        setLoading(true);

        try {
            const response = await axios.post(`${API_BASE_URL}/Auth/login`, {
                username,
                password
            });

            if (response.data.Success) {
                login(response.data);
                navigate('/'); // Redirect to dashboard
            } else {
                setError(response.data.Message || 'Đăng nhập thất bại.');
            }
        } catch (err) {
            console.error("Login error:", err);
            setError('Lỗi kết nối đến máy chủ. Hãy đảm bảo DONGHONUOC_API đang chạy.');
        } finally {
            setLoading(false);
        }
    };

    return (
        <div className="min-h-screen flex items-center justify-center bg-[#e3f2fd]">
            <div className="max-w-md w-full bg-white rounded-lg shadow-lg p-8 border border-[#90caf9]">
                <div className="text-center mb-8">
                    <div className="mx-auto w-16 h-16 bg-[#2196F3] rounded-full flex items-center justify-center mb-4 shadow-md">
                        {/* Simple Water Drop Icon */}
                        <svg xmlns="http://www.w3.org/2000/svg" className="h-8 w-8 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 3v1m0 16a4.5 4.5 0 004.5-4.5c0-3.314-4.5-8.5-4.5-8.5s-4.5 5.186-4.5 8.5A4.5 4.5 0 0012 20zm0 0v-1" />
                        </svg>
                    </div>
                    <h2 className="text-2xl font-bold text-gray-800">Quản Lý Đọc Số</h2>
                    <p className="text-gray-500 mt-1">Hệ thống Water Management</p>
                </div>

                {error && (
                    <div className="mb-4 bg-red-50 border-l-4 border-red-500 p-3 flex items-start">
                        <p className="text-sm text-red-700">{error}</p>
                    </div>
                )}

                <form onSubmit={handleLogin} className="space-y-5">
                    <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1">Tài khoản</label>
                        <input
                            type="text"
                            required
                            className="w-full border border-gray-300 rounded px-3 py-2 outline-none focus:border-[#2196F3] focus:ring-1 focus:ring-[#2196F3]"
                            value={username}
                            onChange={(e) => setUsername(e.target.value)}
                            placeholder="Nhập tên đăng nhập"
                        />
                    </div>

                    <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1">Mật khẩu</label>
                        <input
                            type="password"
                            required
                            className="w-full border border-gray-300 rounded px-3 py-2 outline-none focus:border-[#2196F3] focus:ring-1 focus:ring-[#2196F3]"
                            value={password}
                            onChange={(e) => setPassword(e.target.value)}
                            placeholder="Nhập mật khẩu"
                        />
                    </div>

                    <button
                        type="submit"
                        disabled={loading}
                        className={`w-full text-white font-medium py-2 px-4 rounded transition-colors shadow-sm ${loading ? 'bg-gray-400 cursor-not-allowed' : 'bg-[#2196F3] hover:bg-[#1976D2] border border-[#1e88e5]'
                            }`}
                    >
                        {loading ? 'Đang xác thực...' : 'Đăng Nhập'}
                    </button>
                </form>
            </div>
        </div>
    );
}
