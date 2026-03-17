console.log('🏠 DASHBOARD SCREEN LOADED');
import React, { useState, useEffect } from 'react';
import {
    StyleSheet, View, Text, TouchableOpacity, Image,
    SafeAreaView, Alert,
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import * as ImagePicker from 'expo-image-picker';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { useNavigation } from '@react-navigation/native';
import { StackNavigationProp } from '@react-navigation/stack';
import { useAuth } from '../context/AuthContext';
import ApiService from '../services/ApiService';
import { RootStackParamList } from '../navigation/AppNavigator';

type DashboardNavigationProp = StackNavigationProp<RootStackParamList, 'Dashboard'>;

import CustomDialog from '../components/common/CustomDialog';

const DashboardScreen = () => {
    console.log('⚛️ Rendering DashboardScreen');
    const { user, logout } = useAuth();
    const navigation = useNavigation<DashboardNavigationProp>();
    const [totalCustomers, setTotalCustomers] = useState(0);
    const [avatarBase64, setAvatarBase64] = useState<string | null>(null);
    const [logoutVisible, setLogoutVisible] = useState(false);

    useEffect(() => {
        loadStats();
        loadAvatar();
    }, []);

    const loadAvatar = async () => {
        const saved = await AsyncStorage.getItem('avatar_data');
        if (saved) {
            setAvatarBase64(saved);
        } else if (user?.avatar) {
            setAvatarBase64(user.avatar);
        }
    };

    const loadStats = async () => {
        console.log('📊 Loading dashboard stats...');
        const total = await ApiService.demTongKhach();
        console.log('📈 Total customers:', total);
        setTotalCustomers(total);
    };

    const handleLogoutConfirm = async () => {
        setLogoutVisible(false);
        await AsyncStorage.multiRemove(['avatar_data', 'username', 'fullname']);
        await logout();
    };

    const handlePickAvatar = () => {
        Alert.alert('Chọn ảnh đại diện', '', [
            {
                text: 'Chụp ảnh',
                onPress: async () => {
                    const result = await ImagePicker.launchCameraAsync({
                        allowsEditing: true, aspect: [1, 1], quality: 0.85,
                        base64: true, mediaTypes: ImagePicker.MediaTypeOptions.Images,
                    });
                    if (!result.canceled && result.assets[0].base64) {
                        const b64 = result.assets[0].base64;
                        await AsyncStorage.setItem('avatar_data', b64);
                        if (user?.username) await ApiService.updateAvatar(user.username, b64);
                        setAvatarBase64(b64);
                    }
                },
            },
            {
                text: 'Chọn từ thư viện',
                onPress: async () => {
                    const result = await ImagePicker.launchImageLibraryAsync({
                        allowsEditing: true, aspect: [1, 1], quality: 0.85,
                        base64: true, mediaTypes: ImagePicker.MediaTypeOptions.Images,
                    });
                    if (!result.canceled && result.assets[0].base64) {
                        const b64 = result.assets[0].base64;
                        await AsyncStorage.setItem('avatar_data', b64);
                        if (user?.username) await ApiService.updateAvatar(user.username, b64);
                        setAvatarBase64(b64);
                    }
                },
            },
            { text: 'Hủy', style: 'cancel' },
        ]);
    };

    return (
        <SafeAreaView style={styles.container}>
            <CustomDialog
                visible={logoutVisible}
                title="Đăng xuất"
                content="Bạn có chắc chắn muốn đăng xuất?"
                icon="log-out"
                iconColor="#FF9800"
                confirmText="Đăng xuất"
                cancelText="Hủy"
                onConfirm={handleLogoutConfirm}
                onCancel={() => setLogoutVisible(false)}
            />

            {/* AppBar */}
            <View style={styles.appBar}>
                <Text style={styles.appBarTitle}>Đọc Số</Text>
                <TouchableOpacity onPress={() => setLogoutVisible(true)}>
                    <Ionicons name="log-out-outline" size={26} color="white" />
                </TouchableOpacity>
            </View>

            {/* Body */}
            <View style={styles.body}>
                <View style={{ height: 40 }} />

                {/* Greeting */}
                <Text style={styles.greetingText}>Xin chào,</Text>
                <Text style={styles.nameText}>{user?.fullname ?? user?.username}</Text>

                <View style={{ height: 20 }} />

                {/* Avatar */}
                <TouchableOpacity onPress={handlePickAvatar} style={styles.avatarWrapper}>
                    <View style={styles.avatarCircle}>
                        {avatarBase64 ? (
                            <Image
                                source={{ uri: `data:image/jpeg;base64,${avatarBase64}` }}
                                style={styles.avatarImage}
                            />
                        ) : (
                            <Ionicons name="person" size={60} color="white" />
                        )}
                    </View>
                    {/* Camera icon overlay */}
                    <View style={styles.cameraIcon}>
                        <Ionicons name="camera" size={20} color="#2196F3" />
                    </View>
                </TouchableOpacity>

                <View style={{ height: 40 }} />

                {/* Menu Buttons - Modern Grid */}
                <View style={styles.menuRow}>
                    <TouchableOpacity
                        style={styles.menuBtn}
                        onPress={() => navigation.navigate('DanhSachKH')}
                    >
                        <View style={[styles.iconBox, { backgroundColor: '#E3F2FD' }]}>
                            <Ionicons name="speedometer" size={40} color="#2196F3" />
                        </View>
                        <Text style={styles.menuBtnTxt}>Đọc Số</Text>
                    </TouchableOpacity>

                    <View style={{ width: 24 }} />

                    <TouchableOpacity
                        style={styles.menuBtn}
                        onPress={() => Alert.alert('Thông báo', 'Chức năng đang được phát triển')}
                    >
                        <View style={[styles.iconBox, { backgroundColor: '#F3E5F5' }]}>
                            <Ionicons name="stats-chart" size={40} color="#9C27B0" />
                        </View>
                        <Text style={styles.menuBtnTxt}>Quản Lý</Text>
                    </TouchableOpacity>
                </View>

                <View style={{ flex: 1 }} />

                {/* Footer status text */}
                <View style={styles.footer}>
                    <Ionicons name="people-outline" size={16} color="#757575" style={{ marginRight: 6 }} />
                    <Text style={styles.footerText}>Tổng số khách hàng: {totalCustomers}</Text>
                </View>
                <View style={{ height: 10 }} />
            </View>
        </SafeAreaView>
    );
};

const styles = StyleSheet.create({
    container: { flex: 1, backgroundColor: '#2196F3' }, // Set background to match AppBar
    appBar: {
        backgroundColor: '#2196F3',
        flexDirection: 'row',
        alignItems: 'center',
        justifyContent: 'space-between',
        paddingHorizontal: 20,
        height: 60,
    },
    appBarTitle: { fontSize: 22, color: 'white', fontWeight: 'bold', letterSpacing: 0.5 },
    body: {
        flex: 1,
        alignItems: 'center',
        backgroundColor: 'white',
        borderTopLeftRadius: 30,
        borderTopRightRadius: 30,
        width: '100%',
    },

    greetingText: { fontSize: 20, fontWeight: '400', color: '#616161', marginTop: 10 },
    nameText: { fontSize: 28, fontWeight: 'bold', color: '#212121', marginBottom: 10 },

    avatarWrapper: {
        position: 'relative',
        width: 130,
        height: 130,
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 4 },
        shadowOpacity: 0.15,
        shadowRadius: 10,
        elevation: 10,
    },
    avatarCircle: {
        width: 130, height: 130, borderRadius: 65,
        backgroundColor: '#E1F5FE',
        justifyContent: 'center', alignItems: 'center',
        overflow: 'hidden',
        borderWidth: 4,
        borderColor: 'white',
    },
    avatarImage: { width: 130, height: 130, borderRadius: 65 },
    cameraIcon: {
        position: 'absolute', bottom: 5, right: 5,
        width: 40, height: 40, borderRadius: 20,
        backgroundColor: 'white',
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 2 },
        shadowOpacity: 0.2,
        shadowRadius: 4,
        elevation: 5,
        justifyContent: 'center', alignItems: 'center',
    },

    menuRow: { flexDirection: 'row', justifyContent: 'center', paddingHorizontal: 20 },
    menuBtn: {
        width: 150, height: 160,
        backgroundColor: 'white',
        borderRadius: 24,
        justifyContent: 'center',
        alignItems: 'center',
        padding: 16,
        // Shadow for premium feel
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 8 },
        shadowOpacity: 0.1,
        shadowRadius: 12,
        elevation: 8,
    },
    iconBox: {
        width: 70, height: 70,
        borderRadius: 20,
        justifyContent: 'center',
        alignItems: 'center',
        marginBottom: 16,
    },
    menuBtnTxt: {
        fontSize: 17, fontWeight: '700', color: '#424242',
    },
    footer: {
        flexDirection: 'row',
        alignItems: 'center',
        marginBottom: 20,
        backgroundColor: '#F5F5F5',
        paddingVertical: 8,
        paddingHorizontal: 16,
        borderRadius: 20,
    },
    footerText: { fontSize: 13, color: '#757575', fontWeight: '600' },
});

export default DashboardScreen;
