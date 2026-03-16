import { Alert, ToastAndroid, Platform } from 'react-native';

class UIHelper {
    public static showCustomSnackBar(message: string, isError = false, isSuccess = false) {
        if (Platform.OS === 'android') {
            ToastAndroid.show(message, ToastAndroid.SHORT);
        } else {
            // For iOS, usually one uses a library or custom component.
            // For simplicity in this migration, let's use Alert or a generic log.
            // We can also implement a custom component later.
            console.log(`[${isError ? 'ERROR' : isSuccess ? 'SUCCESS' : 'INFO'}] ${message}`);
        }
    }

    public static async showCustomDialog<T = boolean>(
        title: string,
        content: string,
        cancelText = 'Hủy',
        confirmText = 'Xác nhận'
    ): Promise<T | null> {
        return new Promise((resolve) => {
            Alert.alert(
                title,
                content,
                [
                    {
                        text: cancelText,
                        onPress: () => resolve(null),
                        style: 'cancel',
                    },
                    {
                        text: confirmText,
                        onPress: () => resolve(true as unknown as T),
                    },
                ],
                { cancelable: true }
            );
        });
    }

    public static formatCurrency(value: number): string {
        return value.toLocaleString('vi-VN', { style: 'currency', currency: 'VND' });
    }

    public static formatDate(dateStr: string): string {
        if (!dateStr) return '';
        const date = new Date(dateStr);
        return `${date.getDate()}/${date.getMonth() + 1}/${date.getFullYear()}`;
    }
}

export default UIHelper;
