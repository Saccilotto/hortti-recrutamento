import useSWR from 'swr'

const fetcher = (url: string) => fetch(url).then(r => r.json())

export default function Home() {
  const { data, error } = useSWR('http://localhost:3001/products', fetcher)

  if (error) return <div>Falha ao carregar</div>
  if (!data) return <div>Carregando...</div>

  return (
    <div style={{ padding: 24 }}>
      <h1>Hortti Inventory</h1>
      <ul>
        {data.map((p: any) => (
          <li key={p.id}>{p.name} — {p.category} — R$ {p.price}</li>
        ))}
      </ul>
    </div>
  )
}
