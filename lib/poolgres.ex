defmodule Poolgres do
  def start_sql(opts) do
    start_sql_do(Keyword.keyword?(opts), opts)
  end

  def query(q) when is_binary(q), do: Poolgres.Sup.pool_pid |> :poolboy.transaction(&query(&1, q))
  def exec(f) when is_function(f), do: Poolgres.Sup.pool_pid |> :poolboy.transaction(&f.(&1))

  def query(pid, query) when is_pid(pid) and is_binary(query), do: Poolgres.Worker.query(pid, query)
  def query(name, query) when (is_atom(name) or is_binary(name)) and is_binary(query) do
    Poolgres.Sup.pool_pid(name) |> :poolboy.transaction(fn(x) ->
      Poolgres.Worker.query(x, query)
    end)
  end
  def exec(name, f) when is_atom(name) or is_binary(name) and is_function(f) do
    Poolgres.Sup.pool_pid(name) |> :poolboy.transaction(&f.(&1))
  end

  defp start_sql_do(true, opts) do
    Poolgres.Sup.start_link(opts(opts))
  end
  defp start_sql_do(false, opts) do
    {:ok, pid} = Poolgres.Sup.start_link
    for o <- opts do
      Poolgres.Sup.add_pool(opts(o))
    end
    {:ok, pid}
  end

  defp opts(opts) do
    alias Keyword, as: K
    unless K.get(opts, :database), do: :erlang.error({__MODULE__, "Database required in #{inspect opts}"})
    [ database:     K.get(opts, :database),
      hostname:     K.get(opts, :hostname, "localhost"),
      username:     K.get(opts, :username, K.get(opts, :database)),
      password:     K.get(opts, :password),
      port:         K.get(opts, :port,  5432),
      size:         K.get(opts, :pool_size, 10),
      max_overflow: K.get(opts, :pool_max_overflow, 20) ]
  end

end
