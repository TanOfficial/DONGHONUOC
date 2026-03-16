import React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createStackNavigator } from '@react-navigation/stack';
import { useAuth } from '../context/AuthContext';
import LoginScreen from '../screens/LoginScreen';
import DashboardScreen from '../screens/DashboardScreen';
import DanhSachKHScreen from '../screens/DanhSachKHScreen';
import GhiNuocScreen from '../screens/GhiNuocScreen';
import CameraScreen from '../screens/CameraScreen';

const Stack = createStackNavigator();

export type RootStackParamList = {
    Login: undefined;
    Dashboard: { fullname: string };
    DanhSachKH: undefined;
    GhiNuoc: { customers: any[]; index: number };
    Camera: { onCapture: (uri: string) => void };
};

const AppNavigator = () => {
    const { user, loading } = useAuth();

    if (loading) {
        return null; // Or a loading spinner
    }

    return (
        <NavigationContainer>
            <Stack.Navigator screenOptions={{ headerShown: false }}>
                {!user ? (
                    <Stack.Screen name="Login" component={LoginScreen} />
                ) : (
                    <>
                        <Stack.Screen name="Dashboard" component={DashboardScreen} initialParams={{ fullname: user.fullname }} />
                        <Stack.Screen name="DanhSachKH" component={DanhSachKHScreen} options={{ headerShown: false }} />
                        <Stack.Screen name="GhiNuoc" component={GhiNuocScreen} options={{ headerShown: true, title: 'Ghi Chỉ Số', headerStyle: { backgroundColor: '#2196F3' }, headerTintColor: 'white' }} />
                        <Stack.Screen name="Camera" component={CameraScreen} options={{ headerShown: false }} />
                    </>
                )}
            </Stack.Navigator>
        </NavigationContainer>
    );
};

export default AppNavigator;
