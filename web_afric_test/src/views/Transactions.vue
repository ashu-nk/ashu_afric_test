<template>
    <div class="transactions">
      <div class="header">
        <h2>Transactions du Compte</h2>
        <button @click="$router.back()" class="btn-back">← Retour</button>
      </div>
  
      <!-- Filters -->
      <div class="filters">
        <div class="filter-group">
          <input v-model="filters.search" placeholder="Rechercher..." class="search-input" />
        </div>
        
        <div class="filter-group">
          <select v-model="filters.type" class="select-filter">
            <option value="all">Tous les types</option>
            <option value="debit">Débits</option>
            <option value="credit">Crédits</option>
          </select>
        </div>
  
        <div class="filter-group">
          <input type="date" v-model="filters.startDate" class="date-filter" />
          <span>à</span>
          <input type="date" v-model="filters.endDate" class="date-filter" />
        </div>
  
        <button @click="applyFilters" class="btn-apply">Appliquer</button>
        <button @click="resetFilters" class="btn-reset">Réinitialiser</button>
      </div>
  
      <!-- Transactions Table -->
      <div class="transactions-table">
        <table>
          <thead>
            <tr>
              <th @click="sortBy('date')" class="sortable">
                Date ↑↓
              </th>
              <th @click="sortBy('description')" class="sortable">
                Description ↑↓
              </th>
              <th @click="sortBy('amount')" class="sortable">
                Montant ↑↓
              </th>
              <th>Statut</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="transaction in paginatedTransactions" :key="transaction.id">
              <td>{{ formatDate(transaction.date) }}</td>
              <td>{{ transaction.description }}</td>
              <td :class="{ 'text-red': transaction.amount < 0, 'text-green': transaction.amount > 0 }">
                {{ formatXAF(transaction.amount) }}
              </td>
              <td>
                <span class="status-badge" :class="transaction.status">
                  {{ transaction.status }}
                </span>
              </td>
            </tr>
          </tbody>
        </table>
  
        <!-- Empty State -->
        <div v-if="filteredTransactions.length === 0" class="empty-state">
          <p>Aucune transaction trouvée</p>
        </div>
      </div>
  
      <!-- Pagination -->
      <div class="pagination" v-if="filteredTransactions.length > 0">
        <button @click="prevPage" :disabled="currentPage === 1">← Précédent</button>
        <span>Page {{ currentPage }} sur {{ totalPages }}</span>
        <button @click="nextPage" :disabled="currentPage === totalPages">Suivant →</button>
      </div>
  
      <!-- Loading State -->
      <div v-if="loading" class="loading">
        <div class="spinner"></div>
        <p>Chargement des transactions...</p>
      </div>
    </div>
  </template>
  
  <script setup>
  import { ref, computed, onMounted, watch } from 'vue';
  import { useRoute } from 'vue-router';
  import { formatXAF } from '@/utils/currencyFormatter';
  
  const route = useRoute();
  const accountId = route.query.accountId;
  
  const transactions = ref([]);
  const loading = ref(false);
  const currentPage = ref(1);
  const itemsPerPage = 10;
  
  const filters = ref({
    search: '',
    type: 'all',
    startDate: null,
    endDate: null
  });
  
  const sortField = ref('date');
  const sortDirection = ref('desc');
  
  // Mock API call - replace with actual API
  const fetchTransactions = async () => {
    loading.value = true;
    try {
      // Simulate API delay
      await new Promise(resolve => setTimeout(resolve, 1000));
      
      // Mock data - replace with actual API response
      transactions.value = [
        {
          id: 'tx_1',
          date: '2025-07-12T09:22:00Z',
          amount: -25000,
          currency: 'XAF',
          description: 'Loyer Juillet',
          status: 'posted'
        },
        {
          id: 'tx_2',
          date: '2025-07-10T14:11:00Z',
          amount: 150000,
          currency: 'XAF',
          description: 'Salaire',
          status: 'posted'
        },
        // Add more mock transactions...
      ];
    } catch (error) {
      console.error('Error fetching transactions:', error);
    } finally {
      loading.value = false;
    }
  };
  
  const filteredTransactions = computed(() => {
    let filtered = transactions.value;
  
    // Search filter
    if (filters.value.search) {
      const searchLower = filters.value.search.toLowerCase();
      filtered = filtered.filter(t => 
        t.description.toLowerCase().includes(searchLower)
      );
    }
  
    // Type filter
    if (filters.value.type !== 'all') {
      filtered = filtered.filter(t => 
        filters.value.type === 'debit' ? t.amount < 0 : t.amount > 0
      );
    }
  
    // Date range filter
    if (filters.value.startDate) {
      filtered = filtered.filter(t => 
        new Date(t.date) >= new Date(filters.value.startDate)
      );
    }
    if (filters.value.endDate) {
      filtered = filtered.filter(t => 
        new Date(t.date) <= new Date(filters.value.endDate)
      );
    }
  
    // Sorting
    return filtered.sort((a, b) => {
      let aValue = a[sortField.value];
      let bValue = b[sortField.value];
  
      if (sortField.value === 'date') {
        aValue = new Date(aValue);
        bValue = new Date(bValue);
      }
  
      return sortDirection.value === 'asc' 
        ? aValue < bValue ? -1 : 1
        : aValue > bValue ? -1 : 1;
    });
  });
  
  const paginatedTransactions = computed(() => {
    const start = (currentPage.value - 1) * itemsPerPage;
    return filteredTransactions.value.slice(start, start + itemsPerPage);
  });
  
  const totalPages = computed(() => 
    Math.ceil(filteredTransactions.value.length / itemsPerPage)
  );
  
  const sortBy = (field) => {
    if (sortField.value === field) {
      sortDirection.value = sortDirection.value === 'asc' ? 'desc' : 'asc';
    } else {
      sortField.value = field;
      sortDirection.value = 'desc';
    }
  };
  
  const nextPage = () => {
    if (currentPage.value < totalPages.value) {
      currentPage.value++;
    }
  };
  
  const prevPage = () => {
    if (currentPage.value > 1) {
      currentPage.value--;
    }
  };
  
  const applyFilters = () => {
    currentPage.value = 1;
  };
  
  const resetFilters = () => {
    filters.value = {
      search: '',
      type: 'all',
      startDate: null,
      endDate: null
    };
    currentPage.value = 1;
  };
  
  const formatDate = (dateString) => {
    return new Date(dateString).toLocaleDateString('fr-FR');
  };
  
  onMounted(() => {
    if (accountId) {
      fetchTransactions();
    }
  });
  
  watch(accountId, (newAccountId) => {
    if (newAccountId) {
      fetchTransactions();
    }
  });
  </script>
  
  <style scoped>
  .transactions {
    max-width: 1200px;
    margin: 0 auto;
    padding: 20px;
  }
  
  .header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 20px;
  }
  
  .filters {
    display: flex;
    gap: 15px;
    margin-bottom: 20px;
    flex-wrap: wrap;
    align-items: center;
  }
  
  .filter-group {
    display: flex;
    align-items: center;
    gap: 10px;
  }
  
  .search-input, .select-filter, .date-filter {
    padding: 8px 12px;
    border: 1px solid #ddd;
    border-radius: 4px;
  }
  
  .btn-apply, .btn-reset, .btn-back {
    padding: 8px 16px;
    border: none;
    border-radius: 4px;
    cursor: pointer;
  }
  
  .btn-apply {
    background-color: #4CAF50;
    color: white;
  }
  
  .btn-reset {
    background-color: #f44336;
    color: white;
  }
  
  .btn-back {
    background-color: #2196F3;
    color: white;
  }
  
  .transactions-table {
    background: white;
    border-radius: 8px;
    overflow: hidden;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  }
  
  table {
    width: 100%;
    border-collapse: collapse;
  }
  
  th, td {
    padding: 12px;
    text-align: left;
    border-bottom: 1px solid #eee;
  }
  
  th.sortable {
    cursor: pointer;
    user-select: none;
  }
  
  th.sortable:hover {
    background-color: #f5f5f5;
  }
  
  .text-red {
    color: #f44336;
  }
  
  .text-green {
    color: #4CAF50;
  }
  
  .status-badge {
    padding: 4px 8px;
    border-radius: 12px;
    font-size: 0.8rem;
  }
  
  .status-badge.posted {
    background-color: #e8f5e8;
    color: #2e7d32;
  }
  
  .pagination {
    display: flex;
    justify-content: center;
    align-items: center;
    gap: 20px;
    margin-top: 20px;
  }
  
  .pagination button {
    padding: 8px 16px;
    border: 1px solid #ddd;
    background: white;
    cursor: pointer;
    border-radius: 4px;
  }
  
  .pagination button:disabled {
    opacity: 0.5;
    cursor: not-allowed;
  }
  
  .loading {
    text-align: center;
    padding: 40px;
  }
  
  .empty-state {
    text-align: center;
    padding: 40px;
    color: #666;
  }
  </style>