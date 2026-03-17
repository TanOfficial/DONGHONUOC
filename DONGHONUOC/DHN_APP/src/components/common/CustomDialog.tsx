import React from 'react';
import { Modal, StyleSheet, View, Text, TouchableOpacity, Animated } from 'react-native';
import { Ionicons } from '@expo/vector-icons';

interface CustomDialogProps {
    visible: boolean;
    title: String;
    content: String;
    icon?: keyof typeof Ionicons.glyphMap;
    iconColor?: string;
    confirmText?: string;
    cancelText?: string;
    onConfirm?: () => void;
    onCancel?: () => void;
    isError?: boolean;
}

const CustomDialog: React.FC<CustomDialogProps> = ({
    visible, title, content, icon, iconColor = '#2196F3',
    confirmText, cancelText, onConfirm, onCancel, isError = false
}) => {
    return (
        <Modal visible={visible} transparent animationType="fade">
            <View style={styles.overlay}>
                <View style={styles.card}>
                    {icon && (
                        <View style={[styles.iconWrapper, { backgroundColor: `${iconColor}15` }]}>
                            <Ionicons name={icon} size={40} color={iconColor} />
                        </View>
                    )}
                    <Text style={styles.title}>{title}</Text>
                    <Text style={styles.content}>{content}</Text>

                    <View style={styles.btnRow}>
                        {cancelText && (
                            <TouchableOpacity style={styles.cancelBtn} onPress={onCancel}>
                                <Text style={styles.cancelTxt}>{cancelText}</Text>
                            </TouchableOpacity>
                        )}
                        {confirmText && (
                            <TouchableOpacity
                                style={[styles.confirmBtn, { backgroundColor: isError ? '#F44336' : '#2196F3' }]}
                                onPress={onConfirm}
                            >
                                <Text style={styles.confirmTxt}>{confirmText}</Text>
                            </TouchableOpacity>
                        )}
                    </View>
                </View>
            </View>
        </Modal>
    );
};

const styles = StyleSheet.create({
    overlay: { flex: 1, backgroundColor: 'rgba(0,0,0,0.5)', justifyContent: 'center', alignItems: 'center', padding: 20 },
    card: { backgroundColor: 'white', borderRadius: 20, padding: 24, width: '100%', alignItems: 'center', elevation: 10, shadowColor: '#000', shadowOffset: { width: 0, height: 10 }, shadowOpacity: 0.1, shadowRadius: 20 },
    iconWrapper: { width: 72, height: 72, borderRadius: 36, justifyContent: 'center', alignItems: 'center', marginBottom: 16 },
    title: { fontSize: 20, fontWeight: 'bold', color: '#333', textAlign: 'center', marginBottom: 12 },
    content: { fontSize: 15, color: '#666', textAlign: 'center', lineHeight: 21, marginBottom: 24 },
    btnRow: { flexDirection: 'row', width: '100%' },
    cancelBtn: { flex: 1, height: 48, justifyContent: 'center', alignItems: 'center', marginRight: 12 },
    cancelTxt: { fontSize: 15, fontWeight: '600', color: '#757575' },
    confirmBtn: { flex: 1, height: 48, borderRadius: 10, justifyContent: 'center', alignItems: 'center' },
    confirmTxt: { fontSize: 15, fontWeight: 'bold', color: 'white' },
});

export default CustomDialog;
