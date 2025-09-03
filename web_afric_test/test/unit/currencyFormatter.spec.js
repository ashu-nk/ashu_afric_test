import { formatXAF } from '@/utils/currencyFormatter';

describe('Currency Formatter', () => {
  test('formats XAF currency correctly', () => {
    expect(formatXAF(1000)).toBe('1 000 FCFA');
    expect(formatXAF(2500000)).toBe('2 500 000 FCFA');
  });

  test('handles negative amounts', () => {
    expect(formatXAF(-1000)).toBe('-1 000 FCFA');
  });
});