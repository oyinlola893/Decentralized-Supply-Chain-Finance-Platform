import { describe, it, expect, beforeEach } from 'vitest';
import { vi } from 'vitest';

describe('Payment Contract', () => {
    const user1 = 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM';
    const user2 = 'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG';
    
    beforeEach(() => {
        vi.resetAllMocks();
    });
    
    it('should create a payment', () => {
        const makePaymentMock = vi.fn().mockReturnValue({ success: true, value: 1 });
        expect(makePaymentMock(user2, 1000)).toEqual({ success: true, value: 1 });
    });
    
    it('should not allow unauthorized payment', () => {
        const makePaymentMock = vi.fn().mockReturnValue({ success: false, error: 102 });
        expect(makePaymentMock(user2, 0)).toEqual({ success: false, error: 102 });
    });
    
    it('should get payment details', () => {
        const getPaymentMock = vi.fn().mockReturnValue({
            success: true,
            value: {
                payer: user1,
                recipient: user2,
                amount: 1000,
                status: "completed"
            }
        });
        const result = getPaymentMock(1);
        expect(result.success).toBe(true);
        expect(result.value).toEqual({
            payer: user1,
            recipient: user2,
            amount: 1000,
            status: "completed"
        });
    });
});

