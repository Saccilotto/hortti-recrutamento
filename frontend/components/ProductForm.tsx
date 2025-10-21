import { useState, FormEvent } from 'react';
import { useRouter } from 'next/router';
import Input from './Input';
import Select from './Select';
import Button from './Button';
import { CreateProductData } from '../services/products.service';

interface ProductFormProps {
  initialData?: Partial<CreateProductData>;
  onSubmit: (data: CreateProductData) => Promise<void>;
  submitText: string;
}

export default function ProductForm({ initialData, onSubmit, submitText }: ProductFormProps) {
  const [formData, setFormData] = useState<CreateProductData>({
    name: initialData?.name || '',
    category: initialData?.category || 'fruta',
    price: initialData?.price || 0,
    description: initialData?.description || '',
    stock: initialData?.stock || 0,
  });
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const router = useRouter();

  async function handleSubmit(e: FormEvent) {
    e.preventDefault();
    setError('');
    setLoading(true);

    try {
      await onSubmit(formData);
      router.push('/products');
    } catch (err: any) {
      setError(err.response?.data?.message || 'Erro ao salvar produto');
    } finally {
      setLoading(false);
    }
  }

  const categoryOptions = [
    { value: 'fruta', label: 'Fruta' },
    { value: 'verdura', label: 'Verdura' },
    { value: 'legume', label: 'Legume' },
  ];

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      {error && (
        <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded">
          {error}
        </div>
      )}

      <Input
        label="Nome *"
        value={formData.name}
        onChange={(e) => setFormData({ ...formData, name: e.target.value })}
        placeholder="Ex: Tomate Italiano"
        required
      />

      <Select
        label="Categoria *"
        options={categoryOptions}
        value={formData.category}
        onChange={(e) => setFormData({ ...formData, category: e.target.value as any })}
        required
      />

      <Input
        label="Preço *"
        type="number"
        step="0.01"
        min="0"
        value={formData.price}
        onChange={(e) => setFormData({ ...formData, price: parseFloat(e.target.value) })}
        placeholder="0.00"
        required
      />

      <Input
        label="Estoque"
        type="number"
        min="0"
        value={formData.stock}
        onChange={(e) => setFormData({ ...formData, stock: parseInt(e.target.value) || 0 })}
        placeholder="0"
      />

      <div className="w-full">
        <label className="block text-sm font-medium text-gray-700 mb-1">
          Descrição
        </label>
        <textarea
          className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-green-500"
          rows={4}
          value={formData.description}
          onChange={(e) => setFormData({ ...formData, description: e.target.value })}
          placeholder="Descrição do produto..."
        />
      </div>

      <div className="flex gap-4">
        <Button
          type="button"
          variant="secondary"
          onClick={() => router.push('/products')}
          disabled={loading}
        >
          Cancelar
        </Button>
        <Button type="submit" isLoading={loading} disabled={loading}>
          {submitText}
        </Button>
      </div>
    </form>
  );
}
