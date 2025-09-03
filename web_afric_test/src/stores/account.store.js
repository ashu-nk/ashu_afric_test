import { defineStore } from 'pinia';
import { ref, computed } from 'vue';
import { formatXAF } from '@/utils/currencyFormatter';

export const useAccountStore = defineStore('account', () => {
  const accounts = ref([
    {
      id: 1,
      accountNumber: 'CM00100012345',
      accountName: 'Compte Principal',
      balance: 1250000,
      currency: 'XAF',
      type: 'checking',
      isActive: true
    },
    {
      id: 2,
      accountNumber: 'CM00100067890',
      accountName: 'Compte Épargne',
      balance: 3500000,
      currency: 'XAF',
      type: 'savings',
      isActive: true
    },
    {
      id: 3,
      accountNumber: 'CM00100054321',
      accountName: 'Compte Courant',
      balance: 750000,
      currency: 'XAF',
      type: 'checking',
      isActive: true
    }
  ]);

  const isLoading = ref(false);
  const error = ref(null);

  // Getters
  const totalBalance = computed(() => {
    return accounts.value.reduce((total, account) => total + account.balance, 0);
  });

  const formattedTotalBalance = computed(() => {
    return formatXAF(totalBalance.value);
  });

  const activeAccounts = computed(() => {
    return accounts.value.filter(account => account.isActive);
  });

  // Actions
  const fetchAccounts = async () => {
    isLoading.value = true;
    error.value = null;
    
    try {
      // Simulate API call
      await new Promise(resolve => setTimeout(resolve, 1000));
      // In real app, you would fetch from API here
    } catch (err) {
      error.value = 'Erreur lors du chargement des comptes';
      console.error('Failed to fetch accounts:', err);
    } finally {
      isLoading.value = false;
    }
  };

  const getAccountById = (id) => {
    return accounts.value.find(account => account.id === id);
  };

  const updateAccountBalance = (accountId, amount) => {
    const account = accounts.value.find(acc => acc.id === accountId);
    if (account) {
      account.balance += amount;
    }
  };

  return {
    accounts,
    isLoading,
    error,
    totalBalance,
    formattedTotalBalance,
    activeAccounts,
    fetchAccounts,
    getAccountById,
    updateAccountBalance
  };
});