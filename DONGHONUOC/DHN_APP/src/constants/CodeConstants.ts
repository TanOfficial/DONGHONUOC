import { DialogOption } from "../components/common/OptionDialog";

export const codeOptions: DialogOption[] = [
    // --- NHÓM BÌNH THƯỜNG / CHỦ BÁO ---
    { label: '40 - ĐH bình thường', icon: 'checkmark-circle-outline', value: '40', color: '#4CAF50' },
    { label: '41 - Chủ ghi', icon: 'person-outline', value: '41', color: '#2196F3' },
    { label: '42 - Chủ báo', icon: 'megaphone-outline', value: '42', color: '#2196F3' },
    { label: '43 - Chủ đọc', icon: 'eye-outline', value: '43', color: '#2196F3' },
    
    // --- NHÓM KHÁCH QUAN (VẮNG / ĐÓNG CỬA) ---
    { label: 'F1 - CÓ Ở', icon: 'home-outline', value: 'F1', color: '#4CAF50' },
    { label: '5N - VẮNG CHỦ', icon: 'person-remove-outline', value: '5N', color: '#FF9800' },
    { label: 'N - NHÀ VẮNG', icon: 'walk-outline', value: 'N', color: '#FF9800' },
    { label: '56 - NHÀ ĐÓNG CỬA', icon: 'business-outline', value: '56', color: '#FF9800' },
    { label: '62 - NHÀ ĐÓNG CỬA', icon: 'lock-closed', value: '62', color: '#FF9800' },
    { label: 'F2 - KẸT KHÓA', icon: 'key-outline', value: 'F2', color: '#FF9800' },
    { label: '63 - KẸT KHÓA / CỬA', icon: 'lock-open-outline', value: '63', color: '#FF9800' },
    { label: 'F5 - KHÔNG Ở', icon: 'close-outline', value: 'F5', color: '#607D8B' },
    { label: '5F - KHÔNG Ở', icon: 'bed-outline', value: '5F', color: '#607D8B' },
    { label: 'F3 - CHẤT ĐỒ', icon: 'cube-outline', value: 'F3', color: '#9E9E9E' },
    { label: '68 - CHẤT ĐỒ / VẮNG', icon: 'layers-outline', value: '68', color: '#9E9E9E' },
    { label: 'F4 - ĐÁM TANG', icon: 'alert-circle-outline', value: 'F4', color: '#E91E63' },
    
    // --- NHÓM LỖI KỸ THUẬT / ĐỒNG HỒ ---
    { label: '5K - ĐHN KẸT SỐ', icon: 'pause-circle-outline', value: '5K', color: '#F44336' },
    { label: '66 - ĐHN HƯ / BỂ KÍNH', icon: 'hammer-outline', value: '66', color: '#D32F2F' },
    { label: '45 - ÂM SÂU, KẸT TƯỜNG', icon: 'construct-outline', value: '45', color: '#795548' },
    { label: '46 - ĐHN MẤT TÍN HIỆU', icon: 'wifi-outline', value: '46', color: '#F44336' },
    { label: 'M0 - MẤT TÍN HIỆU', icon: 'flash-off-outline', value: 'M0', color: '#F44336' },
    { label: 'M1 - LỖI TRUYỀN TIN', icon: 'cloud-offline-outline', value: 'M1', color: '#F44336' },
    { label: 'F6 - ĐHN TM HƯ', icon: 'settings-outline', value: 'F6', color: '#D32F2F' },
    { label: '60 - LỖI KỸ THUẬT KHÁC', icon: 'warning-outline', value: '60', color: '#F44336' },

    // --- NHÓM THAY ĐỒNG HỒ ---
    { label: '80 - THAY CHƯA ĐỦ NGÀY', icon: 'calendar-outline', value: '80', color: '#2196F3' },
    { label: '81 - THAY BỒI THƯỜNG', icon: 'build-outline', value: '81', color: '#2196F3' },
    { label: '82 - THAY ĐỊNH KỲ', icon: 'infinite-outline', value: '82', color: '#2196F3' },
    { label: '83 - KIỂM ĐỊNH', icon: 'medal-outline', value: '83', color: '#2196F3' },
    { label: '84 - NÂNG HẠ CỠ', icon: 'resize-outline', value: '84', color: '#2196F3' },
    { label: '85 - ĐHN HAI MẶT', icon: 'copy-outline', value: '85', color: '#2196F3' },
    { label: '86 - RESET', icon: 'refresh-circle-outline', value: '86', color: '#2196F3' },
    { label: '58 - THAY ĐHN / BÁO VẮNG', icon: 'swap-horizontal-outline', value: '58', color: '#2196F3' },
    
    // --- NHÓM CẮT NƯỚC / TẠM KHÓA ---
    { label: 'K - CẮT TẠM', icon: 'cut-outline', value: 'K', color: '#F44336' },
    { label: 'K1 - TẠM KHÓA NƯỚC', icon: 'lock-closed-outline', value: 'K1', color: '#F44336' },
    { label: 'K2 - CẮT TẠM', icon: 'close-circle-outline', value: 'K2', color: '#F44336' },
    { label: 'K3 - CẮT TẬN GỐC', icon: 'nuclear-outline', value: 'K3', color: '#D32F2F' },
    { label: 'K4 - TỰ Ý MỞ CHÌ', icon: 'warning-outline', value: 'K4', color: '#FF9800' },
];
