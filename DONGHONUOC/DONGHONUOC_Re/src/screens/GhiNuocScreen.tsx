import React, { useState, useEffect } from 'react';
import {
    StyleSheet, View, Text, TouchableOpacity, TextInput, ScrollView,
    SafeAreaView, ActivityIndicator, Alert, KeyboardAvoidingView, Platform, Image
} from 'react-native';
import { useRoute, useNavigation } from '@react-navigation/native';
import { Ionicons } from '@expo/vector-icons';
import Checkbox from 'expo-checkbox';
import { Picker } from '@react-native-picker/picker';
import ApiService from '../services/ApiService';
import DatabaseHelper from '../helpers/DatabaseHelper';
import CustomDialog from '../components/common/CustomDialog';
import InputDialog from '../components/common/InputDialog';
import OptionDialog from '../components/common/OptionDialog';

interface Customer {
    ma_danh_bo: string;
    ten_kh: string;
    ma_lo_trinh: string;
    dia_chi: string;
    chi_so_cu: number;
    chi_so_moi?: number | null;
    trang_thai: number;
    ma_ky_doc: number;
    ghi_chu?: string;
    code?: string;
    hinh_anh?: string;
}

const GhiNuocScreen = () => {
    const route = useRoute<any>();
    const navigation = useNavigation();
    const { customers: initialCustomers, index: initialIndex } = route.params;

    const [customers, setCustomers] = useState<Customer[]>(initialCustomers);
    const [currentIndex, setCurrentIndex] = useState(initialIndex);
    const [history, setHistory] = useState<any[]>([]);
    const [tieuThu, setTieuThu] = useState(0);
    const [capturedImage, setCapturedImage] = useState<string | null>(null);
    const [selectedCode, setSelectedCode] = useState('40');

    // Input Controllers
    const [csMoi, setCsMoi] = useState('');
    const [ghiChu, setGhiChu] = useState('');

    // Modal & Loading States
    const [loading, setLoading] = useState(false);
    const [dialogVisible, setDialogVisible] = useState(false);
    const [dialogConfig, setDialogConfig] = useState<any>({});
    const [noteDialogVisible, setNoteDialogVisible] = useState(false);
    const [imageOptionVisible, setImageOptionVisible] = useState(false);

    const currentKH = customers[currentIndex];

    useEffect(() => {
        loadData();
    }, [currentIndex]);

    const loadData = async () => {
        if (!currentKH) return;
        setLoading(true);
        try {
            setCsMoi(currentKH.chi_so_moi?.toString() ?? '');
            setGhiChu(currentKH.ghi_chu ?? '');
            setSelectedCode(currentKH.code ?? '40');
            setCapturedImage(currentKH.hinh_anh ?? null);
            calculateTieuThu(currentKH.chi_so_moi?.toString() ?? '');

            // Load 3 history items
            const hist = await ApiService.layLichSuDoc(currentKH.ma_danh_bo, 3);
            const paddedHist = [...hist];
            while (paddedHist.length < 3) {
                paddedHist.push({ code: '--', chi_so: '--', tieu_thu: '--' });
            }
            setHistory(paddedHist);
        } catch (e) {
            console.error('❌ Lỗi tải dữ liệu khách hàng:', e);
        } finally {
            setLoading(false);
        }
    };

    const calculateTieuThu = (val: string) => {
        const valInt = parseInt(val);
        const oldInt = currentKH.chi_so_cu;
        if (!isNaN(valInt)) {
            setTieuThu(valInt > oldInt ? valInt - oldInt : 0);
        } else {
            setTieuThu(0);
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
        switch (index) {
            case 0: return '#EF9A9A'; // Reddish
            case 1: return '#90CAF9'; // Bluish
            case 2: return '#E6EE9C'; // Yellowish
            default: return 'transparent';
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
                onSelect={(val) => { setImageOptionVisible(false); Alert.alert('Thông báo', 'Mocking camera/gallery process'); }}
                onCancel={() => setImageOptionVisible(false)}
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
                        <Text style={styles.infoLabel}>Hiệu: <Text style={styles.infoValBold}>{currentKH?.ten_kh}</Text></Text>
                        <Text style={styles.infoLabel}>Cỡ: <Text style={styles.infoValBold}>15</Text></Text>
                    </View>

                    <Text style={styles.infoLabel}>Địa Chỉ: <Text style={styles.infoValSemibold}>{currentKH?.dia_chi}</Text></Text>
                    <Text style={styles.infoLabel}>Địa Chỉ DHN: <Text style={styles.infoValBlueSmall}>{currentKH?.dia_chi}</Text></Text>
                    <Text style={styles.infoLabel}>Họ Tên: <Text style={styles.infoValSemibold}>{(currentKH?.ten_kh || '').toUpperCase()}</Text></Text>

                    {/* Orange Note Box matches Flutter exactly */}
                    <TouchableOpacity style={styles.noteBox} onPress={() => setNoteDialogVisible(true)}>
                        <Ionicons name="create-outline" size={20} color="orange" />
                        <View style={{ marginLeft: 8, flex: 1 }}>
                            <Text style={styles.noteTitle}>Ghi Chú:</Text>
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
                            <Text style={styles.statValBlue}>{currentKH?.chi_so_cu}</Text>
                        </View>
                        <View style={[styles.statBox, styles.statBoxOrange]}>
                            <Text style={styles.statLabelOrange}>Tiêu thụ</Text>
                            <Text style={styles.statValOrange}>{tieuThu}</Text>
                        </View>
                    </View>

                    {/* Colored History Table parity */}
                    <View style={styles.table}>
                        <View style={styles.tableRow}>
                            <Text style={[styles.cell, styles.headerCell]}>Code</Text>
                            {[0, 1, 2].map(i => (
                                <View key={i} style={[styles.cell, { backgroundColor: getHistoryRowColor(i) }]}>
                                    <Text style={styles.cellTxt}>{history[i]?.code || '--'}</Text>
                                </View>
                            ))}
                        </View>
                        <View style={styles.tableRow}>
                            <Text style={[styles.cell, styles.headerCell]}>Chỉ số</Text>
                            {[0, 1, 2].map(i => (
                                <View key={i} style={[styles.cell, { backgroundColor: getHistoryRowColor(i) }]}>
                                    <Text style={styles.cellTxt}>{history[i]?.chi_so || '--'}</Text>
                                </View>
                            ))}
                        </View>
                        <View style={styles.tableRow}>
                            <Text style={[styles.cell, styles.headerCell]}>Tiêu thụ</Text>
                            {[0, 1, 2].map(i => (
                                <View key={i} style={[styles.cell, { backgroundColor: getHistoryRowColor(i) }]}>
                                    <Text style={styles.cellTxt}>{history[i]?.tieu_thu || '--'}</Text>
                                </View>
                            ))}
                        </View>
                    </View>

                    <View style={{ height: 16 }} />

                    {/* CSM Input row with tooltip and Camera popup parity */}
                    <View style={styles.inputRow}>
                        <View style={{ width: 80 }}>
                            <Text style={styles.inputLabel}>Code</Text>
                            <View style={styles.pickerWrapper}>
                                <Picker
                                    selectedValue={selectedCode}
                                    onValueChange={v => setSelectedCode(v)}
                                    style={styles.picker}
                                >
                                    <Picker.Item label="40" value="40" />
                                    <Picker.Item label="F" value="F" color="red" />
                                    <Picker.Item label="6" value="6" color="orange" />
                                    <Picker.Item label="10" value="10" />
                                    <Picker.Item label="20" value="20" />
                                </Picker>
                            </View>
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
                <TouchableOpacity style={styles.navBtn} onPress={() => currentIndex > 0 && setCurrentIndex(currentIndex - 1)}>
                    <Ionicons name="chevron-back" size={22} color="#555" />
                    <Text style={styles.navBtnTxt}>Trước</Text>
                </TouchableOpacity>
                <TouchableOpacity style={styles.navBtn} onPress={() => currentIndex < customers.length - 1 && setCurrentIndex(currentIndex + 1)}>
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
        </SafeAreaView>
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
    infoLabel: { fontSize: 15, color: '#424242', fontWeight: '600', marginBottom: 2 },
    infoValBold: { fontSize: 16, fontWeight: 'bold', color: 'black' },
    infoValSemibold: { fontSize: 14, fontWeight: '600', color: 'black' },
    infoValBlueSmall: { fontSize: 14, fontWeight: '600', color: '#2196F3' },

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

    table: { borderWidth: 1.5, borderColor: '#BDBDBD', borderRadius: 2, overflow: 'hidden' },
    tableRow: { flexDirection: 'row', borderBottomWidth: 1, borderBottomColor: '#BDBDBD' },
    cell: { flex: 1, height: 45, justifyContent: 'center', alignItems: 'center', borderRightWidth: 1, borderRightColor: '#BDBDBD' },
    headerCell: { backgroundColor: '#F5F5F5' },
    cellTxt: { fontSize: 16, color: '#333' },

    inputRow: { flexDirection: 'row', marginTop: 16 },
    inputLabel: { fontSize: 14, fontWeight: 'bold', color: '#616161', marginBottom: 4 },
    pickerWrapper: { borderWidth: 1, borderColor: '#DDD', borderRadius: 4, height: 40, justifyContent: 'center' },
    picker: { width: '100%', height: 40 },
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
});

export default GhiNuocScreen;
