import { useEffect, useState } from 'react';
import { useRouter } from 'next/router';
import Layout from '../../../components/Layout';
import Card from '../../../components/Card';
import Loading from '../../../components/Loading';
import Button from '../../../components/Button';
import ProductForm from '../../../components/ProductForm';
import { productsService, Product, CreateProductData } from '../../../services/products.service';
import { useAuth } from '../../../contexts/AuthContext';
import { getImageUrl } from '../../../lib/api';

export default function EditProduct() {
  const [product, setProduct] = useState<Product | null>(null);
  const [loading, setLoading] = useState(true);
  const [uploading, setUploading] = useState(false);
  const { isAuthenticated, loading: authLoading } = useAuth();
  const router = useRouter();
  const { id } = router.query;

  useEffect(() => {
    if (!authLoading && !isAuthenticated) {
      router.push('/login');
    }
  }, [isAuthenticated, authLoading, router]);

  useEffect(() => {
    if (id) {
      fetchProduct();
    }
  }, [id]);

  async function fetchProduct() {
    try {
      const response = await productsService.getById(Number(id));
      setProduct(response.product);
    } catch (error) {
      alert('Erro ao carregar produto');
      router.push('/products');
    } finally {
      setLoading(false);
    }
  }

  async function handleUpdate(data: CreateProductData) {
    await productsService.update(Number(id), data);
  }

  async function handleImageUpload(e: React.ChangeEvent<HTMLInputElement>) {
    const file = e.target.files?.[0];
    if (!file) return;

    setUploading(true);
    try {
      await productsService.uploadImage(Number(id), file);
      await fetchProduct();
      alert('Imagem atualizada com sucesso!');
    } catch (error: any) {
      alert(error.response?.data?.message || 'Erro ao fazer upload');
    } finally {
      setUploading(false);
    }
  }

  if (loading || authLoading) return <Loading />;
  if (!isAuthenticated || !product) return null;

  return (
    <Layout>
      <div className="max-w-2xl mx-auto">
        <h1 className="text-3xl font-bold text-gray-800 mb-6">Editar Produto</h1>

        <Card className="mb-6">
          <h2 className="text-xl font-bold mb-4">Imagem do Produto</h2>
          {product.imageUrl && (
            <div className="mb-4">
              <img
                src={getImageUrl(product.imageUrl) || ''}
                alt={product.name}
                className="w-48 h-48 object-cover rounded-md"
              />
            </div>
          )}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              {product.imageUrl ? 'Atualizar Imagem' : 'Adicionar Imagem'}
            </label>
            <input
              type="file"
              accept="image/*"
              onChange={handleImageUpload}
              disabled={uploading}
              className="block w-full text-sm text-gray-500 file:mr-4 file:py-2 file:px-4 file:rounded-md file:border-0 file:text-sm file:font-semibold file:bg-green-50 file:text-green-700 hover:file:bg-green-100"
            />
            {uploading && <p className="text-sm text-gray-600 mt-2">Enviando...</p>}
          </div>
        </Card>

        <Card>
          <ProductForm
            initialData={product}
            onSubmit={handleUpdate}
            submitText="Salvar Alterações"
          />
        </Card>
      </div>
    </Layout>
  );
}
