import React, { createContext, useContext, useState, useCallback, useEffect } from 'react';
import NotificationOverlay, { NotificationType } from '../components/common/NotificationOverlay';
import UIHelper from '../helpers/UIHelper';

interface NotificationContextData {
    showNotification: (title: string, message: string, type?: NotificationType) => void;
}

const NotificationContext = createContext<NotificationContextData>({} as NotificationContextData);

export const NotificationProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
    const [visible, setVisible] = useState(false);
    const [config, setConfig] = useState<{ title: string; message: string; type: NotificationType }>({
        title: '',
        message: '',
        type: 'info',
    });

    const showNotification = useCallback((title: string, message: string, type: NotificationType = 'info') => {
        setConfig({ title, message, type });
        setVisible(true);
    }, []);

    useEffect(() => {
        UIHelper.setNotificationHandler(showNotification);
    }, [showNotification]);

    const hideNotification = useCallback(() => {
        setVisible(false);
    }, []);

    return (
        <NotificationContext.Provider value={{ showNotification }}>
            {children}
            <NotificationOverlay
                visible={visible}
                title={config.title}
                message={config.message}
                type={config.type}
                onHide={hideNotification}
            />
        </NotificationContext.Provider>
    );
};

export const useNotification = () => useContext(NotificationContext);
