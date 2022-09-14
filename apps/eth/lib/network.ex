defmodule Eth.Network do
  @moduledoc """
  Eth.Network module interacts with Ethereum node using Ethereumex library.
  """

  use GenServer
  alias Eth.Config
  import Eth.Utils

  # Client

  @spec start_link(GenServer.options()) :: {:error, any} | {:ok, pid}
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, Keyword.put(opts, :name, __MODULE__))
  end

  @doc """
  Sends transaction to the Ethereum network and responds the client process
  as soon as the request is completed.

  ## Example

    ```
    iex> Eth.Network.send(%{hash: "0x1a..."})
    :ok
    iex> receive do
    iex>   {:tx_sent, hash} -> hash
    iex> end
    "0x1a..."
    ```
  """
  def send(tx = %{hash: _}) do
    GenServer.cast(__MODULE__, {:send, tx, self()})
  end

  @doc """
  Returns the current block number on the Ethereum network

  ## Example

    ```
    iex> Eth.Network.current_block_number()
    15523595
    ```
  """
  @spec current_block_number() :: integer()
  def current_block_number() do
    {:ok, number} = GenServer.call(__MODULE__, :block_number)
    hex_to_number(number)
  end

  # Server Callbacks

  @impl true
  @spec init(:ok) :: {:ok, nil}
  def init(:ok) do
    {:ok, nil}
  end

  @impl true
  def handle_call(:block_number, _from, _state) do
    {:reply, Config.rpc_client().eth_block_number([]), nil}
  end

  @impl true
  def handle_cast({:send, tx, client}, _) do
    Task.async(fn ->
      {:ok, hash} = send_tx(tx)
      {:tx_sent, hash, client}
    end)

    {:noreply, nil}
  end

  # handle send_tx response
  @impl true
  def handle_info({ref, {:tx_sent, hash, client}}, _) do
    Process.demonitor(ref, [:flush])
    Process.send(client, {:tx_sent, hash}, [])

    {:noreply, nil}
  end

  defp send_tx(tx) do
    # call external resource
    # pretend to send the query and receive the tx hash
    # {:ok, result} = Config.rpc_client().eth_send_transaction(%{...})
    Process.sleep(Config.send_simulation_duration())
    {:ok, tx.hash}
  end
end
