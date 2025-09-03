// import { createRouter, createWebHistory } from 'vue-router';

// import { useAuthStore, useAlertStore } from '@/stores';
// import { Home } from '@/views';
// import accountRoutes from './account.routes';
// import usersRoutes from './users.routes';

// export const router = createRouter({
//     history: createWebHistory(import.meta.env.BASE_URL),
//     linkActiveClass: 'active',
//     routes: [
//         { path: '/', component: Home },
//         { ...accountRoutes },
//         { ...usersRoutes },
//         {
//             path: '/',
//             name: 'Dashboard',
//             component: Dashboard,
//             meta: { requiresAuth: true }
//           },
        
//         // catch all redirect to home page
//         { path: '/:pathMatch(.*)*', redirect: '/' }
//     ]
// });

// router.beforeEach(async (to) => {
//     // clear alert on route change
//     const alertStore = useAlertStore();
//     alertStore.clear();

//     // redirect to login page if not logged in and trying to access a restricted page 
//     const publicPages = ['/account/login', '/account/register'];
//     const authRequired = !publicPages.includes(to.path);
//     const authStore = useAuthStore();

//     if (authRequired && !authStore.user) {
//         authStore.returnUrl = to.fullPath;
//         return '/account/login';
//     }
// });
import { createRouter, createWebHistory } from 'vue-router';

import { useAuthStore, useAlertStore } from '@/stores';
import { Home, Mydashboard,Transactions, Transfer   } from '@/views';

import accountRoutes from './account.routes';
import usersRoutes from './users.routes';

export const router = createRouter({
    history: createWebHistory(import.meta.env.BASE_URL),
    linkActiveClass: 'active',
    routes: [
        // Redirect root path to login page
        { path: '/', redirect: '/auth/login' },

        // Dashboard route - CORRECTLY PLACED INSIDE routes array
        { 
            path: '/myDashboard', 
            name: 'Mydashboard',
          
            component: Mydashboard,
            meta: { requiresAuth: true } 
        },
        
        // Home route (if still needed for other purposes)
        { path: '/home', component: Home, meta: { requiresAuth: true } },

        {
            path: '/transactions',
            name: 'Transactions',
            component:  Transactions,
           
            meta: { requiresAuth: true }
          },
          {
            path: '/transfer', 
            name: 'Transfer',
            component:Transfer,
  
            meta: { requiresAuth: true }
          },
          
        
        // Your existing routes
        { ...accountRoutes },
        { ...usersRoutes },
        
        // Catch all redirect to login page
        { path: '/:pathMatch(.*)*', redirect: '/auth/login' }
    ]
});

router.beforeEach(async (to) => {
    // clear alert on route change
    const alertStore = useAlertStore();
    alertStore.clear();

    // redirect to login page if not logged in and trying to access a restricted page 
    const publicPages = ['/auth/login', '/auth/register'];
    const authRequired = !publicPages.includes(to.path);
    const authStore = useAuthStore();

    if (authRequired && !authStore.user) {
        authStore.returnUrl = to.fullPath;
        return '/auth/login';
    }
});