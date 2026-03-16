console.log('📱 DANH SACH KH SCREEN LOADED');
import React, { useState, useEffect, useCallback } from 'react';
import {
    StyleSheet, View, Text, FlatList, TextInput,
    TouchableOpacity, ActivityIndicator, SafeAreaView, Modal, Alert, ScrollView
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useNavigation } from '@react-navigation/native';
import { StackNavigationProp } from '@react-navigation/stack';
import { RootStackParamList } from '../navigation/AppNavigator';
import ApiService from '../services/ApiService';

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

    // Custom Component States
    const [ipModalVisible, setIpModalVisible] = useState(false);
    const [ipInput, setIpInput] = useState('');
    const [dialogVisible, setDialogVisible] = useState(false);
    const [dialogConfig, setDialogConfig] = useState<any>({});
    const [menuVisible, setMenuVisible] = useState(false);

    const init = async () => {
        try {
            console.log('🔄 Initializing DanhSachKHScreen...');
            const kyDocs = await ApiService.layDanhSachKyDoc();
            console.log('📋 kyDocs received:', JSON.stringify(kyDocs).substring(0, 100));
            if (kyDocs && kyDocs.length > 0) {
                const firstKy = kyDocs[0];
                const kyId = firstKy.MaKyDoc ?? firstKy.maKyDoc ?? firstKy.ID ?? firstKy.id;
                console.log('🎯 Detected MaKyDoc:', kyId);
                if (kyId) {
                    setMaKyDoc(kyId);
                    fetchCustomers(kyId, 1, true);
                } else {
                    console.warn('⚠️ No kyId found in first element of kyDocs');
                }
            } else {
                console.warn('⚠️ kyDocs is empty or null');
            }
        } catch (e) {
            console.error('❌ Error during init:', e);
        }
    };

    useEffect(() => {
        init();
    }, []);

    const fetchCustomers = async (kyId: number, pageNum: number, reset = false) => {
        console.log('🔍 fetchCustomers trigger:', { kyId, pageNum, reset, currentMaKyDoc: maKyDoc });
        if (!kyId || loading) {
            console.log('🚫 fetchCustomers aborted: !kyId or loading');
            return;
        }
        setLoading(true);
        try {
            let data: Customer[] = [];
            if (search.trim()) {
                data = await ApiService.timKiemToAnBo(search, pageNum, 50);
            } else {
                data = await ApiService.layDanhSachDocSo(kyId, pageNum, 50, '', filterStatus === 0 ? undefined : filterStatus - 1);
            }

            // Apply Local Filters (Parity with Flutter)
            let processed = [...data];

            // Handle Advanced Abnormality/Percentage Filters
            if (['Bất Thường Tăng', 'Bất Thường Giảm', '10%', '20%', '30%', '40%', '50%'].includes(filterType)) {
                processed = await Promise.all(processed.map(async (c) => {
                    const history = await ApiService.layLichSuDoc(c.ma_danh_bo, 3);
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
                })).then(results => {
                    if (filterType === 'Bất Thường Tăng') return results.filter(r => r._abnormal === 'tang');
                    if (filterType === 'Bất Thường Giảm') return results.filter(r => r._abnormal === 'giam');

                    const pctMatch = filterType.match(/(\d+)%/);
                    if (pctMatch) {
                        const threshold = parseInt(pctMatch[1]);
                        return results.filter(r => (r._percent || 0) >= threshold);
                    }
                    return results;
                });
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
                setCustomers(prev => [...prev, ...processed]);
            }
            setHasMore(data.length === 50);
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
                        const success = await ApiService.huyDocSo(item.ma_danh_bo, item.ma_ky_doc);
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
                        const success = await ApiService.ghiChiSo(item.ma_danh_bo, item.ma_ky_doc, item.chi_so_cu, '40');
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
                onPress={() => navigation.navigate('GhiNuoc', { customers, index })}
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
                onSelect={(val) => { setMenuVisible(false); Alert.alert('Thông báo', 'Tính năng đang được phát triển'); }}
                onCancel={() => setMenuVisible(false)}
            />

            <Modal visible={filterSortVisible} transparent animationType="slide">
                <View style={styles.modalOverlay}>
                    <View style={styles.modalCard}>
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
                    </View>
                </View>
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
            <Modal visible={ipModalVisible} transparent animationType="fade">
                <View style={styles.modalOverlay}>
                    <View style={styles.modalCard}>
                        <Text style={styles.modalTitle}>Cấu hình Máy chủ</Text>
                        <TextInput style={styles.modalInput} value={ipInput} onChangeText={setIpInput} placeholder="10.0.2.2" />
                        <View style={styles.modalBtns}>
                            <TouchableOpacity onPress={() => setIpModalVisible(false)}><Text style={{ color: '#666', padding: 10 }}>Hủy</Text></TouchableOpacity>
                            <TouchableOpacity onPress={async () => { await ApiService.setBaseUrl(ipInput); setIpModalVisible(false); init(); }}><Text style={{ color: '#2196F3', fontWeight: 'bold', padding: 10 }}>CẬP NHẬT</Text></TouchableOpacity>
                        </View>
                    </View>
                </View>
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
                data={customers}
                renderItem={renderItem}
                keyExtractor={(item, idx) => item.ma_danh_bo + idx}
                onRefresh={() => fetchCustomers(maKyDoc!, 1, true)}
                refreshing={refreshing}
                onEndReached={() => hasMore && !loading && fetchCustomers(maKyDoc!, page + 1)}
                onEndReachedThreshold={0.5}
                ListFooterComponent={() => loading ? <ActivityIndicator style={{ margin: 20 }} color="#2196F3" /> : null}
                contentContainerStyle={styles.listContent}
            />

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
                    onPress={() => hasMore && fetchCustomers(maKyDoc!, page + 1, true)}
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
});

export default DanhSachKHScreen;
