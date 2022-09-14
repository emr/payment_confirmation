defmodule PaymentConfirmation.Transactions do
  @moduledoc """
  An API to communicate with transaction table which is stored in ETS
  """

  use GenServer
  alias PaymentConfirmation.Transaction
  alias Eth.Network
  alias Eth.Confirmation.Tracker

  @type state :: {
          # a list that holds transaction hashes to get transactions ordered
          [],
          # set that holds all transactions' data
          :ets.table()
        }

  @topic inspect(__MODULE__)

  # Client

  @doc """
  Starts the process

  `:name` is always required. It is used to name the ETS table
  """
  @spec start_link(GenServer.options()) :: {:error, any} | {:ok, pid}
  def start_link(opts \\ []) do
    table_name = Keyword.fetch!(opts, :name)
    GenServer.start_link(__MODULE__, table_name, opts)
  end

  @doc """
  Validates the given attributes and creates a new transaction

  ## Examples

    ```
    iex> PaymentConfirmation.Transactions.create(%{hash: "0x2e3db2df7b9b7c15cd3653c7115e5f3ae7ce7dee7303a89fd9ad4915ad6bcbcc"})
    {:ok, %{}}
    ```
  """
  @spec create(map()) :: {:ok, Transaction.t()} | {:error, Ecto.Changeset.t()}
  def create(attrs) do
    case Transaction.changeset(%Transaction{}, attrs) do
      %Ecto.Changeset{valid?: true, changes: changes} ->
        tx = Map.merge(%Transaction{}, changes)
        GenServer.cast(__MODULE__, {:send, tx})
        {:ok, tx}

      changeset ->
        {:error, changeset}
    end
  end

  @spec list :: list(Transaction.t())
  def list() do
    GenServer.call(__MODULE__, :list)
  end

  # PubSub

  @spec subscribe :: :ok | {:error, term()}
  def subscribe() do
    Phoenix.PubSub.subscribe(PaymentConfirmation.PubSub, @topic)
  end

  defp broadcast_change(tx, event) do
    Phoenix.PubSub.broadcast(PaymentConfirmation.PubSub, @topic, {__MODULE__, event, tx})
  end

  # Server Callbacks

  @impl true
  @spec init(atom()) :: {:ok, {list(), :ets.table()}}
  def init(table_name) do
    table = :ets.new(table_name, [:ordered_set, :named_table, read_concurrency: true])
    {:ok, {[], table}}
  end

  @impl true
  def handle_call(:list, _from, {list, table}) do
    {
      :reply,
      list
      |> Enum.map(fn hash ->
        [{_, tx}] = :ets.lookup(table, hash)
        tx
      end),
      {list, table}
    }
  end

  @impl true
  def handle_cast({:send, tx = %Transaction{}}, {list, table}) do
    tx = Map.put(tx, :status, :sending)
    :ok = broadcast_change(tx, [:tx, :sending])

    case :ets.insert_new(table, {tx.hash, tx}) do
      true ->
        :ok = Network.send(%{hash: tx.hash})
        {:noreply, {[tx.hash | list], table}}

      _ ->
        {:noreply, {list, table}}
    end
  end

  @impl true
  def handle_info({:tx_sent, hash}, {list, table}) do
    :ok = Tracker.add(hash)

    [{_, tx}] = :ets.lookup(table, hash)
    tx = Map.put(tx, :status, :pending)
    :ok = broadcast_change(tx, [:tx, :pending])
    :ets.insert(table, {hash, tx})

    {:noreply, {list, table}}
  end

  def handle_info({:tx_confirmed, hash}, {list, table}) do
    [{_, tx}] = :ets.lookup(table, hash)
    tx = Map.put(tx, :status, :confirmed)
    :ok = broadcast_change(tx, [:tx, :confirmed])
    :ets.insert(table, {hash, tx})

    {:noreply, {list, table}}
  end

  def handle_info({:tx_failed, hash}, {list, table}) do
    [{_, tx}] = :ets.lookup(table, hash)
    tx = Map.put(tx, :status, :failed)
    :ok = broadcast_change(tx, [:tx, :failed])
    :ets.insert(table, {hash, tx})

    {:noreply, {list, table}}
  end
end
