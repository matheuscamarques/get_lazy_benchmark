# benchmark.exs
defmodule LazyGetBenchmark do
  # Pré-configura a lista de 1000 champions UMA VEZ
  # Esta lista será usada em todos os cenários de benchmark para simular dados grandes.
  # Use "~4..0B" para preencher números inteiros com zeros à esquerda.
  # Mantendo 100.000 para uma lista bem grande, se for o caso.

    defmodule Champions do
    # list_champions agora simplesmente retorna a lista pré-gerada.
    # O "custo" de gerar a lista já está na linha de @thousands_of_champions.
    @thousands_of_champions for i <- 1..100000, do: "champion_#{:io_lib.format("~4..0B", [i]) |> to_string}"
    def list_champions do
       @thousands_of_champions
    end
  end

  def run do
    IO.puts("Generated #{Enum.count(Champions.list_champions())} champions for benchmark.")

    # Definimos um número de repetições para cada operação dentro do benchmark
    num_repetitions_per_run = 10000

    Benchee.run %{
      # --- Cenários onde a chave NÃO EXISTE (força o lazy load) ---
      "assigns_style_no_key_x#{num_repetitions_per_run}" => fn ->
        # Repetimos a operação 1000 vezes dentro deste bloco
        for _ <- 1..num_repetitions_per_run do
          assigns = %{}
          _ = assigns[:champions] || Champions.list_champions()
        end
      end,

      "map_get_lazy_no_key_x#{num_repetitions_per_run}" => fn ->
        # Repetimos a operação 1000 vezes dentro deste bloco
        for _ <- 1..num_repetitions_per_run do
          map = %{}
          _ = Map.get_lazy(map, :champions, fn -> Champions.list_champions() end)
        end
      end,

      # --- Cenários onde a chave JÁ EXISTE (não há lazy load, apenas acesso) ---
      "assigns_style_with_key_x#{num_repetitions_per_run}" => fn ->
        # Preparamos o assigns fora do loop para não recriar a lista a cada iteração interna
        prepared_assigns = %{champions: Champions.list_champions()}
        # Repetimos a operação 1000 vezes dentro deste bloco
        for _ <- 1..num_repetitions_per_run do
          _ = prepared_assigns[:champions] || Champions.list_champions()
        end
      end,

      "map_get_lazy_with_key_x#{num_repetitions_per_run}" => fn ->
        # Preparamos o map fora do loop para não recriar a lista a cada iteração interna
        prepared_map = %{champions: Champions.list_champions()}
        # Repetimos a operação 1000 vezes dentro deste bloco
        for _ <- 1..num_repetitions_per_run do
          _ = Map.get_lazy(prepared_map, :champions, fn -> Champions.list_champions() end)
        end
      end
    },
    time: 5,         # Tempo para cada benchmark rodar (em segundos)
    memory_time: 1,  # Tempo para cada benchmark de memória rodar (em segundos)
    warmup: 2,       # Tempo para "aquecer" o sistema antes de coletar dados reais
    parallel: 8      # Número de processos paralelos para executar benchmarks
  end
end

LazyGetBenchmark.run()
