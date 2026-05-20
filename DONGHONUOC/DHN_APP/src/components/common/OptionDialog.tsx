import React from 'react';
import { Modal, StyleSheet, View, Text, TouchableOpacity, ScrollView } from 'react-native';
import { Ionicons } from '@expo/vector-icons';

export interface DialogOption {
    label: string;
    icon: keyof typeof Ionicons.glyphMap;
    value: any;
    color?: string;
}

interface OptionDialogProps {
    visible: boolean;
    title: string;
    options: DialogOption[];
    onSelect: (value: any) => void;
    onCancel: () => void;
}

const OptionDialog: React.FC<OptionDialogProps> = ({
    visible, title, options, onSelect, onCancel
}) => {
    return (
        <Modal visible={visible} transparent animationType="fade" onRequestClose={onCancel}>
            <TouchableOpacity style={styles.overlay} activeOpacity={1} onPress={onCancel}>
                <TouchableOpacity activeOpacity={1} style={styles.card}>
                    <Text style={styles.title}>{title}</Text>
                    <ScrollView style={styles.scrollView} showsVerticalScrollIndicator={false}>
                        {options.map((option, idx) => (
                            <TouchableOpacity
                                key={idx}
                                style={styles.optionBtn}
                                onPress={() => onSelect(option.value)}
                            >
                                <View style={[styles.iconBox, { backgroundColor: `${option.color || '#2196F3'}15` }]}>
                                    <Ionicons name={option.icon} size={28} color={option.color || '#2196F3'} />
                                </View>
                                <Text style={styles.optionLabel}>{option.label}</Text>
                            </TouchableOpacity>
                        ))}
                    </ScrollView>
                    <TouchableOpacity style={styles.closeBtn} onPress={onCancel}>
                        <Text style={styles.closeTxt}>Đóng</Text>
                    </TouchableOpacity>
                </TouchableOpacity>
            </TouchableOpacity>
        </Modal>
    );
};

const styles = StyleSheet.create({
    overlay: { flex: 1, backgroundColor: 'rgba(0,0,0,0.5)', justifyContent: 'center', alignItems: 'center', padding: 24 },
    card: { backgroundColor: 'white', borderRadius: 20, padding: 24, width: '100%', elevation: 10 },
    title: { fontSize: 20, fontWeight: 'bold', color: '#333', textAlign: 'center', marginBottom: 20 },
    optionBtn: { flexDirection: 'row', alignItems: 'center', backgroundColor: '#F5F5F5', borderRadius: 12, padding: 12, marginBottom: 12, borderWidth: 1, borderColor: '#EEE' },
    iconBox: { width: 44, height: 44, borderRadius: 8, justifyContent: 'center', alignItems: 'center', marginRight: 16 },
    optionLabel: { fontSize: 16, fontWeight: '600', color: '#333' },
    closeBtn: { marginTop: 8, alignSelf: 'center' },
    closeTxt: { color: '#757575', fontSize: 14 },
    scrollView: { maxHeight: 400 },
});

export default OptionDialog;
