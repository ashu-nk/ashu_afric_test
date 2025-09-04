<template>
    <div class="transfer">
      <div class="header">
        <h2>Effectuer un Virement</h2>
        <button @click="$router.back()" class="btn-back">← Retour</button>
      </div>
  
      <form @submit.prevent="validateForm" class="transfer-form">
        <!-- Source Account -->
        <div class="form-group">
          <label>Compte source *</label>
          <select v-model="transfer.fromAccountId" required>
            <option v-for="account in accounts" :key="account.id" :value="account.id">
              {{ account.accountName }} - {{ formatXAF(account.balance) }}
            </option>
          </select>
        </div>
  
        <!-- Beneficiary -->
        <div class="form-group">
          <label>Numéro de compte bénéficiaire *</label>
          <input 
            v-model="transfer.toAccountNumber" 
            required 
            pattern="[0-9]{10,20}"
            placeholder="1234567890"
          >
        </div>
  
        <!-- Amount -->
        <div class="form-group">
          <label>Montant (XAF) *</label>
          <input 
            v-model.number="transfer.amount" 
            type="number" 
            required 
            :min="1" 
            :max="selectedAccount?.balance"
          >
          <div class="balance-info" v-if="selectedAccount">
            Solde disponible: {{ formatXAF(selectedAccount.balance) }}
          </div>
        </div>
  
        <!-- Note -->
        <div class="form-group">
          <label>Note (optionnel)</label>
          <textarea v-model="transfer.note" placeholder="Raison du virement..."></textarea>
        </div>
  
        <!-- Validation Errors -->
        <div v-if="errors.length" class="error-messages">
          <div v-for="error in errors" :key="error" class="error-message">
            {{ error }}
          </div>
        </div>
  
        <!-- Submit Button -->
        <button type="submit" :disabled="loading" class="btn-submit">
          {{ loading ? 'Traitement...' : 'Continuer' }}
        </button>
      </form>
  
      <!-- Confirmation Modal -->
      <div v-if="showConfirmation" class="modal-overlay">
        <div class="modal-content">
          <h3>Confirmer le Virement</h3>
          
          <div class="transfer-details">
            <div class="detail-row">
              <span class="label">De:</span>
              <span class="value">{{ selectedAccount?.accountName }}</span>
            </div>
            <div class="detail-row">
              <span class="label">Vers:</span>
              <span class="value">{{ transfer.toAccountNumber }}</span>
            </div>
            <div class="detail-row">
              <span class="label">Montant:</span>
              <span class="value">{{ formatXAF(transfer.amount) }}</span>
            </div>
            <div class="detail-row" v-if="transfer.note">
              <span class="label">Note:</span>
              <span class="value">{{ transfer.note }}</span>
            </div>
          </div>
  
          <div class="modal-actions">
            <button @click="showConfirmation = false" class="btn-cancel">
              Annuler
            </button>
            <button @click="executeTransfer" :disabled="loading" class="btn-confirm">
              {{ loading ? 'Traitement...' : 'Confirmer' }}
            </button>
          </div>
        </div>
      </div>
  
      <!-- Success/Error Feedback -->
      <div v-if="feedback.message" :class="['feedback', feedback.type]">
        {{ feedback.message }}
      </div>
    </div>
  </template>
  
  <script setup>
  import { ref, computed, onMounted } from 'vue';
  import { useRouter, useRoute } from 'vue-router';
  import { useAccountStore } from '@/stores/account.store';
  import { formatXAF } from '@/utils/currencyFormatter';
  
  const router = useRouter();
  const route = useRoute();
  const accountStore = useAccountStore();
  
  const transfer = ref({
    fromAccountId: route.query.fromAccount || '',
    toAccountNumber: '',
    amount: null,
    note: ''
  });
  
  const showConfirmation = ref(false);
  const loading = ref(false);
  const errors = ref([]);
  const feedback = ref({ message: '', type: '' });
  
  const accounts = computed(() => accountStore.activeAccounts);
  const selectedAccount = computed(() => 
    accounts.value.find(acc => acc.id === transfer.value.fromAccountId)
  );
  
  const validateForm = () => {
    errors.value = [];
  
    if (!transfer.value.fromAccountId) {
      errors.value.push('Veuillez sélectionner un compte source');
    }
  
    if (!transfer.value.toAccountNumber) {
      errors.value.push('Veuillez saisir le numéro du bénéficiaire');
    } else if (!/^\d{10,20}$/.test(transfer.value.toAccountNumber)) {
      errors.value.push('Le numéro de compte doit contenir 10 à 20 chiffres');
    }
  
    if (!transfer.value.amount || transfer.value.amount <= 0) {
      errors.value.push('Le montant doit être supérieur à 0');
    } else if (selectedAccount.value && transfer.value.amount > selectedAccount.value.balance) {
      errors.value.push('Le montant ne peut pas dépasser le solde du compte');
    }
  
    if (errors.value.length === 0) {
      showConfirmation.value = true;
    }
  };
  
  const executeTransfer = async () => {
    loading.value = true;
    
    try {
      // Simulate API call
      await new Promise(resolve => setTimeout(resolve, 2000));
      
      // Random success/failure for demo
      const isSuccess = Math.random() > 0.2;
      
      if (isSuccess) {
        feedback.value = {
          message: 'Virement effectué avec succès!',
          type: 'success'
        };
        
        // Update account balance locally
        accountStore.updateAccountBalance(
          transfer.value.fromAccountId, 
          -transfer.value.amount
        );
        
        setTimeout(() => {
          router.push('/myDashboard');
        }, 2000);
        
      } else {
        throw new Error('Échec du virement. Veuillez réessayer.');
      }
      
    } catch (error) {
      feedback.value = {
        message: error.message,
        type: 'error'
      };
    } finally {
      loading.value = false;
      showConfirmation.value = false;
    }
  };
  
  onMounted(() => {
    if (!accountStore.accounts.length) {
      accountStore.fetchAccounts();
    }
  });
  </script>
  
  <style scoped>
  .transfer {
    max-width: 600px;
    margin: 0 auto;
    padding: 20px;
  }
  
  .header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 30px;
  }
  
  .transfer-form {
    background: white;
    padding: 30px;
    border-radius: 8px;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  }
  
  .form-group {
    margin-bottom: 20px;
  }
  
  .form-group label {
    display: block;
    margin-bottom: 5px;
    font-weight: bold;
  }
  
  .form-group input,
  .form-group select,
  .form-group textarea {
    width: 100%;
    padding: 10px;
    border: 1px solid #ddd;
    border-radius: 4px;
    box-sizing: border-box;
  }
  
  .balance-info {
    font-size: 0.9rem;
    color: #666;
    margin-top: 5px;
  }
  
  .error-messages {
    background-color: #ffebee;
    border: 1px solid #f44336;
    border-radius: 4px;
    padding: 15px;
    margin-bottom: 20px;
  }
  
  .error-message {
    color: #f44336;
    margin-bottom: 5px;
  }
  
  .btn-submit,
  .btn-back {
    padding: 12px 24px;
    border: none;
    border-radius: 4px;
    cursor: pointer;
    font-size: 1rem;
  }
  
  .btn-submit {
    background-color: #4CAF50;
    color: white;
    width: 100%;
  }
  
  .btn-submit:disabled {
    opacity: 0.6;
    cursor: not-allowed;
  }
  
  .btn-back {
    background-color: #2196F3;
    color: white;
  }
  
  .modal-overlay {
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background-color: rgba(0, 0, 0, 0.5);
    display: flex;
    align-items: center;
    justify-content: center;
    z-index: 1000;
  }
  
  .modal-content {
    background: white;
    padding: 30px;
    border-radius: 8px;
    max-width: 500px;
    width: 90%;
  }
  
  .modal-content h3 {
    margin: 0 0 20px 0;
    color: #2c3e50;
  }
  
  .transfer-details {
    margin-bottom: 30px;
  }
  
  .detail-row {
    display: flex;
    justify-content: space-between;
    margin-bottom: 10px;
    padding: 10px;
    background-color: #f9f9f9;
    border-radius: 4px;
  }
  
  .detail-row .label {
    font-weight: bold;
    color: #666;
  }
  
  .detail-row .value {
    color: #2c3e50;
  }
  
  .modal-actions {
    display: flex;
    gap: 15px;
    justify-content: flex-end;
  }
  
  .btn-cancel,
  .btn-confirm {
    padding: 10px 20px;
    border: none;
    border-radius: 4px;
    cursor: pointer;
  }
  
  .btn-cancel {
    background-color: #f44336;
    color: white;
  }
  
  .btn-confirm {
    background-color: #4CAF50;
    color: white;
  }
  
  .btn-confirm:disabled {
    opacity: 0.6;
    cursor: not-allowed;
  }
  
  .feedback {
    padding: 15px;
    border-radius: 4px;
    margin-top: 20px;
    text-align: center;
  }
  
  .feedback.success {
    background-color: #e8f5e8;
    color: #2e7d32;
    border: 1px solid #4CAF50;
  }
  
  .feedback.error {
    background-color: #ffebee;
    color: #f44336;
    border: 1px solid #f44336;
  }
  </style>