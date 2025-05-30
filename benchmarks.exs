# benchmark.exs
defmodule LazyGetBenchmark do
  # Pré-configura a lista de 1000 champions UMA VEZ
  # Esta lista será usada em todos os cenários de benchmark para simular dados grandes.
  # CORRIGIDO: Use "~4..0B" para preencher números inteiros com zeros à esquerda.

  defmodule Champions do
    # list_champions agora simplesmente retorna a lista pré-gerada.
    # O "custo" de gerar a lista já está na linha de @thousands_of_champions.
    @thousands_of_champions for i <- 1..1000, do: "champion_#{:io_lib.format("~4..0B", [i]) |> to_string}"
    def list_champions do
       @thousands_of_champions
    end
  end

  def run do
    IO.puts("Generated #{Enum.count(Champions.list_champions())} champions for benchmark.")

    Benchee.run %{
      # --- Cenários onde a chave NÃO EXISTE (força o lazy load) ---
      "assigns_style_no_key" => fn ->
        assigns = %{} # Simula `assigns` sem a chave :champions
        # O `||` (OR) garante que `Champions.list_champions()` seja chamada se a chave não existir.
        _ = assigns[:champions] || Champions.list_champions()
      end,

      "map_get_lazy_no_key" => fn ->
        map = %{} # Simula um mapa sem a chave :champions
        # Map.get_lazy chama a função do terceiro argumento se a chave não existir.
        _ = Map.get_lazy(map, :champions, fn -> Champions.list_champions() end)
      end,

      # --- Cenários onde a chave JÁ EXISTE (não há lazy load, apenas acesso) ---
      "assigns_style_with_key" => fn ->
        # Simula `assigns` com a chave :champions já presente
        assigns = %{champions: Champions.list_champions()}
        # O `||` não executará `Champions.list_champions()` aqui.
        _ = assigns[:champions] || Champions.list_champions()
      end,

      "map_get_lazy_with_key" => fn ->
        # Simula um mapa com a chave :champions já presente
        map = %{champions: Champions.list_champions()}
        # Map.get_lazy não executará a função do terceiro argumento aqui.
        _ = Map.get_lazy(map, :champions, fn -> Champions.list_champions() end)
      end
    },
    time: 5,         # Tempo para cada benchmark rodar (em segundos)
    memory_time: 1,  # Tempo para cada benchmark de memória rodar (em segundos)
    warmup: 2,        # Tempo para "aquecer" a JVM antes de coletar dados reais
    parallel: 4    # Número de processos paralelos para executar benchmarks
  end
end

LazyGetBenchmark.run()
