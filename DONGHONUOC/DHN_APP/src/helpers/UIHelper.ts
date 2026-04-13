import { Alert, ToastAndroid, Platform } from 'react-native';

class UIHelper {
    private static showNotificationFunc: (title: string, message: string, type: 'success' | 'error' | 'warning' | 'info') => void;

    public static setNotificationHandler(handler: typeof UIHelper.showNotificationFunc) {
        this.showNotificationFunc = handler;
    }

    public static showCustomSnackBar(message: string, isError = false, isSuccess = false) {
        if (this.showNotificationFunc) {
            const type = isError ? 'error' : isSuccess ? 'success' : 'info';
            const title = isError ? 'Lỗi' : isSuccess ? 'Thành công' : 'Thông báo';
            this.showNotificationFunc(title, message, type);
        } else {
            console.log(`[SNACKBAR] ${message}`);
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
