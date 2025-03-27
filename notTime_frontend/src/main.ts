import './assets/tailwind.css'
import { createRouter, createWebHistory } from 'vue-router'
// @ts-ignore
import router from './routes'
import { createApp } from 'vue'
import App from './App.vue'
import { createPinia } from 'pinia';

const app = createApp(App)
const pinia = createPinia();

app.use(pinia);
app.use(router)
app.mount('#app')
