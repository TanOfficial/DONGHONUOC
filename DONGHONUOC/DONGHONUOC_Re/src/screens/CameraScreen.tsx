import React, { useState, useRef } from 'react';
import { StyleSheet, Text, View, TouchableOpacity, SafeAreaView } from 'react-native';
import { CameraView, useCameraPermissions } from 'expo-camera';
import { Ionicons } from '@expo/vector-icons';
import { useNavigation, useRoute } from '@react-navigation/native';

const CameraScreen = () => {
    const [permission, requestPermission] = useCameraPermissions();
    const navigation = useNavigation<any>();
    const route = useRoute<any>();
    const { onCapture } = route.params;
    const cameraRef = useRef<any>(null);

    if (!permission) {
        return <View />;
    }

    if (!permission.granted) {
        return (
            <View style={styles.container}>
                <Text style={{ textAlign: 'center' }}>Chúng tôi cần quyền truy cập camera để chụp ảnh đồng hồ.</Text>
                <TouchableOpacity style={styles.button} onPress={requestPermission}>
                    <Text style={styles.text}>Cấp quyền</Text>
                </TouchableOpacity>
            </View>
        );
    }

    const takePicture = async () => {
        if (cameraRef.current) {
            const photo = await cameraRef.current.takePictureAsync({ quality: 0.5, base64: true });
            if (onCapture) {
                onCapture(photo.uri);
            }
            navigation.goBack();
        }
    };

    return (
        <View style={styles.container}>
            <CameraView style={styles.camera} ref={cameraRef}>
                <SafeAreaView style={styles.overlay}>
                    <TouchableOpacity style={styles.closeBtn} onPress={() => navigation.goBack()}>
                        <Ionicons name="close" size={32} color="white" />
                    </TouchableOpacity>

                    <View style={styles.focusFrame} />

                    <View style={styles.controls}>
                        <TouchableOpacity style={styles.shutter} onPress={takePicture}>
                            <View style={styles.shutterInner} />
                        </TouchableOpacity>
                    </View>
                </SafeAreaView>
            </CameraView>
        </View>
    );
};

const styles = StyleSheet.create({
    container: {
        flex: 1,
        justifyContent: 'center',
        backgroundColor: 'black',
    },
    camera: {
        flex: 1,
    },
    overlay: {
        flex: 1,
        backgroundColor: 'transparent',
        justifyContent: 'space-between',
        alignItems: 'center',
    },
    closeBtn: {
        alignSelf: 'flex-start',
        margin: 20,
    },
    focusFrame: {
        width: '80%',
        height: 150,
        borderWidth: 2,
        borderColor: 'white',
        borderRadius: 8,
        backgroundColor: 'rgba(255, 255, 255, 0.1)',
    },
    controls: {
        marginBottom: 40,
    },
    shutter: {
        width: 80,
        height: 80,
        borderRadius: 40,
        borderWidth: 4,
        borderColor: 'white',
        justifyContent: 'center',
        alignItems: 'center',
    },
    shutterInner: {
        width: 60,
        height: 60,
        borderRadius: 30,
        backgroundColor: 'white',
    },
    button: {
        backgroundColor: '#2196F3',
        padding: 12,
        borderRadius: 8,
        marginTop: 12,
        alignSelf: 'center',
    },
    text: {
        color: 'white',
        fontWeight: 'bold',
    },
});

export default CameraScreen;
