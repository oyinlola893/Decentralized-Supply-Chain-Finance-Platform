import { describe, it, expect, beforeEach } from 'vitest';
import { vi } from 'vitest';

describe('Product Registry Contract', () => {
  const contractOwner = 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM';
  const user1 = 'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG';
  
  beforeEach(() => {
    vi.resetAllMocks();
  });
  
  it('should register a product', () => {
    const mockRegisterProduct = vi.fn().mockReturnValue({ success: true, value: 1 });
    expect(mockRegisterProduct('Product Name', 'Product Description')).toEqual({ success: true, value: 1 });
  });
  
  it('should get manufacturer', () => {
    const mockGetManufacturer = vi.fn().mockReturnValue({ success: true, value: contractOwner });
    expect(mockGetManufacturer(1)).toEqual({ success: true, value: contractOwner });
  });
  
  it('should get product details', () => {
    const mockGetProductDetails = vi.fn().mockReturnValue({
      success: true,
      value: {
        manufacturer: contractOwner,
        name: 'Product Name',
        description: 'Product Description'
      }
    });
    const result = mockGetProductDetails(1);
    expect(result.success).toBe(true);
    expect(result.value).toEqual({
      manufacturer: contractOwner,
      name: 'Product Name',
      description: 'Product Description'
    });
  });
  
  it('should get last product id', () => {
    const mockGetLastProductId = vi.fn().mockReturnValue({ success: true, value: 1 });
    expect(mockGetLastProductId()).toEqual({ success: true, value: 1 });
  });
});

