import React, { useState, useEffect } from 'react';
import {
    StyleSheet,
    View,
    Text,
    TextInput,
    TouchableOpacity,
    ScrollView,
    SafeAreaView,
    KeyboardAvoidingView,
    Platform,
    ActivityIndicator,
    Modal,
    Image,
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { useAuth } from '../context/AuthContext';
import ApiService from '../services/ApiService';
import UIHelper from '../helpers/UIHelper';

const LoginScreen = () => {
    const { login } = useAuth();
    const [isLoginMode, setIsLoginMode] = useState(true);
    const [username, setUsername] = useState('');
    const [password, setPassword] = useState('');
    const [fullname, setFullname] = useState('');
    const [loading, setLoading] = useState(false);
    const [showSettings, setShowSettings] = useState(false);
    const [serverIp, setServerIp] = useState('192.168.1.144');
    const [tempIp, setTempIp] = useState('');

    useEffect(() => {
        AsyncStorage.getItem('server_ip').then(ip => {
            if (ip) setServerIp(ip);
        });
    }, []);

    const handleOpenSettings = async () => {
        const ip = await AsyncStorage.getItem('server_ip') || serverIp;
        setTempIp(ip);
        setShowSettings(true);
    };

    const handleSaveIp = async () => {
        const ip = tempIp.trim();
        if (ip) {
            await ApiService.setBaseUrl(ip);
            setServerIp(ip);
            UIHelper.showCustomSnackBar(`✅ Đã lưu địa chỉ server: ${ip}`, false, true);
        }
        setShowSettings(false);
    };

    const handleAction = async () => {
        if (!username || !password || (!isLoginMode && !fullname)) {
            UIHelper.showCustomSnackBar('Vui lòng nhập đầy đủ thông tin!', true);
            return;
        }

        setLoading(true);
        try {
            if (isLoginMode) {
                const userData = await ApiService.dangNhap(username, password);
                if (userData) {
                    UIHelper.showCustomSnackBar('Đăng nhập thành công!', false, true);
                    // Persistent storage parity with Flutter
                    await AsyncStorage.setItem('fullname', userData.fullname);
                    if (userData.avatar) {
                        await AsyncStorage.setItem('avatar_data', userData.avatar);
                    } else {
                        await AsyncStorage.removeItem('avatar_data');
                    }
                    await login(userData);
                } else {
                    UIHelper.showCustomSnackBar('Sai tài khoản hoặc mật khẩu!', true);
                }
            } else {
                const success = await ApiService.dangKy(username, password, fullname);
                if (success) {
                    UIHelper.showCustomSnackBar('Đăng ký thành công! Vui lòng đăng nhập.', false, true);
                    setIsLoginMode(true);
                } else {
                    UIHelper.showCustomSnackBar('Tên đăng nhập đã tồn tại!', true);
                }
            }
        } catch (e) {
            UIHelper.showCustomSnackBar('Có lỗi xảy ra, vui lòng thử lại!', true);
        } finally {
            setLoading(false);
        }
    };

    return (
        <SafeAreaView style={styles.container}>
            {/* Settings Modal */}
            <Modal visible={showSettings} transparent animationType="fade" onRequestClose={() => setShowSettings(false)}>
                <TouchableOpacity style={styles.modalOverlay} activeOpacity={1} onPress={() => setShowSettings(false)}>
                    <TouchableOpacity activeOpacity={1} style={styles.modalCard}>
                        <Text style={styles.modalTitle}>⚙️ Cấu hình Server</Text>
                        <Text style={styles.modalSubtitle}>Nhập địa chỉ IP của server API</Text>
                        <TextInput
                            style={styles.modalInput}
                            value={tempIp}
                            onChangeText={setTempIp}
                            placeholder="Ví dụ: 192.168.1.100"
                            keyboardType="url"
                            autoCapitalize="none"
                        />
                        <Text style={styles.modalHint}>Port mặc định: 5000</Text>
                        <View style={styles.modalButtons}>
                            <TouchableOpacity style={styles.modalBtnCancel} onPress={() => setShowSettings(false)}>
                                <Text style={styles.modalBtnCancelText}>Hủy</Text>
                            </TouchableOpacity>
                            <TouchableOpacity style={styles.modalBtnSave} onPress={handleSaveIp}>
                                <Text style={styles.modalBtnSaveText}>💾 Lưu</Text>
                            </TouchableOpacity>
                        </View>
                    </TouchableOpacity>
                </TouchableOpacity>
            </Modal>

            <KeyboardAvoidingView
                behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
                style={styles.flex}
            >
                {/* Gear button - top right */}
                <TouchableOpacity style={styles.settingsBtn} onPress={handleOpenSettings}>
                    <Ionicons name="settings-outline" size={26} color="#999" />
                    <Text style={styles.ipBadge}>{serverIp}</Text>
                </TouchableOpacity>

                <ScrollView contentContainerStyle={styles.scrollContent}>
                    <View style={styles.logoContainer}>
                        <View style={styles.logoCircle}>
                            <Image
                                source={require('../../assets/logo.png')}
                                style={styles.logoImage}
                                resizeMode="contain"
                            />
                        </View>
                    </View>

                    <Text style={styles.title}>{isLoginMode ? 'ĐĂNG NHẬP' : 'ĐĂNG KÝ'}</Text>

                    <View style={styles.form}>
                        <View style={styles.inputContainer}>
                            <Ionicons name="person-outline" size={24} color="#666" style={styles.inputIcon} />
                            <TextInput
                                style={styles.input}
                                placeholder="Tên đăng nhập"
                                value={username}
                                onChangeText={setUsername}
                                autoCapitalize="none"
                            />
                        </View>

                        <View style={styles.inputContainer}>
                            <Ionicons name="lock-closed-outline" size={24} color="#666" style={styles.inputIcon} />
                            <TextInput
                                style={styles.input}
                                placeholder="Mật khẩu"
                                value={password}
                                onChangeText={setPassword}
                                secureTextEntry
                            />
                        </View>

                        {!isLoginMode && (
                            <View style={styles.inputContainer}>
                                <Ionicons name="id-card-outline" size={24} color="#666" style={styles.inputIcon} />
                                <TextInput
                                    style={styles.input}
                                    placeholder="Họ và tên"
                                    value={fullname}
                                    onChangeText={setFullname}
                                />
                            </View>
                        )}

                        <TouchableOpacity
                            style={styles.button}
                            onPress={handleAction}
                            disabled={loading}
                        >
                            {loading ? (
                                <ActivityIndicator color="white" />
                            ) : (
                                <>
                                    <Ionicons name="water" size={24} color="white" />
                                    <Text style={styles.buttonText}>
                                        {isLoginMode ? ' ĐĂNG NHẬP' : ' ĐĂNG KÝ'}
                                    </Text>
                                </>
                            )}
                        </TouchableOpacity>

                        <TouchableOpacity
                            onPress={() => setIsLoginMode(!isLoginMode)}
                            style={styles.toggleButton}
                        >
                            <Text style={styles.toggleText}>
                                {isLoginMode
                                    ? 'Chưa có tài khoản? Đăng ký'
                                    : 'Đã có tài khoản? Đăng nhập'}
                            </Text>
                        </TouchableOpacity>
                    </View>
                </ScrollView>
            </KeyboardAvoidingView>
        </SafeAreaView>
    );
};

const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: '#E3F2FD',
    },
    flex: {
        flex: 1,
    },
    settingsBtn: {
        position: 'absolute',
        top: 16,
        right: 16,
        zIndex: 10,
        alignItems: 'center',
    },
    ipBadge: {
        fontSize: 9,
        color: '#AAA',
        marginTop: 2,
    },
    scrollContent: {
        flexGrow: 1,
        justifyContent: 'center',
        padding: 32,
        paddingTop: 60,
    },
    logoContainer: {
        alignItems: 'center',
        marginBottom: 24,
    },
    logoCircle: {
        width: 100,
        height: 100,
        borderRadius: 50,
        backgroundColor: 'white',
        justifyContent: 'center',
        alignItems: 'center',
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 4 },
        shadowOpacity: 0.1,
        shadowRadius: 8,
        elevation: 5,
    },
    logoImage: {
        width: 70,
        height: 70,
    },
    brandName: {
        fontSize: 18,
        fontWeight: '900',
        color: '#1976D2',
        marginTop: 12,
        letterSpacing: 2,
    },
    title: {
        fontSize: 24,
        fontWeight: 'bold',
        textAlign: 'center',
        letterSpacing: 1.5,
        marginBottom: 40,
        color: '#333',
    },
    form: {
        width: '100%',
    },
    inputContainer: {
        flexDirection: 'row',
        alignItems: 'center',
        backgroundColor: 'white',
        borderRadius: 8,
        borderWidth: 1,
        borderColor: '#E0E0E0',
        marginBottom: 16,
        paddingHorizontal: 16,
    },
    inputIcon: {
        marginRight: 12,
    },
    input: {
        flex: 1,
        height: 56,
        fontSize: 16,
    },
    button: {
        backgroundColor: '#2196F3',
        height: 56,
        borderRadius: 8,
        flexDirection: 'row',
        justifyContent: 'center',
        alignItems: 'center',
        marginTop: 16,
        shadowColor: '#2196F3',
        shadowOffset: { width: 0, height: 4 },
        shadowOpacity: 0.3,
        shadowRadius: 5,
        elevation: 5,
    },
    buttonText: {
        color: 'white',
        fontSize: 16,
        fontWeight: 'bold',
        letterSpacing: 1.2,
    },
    toggleButton: {
        marginTop: 24,
        alignItems: 'center',
    },
    toggleText: {
        color: '#1976D2',
        fontSize: 14,
    },
    // Modal
    modalOverlay: {
        flex: 1,
        backgroundColor: 'rgba(0,0,0,0.5)',
        justifyContent: 'center',
        alignItems: 'center',
        padding: 24,
    },
    modalCard: {
        backgroundColor: 'white',
        borderRadius: 16,
        padding: 24,
        width: '100%',
    },
    modalTitle: {
        fontSize: 18,
        fontWeight: 'bold',
        color: '#333',
        marginBottom: 4,
    },
    modalSubtitle: {
        fontSize: 13,
        color: '#888',
        marginBottom: 16,
    },
    modalInput: {
        borderWidth: 1,
        borderColor: '#DDD',
        borderRadius: 8,
        paddingHorizontal: 16,
        height: 48,
        fontSize: 16,
        backgroundColor: '#F9F9F9',
    },
    modalHint: {
        fontSize: 11,
        color: '#AAA',
        marginTop: 6,
        marginBottom: 20,
    },
    modalButtons: {
        flexDirection: 'row',
        gap: 12,
    },
    modalBtnCancel: {
        flex: 1,
        height: 44,
        borderRadius: 8,
        borderWidth: 1,
        borderColor: '#DDD',
        justifyContent: 'center',
        alignItems: 'center',
    },
    modalBtnCancelText: {
        color: '#666',
        fontWeight: '600',
    },
    modalBtnSave: {
        flex: 1,
        height: 44,
        borderRadius: 8,
        backgroundColor: '#2196F3',
        justifyContent: 'center',
        alignItems: 'center',
    },
    modalBtnSaveText: {
        color: 'white',
        fontWeight: 'bold',
    },
});

export default LoginScreen;
