import React, { useState, useEffect } from 'react';
import {
    StyleSheet, View, Text, TouchableOpacity, TextInput, ScrollView,
    SafeAreaView, ActivityIndicator, Alert, KeyboardAvoidingView, Platform, Image, Modal
} from 'react-native';
import { useRoute, useNavigation } from '@react-navigation/native';
import { Ionicons } from '@expo/vector-icons';
import Checkbox from 'expo-checkbox';
import ApiService from '../services/ApiService';
import DatabaseHelper from '../helpers/DatabaseHelper';
import UIHelper from '../helpers/UIHelper';
import CustomDialog from '../components/common/CustomDialog';
import InputDialog from '../components/common/InputDialog';
import OptionDialog, { DialogOption } from '../components/common/OptionDialog';
import * as ImagePicker from 'expo-image-picker';

interface Customer {
    ma_danh_bo: string;
    ten_kh: string;
    ma_lo_trinh: string;
    dia_chi: string;
    chi_so_cu: number;
    chi_so_moi?: number | null;
    tieu_thu_cu?: number;
    code_cu?: string;
    trang_thai: number;
    ma_ky_doc: number;
    ghi_chu?: string;
    code?: string;
    hinh_anh?: string;
    hieu?: string;
    co?: string;
    so_than?: string;
    sdt?: string;
    gb?: string;
    dm?: string;
    dmhn?: number;
    tbtt?: number;
    tien_nuoc?: number;
    thue_gtgt?: number;
    phivmt?: number;
    thue_tdvtn?: number;
    tong_cong?: number;
    ghi_chu_kh?: string;
    nam?: number;
    ky?: string;
    ngay_bd?: string;
    ngay_kt?: string;
}

const InfoItem = ({ label, value, boldValue = false }: { label: string, value: any, boldValue?: boolean }) => (
    <View style={styles.infoPopupRow}>
        <Text style={styles.infoPopupLabel}>{label}</Text>
        <Text style={[styles.infoPopupVal, boldValue && { fontWeight: 'bold', color: '#000' }]}>{value || '--'}</Text>
    </View>
);

const GhiNuocScreen = () => {
    const route = useRoute<any>();
    const navigation = useNavigation();
    const { customers: initialCustomers, index: initialIndex } = route.params;
    const [customers, setCustomers] = useState<Customer[]>(initialCustomers);
    const [currentIndex, setCurrentIndex] = useState(Number(initialIndex));
    const [history, setHistory] = useState<any[]>([]);
    const [tieuThu, setTieuThu] = useState(0);
    const [capturedImage, setCapturedImage] = useState<string | null>(null);
    const [selectedCode, setSelectedCode] = useState('40');

    // Input Controllers
    const [csMoi, setCsMoi] = useState('');
    const [ghiChu, setGhiChu] = useState('');

    // Modal & Loading States
    const [loading, setLoading] = useState(false);
    const [historyLoading, setHistoryLoading] = useState(false);
    const [historyCache, setHistoryCache] = useState<Record<string, any[]>>({});
    const [dialogVisible, setDialogVisible] = useState(false);
    const [dialogConfig, setDialogConfig] = useState<any>({});
    const [noteDialogVisible, setNoteDialogVisible] = useState(false);
    const [imageOptionVisible, setImageOptionVisible] = useState(false);
    const [codeModalVisible, setCodeModalVisible] = useState(false);

    const currentKH = customers[currentIndex];

    const [infoModalVisible, setInfoModalVisible] = useState(false);

    const codeOptions: DialogOption[] = [
        { label: '40 - ĐH bình thường', icon: 'checkmark-circle-outline', value: '40', color: '#4CAF50' },
        { label: '41 - Chủ ghi', icon: 'person-outline', value: '41', color: '#2196F3' },
        { label: '42 - Chủ báo', icon: 'megaphone-outline', value: '42', color: '#2196F3' },
        { label: '43 - Chủ đọc', icon: 'eye-outline', value: '43', color: '#2196F3' },
        { label: '45 - Âm sâu, Kẹt tường', icon: 'construct-outline', value: '45', color: '#795548' },
        { label: '46 - ĐHN mất tín hiệu', icon: 'wifi-outline', value: '46', color: '#F44336' },
        { label: 'F1 - CÓ Ở', icon: 'home-outline', value: 'F1', color: '#4CAF50' },
        { label: 'F2 - KẸT KHÓA', icon: 'lock-closed-outline', value: 'F2', color: '#FF9800' },
        { label: 'F3 - CHẤT ĐỒ', icon: 'cube-outline', value: 'F3', color: '#9E9E9E' },
        { label: 'F4 - ĐÁM TANG', icon: 'alert-circle-outline', value: 'F4', color: '#E91E63' },
        { label: 'F5 - KHÔNG Ở', icon: 'close-outline', value: 'F5', color: '#607D8B' },
        { label: 'F6 - ĐHN TM HƯ', icon: 'settings-outline', value: 'F6', color: '#D32F2F' },
        { label: '80 - THAY CHƯA ĐỦ NGÀY', icon: 'calendar-outline', value: '80', color: '#2196F3' },
        { label: '81 - THAY BỒI THƯỜNG', icon: 'build-outline', value: '81', color: '#2196F3' },
        { label: '82 - THAY ĐỊNH KỲ', icon: 'infinite-outline', value: '82', color: '#2196F3' },
        { label: '83 - KIỂM ĐỊNH', icon: 'medal-outline', value: '83', color: '#2196F3' },
        { label: '84 - NÂNG HẠ CỠ', icon: 'resize-outline', value: '84', color: '#2196F3' },
        { label: '85 - ĐHN HAI MẶT', icon: 'copy-outline', value: '85', color: '#2196F3' },
        { label: '86 - RESET', icon: 'refresh-circle-outline', value: '86', color: '#2196F3' },
        { label: 'K - CẮT TẠM', icon: 'cut-outline', value: 'K', color: '#F44336' },
        { label: 'K1 - TẠM KHÓA NƯỚC', icon: 'lock-closed-outline', value: 'K1', color: '#F44336' },
        { label: 'K2 - CẮT TẠM', icon: 'close-circle-outline', value: 'K2', color: '#F44336' },
        { label: 'K3 - CẮT TẬN GỐC', icon: 'nuclear-outline', value: 'K3', color: '#D32F2F' },
        { label: 'K4 - TỰ Ý MỞ CHÌ', icon: 'warning-outline', value: 'K4', color: '#FF9800' },
    ];

    useEffect(() => {
        loadData();
    }, [currentIndex]);

    const loadData = async () => {
        if (!currentKH) return;

        // Instant data from customers list
        const initialCsMoi = currentKH.chi_so_moi?.toString() ?? '';
        setCsMoi(initialCsMoi);
        setGhiChu(currentKH.ghi_chu ?? '');
        setSelectedCode(currentKH.code ?? '40');
        setCapturedImage(currentKH.hinh_anh ?? null);

        // Use cache for history if available
        if (historyCache[currentKH.ma_danh_bo]) {
            const cached = historyCache[currentKH.ma_danh_bo];
            setHistory(cached);
            calculateTieuThu(initialCsMoi, cached);
            return;
        }

        setHistoryLoading(true);
        try {
            // Load 3 history items
            const hist = await ApiService.layLichSuDoc(currentKH.ma_danh_bo, 5);

            // Filter history to ONLY include periods BEFORE the current one
            const currentKy = parseInt(currentKH.ky || '0');
            const currentNam = currentKH.nam || 0;

            const filteredHist = hist.filter((h: any) => {
                const hKy = parseInt(h.ky || '0');
                const hNam = h.nam || 0;
                if (hNam < currentNam) return true;
                if (hNam === currentNam && hKy < currentKy) return true;
                return false;
            }).slice(0, 3);

            const paddedHist = [...filteredHist];
            while (paddedHist.length < 3) {
                paddedHist.push({ code: '--', chi_so: '--', tieu_thu: '--' });
            }
            setHistory(paddedHist);
            setHistoryCache(prev => ({ ...prev, [currentKH.ma_danh_bo]: paddedHist }));

            // Re-calculate consumption based on filtered history base
            calculateTieuThu(initialCsMoi, paddedHist);
        } catch (e) {
            console.error('❌ Lỗi tải dữ liệu khách hàng:', e);
            const errorHist = [{ code: '!', chi_so: 'Lỗi', tieu_thu: 'mạng' }, { code: '--', chi_so: '--', tieu_thu: '--' }, { code: '--', chi_so: '--', tieu_thu: '--' }];
            setHistory(errorHist);
        } finally {
            setHistoryLoading(false);
        }
    };

    const calculateTieuThu = (val: string, currentHistory?: any[]) => {
        const valInt = parseInt(val);
        // ALWAYS base consumption on the record's OWN chi_so_cu
        const oldInt = currentKH.chi_so_cu;

        if (!isNaN(valInt)) {
            setTieuThu(valInt > oldInt ? valInt - oldInt : 0);
        } else {
            setTieuThu(0);
        }
    };

    const calculateBill = (tt: number, gb?: string, dmStr?: string, dmhnStr?: number) => {
        let waterMoney = 0;
        let vat = 0;
        let envFee = 0;
        let envTax = 0;

        const dm = parseInt(dmStr || '0') || 0;
        const dmhn = dmhnStr || 0;

        if (gb === '11') {
            const shn = Math.min(tt, dmhn);
            let remaining = tt - shn;

            const maxShtm = Math.max(0, dm - dmhn);
            const shtm = Math.min(remaining, maxShtm);
            remaining -= shtm;

            // SHVM1 is usually DM / 2 (from 4m3 to 6m3 is 2m3 per person)
            const maxShvm1 = dm > 0 ? dm / 2 : 0;
            const shvm1 = Math.min(remaining, maxShvm1);
            remaining -= shvm1;

            const shvm2 = remaining;

            waterMoney = (shn * 6300) + (shtm * 6700) + (shvm1 * 12900) + (shvm2 * 14400);

            vat = Math.round(waterMoney * 0.05);
            envFee = Math.round(tt * 3470);
            envTax = Math.round(envFee * 0.08);
        } else {
            // Default for other GBs
            waterMoney = tt * 11566;
            vat = Math.round(waterMoney * 0.05);
            envFee = Math.round(tt * 3470);
            envTax = Math.round(envFee * 0.08);
        }

        const total = Math.round(waterMoney + vat + envFee + envTax);

        return {
            waterMoney: Math.round(waterMoney).toLocaleString('vi-VN'),
            vat: vat.toLocaleString('vi-VN'),
            envFee: envFee.toLocaleString('vi-VN'),
            envTax: envTax.toLocaleString('vi-VN'),
            total: total.toLocaleString('vi-VN')
        };
    };

    const [selectedHistory, setSelectedHistory] = useState<any>(null);

    const handleHistoryClick = (idx: number) => {
        if (idx === 3) {
            // Current input (Teal)
            if (!csMoi) return;
            setSelectedHistory({
                ky: currentKH?.ky || '01',
                nam: currentKH?.nam?.toString() || '2026',
                code: selectedCode,
                chi_so_cu: currentKH?.chi_so_cu,
                chi_so: csMoi,
                tieu_thu: tieuThu,
                hinh_anh: capturedImage,
                ngay_bd: currentKH?.ngay_bd || '--',
                ngay_kt: currentKH?.ngay_kt || '--'
            });
            setInfoModalVisible(true);
        } else if (idx === 2) {
            // Yellow Column (Latest History Relative to current record)
            const item = (history.length > 0 && history[0].chi_so !== '--') ? history[0] : {
                ky: '--', nam: '--',
                code: currentKH?.code_cu || currentKH?.code || '--',
                chi_so_cu: '--',
                chi_so: currentKH?.chi_so_cu?.toString(),
                tieu_thu: currentKH?.tieu_thu_cu?.toString() ?? '--',
                tien_nuoc: currentKH?.tien_nuoc,
                thue_gtgt: currentKH?.thue_gtgt,
                phivmt: currentKH?.phivmt,
                thue_tdvtn: currentKH?.thue_tdvtn,
                tong_cong: currentKH?.tong_cong,
                hinh_anh: null,
                ngay_bd: currentKH?.ngay_bd || '--',
                ngay_kt: currentKH?.ngay_kt || '--'
            };
            setSelectedHistory(item);
            setInfoModalVisible(true);
        } else {
            // idx=0 -> history[2], idx=1 -> history[1]
            const historyIdx = idx === 0 ? 2 : 1;
            const item = history[historyIdx];
            if (!item || item.chi_so === '--') return;
            setSelectedHistory(item);
            setInfoModalVisible(true);
        }
    };

    const handleSave = async (silent = false, useOldIndex = false) => {
        let valInt = useOldIndex ? currentKH.chi_so_cu : parseInt(csMoi);

        if (isNaN(valInt)) {
            if (!silent) {
                setDialogConfig({
                    title: 'Ghi nhanh',
                    content: `Bạn chưa nhập chỉ số mới. Bạn có muốn đánh dấu ĐÃ ĐỌC với chỉ số cũ (${currentKH.chi_so_cu}) không?`,
                    icon: 'flash',
                    iconColor: '#FF9800',
                    confirmText: 'Đồng ý',
                    cancelText: 'Bỏ qua',
                    onConfirm: async () => {
                        setDialogVisible(false);
                        await performSave(currentKH.chi_so_cu);
                    }
                });
                setDialogVisible(true);
            }
            return;
        }
        await performSave(valInt, silent);
    };
    const _takePhoto = async () => {
        const { status } = await ImagePicker.requestCameraPermissionsAsync();
        if (status !== 'granted') {
            Alert.alert('Lỗi', 'Ứng dụng cần quyền truy cập Camera để chụp ảnh!');
            return;
        }

        try {
            console.log('📸 Launching Camera...');
            const result = await ImagePicker.launchCameraAsync({
                mediaTypes: ImagePicker.MediaTypeOptions.Images,
                allowsEditing: false,
                aspect: [4, 3],
                quality: 0.8,
            });

            console.log('📸 Camera Result:', JSON.stringify(result));
            if (!result.canceled && result.assets && result.assets.length > 0) {
                const uri = result.assets[0].uri;
                console.log('📸 Photo URI success:', uri);
                setCapturedImage(uri);
            } else {
                console.log('📸 Camera cancelled or no assets');
            }
        } catch (e: any) {
            console.error('📸 Camera Error:', e);
            Alert.alert('Lỗi Camera', e.message || 'Không thể mở máy ảnh');
        }
    };

    const _pickImage = async () => {
        const { status } = await ImagePicker.requestMediaLibraryPermissionsAsync();
        if (status !== 'granted') {
            Alert.alert('Lỗi', 'Ứng dụng cần quyền truy cập Thư viện ảnh!');
            return;
        }

        try {
            console.log('🖼️ Launching Library...');
            const result = await ImagePicker.launchImageLibraryAsync({
                mediaTypes: ImagePicker.MediaTypeOptions.Images,
                allowsEditing: false,
                aspect: [4, 3],
                quality: 0.8,
            });

            console.log('🖼️ Library Result:', JSON.stringify(result));
            if (!result.canceled && result.assets && result.assets.length > 0) {
                const uri = result.assets[0].uri;
                console.log('🖼️ Picked URI success:', uri);
                setCapturedImage(uri);
            } else {
                console.log('🖼️ Library cancelled or no assets');
            }
        } catch (e: any) {
            console.error('🖼️ Library Error:', e);
            Alert.alert('Lỗi Thư viện', e.message || 'Không thể chọn ảnh');
        }
    };

    const performSave = async (val: number, silent = false) => {
        setLoading(true);
        try {
            const success = await ApiService.ghiChiSo(currentKH.ma_danh_bo, currentKH.ma_ky_doc, val, selectedCode, ghiChu, capturedImage ?? undefined);

            // Update local state for offline feedback
            const updated = [...customers];
            updated[currentIndex] = { ...currentKH, trang_thai: 1, chi_so_moi: val, ghi_chu: ghiChu, code: selectedCode, hinh_anh: capturedImage ?? undefined };
            setCustomers(updated);
            setCsMoi(val.toString());
            calculateTieuThu(val.toString());

            if (success) {
                if (!silent) Alert.alert('Thành công', 'Đã lưu chỉ số lên Server');
            } else {
                if (!silent) Alert.alert('Thông báo', 'Lưu server thất bại. Dữ liệu đã lưu tạm thời trên máy.');
            }
            // Save to local SQLite
            await DatabaseHelper.capNhatChiSo(currentKH.ma_danh_bo, val, capturedImage ?? '', ghiChu, selectedCode);
        } catch (e) {
            if (!silent) Alert.alert('Lỗi', 'Không thể kết nối tới server.');
        } finally {
            setLoading(false);
        }
    };

    const handleUnmark = async () => {
        setDialogConfig({
            title: 'Xác nhận',
            content: 'Bạn có muốn hủy trạng thái ĐÃ ĐỌC của khách hàng này?',
            icon: 'help-circle',
            iconColor: '#FF9800',
            confirmText: 'Đồng ý',
            cancelText: 'Bỏ qua',
            onConfirm: async () => {
                setDialogVisible(false);
                setLoading(true);
                try {
                    const success = await ApiService.huyDocSo(currentKH.ma_danh_bo, currentKH.ma_ky_doc);
                    if (success) {
                        const updated = [...customers];
                        updated[currentIndex] = { ...currentKH, trang_thai: 0, chi_so_moi: null };
                        setCustomers(updated);
                        setCsMoi('');
                        setTieuThu(0);
                        await DatabaseHelper.resetTrangThaiLocal(currentKH.ma_danh_bo);
                    } else {
                        Alert.alert('Lỗi', 'Không thể hủy trạng thái trên server.');
                    }
                } catch (e) {
                    Alert.alert('Lỗi', 'Có lỗi xảy ra khi hủy đọc số.');
                } finally {
                    setLoading(false);
                }
            }
        });
        setDialogVisible(true);
    };

    const handleNoteSave = async (text: string) => {
        setGhiChu(text);
        setNoteDialogVisible(false);
        const updated = [...customers];
        updated[currentIndex] = { ...currentKH, ghi_chu: text };
        setCustomers(updated);
        await ApiService.capNhatGhiChu(currentKH.ma_danh_bo, currentKH.ma_ky_doc, text);
        await DatabaseHelper.capNhatChiSo(currentKH.ma_danh_bo, currentKH.chi_so_moi || 0, currentKH.hinh_anh || '', text, currentKH.code || '40');
    };

    const getHistoryRowColor = (index: number) => {
        if (index === 0) return '#FFEBEE'; // Pink (Oldest)
        if (index === 1) return '#E3F2FD'; // Blue (Medium)
        if (index === 2) return '#FFF9C4'; // Yellow (Latest History / Old Index)
        if (index === 3) return '#B2DFDB'; // Teal (Current Input)
        return 'white';
    };

    const _saveCurrentTemp = () => {
        if (!currentKH) return;
        const updated = [...customers];
        const valInt = parseInt(csMoi);
        updated[currentIndex] = {
            ...currentKH,
            chi_so_moi: isNaN(valInt) ? currentKH.chi_so_moi : valInt,
            ghi_chu: ghiChu,
            code: selectedCode,
            hinh_anh: capturedImage ?? undefined
        };
        setCustomers(updated);
    };

    const _navigatePrevious = () => {
        if (currentIndex > 0) {
            _saveCurrentTemp();
            setCurrentIndex(prev => prev - 1);
        } else {
            UIHelper.showCustomSnackBar('Đây là khách hàng đầu tiên!');
        }
    };

    const _navigateNext = () => {
        if (currentIndex < customers.length - 1) {
            _saveCurrentTemp();
            setCurrentIndex(prev => prev + 1);
        } else {
            UIHelper.showCustomSnackBar('Đây là khách hàng cuối cùng!');
        }
    };

    return (
        <SafeAreaView style={styles.container}>
            {loading && (
                <View style={styles.loadingOverlay}>
                    <ActivityIndicator size="large" color="#2196F3" />
                </View>
            )}
            <CustomDialog visible={dialogVisible} {...dialogConfig} onCancel={() => setDialogVisible(false)} />
            <InputDialog
                visible={noteDialogVisible}
                title="Ghi Chú KH"
                initialValue={ghiChu}
                onConfirm={handleNoteSave}
                onCancel={() => setNoteDialogVisible(false)}
            />
            <OptionDialog
                visible={imageOptionVisible}
                title="Chọn nguồn ảnh"
                options={[
                    { label: 'Chụp ảnh', icon: 'camera', value: 'camera', color: '#2196F3' },
                    { label: 'Chọn từ thư viện', icon: 'images', value: 'gallery', color: '#4CAF50' },
                ]}
                onSelect={(val) => {
                    setImageOptionVisible(false);
                    // iOS needs a more significant delay sometimes
                    setTimeout(() => {
                        if (val === 'camera') _takePhoto();
                        else if (val === 'gallery') _pickImage();
                    }, Platform.OS === 'ios' ? 800 : 100);
                }}
                onCancel={() => setImageOptionVisible(false)}
            />
            <Modal visible={infoModalVisible} transparent animationType="fade" onRequestClose={() => setInfoModalVisible(false)}>
                <View style={[styles.modalOverlay, { backgroundColor: 'rgba(0,0,0,0.6)', justifyContent: 'center' }]}>
                    <View style={styles.infoPopupCard}>
                        <Text style={styles.infoPopupTitle}>Thông Tin</Text>
                        <ScrollView style={{ maxHeight: 450 }} contentContainerStyle={{ paddingBottom: 20 }}>
                            <InfoItem label="Kỳ" value={`${selectedHistory?.ky || '01'}/${selectedHistory?.nam || '2026'}`} />
                            <InfoItem label="Từ ngày" value={selectedHistory?.ngay_bd || '08/01/2026'} />
                            <InfoItem label="Đến ngày" value={selectedHistory?.ngay_kt || '08/02/2026'} />
                            <InfoItem label="MLT" value={currentKH?.ma_lo_trinh} />
                            <InfoItem label="Danh Bộ" value={currentKH?.ma_danh_bo} boldValue />
                            <InfoItem label="Khách Hàng" value={currentKH?.ten_kh} boldValue />
                            <InfoItem label="Địa Chỉ" value={currentKH?.dia_chi} />
                            <InfoItem label="Giá Biểu" value={currentKH?.gb} />
                            <InfoItem label="Định Mức" value={currentKH?.dm} />
                            <InfoItem label="Code" value={selectedHistory?.code} />
                            <InfoItem label="Chỉ Số Cũ" value={selectedHistory?.chi_so_cu || '--'} />
                            <InfoItem label="Chỉ Số Mới" value={selectedHistory?.chi_so || '--'} />
                            <InfoItem label="Tiêu Thụ" value={selectedHistory?.tieu_thu} boldValue />

                            {(() => {
                                let bd;
                                if (selectedHistory?.tong_cong !== undefined && selectedHistory?.ky === '--') {
                                    // Use exact values from database for old DocSo records
                                    bd = {
                                        waterMoney: (selectedHistory.tien_nuoc || 0).toLocaleString('vi-VN'),
                                        vat: (selectedHistory.thue_gtgt || 0).toLocaleString('vi-VN'),
                                        envFee: (selectedHistory.phivmt || 0).toLocaleString('vi-VN'),
                                        envTax: (selectedHistory.thue_tdvtn || 0).toLocaleString('vi-VN'),
                                        total: (selectedHistory.tong_cong || 0).toLocaleString('vi-VN')
                                    };
                                } else {
                                    // Provisionally calculate for new numbers
                                    bd = calculateBill(Number(selectedHistory?.tieu_thu) || 0, currentKH?.gb, currentKH?.dm?.toString(), currentKH?.dmhn);
                                }
                                return (
                                    <>
                                        <InfoItem label="Tiền Nước" value={`${bd.waterMoney}`} />
                                        <InfoItem label="Thuế GTGT" value={`${bd.vat}`} />
                                        <InfoItem label="TDVTN" value={`${bd.envFee}`} />
                                        <InfoItem label="Thuế TDVTN" value={`${bd.envTax}`} />
                                        <InfoItem label="Tổng Cộng" value={`${bd.total}`} boldValue />
                                    </>
                                );
                            })()}

                            {selectedHistory?.hinh_anh && (
                                <View style={{ alignItems: 'center', marginTop: 10 }}>
                                    <Image source={{ uri: selectedHistory.hinh_anh }} style={styles.infoPopupImg} resizeMode="contain" />
                                </View>
                            )}
                        </ScrollView>
                        <TouchableOpacity style={styles.infoPopupClose} onPress={() => setInfoModalVisible(false)}>
                            <Text style={styles.infoPopupCloseTxt}>Đóng</Text>
                        </TouchableOpacity>
                    </View>
                </View>
            </Modal>
            <OptionDialog
                visible={codeModalVisible}
                title="Chọn mã Code"
                options={codeOptions}
                onSelect={(val) => {
                    setSelectedCode(val);
                    setCodeModalVisible(false);
                }}
                onCancel={() => setCodeModalVisible(false)}
            />

            <KeyboardAvoidingView behavior={Platform.OS === 'ios' ? 'padding' : undefined} style={{ flex: 1 }}>
                <ScrollView contentContainerStyle={styles.scrollContent}>
                    {/* Header: Rich Text Parity */}
                    <View style={styles.headerRow}>
                        <Text style={styles.headerLabel}>MLT: <Text style={styles.headerValBlue}>{currentKH?.ma_lo_trinh}</Text></Text>
                        <View style={styles.statusBox}>
                            <Checkbox
                                value={currentKH?.trang_thai === 1}
                                onValueChange={(val) => val ? handleSave(true) : handleUnmark()}
                                color={currentKH?.trang_thai === 1 ? '#2196F3' : undefined}
                                style={{ margin: 8 }}
                            />
                            <Text style={styles.statusTxt}>Đã đọc</Text>
                        </View>
                    </View>

                    <Text style={styles.headerLabel}>Danh Bộ: <Text style={styles.danhBoVal}>{currentKH?.ma_danh_bo}</Text></Text>

                    <View style={styles.infoRow}>
                        <Text style={styles.infoLabel}>Hiệu: <Text style={styles.infoValBold}>{currentKH?.hieu || '--'}</Text></Text>
                        <Text style={styles.infoLabel}>Cỡ: <Text style={styles.infoValBold}>{currentKH?.co || '15'}</Text></Text>
                        <Text style={styles.infoLabel}>Số Thân: <Text style={styles.infoValSemibold}>{currentKH?.so_than || '--'}</Text></Text>
                    </View>

                    <Text style={styles.infoLabel}>Địa Chi: <Text style={styles.infoValSemibold}>{currentKH?.dia_chi}</Text></Text>
                    <Text style={styles.infoLabel}>SĐT: <Text style={styles.infoValBlueSmall}>{currentKH?.sdt || '--'}</Text></Text>
                    <Text style={styles.infoLabel}>Họ Tên: <Text style={styles.infoValSemibold}>{(currentKH?.ten_kh || '').toUpperCase()}</Text></Text>

                    {/* Billing Details Row */}
                    <View style={styles.billingRow}>
                        <View style={styles.billItem}><Text style={styles.billLabel}>GB</Text><Text style={styles.billValRed}>{currentKH?.gb || '--'}</Text></View>
                        <View style={styles.billItem}><Text style={styles.billLabel}>ĐM</Text><Text style={styles.billVal}>{currentKH?.dm || '--'}</Text></View>
                        <View style={styles.billItem}><Text style={styles.billLabel}>ĐMHN</Text><Text style={styles.billVal}>{currentKH?.dmhn || '0'}</Text></View>
                        <View style={styles.billItem}><Text style={styles.billLabel}>TBTT</Text><Text style={styles.billValRed}>{currentKH?.tbtt || '0'}</Text></View>
                    </View>

                    {/* Orange Note Box matches Flutter exactly */}
                    <TouchableOpacity style={styles.noteBox} onPress={() => setNoteDialogVisible(true)}>
                        <Ionicons name="create-outline" size={20} color="orange" />
                        <View style={{ marginLeft: 8, flex: 1 }}>
                            <Text style={styles.noteTitle}>Ghi Chú:</Text>
                            {currentKH?.ghi_chu_kh ? (
                                <Text style={[styles.noteTxt, { color: '#D84315', marginBottom: 2 }]} numberOfLines={2}>
                                    [KH] {currentKH.ghi_chu_kh}
                                </Text>
                            ) : null}
                            <Text style={ghiChu ? styles.noteTxt : styles.noteHint} numberOfLines={1}>
                                {ghiChu || 'Chưa có ghi chú (Chạm để sửa)'}
                            </Text>
                        </View>
                    </TouchableOpacity>

                    <View style={styles.divider} />

                    <Text style={styles.secTitle}>Tình Trạng</Text>

                    {/* Stat Boxes with specific opacities and colors */}
                    <View style={styles.statsRow}>
                        <View style={[styles.statBox, styles.statBoxBlue]}>
                            <Text style={styles.statLabelBlue}>CS Cũ</Text>
                            <Text style={styles.statValBlue}>
                                {currentKH?.chi_so_cu ?? '--'}
                            </Text>
                        </View>
                        <View style={[styles.statBox, styles.statBoxOrange]}>
                            <Text style={styles.statLabelOrange}>Tiêu thụ</Text>
                            <Text style={styles.statValOrange}>{tieuThu}</Text>
                        </View>
                    </View>

                    {/* Colored History Table parity */}
                    {/* Colored History Table parity */}
                    <View style={styles.table}>
                        {historyLoading && (
                            <View style={styles.tableLoading}>
                                <ActivityIndicator size="small" color="#2196F3" />
                            </View>
                        )}
                        <View style={styles.tableRow}>
                            <View style={[styles.cell, styles.headerCell]}>
                                <Text style={styles.headerCellTxt}>Code</Text>
                            </View>
                            {[0, 1, 2, 3].map(i => {
                                // Teal (i=3) Empty until csMoi, Yellow (i=2) Fallback to currentKH.code
                                let val = '--';
                                if (i === 3) val = csMoi ? selectedCode : '--';
                                else if (i === 2) val = (history[0]?.code !== '--' ? history[0]?.code : (currentKH?.code_cu || currentKH?.code)) || '--';
                                else if (i === 1) val = history[1]?.code || '--';
                                else if (i === 0) val = history[2]?.code || '--';

                                return (
                                    <TouchableOpacity
                                        key={i}
                                        style={[styles.cell, { backgroundColor: getHistoryRowColor(i) }]}
                                        onPress={() => handleHistoryClick(i)}
                                    >
                                        <Text style={styles.cellTxt}>{val}</Text>
                                    </TouchableOpacity>
                                );
                            })}
                        </View>
                        <View style={styles.tableRow}>
                            <View style={[styles.cell, styles.headerCell]}>
                                <Text style={styles.headerCellTxt}>Chỉ số</Text>
                            </View>
                            {[0, 1, 2, 3].map(i => {
                                // Teal (i=3) Empty until csMoi, Yellow (i=2) Fallback to currentKH.chi_so_cu
                                let val = '--';
                                if (i === 3) val = csMoi || '--';
                                else if (i === 2) val = (history[0]?.chi_so !== '--' ? history[0]?.chi_so : currentKH?.chi_so_cu?.toString()) || '--';
                                else if (i === 1) val = history[1]?.chi_so || '--';
                                else if (i === 0) val = history[2]?.chi_so || '--';

                                return (
                                    <TouchableOpacity
                                        key={i}
                                        style={[styles.cell, { backgroundColor: getHistoryRowColor(i) }]}
                                        onPress={() => handleHistoryClick(i)}
                                    >
                                        <Text style={styles.cellTxt}>{val}</Text>
                                    </TouchableOpacity>
                                );
                            })}
                        </View>
                        <View style={styles.tableRow}>
                            <View style={[styles.cell, styles.headerCell]}>
                                <Text style={styles.headerCellTxt}>Tiêu thụ</Text>
                            </View>
                            {[0, 1, 2, 3].map(i => {
                                // Teal (i=3) Empty until csMoi, Yellow (i=2) Consumption
                                let val: any = '--';
                                let hasPhoto = false;

                                if (i === 3) {
                                    val = csMoi ? tieuThu : '--';
                                    hasPhoto = !!capturedImage && !!csMoi;
                                } else if (i === 2) {
                                    val = (history[0]?.tieu_thu && history[0]?.tieu_thu !== '--') ? history[0]?.tieu_thu : (currentKH?.tieu_thu_cu ?? '--');
                                    hasPhoto = !!history[0]?.hinh_anh && history[0]?.hinh_anh !== '--';
                                } else if (i === 1) {
                                    val = history[1]?.tieu_thu || '--';
                                    hasPhoto = !!history[1]?.hinh_anh && history[1]?.hinh_anh !== '--';
                                } else if (i === 0) {
                                    val = history[2]?.tieu_thu || '--';
                                    hasPhoto = !!history[2]?.hinh_anh && history[2]?.hinh_anh !== '--';
                                }

                                return (
                                    <TouchableOpacity
                                        key={i}
                                        style={[styles.cell, { backgroundColor: getHistoryRowColor(i) }]}
                                        onPress={() => handleHistoryClick(i)}
                                    >
                                        <View style={{ flexDirection: 'row', alignItems: 'center' }}>
                                            <Text style={styles.cellTxt}>{val === 0 ? '0' : val}</Text>
                                            {hasPhoto && <Ionicons name="camera" size={14} color="#2196F3" style={{ marginLeft: 4 }} />}
                                        </View>
                                    </TouchableOpacity>
                                );
                            })}
                        </View>
                    </View>

                    <View style={{ height: 16 }} />

                    {/* CSM Input row with tooltip and Camera popup parity */}
                    <View style={styles.inputRow}>
                        <View style={{ width: 100 }}>
                            <Text style={styles.inputLabel}>Code</Text>
                            <TouchableOpacity
                                style={styles.pickerWrapper}
                                onPress={() => setCodeModalVisible(true)}
                            >
                                <Text style={[styles.pickerText, { color: selectedCode === 'F' ? 'red' : selectedCode === '6' ? 'orange' : '#333' }]}>
                                    {selectedCode}
                                </Text>
                                <Ionicons name="chevron-down" size={16} color="#666" />
                            </TouchableOpacity>
                            <Text style={styles.codeSub}>
                                {selectedCode === '40' ? 'ĐH bình\nthường' : selectedCode === 'F' ? 'ĐH hỏng' : selectedCode === '6' ? 'Khóa nước' : selectedCode === '10' ? 'ĐH ngược' : 'Nhà trống'}
                            </Text>
                        </View>

                        <View style={{ flex: 1, marginLeft: 20 }}>
                            <View style={styles.csmHeader}>
                                <Text style={styles.inputLabel}>CSM</Text>
                                <TouchableOpacity onPress={() => setImageOptionVisible(true)} style={styles.camBtn}>
                                    <Ionicons name="camera" size={24} color="#666" />
                                </TouchableOpacity>
                                {capturedImage && (
                                    <View style={styles.thumbWrapper}>
                                        <Image source={{ uri: capturedImage }} style={styles.thumb} />
                                        <TouchableOpacity style={styles.closeThumb} onPress={() => setCapturedImage(null)}>
                                            <Ionicons name="close-circle" size={20} color="red" />
                                        </TouchableOpacity>
                                    </View>
                                )}
                            </View>
                            <TextInput
                                style={styles.csmInput}
                                value={csMoi}
                                onChangeText={v => { setCsMoi(v); calculateTieuThu(v); }}
                                keyboardType="numeric"
                                placeholder="0"
                            />
                        </View>
                    </View>
                </ScrollView>
            </KeyboardAvoidingView>

            {/* Bottom Navigation Buttons matches Flutter exactly */}
            <View style={styles.bottomNav}>
                <TouchableOpacity style={styles.navBtn} onPress={_navigatePrevious}>
                    <Ionicons name="chevron-back" size={22} color="#555" />
                    <Text style={styles.navBtnTxt}>Trước</Text>
                </TouchableOpacity>
                <TouchableOpacity style={styles.navBtn} onPress={_navigateNext}>
                    <Ionicons name="chevron-forward" size={22} color="#555" />
                    <Text style={styles.navBtnTxt}>Sau</Text>
                </TouchableOpacity>
                <TouchableOpacity style={styles.navBtn} onPress={() => Alert.alert('PC', 'Mở chia sẻ dữ liệu CSV')}>
                    <Ionicons name="share-social" size={22} color="teal" />
                    <Text style={styles.navBtnTxt}>PC</Text>
                </TouchableOpacity>
                <TouchableOpacity style={styles.navBtn} onPress={() => setNoteDialogVisible(true)}>
                    <Ionicons name="create" size={22} color="#B8860B" />
                    <Text style={styles.navBtnTxt}>Ghi Chú</Text>
                </TouchableOpacity>
                <TouchableOpacity style={styles.navBtn} onPress={() => Alert.alert('In', 'In biên nhận tạm tính')}>
                    <Ionicons name="print" size={22} color="purple" />
                    <Text style={styles.navBtnTxt}>In</Text>
                </TouchableOpacity>
                <TouchableOpacity style={styles.navBtn} onPress={() => handleSave()}>
                    <Ionicons name="save" size={22} color="#1565C0" />
                    <Text style={[styles.navBtnTxt, { color: '#1565C0' }]}>Lưu</Text>
                </TouchableOpacity>
            </View>
        </SafeAreaView >
    );
};

const styles = StyleSheet.create({
    container: { flex: 1, backgroundColor: 'white' },
    scrollContent: { padding: 16 },
    headerRow: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', marginBottom: 8 },
    headerLabel: { fontSize: 15, color: '#424242', fontWeight: '600', marginBottom: 4 },
    headerValBlue: { fontSize: 18, color: '#2196F3', fontWeight: 'bold' },
    danhBoVal: { fontSize: 22, color: '#2196F3', fontWeight: 'bold' },
    statusBox: { flexDirection: 'row', alignItems: 'center', borderWidth: 1, borderColor: '#DDD', borderRadius: 4, paddingRight: 8 },
    statusTxt: { fontSize: 13, color: '#424242', fontWeight: '500' },

    infoRow: { flexDirection: 'row', justifyContent: 'space-between', marginTop: 4 },
    infoLabel: { fontSize: 13, color: '#424242', fontWeight: '500', marginBottom: 2 },
    infoValBold: { fontSize: 14, fontWeight: 'bold', color: 'black' },
    infoValSemibold: { fontSize: 13, fontWeight: '600', color: 'black' },
    infoValBlueSmall: { fontSize: 13, fontWeight: '600', color: '#2196F3' },

    billingRow: { flexDirection: 'row', justifyContent: 'space-between', paddingVertical: 8, borderTopWidth: 1, borderTopColor: '#EEE', marginTop: 8 },
    billItem: { flexDirection: 'row', alignItems: 'center' },
    billLabel: { fontSize: 12, color: '#757575', marginRight: 4 },
    billVal: { fontSize: 15, fontWeight: '700', color: '#333' },
    billValRed: { fontSize: 16, fontWeight: '800', color: '#F44336' },

    noteBox: { marginTop: 8, padding: 12, borderRadius: 8, backgroundColor: '#FFF3E0', flexDirection: 'row', borderWidth: 1, borderColor: '#FF980033' },
    noteTitle: { fontSize: 13, fontWeight: 'bold', color: '#E65100' },
    noteTxt: { fontSize: 14, color: '#333', fontStyle: 'italic' },
    noteHint: { fontSize: 14, color: '#999', fontStyle: 'italic' },

    divider: { height: 1, backgroundColor: '#EEE', marginVertical: 16 },
    secTitle: { fontSize: 14, color: '#757575', fontWeight: '600', marginBottom: 8 },

    statsRow: { flexDirection: 'row', justifyContent: 'space-around', marginBottom: 16 },
    statBox: { width: 110, padding: 12, borderRadius: 8, alignItems: 'center', borderWidth: 1 },
    statBoxBlue: { backgroundColor: '#2196F315', borderColor: '#2196F34D' },
    statBoxOrange: { backgroundColor: '#FF980015', borderColor: '#FF98004D' },
    statLabelBlue: { fontSize: 13, color: '#2196F3', fontWeight: 'bold' },
    statValBlue: { fontSize: 20, color: '#2196F3', fontWeight: 'bold' },
    statLabelOrange: { fontSize: 13, color: '#FF9800', fontWeight: 'bold' },
    statValOrange: { fontSize: 20, color: '#FF9800', fontWeight: 'bold' },

    table: { borderWidth: 1.5, borderColor: '#9E9E9E', borderRadius: 4, overflow: 'hidden', backgroundColor: 'white' },
    tableRow: { flexDirection: 'row', borderBottomWidth: 1.5, borderBottomColor: '#9E9E9E' },
    cell: { flex: 1, height: 50, justifyContent: 'center', alignItems: 'center', borderRightWidth: 1.5, borderRightColor: '#9E9E9E' },
    headerCell: { backgroundColor: '#ECEFF1', flex: 0.9 },
    cellTxt: { fontSize: 16, color: '#212121', fontWeight: '500' },
    headerCellTxt: { fontSize: 15, fontWeight: 'bold', color: '#455A64' },

    inputRow: { flexDirection: 'row', marginTop: 16 },
    inputLabel: { fontSize: 14, fontWeight: 'bold', color: '#616161', marginBottom: 4 },
    pickerWrapper: {
        borderWidth: 1,
        borderColor: '#DDD',
        borderRadius: 4,
        height: 44,
        flexDirection: 'row',
        alignItems: 'center',
        paddingHorizontal: 12,
        justifyContent: 'space-between',
        backgroundColor: '#F9F9F9'
    },
    pickerText: { fontSize: 18, fontWeight: 'bold' },
    codeSub: { fontSize: 11, color: '#9E9E9E', fontStyle: 'italic', marginTop: 4, lineHeight: 14 },

    csmHeader: { flexDirection: 'row', alignItems: 'center', gap: 10, marginBottom: 4 },
    camBtn: { width: 44, height: 44, borderRadius: 8, backgroundColor: '#EEEEEE', justifyContent: 'center', alignItems: 'center' },
    thumbWrapper: { position: 'relative', marginLeft: 10 },
    thumb: { width: 70, height: 70, borderRadius: 8, borderWidth: 2, borderColor: '#4CAF50' },
    closeThumb: { position: 'absolute', top: -10, right: -10 },
    csmInput: { borderBottomWidth: 3, borderBottomColor: '#FF4081', fontSize: 32, fontWeight: 'bold', paddingVertical: 4, color: '#333' },

    bottomNav: { height: 60, backgroundColor: '#F5F5F5', borderTopWidth: 1, borderTopColor: '#DDD', flexDirection: 'row', justifyContent: 'space-evenly' },
    navBtn: { justifyContent: 'center', alignItems: 'center', paddingHorizontal: 4 },
    navBtnTxt: { fontSize: 11, fontWeight: 'bold', color: '#555', marginTop: 2 },
    loadingOverlay: {
        ...StyleSheet.absoluteFillObject,
        backgroundColor: 'rgba(255,255,255,0.7)',
        justifyContent: 'center',
        alignItems: 'center',
        zIndex: 999
    },
    modalOverlay: { flex: 1, backgroundColor: 'rgba(0,0,0,0.5)', justifyContent: 'center', alignItems: 'center', padding: 20 },
    infoPopupCard: { backgroundColor: 'white', borderRadius: 12, padding: 20, width: '90%', elevation: 10 },
    infoPopupTitle: { fontSize: 20, fontWeight: 'bold', color: '#333', marginBottom: 20, textAlign: 'center' },
    infoPopupRow: { flexDirection: 'row', justifyContent: 'space-between', paddingVertical: 6, borderBottomWidth: 0.5, borderBottomColor: '#EEE' },
    infoPopupLabel: { fontSize: 15, color: '#666' },
    infoPopupVal: { fontSize: 16, color: '#333', textAlign: 'right', flex: 1, marginLeft: 10 },
    infoPopupImg: { width: '100%', height: 200, borderRadius: 8, marginTop: 15 },
    infoPopupClose: { backgroundColor: '#2196F3', padding: 12, borderRadius: 8, marginTop: 20, alignItems: 'center' },
    infoPopupCloseTxt: { color: 'white', fontWeight: 'bold', fontSize: 16 },
    tableLoading: {
        position: 'absolute',
        top: 0,
        left: 0,
        right: 0,
        bottom: 0,
        backgroundColor: 'rgba(255,255,255,0.7)',
        zIndex: 10,
        justifyContent: 'center',
        alignItems: 'center',
    },
});

export default GhiNuocScreen;
