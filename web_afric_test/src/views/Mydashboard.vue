<template>
    <div class="dashboard">
      <div class="dashboard-header">
        <h1>Tableau de Bord</h1>
        <div class="total-balance">
          Solde total: <strong>{{ accountStore.formattedTotalBalance }}</strong>
        </div>
      </div>
  
      <!-- Loading State -->
      <div v-if="accountStore.isLoading" class="loading-state">
        <div class="spinner"></div>
        <p>Chargement de vos comptes...</p>
      </div>
  
      <!-- Error State -->
      <div v-else-if="accountStore.error" class="error-state">
        <div class="error-icon">⚠️</div>
        <h3>Erreur de chargement</h3>
        <p>{{ accountStore.error }}</p>
        <button @click="accountStore.fetchAccounts()" class="btn btn-primary">
          Réessayer
        </button>
      </div>
  
      <!-- Empty State -->
      <div v-else-if="accountStore.activeAccounts.length === 0" class="empty-state">
        <div class="empty-icon">🏦</div>
        <h3>Aucun compte actif</h3>
        <p>Vous n'avez aucun compte bancaire actif pour le moment.</p>
      </div>
  
      <!-- Success State -->
      <div v-else class="dashboard-content">
        <div class="accounts-grid">
          <AccountCard
            v-for="account in accountStore.activeAccounts"
            :key="account.id"
            :account="account"
            @view-transactions="handleViewTransactions"
            @make-transfer="handleMakeTransfer"
          />
        </div>
  
        <!-- Dashboard summary stats -->
        <div class="dashboard-summary">
          <div class="summary-card">
            <h4>Nombre de comptes</h4>
            <p class="summary-value">{{ accountStore.activeAccounts.length }}</p>
          </div>
          <div class="summary-card">
            <h4>Solde total</h4>
            <p class="summary-value">{{ accountStore.formattedTotalBalance }}</p>
          </div>
        </div>
      </div>
    </div>
  </template>
  
  <script setup>
  import { onMounted } from 'vue';
  import { useRouter } from 'vue-router';
  import { useAccountStore } from '@/stores/account.store';
  import AccountCard from '@/components/AccountCard.vue';
  
  const accountStore = useAccountStore();
  const router = useRouter();
  
  onMounted(() => {
    accountStore.fetchAccounts();
  });
  
  const handleViewTransactions = (accountId) => {
    router.push({
      name: 'Transactions',
      query: { accountId }
    });
  };
  
  const handleMakeTransfer = (accountId) => {
    router.push({
      name: 'Transfer',
      query: { fromAccount: accountId }
    });
  };
  </script>
  
  <style scoped>
  .dashboard {
    max-width: 1200px;
    margin: 0 auto;
    padding: 20px;
  }
  
  .dashboard-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 30px;
    padding-bottom: 20px;
    border-bottom: 1px solid #eee;
  }
  
  .dashboard-header h1 {
    margin: 0;
    color: #2c3e50;
  }
  
  .total-balance {
    font-size: 1.1rem;
    color: #666;
  }
  
  .accounts-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
    gap: 20px;
    margin-bottom: 30px;
  }
  
  .dashboard-summary {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
    gap: 20px;
  }
  
  .summary-card {
    background: white;
    padding: 20px;
    border-radius: 8px;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
    text-align: center;
  }
  
  .summary-card h4 {
    margin: 0 0 10px 0;
    color: #666;
    font-size: 0.9rem;
    font-weight: normal;
  }
  
  .summary-value {
    margin: 0;
    font-size: 1.5rem;
    font-weight: bold;
    color: #2c3e50;
  }
  
  /* Loading, Error, and Empty States */
  .loading-state,
  .error-state,
  .empty-state {
    text-align: center;
    padding: 60px 20px;
    background: white;
    border-radius: 8px;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  }
  
  .spinner {
    width: 40px;
    height: 40px;
    border: 4px solid #f3f3f3;
    border-top: 4px solid #4CAF50;
    border-radius: 50%;
    animation: spin 1s linear infinite;
    margin: 0 auto 20px;
  }
  
  @keyframes spin {
    0% { transform: rotate(0deg); }
    100% { transform: rotate(360deg); }
  }
  
  .error-icon,
  .empty-icon {
    font-size: 3rem;
    margin-bottom: 20px;
  }
  
  .error-state h3,
  .empty-state h3 {
    margin: 0 0 10px 0;
    color: #2c3e50;
  }
  
  .error-state p,
  .empty-state p {
    margin: 0 0 20px 0;
    color: #666;
  }
  
  @media (max-width: 768px) {
    .dashboard-header {
      flex-direction: column;
      gap: 15px;
      text-align: center;
    }
    
    .accounts-grid {
      grid-template-columns: 1fr;
    }
  }
  </style>