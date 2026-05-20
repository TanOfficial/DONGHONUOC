console.log('📱 DANH SACH KH SCREEN LOADED');
import React, { useState, useEffect, useCallback, useRef } from 'react';
import { 
    StyleSheet, View, Text, FlatList, TextInput,
    TouchableOpacity, ActivityIndicator, SafeAreaView, Modal, Alert, ScrollView, Platform, ActionSheetIOS
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useNavigation } from '@react-navigation/native';
import { StackNavigationProp } from '@react-navigation/stack';
import { RootStackParamList } from '../navigation/AppNavigator';
import ApiService from '../services/ApiService';
import UIHelper from '../helpers/UIHelper';
import DatabaseHelper from '../helpers/DatabaseHelper';
import * as DocumentPicker from 'expo-document-picker';
import * as FileSystem from 'expo-file-system';
import { Picker } from '@react-native-picker/picker';

interface Customer {
    ma_danh_bo: string;
    ten_kh: string;
    dia_chi: string;
    ma_lo_trinh: string;
    chi_so_cu: number;
    chi_so_moi?: number;
    tieu_thu?: number;
    trang_thai: number;
    code: string;
    ma_ky_doc: number;
    ghi_chu?: string;
    hinh_anh?: string;
    hieu?: string;
    co?: string;
    so_than?: string;
    sdt?: string;
    gb?: string;
    dm?: string;
    dmhn?: number;
    tbtt?: number;
    _abnormal?: string | null;
    _percent?: number;
}

type DanhSachKHNavigationProp = StackNavigationProp<RootStackParamList, 'DanhSachKH'>;

const FILTER_OPTIONS = ['Tất cả', 'F', '6', 'Bất Thường Tăng', 'Bất Thường Giảm', 'Chủ Báo', 'Chưa Gửi TB', '10%', '20%', '30%', '40%', '50%'];
const SORT_OPTIONS = ['MLT', 'Thời Gian Tăng', 'Thời Gian Giảm'];

import CustomDialog from '../components/common/CustomDialog';
import OptionDialog, { DialogOption } from '../components/common/OptionDialog';

const DanhSachKHScreen = () => {
    console.log('⚛️ Rendering DanhSachKHScreen');
    const navigation = useNavigation<DanhSachKHNavigationProp>();
    const [customers, setCustomers] = useState<Customer[]>([]);
    const [loading, setLoading] = useState(false);
    const [refreshing, setRefreshing] = useState(false);
    const [page, setPage] = useState(1);
    const [hasMore, setHasMore] = useState(true);
    const [search, setSearch] = useState('');
    const [showSearch, setShowSearch] = useState(false);
    const [maKyDoc, setMaKyDoc] = useState<number | null>(null);
    const [filterStatus, setFilterStatus] = useState(0); // 0: Tất cả, 1: Chưa Đọc, 2: Đã Đọc
    const [filterType, setFilterType] = useState('Tất cả');
    const [sortType, setSortType] = useState('MLT');
    const [filterSortVisible, setFilterSortVisible] = useState(false);
    const [showScrollTop, setShowScrollTop] = useState(false);
    const flatListRef = useRef<FlatList>(null);

    // Custom Component States
    const [ipModalVisible, setIpModalVisible] = useState(false);
    const [ipInput, setIpInput] = useState('');
    const [dialogVisible, setDialogVisible] = useState(false);
    const [dialogConfig, setDialogConfig] = useState<any>({});
    const [menuVisible, setMenuVisible] = useState(false);

    // Download & CSV States
    const [downloadDialogVisible, setDownloadDialogVisible] = useState(false);
    const [kyDocList, setKyDocList] = useState<any[]>([]);
    const [dotList, setDotList] = useState<string[]>([]);
    const [mayList, setMayList] = useState<string[]>(['01', '02', '03', '04', '05', '17', '23', '26', '55']);
    const [selectedTo, setSelectedTo] = useState('Tân Phú 1');
    const [selectedMay, setSelectedMay] = useState('01');
    const [selectedDot, setSelectedDot] = useState('01');
    const [selectedNam, setSelectedNam] = useState(new Date().getFullYear().toString());

    const init = async () => {
        if (loading) return;
        setLoading(true);
        try {
            console.log('🔄 Initializing DanhSachKHScreen (Sync Flow)...');
            const kyDocs = await ApiService.layDanhSachKyDoc();
            console.log('📋 kyDocs count:', kyDocs?.length);

            if (kyDocs && kyDocs.length > 0) {
                setKyDocList(kyDocs);
                
                // Trình tự mới: Không tự động tìm kỳ có dữ liệu và tải về nữa.
                // Chỉ thiết lập kỳ hiện tại dựa trên kỳ đầu tiên trong danh sách.
                const firstKy = kyDocs[0];
                const defaultKyId = firstKy.MaKyDoc ?? firstKy.maKyDoc ?? firstKy.ID ?? firstKy.id;
                if (defaultKyId) {
                    setMaKyDoc(defaultKyId);
                    console.log(`📡 Default Ky set to: ${defaultKyId}. Waiting for manual download.`);
                }
            } else {
                console.warn('⚠️ No kyDocs returned from API');
            }
        } catch (e) {
            console.error('❌ Error during init:', e);
            UIHelper.showCustomSnackBar('Không thể tải danh sách kỳ đọc', true);
        } finally {
            setLoading(false);
            console.log('🏁 Initialization finished');
        }
    };

    useEffect(() => {
        init();
    }, []);

    useEffect(() => {
        const fetchFilters = async () => {
            if (maKyDoc && downloadDialogVisible) {
                console.log(`🔄 Fetching dynamic filters for MaKyDoc: ${maKyDoc}`);
                const filters = await ApiService.layFiltersTheoKy(maKyDoc);
                
                if (filters.dots && filters.dots.length > 0) {
                    setDotList(filters.dots);
                    if (!filters.dots.includes(selectedDot)) setSelectedDot(filters.dots[0]);
                } else {
                    setDotList([]);
                    setSelectedDot('');
                }

                if (filters.mays && filters.mays.length > 0) {
                    setMayList(filters.mays);
                    if (!filters.mays.includes(selectedMay)) setSelectedMay(filters.mays[0]); // Auto select first valid machine
                } else {
                    setMayList([]);
                    setSelectedMay('');
                }
            }
        };
        fetchFilters();
    }, [maKyDoc, downloadDialogVisible]);

    const fetchCustomers = async (kyId: number, pageNum: number, reset = false) => {
        console.log('🔍 fetchCustomers trigger:', { kyId, pageNum, reset, currentMaKyDoc: maKyDoc });
        if (!kyId || loading) return;

        // Ensure page update is clean
        if (reset) {
            setPage(1);
            flatListRef.current?.scrollToOffset({ offset: 0, animated: true });
        } else {
            flatListRef.current?.scrollToOffset({ offset: 0, animated: true });
        }

        setLoading(true);
        try {
            // 1. Fetch ALL local data for this Ky
            const localData: any[] = await DatabaseHelper.layDanhSachTheoKy(kyId);
            const isFullDownloaded = localData.length > 50;

            let data: Customer[] = [];
            let totalFiltered = 0;

            if (isFullDownloaded) {
                // LOCAL-FIRST: Perform search and basic status filtering against the full local set
                console.log('⚡ Using Local-First filtering (Large dataset detected)');
                let filtered = [...localData];

                // Text Search
                if (search.trim()) {
                    const q = search.toLowerCase();
                    filtered = filtered.filter(kh =>
                        (kh.ten_kh || '').toLowerCase().includes(q) ||
                        (kh.ma_danh_bo || '').toLowerCase().includes(q) ||
                        (kh.dia_chi || '').toLowerCase().includes(q) ||
                        (kh.ma_lo_trinh || '').toLowerCase().includes(q)
                    );
                }

                // Status Toggle
                if (filterStatus === 1) filtered = filtered.filter(kh => kh.trang_thai === 0);
                if (filterStatus === 2) filtered = filtered.filter(kh => kh.trang_thai === 1);

                totalFiltered = filtered.length;
                // Slice for current page
                data = filtered.slice((pageNum - 1) * 50, pageNum * 50);
                setHasMore(totalFiltered > pageNum * 50);
            } else {
                // API-FIRST (Standard behavior)
                try {
                    if (search.trim()) {
                        data = await ApiService.timKiemToAnBo(search, pageNum, 50);
                    } else {
                        data = await ApiService.layDanhSachDocSo(kyId, pageNum, 50, '', filterStatus === 0 ? undefined : filterStatus - 1, selectedDot, selectedMay);
                    }
                } catch (apiErr) {
                    console.warn('⚠️ API fetch failed:', apiErr);
                }

                // Merge Local -> Server (as before)
                if (localData.length > 0) {
                    if (data.length === 0) {
                        data = localData.slice((pageNum - 1) * 50, pageNum * 50);
                    } else {
                        const localMap = new Map<string, any>(localData.map((l: any) => [l.ma_danh_bo.trim(), l]));
                        data = data.map(serverItem => {
                            const mdb = (serverItem.ma_danh_bo || '').trim();
                            const local = localMap.get(mdb);
                            if (local) {
                                return {
                                    ...serverItem,
                                    chi_so_moi: local.chi_so_moi || serverItem.chi_so_moi,
                                    trang_thai: local.trang_thai || serverItem.trang_thai,
                                    hinh_anh: local.hinh_anh || serverItem.hinh_anh,
                                    ghi_chu: local.ghi_chu || serverItem.ghi_chu,
                                    code: local.code || serverItem.code,
                                };
                            }
                            return serverItem;
                        });
                    }
                }
                setHasMore(data.length === 50);
            }

            let processed = [...data];

            // Handle Advanced Abnormality/Percentage Filters
            if (['Bất Thường Tăng', 'Bất Thường Giảm', '10%', '20%', '30%', '40%', '50%'].includes(filterType)) {
                // Bulk fetch history for all visible customers to avoid 50 individual calls
                const maDanhBos = processed.map(c => c.ma_danh_bo);
                const historyMap = await ApiService.layLichSuDocBulk(maDanhBos, 3);

                processed = processed.map((c) => {
                    const history = historyMap[c.ma_danh_bo] || [];
                    if (history.length === 0) return { ...c, _abnormal: null };

                    const currentTT = (c.chi_so_moi || 0) - c.chi_so_cu;
                    const avgTT = history.reduce((sum: number, h: any) => sum + (h.tieu_thu || 0), 0) / history.length;
                    const prevTT = history[0].tieu_thu || 0;

                    let type: string | null = null;
                    if (currentTT > avgTT * 1.5) type = 'tang';
                    else if (currentTT < avgTT * 0.5) type = 'giam';

                    let percent = 0;
                    if (prevTT > 0) {
                        percent = Math.abs(currentTT - prevTT) / prevTT * 100;
                    }

                    return { ...c, _abnormal: type, _percent: percent };
                });

                if (filterType === 'Bất Thường Tăng') {
                    processed = processed.filter(c => c._abnormal === 'tang');
                } else if (filterType === 'Bất Thường Giảm') {
                    processed = processed.filter(c => c._abnormal === 'giam');
                } else if (filterType.includes('%')) {
                    const percentThreshold = parseInt(filterType);
                    processed = processed.filter(c => (c._percent || 0) >= percentThreshold);
                }
            } else if (filterType === 'F') {
                processed = processed.filter(c => c.code === 'F');
            } else if (filterType === '6') {
                processed = processed.filter(c => c.code === '6');
            } else if (filterType === 'Chủ Báo') {
                processed = processed.filter(c => {
                    const gc = (c.ghi_chu || '').toLowerCase();
                    return gc.includes('chủ báo') || gc.includes('chu bao');
                });
            }

            // Sort
            if (sortType === 'MLT') {
                processed.sort((a, b) => (a.ma_lo_trinh || '').localeCompare(b.ma_lo_trinh || ''));
            } else if (sortType === 'Thời Gian Tăng') {
                // In a real app we'd sort by date
            }

            if (reset) {
                setCustomers(processed);
            } else {
                setCustomers(processed); // With footer buttons, we always replace the set for the specific page
            }
            console.log(`📊 Page ${pageNum} loaded: ${processed.length} items. Total Filtered: ${totalFiltered}`);
            setHasMore(isFullDownloaded ? (totalFiltered > pageNum * 50) : (data.length === 50));
            setPage(pageNum);
        } catch (e) {
            console.error('❌ Lỗi tải khách hàng:', e);
        } finally {
            setLoading(false);
            setRefreshing(false);
        }
    };

    const handleQuickMarkToggle = async (item: Customer, index: number) => {
        const isDone = item.trang_thai === 1;
        if (isDone) {
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
                        const success = await ApiService.huyDocSo(item.ma_danh_bo, item.ma_ky_doc || maKyDoc || 0);
                        if (success) {
                            const updated = [...customers];
                            updated[index] = { ...item, trang_thai: 0, chi_so_moi: undefined };
                            setCustomers(updated);
                        } else {
                            Alert.alert('Lỗi', 'Không thể hủy trạng thái trên server.');
                        }
                    } catch (e) {
                        Alert.alert('Lỗi', 'Có lỗi xảy ra.');
                    } finally {
                        setLoading(false);
                    }
                }
            });
            setDialogVisible(true);
        } else {
            setDialogConfig({
                title: 'Xác nhận Đã Đọc',
                content: `Bạn có muốn đánh dấu khách hàng này là ĐÃ ĐỌC?\n(Chỉ số mới sẽ được gán bằng Chỉ số cũ: ${item.chi_so_cu})`,
                icon: 'checkmark-circle',
                iconColor: '#4CAF50',
                confirmText: 'Đồng ý',
                cancelText: 'Bỏ qua',
                onConfirm: async () => {
                    setDialogVisible(false);
                    setLoading(true);
                    try {
                        const success = await ApiService.ghiChiSo(item.ma_danh_bo, item.ma_ky_doc || maKyDoc || 0, item.chi_so_cu, '40');
                        if (success) {
                            const updated = [...customers];
                            updated[index] = { ...item, trang_thai: 1, chi_so_moi: item.chi_so_cu };
                            setCustomers(updated);
                        } else {
                            Alert.alert('Lỗi', 'Không thể ghi chỉ số lên server.');
                        }
                    } catch (e) {
                        Alert.alert('Lỗi', 'Có lỗi xảy ra.');
                    } finally {
                        setLoading(false);
                    }
                }
            });
            setDialogVisible(true);
        }
    };

    const renderItem = ({ item, index }: { item: Customer; index: number }) => {
        const isDone = item.trang_thai === 1;
        return (
            <TouchableOpacity
                style={[styles.card, !isDone && styles.cardUnread]}
                onPress={() => {
                    const mapped = customers.map(c => ({
                        ...c,
                        ma_ky_doc: (c.ma_ky_doc === 0 || !c.ma_ky_doc) ? maKyDoc || 0 : c.ma_ky_doc
                    }));
                    navigation.navigate('GhiNuoc', { customers: mapped, index });
                }}
            >
                <TouchableOpacity onPress={() => handleQuickMarkToggle(item, index)} style={styles.cardLeading}>
                    <View style={[styles.avatar, { backgroundColor: isDone ? '#4CAF50' : '#FF9800' }]}>
                        <Ionicons name={isDone ? "checkmark" : "medal-outline"} size={22} color="white" />
                    </View>
                </TouchableOpacity>

                <View style={styles.cardContent}>
                    <View style={styles.cardHeader}>
                        <Text style={styles.nameText} numberOfLines={1}>{item.ten_kh}</Text>
                        {!isDone && (
                            <View style={styles.unreadBadge}>
                                <Text style={styles.unreadBadgeTxt}>Chưa đọc</Text>
                            </View>
                        )}
                    </View>
                    <Text style={styles.subText}>Mã: {item.ma_danh_bo} | MLT: <Text style={{ color: '#2196F3', fontWeight: 'bold' }}>{item.ma_lo_trinh}</Text></Text>
                    <Text style={styles.addressText} numberOfLines={1}>{item.dia_chi}</Text>
                </View>

                <View style={styles.cardTrailing}>
                    <Text style={styles.infoLabel}>CS: {item.chi_so_cu}</Text>
                    {isDone && <Text style={styles.infoValue}>→ {item.chi_so_moi}</Text>}
                </View>
            </TouchableOpacity>
        );
    };

    const daDocCount = customers.filter(c => c.trang_thai === 1).length;
    const chuaDocCount = customers.length - daDocCount;

    const handleFullDownload = async () => {
        if (!maKyDoc) {
            UIHelper.showCustomSnackBar('Vui lòng chọn kỳ đọc trước', true);
            return;
        }
        setDownloadDialogVisible(false);
        setLoading(true);
        try {
            const filterInfo = `(Tổ: ${selectedTo}, Máy: ${selectedMay}, Đợt: ${selectedDot})`;
            UIHelper.showCustomSnackBar(`Đang tải dữ liệu kỳ ${maKyDoc} ${filterInfo}...`, false);

            // For now, use selectedDot as maLoTrinh and selectedMay
            const allData = await ApiService.layToanBoDanhSachDocSo(maKyDoc, selectedDot, selectedMay);

            if (allData && allData.length > 0) {
                await DatabaseHelper.luuDanhSachKhachHang(allData, maKyDoc);
                UIHelper.showCustomSnackBar(`Đã tải và lưu ${allData.length} khách hàng!`, false, true);
                fetchCustomers(maKyDoc, 1, true);
            } else {
                UIHelper.showCustomSnackBar('Không có dữ liệu cho bộ lọc này', true);
            }
        } catch (error) {
            console.error('❌ Download error:', error);
            UIHelper.showCustomSnackBar('Lỗi khi tải dữ liệu', true);
        } finally {
            setLoading(false);
        }
    };

    const handleImportCSV = async () => {
        try {
            const result = await DocumentPicker.getDocumentAsync({
                type: 'text/comma-separated-values',
                copyToCacheDirectory: true,
            });

            if (result.canceled) return;

            setLoading(true);
            const content = await FileSystem.readAsStringAsync(result.assets[0].uri);
            const count = await DatabaseHelper.importFromCSV(content);

            if (count > 0) {
                UIHelper.showCustomSnackBar(`Đã nạp thành công ${count} khách hàng từ CSV!`, false, true);
                if (maKyDoc) fetchCustomers(maKyDoc, 1, true);
            } else {
                UIHelper.showCustomSnackBar('File CSV không đúng định dạng (Mã DB, Tên KH, Địa Chỉ, CS Cũ)', true);
            }
        } catch (error) {
            console.error('❌ CSV Import error:', error);
            UIHelper.showCustomSnackBar('Lỗi khi nạp file CSV', true);
        } finally {
            setLoading(false);
        }
    };

    // Helper for iOS selection
    const showIOSActionSheet = (title: string, options: string[], onSelect: (val: string) => void) => {
        ActionSheetIOS.showActionSheetWithOptions(
            {
                options: ['Hủy', ...options],
                cancelButtonIndex: 0,
                title: title,
            },
            (buttonIndex) => {
                if (buttonIndex > 0) {
                    onSelect(options[buttonIndex - 1]);
                }
            }
        );
    };

    const renderPickerBox = (label: string, value: string, options: string[], onSelect: (val: string) => void, pickerElement: React.ReactNode) => {
        if (Platform.OS === 'ios') {
            return (
                <View style={styles.dlRow}>
                    <Text style={[styles.dlLabel, { width: 45, color: '#333', fontWeight: 'bold' }]}>{label}</Text>
                    <TouchableOpacity 
                        style={styles.dlPicker} 
                        onPress={() => showIOSActionSheet(`Chọn ${label}`, options, onSelect)}
                    >
                        <View style={{ flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', paddingHorizontal: 12, flex: 1 }}>
                            <Text style={{ fontSize: 15, color: '#333' }}>{value || '--'}</Text>
                            <Ionicons name="chevron-down" size={18} color="#2196F3" />
                        </View>
                    </TouchableOpacity>
                </View>
            );
        }

        return (
            <View style={styles.dlRow}>
                <Text style={[styles.dlLabel, { width: 45, color: '#333', fontWeight: 'bold' }]}>{label}</Text>
                <View style={styles.dlPicker}>
                    {pickerElement}
                </View>
            </View>
        );
    };

    return (
        <SafeAreaView style={styles.container}>
            {loading && (
                <View style={styles.loadingOverlay}>
                    <ActivityIndicator size="large" color="#2196F3" />
                </View>
            )}
            <CustomDialog
                visible={dialogVisible}
                {...dialogConfig}
                onCancel={() => setDialogVisible(false)}
            />

            <OptionDialog
                visible={menuVisible}
                title="Tùy chọn dữ liệu"
                options={[
                    { label: 'Tải Dữ Liệu Đọc Số', icon: 'download', value: 'download', color: '#2196F3' },
                    { label: 'Import CSV', icon: 'document-attach', value: 'import', color: '#4CAF50' },
                    { label: 'Export CSV', icon: 'share', value: 'export', color: '#E91E63' },
                ]}
                onSelect={(val) => {
                    setMenuVisible(false);
                    if (val === 'download') {
                        setDownloadDialogVisible(true);
                    } else if (val === 'import') {
                        handleImportCSV();
                    } else {
                        Alert.alert('Thông báo', 'Tính năng đang được phát triển');
                    }
                }}
                onCancel={() => setMenuVisible(false)}
            />

            <Modal visible={downloadDialogVisible} transparent animationType="fade" onRequestClose={() => setDownloadDialogVisible(false)}>
                <TouchableOpacity style={[styles.modalOverlay, { backgroundColor: 'rgba(0,0,0,0.6)', justifyContent: 'center' }]} activeOpacity={1} onPress={() => setDownloadDialogVisible(false)}>
                    <TouchableOpacity activeOpacity={1} style={[styles.modalCard, { borderRadius: 16, marginHorizontal: 20, elevation: 20, borderTopLeftRadius: 16, borderTopRightRadius: 16, maxHeight: '90%' }]}>
                        <Text style={styles.modalTitle}>Tải Dữ Liệu Đọc Số</Text>

                        <View style={styles.dlForm}>
                            {renderPickerBox(
                                'Tổ', 
                                selectedTo, 
                                ['Tân Phú 1', 'Tân Phú 2', 'Tân Phú 3'],
                                (v) => setSelectedTo(v),
                                <Picker selectedValue={selectedTo} onValueChange={v => setSelectedTo(v)} style={styles.picker} dropdownIconColor="#2196F3">
                                    {['Tân Phú 1', 'Tân Phú 2', 'Tân Phú 3'].map(to => <Picker.Item key={to} label={to} value={to} style={{ fontSize: 14 }} />)}
                                </Picker>
                            )}

                            <View style={styles.dlRow}>
                                <Text style={[styles.dlLabel, { width: 45, color: '#333', fontWeight: 'bold' }]}>Máy</Text>
                                <View style={[styles.dlPicker, { flexDirection: 'row', alignItems: 'center' }]}>
                                    <TextInput 
                                        style={[styles.picker, { flex: 1, height: 40, paddingLeft: 12, color: '#000' }]} 
                                        value={selectedMay}
                                        onChangeText={v => setSelectedMay(v)}
                                        keyboardType="numeric"
                                        placeholder="Nhập máy..."
                                    />
                                    <View style={{ width: 40, height: 40, justifyContent: 'center', overflow: 'hidden' }}>
                                        <Picker 
                                            selectedValue={null} 
                                            onValueChange={v => { if (v) setSelectedMay(v); }}
                                            style={{ opacity: 0, position: 'absolute', width: 100, height: 100 }}
                                        >
                                            <Picker.Item label="Chọn nhanh..." value={null} />
                                            {mayList.map(m => (
                                                <Picker.Item key={m} label={m} value={m} />
                                            ))}
                                        </Picker>
                                        <Ionicons name="chevron-down" size={20} color="#2196F3" style={{ alignSelf: 'center' }} pointerEvents="none" />
                                    </View>
                                </View>
                            </View>

                            {renderPickerBox(
                                'Năm', 
                                selectedNam, 
                                [...new Set(kyDocList.map(k => (k.Nam ?? k.nam ?? 2024).toString()))].sort((a, b) => b.localeCompare(a)),
                                (v) => {
                                    setSelectedNam(v);
                                    const firstKy = kyDocList.find(k => (k.Nam?.toString() === v || k.nam?.toString() === v));
                                    if (firstKy) {
                                        const id = firstKy.MaKyDoc ?? firstKy.maKyDoc ?? firstKy.ID ?? firstKy.id;
                                        setMaKyDoc(id);
                                    }
                                },
                                <Picker selectedValue={selectedNam} onValueChange={v => {
                                    setSelectedNam(v);
                                    const firstKy = kyDocList.find(k => (k.Nam?.toString() === v || k.nam?.toString() === v));
                                    if (firstKy) {
                                        const id = firstKy.MaKyDoc ?? firstKy.maKyDoc ?? firstKy.ID ?? firstKy.id;
                                        setMaKyDoc(id);
                                    }
                                }} style={styles.picker} dropdownIconColor="#2196F3">
                                    {[...new Set(kyDocList.map(k => (k.Nam ?? k.nam ?? 2024).toString()))]
                                        .sort((a, b) => b.localeCompare(a))
                                        .map(y => <Picker.Item key={y} label={y} value={y} style={{ fontSize: 14 }} />)}
                                </Picker>
                            )}

                            {renderPickerBox(
                                'Kỳ', 
                                kyDocList.find(k => (k.MaKyDoc === maKyDoc || k.maKyDoc === maKyDoc || k.ID === maKyDoc || k.id === maKyDoc))?.Ky?.toString() || '--', 
                                kyDocList.filter(k => (k.Nam?.toString() === selectedNam || k.nam?.toString() === selectedNam)).map(k => (k.Ky ?? k.ky ?? '1').toString()),
                                (v) => {
                                    const selected = kyDocList.find(k => (k.Nam?.toString() === selectedNam || k.nam?.toString() === selectedNam) && (k.Ky?.toString() === v || k.ky?.toString() === v));
                                    if (selected) setMaKyDoc(selected.MaKyDoc ?? selected.maKyDoc ?? selected.ID ?? selected.id);
                                },
                                <Picker selectedValue={maKyDoc?.toString()} onValueChange={v => setMaKyDoc(parseInt(v))} style={styles.picker} dropdownIconColor="#2196F3">
                                    {kyDocList
                                        .filter(k => (k.Nam?.toString() === selectedNam || k.nam?.toString() === selectedNam))
                                        .map(k => {
                                            const id = k.MaKyDoc ?? k.maKyDoc ?? k.ID ?? k.id;
                                            const kyValue = k.Ky ?? k.ky ?? '1';
                                            return <Picker.Item key={id} label={kyValue.toString()} value={id.toString()} style={{ fontSize: 14 }} />;
                                        })}
                                </Picker>
                            )}

                            {renderPickerBox(
                                'Đợt', 
                                selectedDot.padStart(2, '0'), 
                                dotList.map(d => d.padStart(2, '0')),
                                (v) => setSelectedDot(v.replace(/^0+/, '') || '0'),
                                <Picker selectedValue={selectedDot} onValueChange={v => setSelectedDot(v)} style={styles.picker} dropdownIconColor="#2196F3">
                                    {dotList.length > 0 
                                        ? dotList.map(d => <Picker.Item key={d} label={d.padStart(2, '0')} value={d} style={{ fontSize: 14 }} />)
                                        : <Picker.Item label="--" value="" />
                                    }
                                </Picker>
                            )}
                        </View>

                        <View style={styles.dlActions}>
                            <TouchableOpacity style={styles.dlBtn} onPress={handleFullDownload}>
                                <Text style={styles.dlBtnTxt}>TẢI VỀ</Text>
                            </TouchableOpacity>
                            <TouchableOpacity style={styles.dlBtnMsg} onPress={() => setDownloadDialogVisible(false)}>
                                <Text style={styles.dlBtnTxt}>TIN NHẮN</Text>
                            </TouchableOpacity>
                        </View>

                        <TouchableOpacity style={{ alignSelf: 'center', marginTop: 20, padding: 10 }} onPress={() => setDownloadDialogVisible(false)}>
                            <Text style={{ color: '#F44336', fontWeight: 'bold', fontSize: 16 }}>QUAY LẠI</Text>
                        </TouchableOpacity>
                    </TouchableOpacity>
                </TouchableOpacity>
            </Modal>

            <Modal visible={filterSortVisible} transparent animationType="slide" onRequestClose={() => setFilterSortVisible(false)}>
                <TouchableOpacity style={styles.modalOverlay} activeOpacity={1} onPress={() => setFilterSortVisible(false)}>
                    <TouchableOpacity activeOpacity={1} style={styles.modalCard}>
                        <Text style={styles.modalTitle}>Lọc & Sắp xếp</Text>

                        <Text style={styles.inputLabel}>Lọc theo loại</Text>
                        <TextInput style={styles.modalInput} value={filterType} editable={false} />
                        {/* Simplified for now, in a real parity app we'd use a Picker here */}
                        <ScrollView horizontal showsHorizontalScrollIndicator={false} style={{ marginBottom: 10 }}>
                            {FILTER_OPTIONS.map(opt => (
                                <TouchableOpacity key={opt} onPress={() => setFilterType(opt)} style={[styles.miniBtn, filterType === opt && styles.miniBtnActive]}>
                                    <Text style={[styles.miniBtnTxt, filterType === opt && styles.txtWhite]}>{opt}</Text>
                                </TouchableOpacity>
                            ))}
                        </ScrollView>

                        <Text style={styles.inputLabel}>Sắp xếp</Text>
                        <View style={styles.sortRow}>
                            {SORT_OPTIONS.map(opt => (
                                <TouchableOpacity key={opt} onPress={() => setSortType(opt)} style={[styles.miniBtn, sortType === opt && styles.miniBtnActive]}>
                                    <Text style={[styles.miniBtnTxt, sortType === opt && styles.txtWhite]}>{opt}</Text>
                                </TouchableOpacity>
                            ))}
                        </View>

                        <View style={styles.modalBtns}>
                            <TouchableOpacity style={styles.cancelBtn} onPress={() => setFilterSortVisible(false)}>
                                <Text style={styles.cancelBtnTxt}>Hủy</Text>
                            </TouchableOpacity>
                            <TouchableOpacity style={styles.applyBtn} onPress={() => { setFilterSortVisible(false); fetchCustomers(maKyDoc!, 1, true); }}>
                                <Text style={styles.applyBtnTxt}>Áp dụng</Text>
                            </TouchableOpacity>
                        </View>
                    </TouchableOpacity>
                </TouchableOpacity>
            </Modal>

            {/* Top bar */}
            <View style={styles.topBar}>
                <TouchableOpacity onPress={() => navigation.goBack()} style={styles.backBtn}>
                    <Ionicons name="arrow-back" size={24} color="white" />
                </TouchableOpacity>

                {showSearch ? (
                    <View style={styles.searchBar}>
                        <Ionicons name="search" size={18} color="#2196F3" style={{ marginRight: 8 }} />
                        <TextInput
                            style={styles.searchInput}
                            placeholder="Tìm tên, mã, địa chỉ..."
                            value={search}
                            onChangeText={setSearch}
                            onSubmitEditing={() => fetchCustomers(maKyDoc!, 1, true)}
                            autoFocus
                        />
                        <TouchableOpacity onPress={() => { setSearch(''); setShowSearch(false); fetchCustomers(maKyDoc!, 1, true); }}>
                            <Ionicons name="close" size={22} color="#666" />
                        </TouchableOpacity>
                    </View>
                ) : (
                    <View style={styles.topBarContent}>
                        <Text style={styles.topBarTitle}>Khách Hàng</Text>
                        <View style={styles.topActions}>
                            <TouchableOpacity onPress={() => setShowSearch(true)} style={styles.topBarBtn}><Ionicons name="search" size={22} color="white" /></TouchableOpacity>
                            <TouchableOpacity onPress={() => setFilterSortVisible(true)} style={styles.topBarBtn}><Ionicons name="filter" size={22} color="white" /></TouchableOpacity>
                            <TouchableOpacity onPress={() => setMenuVisible(true)} style={styles.topBarBtn}><Ionicons name="download-outline" size={22} color="white" /></TouchableOpacity>
                            <TouchableOpacity onPress={() => setIpModalVisible(true)} style={styles.topBarBtn}><Ionicons name="settings-outline" size={22} color="white" /></TouchableOpacity>
                        </View>
                    </View>
                )}
            </View>

            {/* IP Modal matches InputDialog style but for IP */}
            <Modal visible={ipModalVisible} transparent animationType="fade" onRequestClose={() => setIpModalVisible(false)}>
                <TouchableOpacity style={styles.modalOverlay} activeOpacity={1} onPress={() => setIpModalVisible(false)}>
                    <TouchableOpacity activeOpacity={1} style={styles.modalCard}>
                        <Text style={styles.modalTitle}>Cấu hình Máy chủ</Text>
                        <TextInput style={styles.modalInput} value={ipInput} onChangeText={setIpInput} placeholder="10.0.2.2" />
                        <View style={styles.modalBtns}>
                            <TouchableOpacity onPress={() => setIpModalVisible(false)}><Text style={{ color: '#666', padding: 10 }}>Hủy</Text></TouchableOpacity>
                            <TouchableOpacity onPress={async () => { await ApiService.setBaseUrl(ipInput); setIpModalVisible(false); init(); }}><Text style={{ color: '#2196F3', fontWeight: 'bold', padding: 10 }}>CẬP NHẬT</Text></TouchableOpacity>
                        </View>
                    </TouchableOpacity>
                </TouchableOpacity>
            </Modal>

            {/* Filter Toggle Row matches Flutter exactly */}
            <View style={styles.filterToggleRow}>
                <TouchableOpacity style={[styles.filterBtn, filterStatus === 0 && styles.filterBtnActiveBlue]} onPress={() => { setFilterStatus(0); fetchCustomers(maKyDoc!, 1, true); }}>
                    <Text style={[styles.filterBtnTxt, filterStatus === 0 && styles.txtWhite]}>Tất cả</Text>
                </TouchableOpacity>
                <TouchableOpacity style={[styles.filterBtn, filterStatus === 1 && styles.filterBtnActiveRed]} onPress={() => { setFilterStatus(1); fetchCustomers(maKyDoc!, 1, true); }}>
                    <Text style={[styles.filterBtnTxt, filterStatus === 1 && styles.txtWhite]}>Chưa đọc</Text>
                </TouchableOpacity>
                <TouchableOpacity style={[styles.filterBtn, filterStatus === 2 && styles.filterBtnActiveGreen]} onPress={() => { setFilterStatus(2); fetchCustomers(maKyDoc!, 1, true); }}>
                    <Text style={[styles.filterBtnTxt, filterStatus === 2 && styles.txtWhite]}>Đã đọc</Text>
                </TouchableOpacity>
            </View>

            {/* Summary Bar match blue[50] */}
            <View style={styles.summaryBar}>
                <Text style={styles.summaryText}>Trang: <Text style={{ fontWeight: 'bold' }}>{page}</Text></Text>
                <Text style={[styles.summaryText, { color: '#2E7D32' }]}>Đã đọc: {daDocCount}</Text>
                <Text style={[styles.summaryText, { color: '#C62828' }]}>Chưa đọc: {chuaDocCount}</Text>
            </View>

            <FlatList
                ref={flatListRef}
                data={customers}
                renderItem={renderItem}
                keyExtractor={(item, idx) => item.ma_danh_bo + idx}
                onRefresh={() => fetchCustomers(maKyDoc!, 1, true)}
                refreshing={refreshing}
                onScroll={(e) => {
                    const offset = e.nativeEvent.contentOffset.y;
                    setShowScrollTop(offset > 300);
                }}
                ListFooterComponent={() => loading ? <ActivityIndicator style={{ margin: 20 }} color="#2196F3" /> : null}
                contentContainerStyle={styles.listContent}
            />

            {showScrollTop && (
                <TouchableOpacity
                    style={styles.scrollTopBtn}
                    onPress={() => flatListRef.current?.scrollToOffset({ offset: 0, animated: true })}
                >
                    <Ionicons name="arrow-up" size={24} color="white" />
                </TouchableOpacity>
            )}

            {/* Pagination Footer exact match Flutter */}
            <View style={styles.paginationFooter}>
                <TouchableOpacity
                    style={[styles.pageNavBtn, page <= 1 && styles.pageBtnDisabled]}
                    onPress={() => page > 1 && fetchCustomers(maKyDoc!, page - 1, true)}
                >
                    <Ionicons name="chevron-back" size={14} color="white" />
                    <Text style={styles.pageBtnTxt}>Trước</Text>
                </TouchableOpacity>

                <View style={styles.pageIndicatorBox}>
                    <Text style={styles.pageIndicatorMain}>Trang {page}</Text>
                    <Text style={styles.pageIndicatorSub}>Hiện: {customers.length} người</Text>
                </View>

                <TouchableOpacity
                    style={[styles.pageNavBtn, !hasMore && styles.pageBtnDisabled]}
                    onPress={() => hasMore && fetchCustomers(maKyDoc!, page + 1)}
                >
                    <Text style={styles.pageBtnTxt}>Tiếp</Text>
                    <Ionicons name="chevron-forward" size={14} color="white" />
                </TouchableOpacity>
            </View>
        </SafeAreaView>
    );
};

const styles = StyleSheet.create({
    container: { flex: 1, backgroundColor: '#FFF' },
    topBar: { backgroundColor: '#2196F3', height: 56, flexDirection: 'row', alignItems: 'center', paddingHorizontal: 4 },
    backBtn: { padding: 8 },
    topBarContent: { flex: 1, flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between', paddingRight: 8 },
    topBarTitle: { color: 'white', fontSize: 18, fontWeight: 'bold' },
    topActions: { flexDirection: 'row', gap: 5 },
    topBarBtn: { padding: 10 },
    searchBar: { flex: 1, flexDirection: 'row', alignItems: 'center', backgroundColor: 'white', borderRadius: 4, marginHorizontal: 8, paddingHorizontal: 10, height: 40, borderWidth: 1, borderColor: '#2196F3' },
    searchInput: { flex: 1, fontSize: 16 },

    filterToggleRow: { flexDirection: 'row', justifyContent: 'center', paddingVertical: 8, backgroundColor: '#F5F5F5' },
    filterBtn: { paddingHorizontal: 16, paddingVertical: 6, borderRadius: 20, backgroundColor: 'white', marginHorizontal: 4, borderWidth: 1, borderColor: '#DDD' },
    filterBtnActiveBlue: { backgroundColor: '#2196F3', borderColor: '#2196F3' },
    filterBtnActiveRed: { backgroundColor: '#F44336', borderColor: '#F44336' },
    filterBtnActiveGreen: { backgroundColor: '#4CAF50', borderColor: '#4CAF50' },
    filterBtnTxt: { fontSize: 13, fontWeight: 'bold', color: '#666' },
    txtWhite: { color: 'white' },

    summaryBar: { flexDirection: 'row', justifyContent: 'space-around', paddingVertical: 12, backgroundColor: '#E3F2FD' },
    summaryText: { fontSize: 14, color: '#1976D2' },

    listContent: { padding: 8 },
    card: { backgroundColor: 'white', borderRadius: 8, padding: 12, marginBottom: 8, flexDirection: 'row', alignItems: 'center', elevation: 2, shadowColor: '#000', shadowOffset: { width: 0, height: 1 }, shadowOpacity: 0.1, shadowRadius: 2 },
    cardUnread: { borderWidth: 1.5, borderColor: 'orange', backgroundColor: '#FFF8E1' },
    cardLeading: { marginRight: 12 },
    avatar: { width: 44, height: 44, borderRadius: 22, justifyContent: 'center', alignItems: 'center' },
    cardContent: { flex: 1 },
    cardHeader: { flexDirection: 'row', alignItems: 'center', marginBottom: 2 },
    nameText: { fontSize: 15, fontWeight: 'bold', color: '#333', flex: 1 },
    unreadBadge: { backgroundColor: 'orange', paddingHorizontal: 6, paddingVertical: 2, borderRadius: 10, marginLeft: 6 },
    unreadBadgeTxt: { color: 'white', fontSize: 10, fontWeight: 'bold' },
    subText: { fontSize: 13, color: '#666' },
    addressText: { fontSize: 12, color: '#888', marginTop: 2 },
    cardTrailing: { alignItems: 'flex-end', marginLeft: 8 },
    infoLabel: { fontSize: 12, color: '#666' },
    infoValue: { fontSize: 12, color: '#4CAF50', fontWeight: 'bold' },

    paginationFooter: { flexDirection: 'row', backgroundColor: 'white', padding: 10, alignItems: 'center', borderTopWidth: 1, borderTopColor: '#EEE', elevation: 5, shadowColor: '#000', shadowOffset: { width: 0, height: -1 }, shadowOpacity: 0.1, shadowRadius: 4 },
    pageNavBtn: { flexDirection: 'row', alignItems: 'center', backgroundColor: '#2196F3', paddingHorizontal: 12, paddingVertical: 8, borderRadius: 4, gap: 4 },
    pageBtnDisabled: { backgroundColor: '#BBB' },
    pageBtnTxt: { color: 'white', fontWeight: 'bold', fontSize: 13 },
    pageIndicatorBox: { flex: 1, alignItems: 'center' },
    pageIndicatorMain: { fontSize: 14, fontWeight: 'bold', color: '#333' },
    pageIndicatorSub: { fontSize: 11, color: '#757575' },

    modalOverlay: { flex: 1, backgroundColor: 'rgba(0,0,0,0.5)', justifyContent: 'flex-end' },
    modalCard: { backgroundColor: 'white', borderTopLeftRadius: 20, borderTopRightRadius: 20, padding: 20, maxHeight: '80%' },
    modalTitle: { fontSize: 20, fontWeight: 'bold', marginBottom: 20, textAlign: 'center' },
    inputLabel: { fontSize: 14, color: '#666', marginBottom: 8 },
    modalInput: { backgroundColor: '#f5f5f5', padding: 12, borderRadius: 8, marginBottom: 15, color: '#333' },
    miniBtn: { paddingHorizontal: 15, paddingVertical: 8, borderRadius: 20, backgroundColor: '#f0f0f0', marginRight: 8, marginBottom: 8 },
    miniBtnActive: { backgroundColor: '#2196F3' },
    miniBtnTxt: { fontSize: 13, color: '#666' },
    sortRow: { flexDirection: 'row', flexWrap: 'wrap', marginBottom: 20 },
    modalBtns: { flexDirection: 'row', justifyContent: 'space-between', marginTop: 10 },
    cancelBtn: { flex: 1, padding: 15, alignItems: 'center' },
    applyBtn: { flex: 1, backgroundColor: '#2196F3', padding: 15, borderRadius: 10, alignItems: 'center' },
    cancelBtnTxt: { color: '#666', fontWeight: 'bold' },
    applyBtnTxt: { color: '#fff', fontWeight: 'bold' },

    loadingOverlay: {
        ...StyleSheet.absoluteFillObject,
        backgroundColor: 'rgba(255,255,255,0.7)',
        justifyContent: 'center',
        alignItems: 'center',
        zIndex: 999
    },
    dlForm: { paddingVertical: 10 },
    dlRow: { flexDirection: 'row', alignItems: 'center', marginBottom: 15 },
    dlLabel: { width: 45, color: '#333', fontWeight: 'bold' },
    dlPicker: { flex: 1, backgroundColor: '#f0f0f0', borderRadius: 8, height: 55, justifyContent: 'center', borderWidth: 1, borderColor: '#DDD' },
    picker: { height: 55, width: '100%' },
    dlActions: { flexDirection: 'row', justifyContent: 'space-between', marginTop: 20 },
    dlBtn: { flex: 1, backgroundColor: '#f0f0f0', paddingVertical: 14, borderRadius: 8, alignItems: 'center', marginRight: 12, elevation: 3, shadowColor: '#000', shadowOffset: { width: 0, height: 2 }, shadowOpacity: 0.2, shadowRadius: 2 },
    dlBtnMsg: { flex: 1, backgroundColor: '#f0f0f0', paddingVertical: 14, borderRadius: 8, alignItems: 'center', elevation: 3, shadowColor: '#000', shadowOffset: { width: 0, height: 2 }, shadowOpacity: 0.2, shadowRadius: 2 },
    dlBtnTxt: { fontWeight: 'bold', color: 'black', fontSize: 15 },
    scrollTopBtn: {
        position: 'absolute',
        bottom: 120, // Moved higher to avoid overlap with pagination footer
        right: 20,
        backgroundColor: '#2196F3',
        width: 50,
        height: 50,
        borderRadius: 25,
        justifyContent: 'center',
        alignItems: 'center',
        elevation: 5,
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 2 },
        shadowOpacity: 0.25,
        shadowRadius: 3.84,
    }
});

export default DanhSachKHScreen;
