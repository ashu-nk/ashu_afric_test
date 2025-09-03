
import { Layout, Login, Register } from '@/views/account';

export default {
    path: '/auth', // Changed from /account to /auth
    component: Layout,
    children: [
        { path: '', redirect: 'login' },
        { path: 'login', component: Login },
        { path: 'register', component: Register }
    ]
};