import React, { useEffect, useRef } from 'react';
import {
    StyleSheet,
    View,
    Text,
    Animated,
    Dimensions,
    TouchableOpacity,
    Platform,
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { BlurView } from 'expo-blur';
import { useSafeAreaInsets } from 'react-native-safe-area-context';

export type NotificationType = 'success' | 'error' | 'warning' | 'info';

interface NotificationProps {
    visible: boolean;
    title: string;
    message: string;
    type: NotificationType;
    onHide: () => void;
    duration?: number;
}

const { width } = Dimensions.get('window');

const NotificationOverlay: React.FC<NotificationProps> = ({
    visible,
    title,
    message,
    type,
    onHide,
    duration = 4000,
}) => {
    const insets = useSafeAreaInsets();
    const translateY = useRef(new Animated.Value(-200)).current;
    const opacity = useRef(new Animated.Value(0)).current;

    useEffect(() => {
        if (visible) {
            // Slide Down
            Animated.parallel([
                Animated.spring(translateY, {
                    toValue: 0,
                    useNativeDriver: true,
                    tension: 50,
                    friction: 8,
                }),
                Animated.timing(opacity, {
                    toValue: 1,
                    duration: 300,
                    useNativeDriver: true,
                }),
            ]).start();

            const timer = setTimeout(() => {
                hide();
            }, duration);

            return () => clearTimeout(timer);
        }
    }, [visible]);

    const hide = () => {
        Animated.parallel([
            Animated.timing(translateY, {
                toValue: -200,
                duration: 300,
                useNativeDriver: true,
            }),
            Animated.timing(opacity, {
                toValue: 0,
                duration: 200,
                useNativeDriver: true,
            }),
        ]).start(() => {
            onHide();
        });
    };

    if (!visible && (translateY as any)._value === -200) return null;

    const getStatusConfig = () => {
        switch (type) {
            case 'success':
                return { icon: 'checkmark-circle', color: '#4CAF50' };
            case 'error':
                return { icon: 'close-circle', color: '#F44336' };
            case 'warning':
                return { icon: 'warning', color: '#FF9800' };
            default:
                return { icon: 'information-circle', color: '#2196F3' };
        }
    };

    const config = getStatusConfig();

    return (
        <Animated.View
            style={[
                styles.container,
                {
                    top: insets.top + 10,
                    transform: [{ translateY }],
                    opacity: opacity,
                },
            ]}
        >
            <BlurView intensity={60} tint="light" style={styles.blurContainer}>
                <View style={[styles.content, { borderColor: `${config.color}99` }]}>
                    <View style={styles.iconContainer}>
                        <Ionicons name={config.icon as any} size={28} color={config.color} />
                    </View>
                    <View style={styles.textContainer}>
                        <Text style={styles.title}>{title}</Text>
                        <Text style={styles.message} numberOfLines={2}>{message}</Text>
                    </View>
                    <TouchableOpacity onPress={hide} style={styles.closeButton}>
                        <Ionicons name="close" size={20} color="#999" />
                    </TouchableOpacity>
                </View>
            </BlurView>
        </Animated.View>
    );
};

const styles = StyleSheet.create({
    container: {
        position: 'absolute',
        left: 16,
        right: 16,
        zIndex: 9999,
        // Shadow for premium feel
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 4 },
        shadowOpacity: 0.15,
        shadowRadius: 10,
        elevation: 8,
    },
    blurContainer: {
        borderRadius: 16,
        overflow: 'hidden',
    },
    content: {
        flexDirection: 'row',
        alignItems: 'center',
        padding: 16,
        borderRadius: 16,
        borderWidth: 1.5, // slightly thicker
        backgroundColor: 'rgba(255, 255, 255, 0.9)', // solid enough for contrast
    },
    iconContainer: {
        marginRight: 12,
    },
    textContainer: {
        flex: 1,
    },
    title: {
        fontSize: 15,
        fontWeight: 'bold',
        color: '#333',
        marginBottom: 2,
    },
    message: {
        fontSize: 13,
        color: '#666',
        lineHeight: 18,
    },
    closeButton: {
        marginLeft: 8,
        padding: 4,
    },
});

export default NotificationOverlay;
