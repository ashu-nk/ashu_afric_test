<template>
    <div class="account-card" :class="[account.type, { 'account-inactive': !account.isActive }]">
      <div class="account-header">
        <h3 class="account-name">{{ account.accountName }}</h3>
        <span class="account-type">{{ accountTypeLabel }}</span>
      </div>
      
      <div class="account-balance">
        {{ formatXAF(account.balance) }}
      </div>
      
      <div class="account-number">
        {{ account.accountNumber }}
      </div>
      
      <div class="account-actions" v-if="account.isActive">
        <button 
          @click="$emit('view-transactions', account.id)" 
          class="btn btn-primary"
        >
          Voir transactions
        </button>
        <button 
          @click="$emit('make-transfer', account.id)" 
          class="btn btn-secondary"
        >
          Faire un virement
        </button>
      </div>
      
      <div v-else class="account-inactive-message">
        Compte désactivé
      </div>
    </div>
  </template>
  
  <script setup>
  import { computed } from 'vue';
  import { formatXAF } from '@/utils/currencyFormatter';
  
  const props = defineProps({
    account: {
      type: Object,
      required: true
    }
  });
  
  defineEmits(['view-transactions', 'make-transfer']);
  
  const accountTypeLabel = computed(() => {
    const types = {
      checking: 'Compte Courant',
      savings: 'Compte Épargne',
      investment: 'Compte Investissement'
    };
    return types[props.account.type] || props.account.type;
  });
  </script>
  
  <style scoped>
  .account-card {
    background: white;
    border-radius: 12px;
    padding: 20px;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
    border-left: 4px solid #4CAF50;
    transition: transform 0.2s ease, box-shadow 0.2s ease;
  }
  
  .account-card:hover {
    transform: translateY(-2px);
    box-shadow: 0 4px 16px rgba(0, 0, 0, 0.15);
  }
  
  .account-card.savings {
    border-left-color: #2196F3;
  }
  
  .account-card.investment {
    border-left-color: #FF9800;
  }
  
  .account-card.account-inactive {
    border-left-color: #9E9E9E;
    opacity: 0.7;
  }
  
  .account-header {
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
    margin-bottom: 16px;
  }
  
  .account-name {
    margin: 0;
    font-size: 1.1rem;
    color: #333;
  }
  
  .account-type {
    background: #f5f5f5;
    padding: 4px 8px;
    border-radius: 12px;
    font-size: 0.8rem;
    color: #666;
  }
  
  .account-balance {
    font-size: 1.8rem;
    font-weight: bold;
    color: #2c3e50;
    margin-bottom: 8px;
  }
  
  .account-number {
    color: #666;
    font-size: 0.9rem;
    margin-bottom: 20px;
  }
  
  .account-actions {
    display: flex;
    gap: 10px;
  }
  
  .btn {
    padding: 8px 16px;
    border: none;
    border-radius: 6px;
    cursor: pointer;
    font-size: 0.9rem;
    transition: background-color 0.2s ease;
  }
  
  .btn-primary {
    background-color: #4CAF50;
    color: white;
  }
  
  .btn-primary:hover {
    background-color: #45a049;
  }
  
  .btn-secondary {
    background-color: #2196F3;
    color: white;
  }
  
  .btn-secondary:hover {
    background-color: #0b7dda;
  }
  
  .account-inactive-message {
    color: #9E9E9E;
    font-style: italic;
    text-align: center;
    padding: 10px;
  }
  </style>