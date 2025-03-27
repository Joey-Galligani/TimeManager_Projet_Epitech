import { useRouter } from 'vue-router';
import { useAuthStore } from '../stores/auth';

export async function authFetch(url: string, options: any = {}) {
    const authStore = useAuthStore();
    const router = useRouter();

    if (!authStore.token || authStore.isTokenExpired) {
        authStore.clearAuthData();
        router.push('/log-reg');
        throw new Error('Token expired or not present');
    }

    if (!options.headers) {
        options.headers = {};
    }

    options.headers['Authorization'] = `Bearer ${authStore.token}`;

    const response = await fetch(url, options);

    if (response.status === 401) {
        // Unauthorized, handle token expiration
        authStore.clearAuthData();
        router.push('/log-reg');
        throw new Error('Unauthorized');
    }

    return response;
}

//! Example usage in any component
// import { authFetch } from '../utils/authFetch';

// const response = await authFetch('http://localhost:4000/api/protected', {
//   method: 'GET',
// });