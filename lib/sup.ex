defmodule Poolgres.Sup do
  use Supervisor

  def start_link(), do: :supervisor.start_link({:local, __MODULE__}, __MODULE__, [])
  def start_link(opts), do: :supervisor.start_link({:local, __MODULE__}, __MODULE__, opts)

  def init(opts) do
    tree = [
      pool_spec(opts)
    ]
    supervise(tree, strategy: :one_for_one)
  end

  def add_pool(opts) do
    :supervisor.start_child(__MODULE__, pool_spec(opts))
  end

  def pool_pid do
    [{_, pid, :worker, [:poolboy]}|_] = :supervisor.which_children(__MODULE__)
    pid
  end

  def pool_pid(name) when is_atom(name) do
    :supervisor.which_children(__MODULE__) |> 
    Enum.filter(fn({{:local, name}, _pid, :worker, [:poolboy]}) when name == name -> true; 
                  (_) -> false end)        |>
    hd |> elem(1)
  end
  def pool_pid(x) when is_binary(x), do: pool_pid(x |> :erlang.binary_to_existing_atom)

  defp pool_spec(database: database, hostname: hostname, 
                 username: username, password: password, 
                 port: port,         size: size, 
                 max_overflow: max_overflow) do
    :poolboy.child_spec({ :local, database |> :erlang.binary_to_atom },
                        [ worker_module: Poolgres.Worker,
                          size:          size,
                          max_overflow:  max_overflow],
                        [ database: database,
                          hostname: hostname,
                          port:     port,
                          username: username,
                          password: password ])
  end

end
