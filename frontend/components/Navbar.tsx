import Link from 'next/link';
import { useAuth } from '../contexts/AuthContext';
import Button from './Button';

export default function Navbar() {
  const { user, logout, isAuthenticated } = useAuth();

  return (
    <nav className="bg-white shadow-md">
      <div className="container mx-auto px-4">
        <div className="flex justify-between items-center h-16">
          <Link href="/products" className="text-2xl font-bold text-green-600">
            Hortti Inventory
          </Link>

          <div className="flex items-center gap-4">
            {isAuthenticated ? (
              <>
                <span className="text-gray-700">Olá, {user?.name}</span>
                <Link href="/products">
                  <Button variant="secondary">Produtos</Button>
                </Link>
                <Link href="/products/create">
                  <Button variant="primary">Novo Produto</Button>
                </Link>
                <Button variant="danger" onClick={logout}>
                  Sair
                </Button>
              </>
            ) : (
              <Link href="/login">
                <Button variant="primary">Entrar</Button>
              </Link>
            )}
          </div>
        </div>
      </div>
    </nav>
  );
}
