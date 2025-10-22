module.exports = {
  reactStrictMode: true,
  swcMinify: true,
  images: {
    domains: ['localhost', 'api.cantinhoverde.app.br'],
  },
  publicRuntimeConfig: {
    apiUrl: process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001/api',
  },
}
