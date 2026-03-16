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
        if (saved) setAvatarBase64(saved);
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
                <Text style={styles.greetingText}>Xin chào</Text>
                <Text style={styles.nameText}>{user?.fullname ?? user?.username}</Text>

                <View style={{ height: 24 }} />

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

                {/* Menu Buttons match Flutter 140x140 */}
                <View style={styles.menuRow}>
                    <TouchableOpacity
                        style={styles.menuBtn}
                        onPress={() => navigation.navigate('DanhSachKH')}
                    >
                        <Image source={require('../../assets/icon_nuoc.png')} style={styles.menuIcon} />
                        <Text style={styles.menuBtnTxt}>Đọc Số</Text>
                    </TouchableOpacity>

                    <View style={{ width: 24 }} />

                    <TouchableOpacity
                        style={[styles.menuBtn, { backgroundColor: '#F5F5F5' }]}
                        onPress={() => Alert.alert('Thông báo', 'Chức năng đang được phát triển')}
                    >
                        <Image source={require('../../assets/icon_quanly.png')} style={styles.menuIcon} />
                        <Text style={styles.menuBtnTxt}>Quản Lý</Text>
                    </TouchableOpacity>
                </View>

                <View style={{ flex: 1 }} />

                {/* Footer status text */}
                <Text style={styles.footerText}>Tổng số khách hàng: {totalCustomers}</Text>
            </View>
        </SafeAreaView>
    );
};

const styles = StyleSheet.create({
    container: { flex: 1, backgroundColor: '#fff' },
    appBar: {
        backgroundColor: '#2196F3',
        flexDirection: 'row',
        alignItems: 'center',
        justifyContent: 'space-between',
        paddingHorizontal: 16,
        height: 56,
    },
    appBarTitle: { fontSize: 20, color: 'white', fontWeight: 'bold' },
    body: { flex: 1, alignItems: 'center', backgroundColor: 'white' },

    greetingText: { fontSize: 28, fontWeight: '500', color: '#2196F3' },
    nameText: { fontSize: 32, fontWeight: 'bold', color: '#2196F3' },

    avatarWrapper: { position: 'relative', width: 120, height: 120 },
    avatarCircle: {
        width: 120, height: 120, borderRadius: 60,
        backgroundColor: '#2196F3',
        justifyContent: 'center', alignItems: 'center', overflow: 'hidden',
    },
    avatarImage: { width: 120, height: 120, borderRadius: 60 },
    cameraIcon: {
        position: 'absolute', bottom: 0, right: 0,
        width: 36, height: 36, borderRadius: 18,
        backgroundColor: 'white',
        borderWidth: 2, borderColor: '#2196F3',
        justifyContent: 'center', alignItems: 'center',
    },

    menuRow: { flexDirection: 'row', justifyContent: 'center' },
    menuBtn: {
        width: 140, height: 140,
        backgroundColor: '#EEEEEE',
        borderRadius: 12,
        justifyContent: 'center',
        alignItems: 'center',
        padding: 16,
    },
    menuIcon: { width: 70, height: 70, resizeMode: 'contain' },
    menuBtnTxt: {
        fontSize: 16, fontWeight: 'bold', color: '#424242', marginTop: 8,
    },
    footerText: { fontSize: 14, color: '#757575', marginBottom: 16 },
});

export default DashboardScreen;
