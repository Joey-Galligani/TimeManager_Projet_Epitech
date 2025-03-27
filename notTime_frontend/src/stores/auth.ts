import { defineStore } from 'pinia';
import { ref, computed } from 'vue';
import { useRouter } from 'vue-router';
import { jwtDecode } from 'jwt-decode';

interface DecodedToken {
    exp: number;
    user_id: number;
    [key: string]: any;
}

interface UserInfo {
    id: number;
    name: string | null;
    username: string | null;
    email: string;
    is_admin: boolean;
    lastname: string | null;
    phone: string | null;
    team_id: number | null;
    url_picture: string | null;
    // Add other fields as needed
}

export const useAuthStore = defineStore('auth', () => {
    const token = ref<string | null>(localStorage.getItem('token'));
    const isAuthenticated = ref<boolean>(!!token.value);
    const userInfo = ref<UserInfo | null>(localStorage.getItem('userInfo') ? JSON.parse(localStorage.getItem('userInfo')!) : null);
    const logoutTimer = ref<number | null>(null);
    const router = useRouter();

    function setToken(newToken: string) {
        token.value = newToken;
        isAuthenticated.value = true;
        localStorage.setItem('token', newToken);
        console.log('Token set:', newToken);
        setLogoutTimer();
    }

    function setUserInfo(newUserInfo: UserInfo) {
        userInfo.value = newUserInfo;
        localStorage.setItem('userInfo', JSON.stringify(newUserInfo));
        console.log('User info set:', newUserInfo);
    }

    function clearAuthData() {
        token.value = null;
        isAuthenticated.value = false;
        userInfo.value = null;
        localStorage.removeItem('token');
        localStorage.removeItem('userInfo');
        if (logoutTimer.value) {
            clearTimeout(logoutTimer.value);
            logoutTimer.value = null;
        }
    }

    function decodeToken(): DecodedToken | null {
        if (!token.value) return null;
        try {
            return jwtDecode<DecodedToken>(token.value);
        } catch (e) {
            console.error('Invalid token:', e);
            return null;
        }
    }

    const isTokenExpired = computed(() => {
        const decoded = decodeToken();
        if (!decoded || !decoded.exp) {
            return true;
        }
        const currentTime = Date.now() / 1000;
        console.log("currentTime", currentTime);
        console.log("decoded.exp", decoded.exp);

        return decoded.exp < currentTime;
    });

    function setLogoutTimer() {
        const decoded = decodeToken();
        if (!decoded || !decoded.exp) {
            clearAuthData();
            return;
        }
        const currentTime = Date.now() / 1000;
        const expiresIn = (decoded.exp - currentTime) * 1000; // Convert to milliseconds
        if (expiresIn <= 0) {
            clearAuthData();
        } else {
            if (logoutTimer.value) {
                clearTimeout(logoutTimer.value);
            }
            logoutTimer.value = setTimeout(() => {
                clearAuthData();
                router.push('/log-reg');
            }, expiresIn);
        }
    }

    // Initialize the logout timer if authenticated
    if (isAuthenticated.value && !isTokenExpired.value) {
        setLogoutTimer();
    }

    // Listen to localStorage changes (for multi-tab support)
    window.addEventListener('storage', (event) => {
        if (event.key === 'token') {
            if (!event.newValue) {
                // Token was removed in another tab
                clearAuthData();
            } else {
                // Token was updated in another tab
                token.value = event.newValue;
                isAuthenticated.value = true;
                setLogoutTimer();
            }
        }
    });

    return {
        token,
        isAuthenticated,
        userInfo,
        setToken,
        setUserInfo,
        clearAuthData,
        isTokenExpired,
    };
});
