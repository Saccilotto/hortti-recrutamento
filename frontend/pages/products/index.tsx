import { useState, useEffect } from 'react';
import { useRouter } from 'next/router';
import Link from 'next/link';
import Layout from '../../components/Layout';
import Loading from '../../components/Loading';
import Card from '../../components/Card';
import Input from '../../components/Input';
import Select from '../../components/Select';
import Button from '../../components/Button';
import { productsService, Product, QueryParams } from '../../services/products.service';
import { useAuth } from '../../contexts/AuthContext';

export default function Products() {
  const [products, setProducts] = useState<Product[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [category, setCategory] = useState('');
  const [sortBy, setSortBy] = useState<'name' | 'price'>('name');
  const [order, setOrder] = useState<'ASC' | 'DESC'>('ASC');
  const [page, setPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const { isAuthenticated } = useAuth();
  const router = useRouter();

  useEffect(() => {
    fetchProducts();
  }, [search, category, sortBy, order, page]);

  async function fetchProducts() {
    try {
      setLoading(true);
      const params: QueryParams = {
        page,
        limit: 12,
        sortBy,
        order,
      };

      if (search) params.search = search;
      if (category) params.category = category as 'fruta' | 'verdura' | 'legume';

      const response = await productsService.getAll(params);
      setProducts(response.data);
      setTotalPages(response.meta.totalPages);
    } catch (error) {
      console.error('Erro ao carregar produtos:', error);
    } finally {
      setLoading(false);
    }
  }

  async function handleDelete(id: number) {
    if (!confirm('Tem certeza que deseja excluir este produto?')) return;

    try {
      await productsService.delete(id);
      fetchProducts();
    } catch (error: any) {
      alert(error.response?.data?.message || 'Erro ao excluir produto');
    }
  }

  const categoryOptions = [
    { value: '', label: 'Todas as categorias' },
    { value: 'fruta', label: 'Frutas' },
    { value: 'verdura', label: 'Verduras' },
    { value: 'legume', label: 'Legumes' },
  ];

  const sortByOptions = [
    { value: 'name', label: 'Nome' },
    { value: 'price', label: 'Preço' },
  ];

  const orderOptions = [
    { value: 'ASC', label: 'Crescente' },
    { value: 'DESC', label: 'Decrescente' },
  ];

  if (loading && products.length === 0) return <Loading />;

  return (
    <Layout>
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-gray-800">Produtos</h1>
        <p className="text-gray-600 mt-2">Gerencie o inventário do Cantinho Verde</p>
      </div>

      <Card className="mb-6">
        <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
          <Input
            placeholder="Buscar por nome..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
          />
          <Select
            options={categoryOptions}
            value={category}
            onChange={(e) => setCategory(e.target.value)}
          />
          <Select
            options={sortByOptions}
            value={sortBy}
            onChange={(e) => setSortBy(e.target.value as 'name' | 'price')}
          />
          <Select
            options={orderOptions}
            value={order}
            onChange={(e) => setOrder(e.target.value as 'ASC' | 'DESC')}
          />
        </div>
      </Card>

      {products.length === 0 ? (
        <Card>
          <p className="text-center text-gray-600">Nenhum produto encontrado</p>
        </Card>
      ) : (
        <>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
            {products.map((product) => (
              <Card key={product.id} className="flex flex-col">
                <div className="aspect-square bg-gray-200 rounded-md mb-4 overflow-hidden">
                  {product.imageUrl ? (
                    <img
                      src={product.imageUrl}
                      alt={product.name}
                      className="w-full h-full object-cover"
                    />
                  ) : (
                    <div className="w-full h-full flex items-center justify-center text-gray-400">
                      Sem imagem
                    </div>
                  )}
                </div>

                <h3 className="font-bold text-lg mb-1">{product.name}</h3>
                <p className="text-sm text-gray-600 mb-2 capitalize">{product.category}</p>
                <p className="text-2xl font-bold text-green-600 mb-2">
                  R$ {Number(product.price).toFixed(2)}
                </p>
                <p className="text-sm text-gray-600 mb-4">Estoque: {product.stock}</p>

                {isAuthenticated && (
                  <div className="flex gap-2 mt-auto">
                    <Link href={`/products/${product.id}/edit`} className="flex-1">
                      <Button variant="secondary" className="w-full">
                        Editar
                      </Button>
                    </Link>
                    <Button
                      variant="danger"
                      onClick={() => handleDelete(product.id)}
                      className="flex-1"
                    >
                      Excluir
                    </Button>
                  </div>
                )}
              </Card>
            ))}
          </div>

          {totalPages > 1 && (
            <div className="mt-8 flex justify-center gap-2">
              <Button
                variant="secondary"
                disabled={page === 1}
                onClick={() => setPage(page - 1)}
              >
                Anterior
              </Button>
              <span className="px-4 py-2 text-gray-700">
                Página {page} de {totalPages}
              </span>
              <Button
                variant="secondary"
                disabled={page === totalPages}
                onClick={() => setPage(page + 1)}
              >
                Próxima
              </Button>
            </div>
          )}
        </>
      )}
    </Layout>
  );
}
