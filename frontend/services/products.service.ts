import { api } from '../lib/api';

export interface Product {
  id: number;
  name: string;
  category: 'fruta' | 'verdura' | 'legume';
  price: number;
  imageUrl?: string | null;
  description?: string | null;
  stock: number;
  isActive: boolean;
  createdAt: string;
  updatedAt: string;
}

export interface ProductsResponse {
  data: Product[];
  meta: {
    total: number;
    page: number;
    limit: number;
    totalPages: number;
  };
}

export interface QueryParams {
  search?: string;
  category?: 'fruta' | 'verdura' | 'legume';
  sortBy?: 'name' | 'price' | 'createdAt';
  order?: 'ASC' | 'DESC';
  page?: number;
  limit?: number;
}

export interface CreateProductData {
  name: string;
  category: 'fruta' | 'verdura' | 'legume';
  price: number;
  description?: string;
  stock?: number;
  imageUrl?: string;
}

export const productsService = {
  async getAll(params?: QueryParams): Promise<ProductsResponse> {
    const { data } = await api.get<ProductsResponse>('/products', { params });
    return data;
  },

  async getById(id: number): Promise<{ product: Product }> {
    const { data } = await api.get<{ product: Product }>(`/products/${id}`);
    return data;
  },

  async create(productData: CreateProductData): Promise<{ product: Product; message: string }> {
    const { data } = await api.post<{ product: Product; message: string }>('/products', productData);
    return data;
  },

  async update(id: number, productData: Partial<CreateProductData>): Promise<{ product: Product; message: string }> {
    const { data } = await api.patch<{ product: Product; message: string }>(`/products/${id}`, productData);
    return data;
  },

  async delete(id: number): Promise<void> {
    await api.delete(`/products/${id}`);
  },

  async uploadImage(id: number, file: File): Promise<{ product: Product; message: string }> {
    const formData = new FormData();
    formData.append('file', file);
    const { data } = await api.patch<{ product: Product; message: string }>(`/products/${id}/image`, formData, {
      headers: {
        'Content-Type': 'multipart/form-data',
      },
    });
    return data;
  },
};
