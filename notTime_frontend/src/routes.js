import { createRouter, createWebHistory } from 'vue-router';
import { useAuthStore } from './stores/auth';
import Accueil from './pages/Accueil.vue';
import Clock from './pages/Clock.vue';
import Calendar from './pages/Calendar.vue';
import Holydays from './pages/Holyday.vue';
import Login from './pages/Login.vue';
import Dashboard from './pages/Dashboard.vue';

const routes = [
    { path: '/', redirect: '/log-reg' },
    { path: '/log-reg', name: 'LoginRegister', component: Login },
    { path: '/home', name: 'Accueil', component: Accueil },
    { path: '/clock', name: 'Clock', component: Clock },
    { path: '/calendar', name: 'Calendar', component: Calendar },
    { path: '/holyday', name: 'Holyday', component: Holydays },
    { path: '/dashboard', name: 'Dashboard', component: Dashboard},
];

const router = createRouter({
    history: createWebHistory(),
    routes,
});

// Global navigation guard
router.beforeEach((to, from, next) => {
    const authStore = useAuthStore();

    if (authStore.isAuthenticated && authStore.isTokenExpired) {
        // Token is expired, clear auth and redirect to login
        authStore.clearAuthData();
        next({ name: 'LoginRegister' });
    } else if (authStore.isAuthenticated && !authStore.isTokenExpired) {
        if (to.name === 'LoginRegister') {
            // Redirect authenticated users away from the login/register page
            next({ name: 'Accueil' });
        } else {
            next();
        }
    } else if (to.name !== 'LoginRegister' && !authStore.isAuthenticated) {
        // User is not authenticated, redirect to login
        next({ name: 'LoginRegister' });
    } else {
        next();
    }
});

export default router;
