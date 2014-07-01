defmodule Poolgres.Worker do
  use GenServer
  @behaviour :poolboy_worker

  def query(pid, q) when is_pid(pid) and is_binary(q) do
    :gen_server.call(pid, {:query, q})
  end

  def exec(pid, f) when is_pid(pid) and is_function(f) do
    :gen_server.call(pid, {:exec, f})
  end

  def start_link(args), do: :gen_server.start_link(__MODULE__, args, [])
  def init(opts) do
    :erlang.process_flag(:trap_exit, true)
    Postgrex.Connection.start_link(opts)
  end

  def handle_call({:query, q}, _from, connection) do
    {:reply, Postgrex.Connection.query(connection, q), connection}
  end

  def handle_call({:exec, f}, _from, connection) do
    {:reply, f.(connection), connection}
  end

end
