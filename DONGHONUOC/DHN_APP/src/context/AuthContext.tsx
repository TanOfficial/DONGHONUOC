import React, { createContext, useState, useEffect, useContext } from 'react';
import AsyncStorage from '@react-native-async-storage/async-storage';
import ApiService from '../services/ApiService';

interface User {
    username: string;
    fullname: string;
    vaiTro: string;
    avatar: string | null;
}

interface AuthContextType {
    user: User | null;
    loading: boolean;
    login: (userData: User) => Promise<void>;
    logout: () => Promise<void>;
    updateUserAvatar: (avatarBase64: string) => Promise<void>;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const AuthProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
    const [user, setUser] = useState<User | null>(null);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        loadUser();
    }, []);

    const loadUser = async () => {
        try {
            const savedUser = await AsyncStorage.getItem('user_session');
            if (savedUser) {
                const userData = JSON.parse(savedUser);
                setUser(userData);
                ApiService.setUsername(userData.username);
            }
        } catch (e) {
            console.error('Failed to load user session', e);
        } finally {
            setLoading(false);
        }
    };

    const login = async (userData: User) => {
        setUser(userData);
        ApiService.setUsername(userData.username);
        await AsyncStorage.setItem('user_session', JSON.stringify(userData));
    };

    const logout = async () => {
        setUser(null);
        ApiService.setUsername(null);
        await AsyncStorage.removeItem('user_session');
    };

    const updateUserAvatar = async (avatarBase64: string) => {
        if (user) {
            const updatedUser = { ...user, avatar: avatarBase64 };
            setUser(updatedUser);
            await AsyncStorage.setItem('user_session', JSON.stringify(updatedUser));
        }
    };

    return (
        <AuthContext.Provider value={{ user, loading, login, logout, updateUserAvatar }}>
            {children}
        </AuthContext.Provider>
    );
};

export const useAuth = () => {
    const context = useContext(AuthContext);
    if (context === undefined) {
        throw new Error('useAuth must be used within an AuthProvider');
    }
    return context;
};
