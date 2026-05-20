import React, { useState, useEffect } from 'react';
import { Modal, StyleSheet, View, Text, TouchableOpacity, TextInput } from 'react-native';

interface InputDialogProps {
    visible: boolean;
    title: string;
    initialValue?: string;
    hintText?: string;
    confirmText?: string;
    cancelText?: string;
    onConfirm: (text: string) => void;
    onCancel: () => void;
}

const InputDialog: React.FC<InputDialogProps> = ({
    visible, title, initialValue = '', hintText, confirmText = 'Lưu', cancelText = 'Hủy', onConfirm, onCancel
}) => {
    const [text, setText] = useState(initialValue);

    useEffect(() => {
        if (visible) setText(initialValue);
    }, [visible, initialValue]);

    return (
        <Modal visible={visible} transparent animationType="fade" onRequestClose={onCancel}>
            <TouchableOpacity style={styles.overlay} activeOpacity={1} onPress={onCancel}>
                <TouchableOpacity activeOpacity={1} style={styles.card}>
                    <Text style={styles.title}>{title}</Text>
                    <TextInput
                        style={styles.input}
                        value={text}
                        onChangeText={setText}
                        placeholder={hintText}
                        multiline
                        autoFocus
                    />
                    <View style={styles.btnRow}>
                        <TouchableOpacity onPress={() => setText('')}>
                            <Text style={styles.clearTxt}>Xóa trắng</Text>
                        </TouchableOpacity>
                        <View style={{ flex: 1 }} />
                        <TouchableOpacity onPress={onCancel}>
                            <Text style={styles.cancelTxt}>{cancelText}</Text>
                        </TouchableOpacity>
                        <TouchableOpacity style={styles.confirmBtn} onPress={() => onConfirm(text)}>
                            <Text style={styles.confirmTxt}>{confirmText}</Text>
                        </TouchableOpacity>
                    </View>
                </TouchableOpacity>
            </TouchableOpacity>
        </Modal>
    );
};

const styles = StyleSheet.create({
    overlay: { flex: 1, backgroundColor: 'rgba(0,0,0,0.5)', justifyContent: 'center', alignItems: 'center', padding: 24 },
    card: { backgroundColor: 'white', borderRadius: 20, padding: 24, width: '100%', elevation: 10 },
    title: { fontSize: 20, fontWeight: 'bold', color: '#333', textAlign: 'center', marginBottom: 16 },
    input: { backgroundColor: '#F9F9F9', borderWidth: 1, borderColor: '#DDD', borderRadius: 12, padding: 12, fontSize: 16, minHeight: 100, textAlignVertical: 'top', marginBottom: 24 },
    btnRow: { flexDirection: 'row', alignItems: 'center' },
    clearTxt: { color: '#F44336', fontWeight: '600' },
    cancelTxt: { color: '#757575', paddingHorizontal: 16 },
    confirmBtn: { backgroundColor: '#2196F3', borderRadius: 10, paddingHorizontal: 20, paddingVertical: 10 },
    confirmTxt: { color: 'white', fontWeight: 'bold' },
});

export default InputDialog;
