import { api } from '../lib/api';

export interface LoginCredentials {
  email: string;
  password: string;
}

export interface RegisterData {
  email: string;
  password: string;
  name: string;
}

export interface User {
  id: number;
  email: string;
  name: string;
  role: string;
}

export interface AuthResponse {
  user: User;
  token: string;
  message: string;
}

export const authService = {
  async login(credentials: LoginCredentials): Promise<AuthResponse> {
    const { data } = await api.post<AuthResponse>('/auth/login', credentials);
    return data;
  },

  async register(userData: RegisterData): Promise<AuthResponse> {
    const { data } = await api.post<AuthResponse>('/auth/register', userData);
    return data;
  },

  async getProfile(): Promise<{ user: User }> {
    const { data } = await api.get<{ user: User }>('/auth/me');
    return data;
  },

  async verifyToken(): Promise<{ valid: boolean; user: any }> {
    const { data} = await api.get<{ valid: boolean; user: any }>('/auth/verify');
    return data;
  },
};
