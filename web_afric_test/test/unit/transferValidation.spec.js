import { validateTransfer } from '@/utils/transferValidation';

describe('Transfer Validation', () => {
  it('validates transfer amount is positive', () => {
    const result = validateTransfer(0, 1000);
    expect(result.isValid).toBe(false);
    expect(result.errors).toContain('Le montant doit être supérieur à 0');

    const result2 = validateTransfer(-100, 1000);
    expect(result2.isValid).toBe(false);
  });

  it('validates amount does not exceed balance', () => {
    const result = validateTransfer(1500, 1000);
    expect(result.isValid).toBe(false);
    expect(result.errors).toContain('Le montant ne peut pas dépasser le solde du compte');
  });

  it('returns valid for correct amounts', () => {
    const result = validateTransfer(500, 1000);
    expect(result.isValid).toBe(true);
    expect(result.errors).toHaveLength(0);

    const result2 = validateTransfer(1000, 1000);
    expect(result2.isValid).toBe(true);
  });
});