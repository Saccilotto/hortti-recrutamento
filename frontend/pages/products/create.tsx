import { useEffect } from 'react';
import { useRouter } from 'next/router';
import Layout from '../../components/Layout';
import Card from '../../components/Card';
import ProductForm from '../../components/ProductForm';
import { productsService, CreateProductData } from '../../services/products.service';
import { useAuth } from '../../contexts/AuthContext';

export default function CreateProduct() {
  const { isAuthenticated, loading } = useAuth();
  const router = useRouter();

  useEffect(() => {
    if (!loading && !isAuthenticated) {
      router.push('/login');
    }
  }, [isAuthenticated, loading, router]);

  async function handleCreate(data: CreateProductData) {
    await productsService.create(data);
  }

  if (loading) return null;
  if (!isAuthenticated) return null;

  return (
    <Layout>
      <div className="max-w-2xl mx-auto">
        <h1 className="text-3xl font-bold text-gray-800 mb-6">Novo Produto</h1>
        <Card>
          <ProductForm onSubmit={handleCreate} submitText="Criar Produto" />
        </Card>
      </div>
    </Layout>
  );
}
