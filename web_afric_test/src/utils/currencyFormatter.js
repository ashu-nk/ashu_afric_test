export const formatXAF = (amount) => {
    return new Intl.NumberFormat('fr-CM', {
      style: 'currency',
      currency: 'XAF',
      minimumFractionDigits: 0,
      maximumFractionDigits: 0
    }).format(amount);
  };
  
  export const formatNumber = (number) => {
    return new Intl.NumberFormat('fr-CM').format(number);
  };