import React, { useState, useEffect } from 'react';
import { AuthProvider } from './src/context/AuthContext';
import { NotificationProvider } from './src/context/NotificationContext';
import AppNavigator from './src/navigation/AppNavigator';
import { GestureHandlerRootView } from 'react-native-gesture-handler';
import { SafeAreaProvider } from 'react-native-safe-area-context';
import * as Font from 'expo-font';
import { Ionicons } from '@expo/vector-icons';

export default function App() {
  const [fontLoaded, setFontLoaded] = useState(false);

  useEffect(() => {
    async function loadFonts() {
      try {
        await Font.loadAsync(Ionicons.font);
      } catch (e) {
        console.warn('Font loading error:', e);
      } finally {
        setFontLoaded(true);
      }
    }
    loadFonts();
  }, []);

  if (!fontLoaded) return null;

  return (
    <SafeAreaProvider>
      <GestureHandlerRootView style={{ flex: 1 }}>
        <NotificationProvider>
          <AuthProvider>
            <AppNavigator />
          </AuthProvider>
        </NotificationProvider>
      </GestureHandlerRootView>
    </SafeAreaProvider>
  );
}
