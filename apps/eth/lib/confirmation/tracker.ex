defmodule Eth.Confirmation.Tracker do
  @moduledoc """
  This module is a GenServer that runs asynchronously. It tracks whether the given
  transactions are confirmed on the network. Takes the transaction hash with
  `Eth.Confirmation.Tracker.add/1` and sends `{:tx_confirmed, hash}` or
  `{:tx_failed, hash}` message to the client process when the pending transactions
  is confirmed or reaches maximum attempts. Uses `Eth.Confirmation.Job` to track
  about active confirmation jobs.
  """

  use GenServer
  alias Eth.Config
  alias Eth.Network
  alias Eth.Confirmation.Job
  import Eth.Utils

  @type state :: %{String.t() => Job.t()}

  # Client

  @spec start_link(GenServer.options()) :: {:error, any} | {:ok, pid}
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, Keyword.put(opts, :name, __MODULE__))
  end

  @doc """
  Adds a transaction to the tracking list. Whenever the transactions is confirmed,
  sends `{:tx_confirmed, hash}` message to the client process. If the transaction
  is not confirmed after number of attempts configured by application, sends
  `{:tx_failed, hash}` message.

  ## Examples

    ```
    iex> Eth.Confirmation.Tracker.add("0x1a...")
    :ok
    iex> receive do
    iex>   msg -> msg
    iex> end
    {:tx_confirmed, "0x1a..."}
    ```
  """
  @spec add(String.t()) :: :ok
  def add(hash) do
    GenServer.cast(__MODULE__, {:add, hash, self()})
  end

  # Server Callbacks

  @impl true
  @spec init(:ok) :: {:ok, state()}
  def init(:ok) do
    schedule_next_check()

    {:ok, %{}}
  end

  @impl true
  def handle_cast({:add, hash, client}, state) do
    {:noreply, Map.put(state, hash, Job.create(hash, client))}
  end

  @impl true
  def handle_info(:check, state) do
    new_state =
      state
      |> check()
      |> Enum.map(fn {:ok, job} ->
        {job.hash, job}
      end)
      |> Map.new()

    schedule_next_check()

    {:noreply, new_state}
  end

  defp check(state) do
    max_concurrency = System.schedulers_online() * 2

    current_block = Network.current_block_number()
    confirmation_block_count = Config.confirmation_block_count()
    max_attempts = Config.confirmation_max_attempts()

    state
    |> Task.async_stream(
      fn {_, job} ->
        check_confirmation(job, %{
          current_block: current_block,
          confirmation_block_count: confirmation_block_count,
          max_attempts: max_attempts
        })
      end,
      ordered: false,
      max_concurrency: max_concurrency
    )
    |> Enum.filter(fn {:ok, job} ->
      case job.status do
        :pending ->
          true

        _ ->
          respond_client(job)
          false
      end
    end)
  end

  defp respond_client(%Job{client: client, hash: hash, status: :confirmed}) do
    Process.send(client, {:tx_confirmed, hash}, [])
  end

  defp respond_client(%Job{client: client, hash: hash, status: :failed}) do
    Process.send(client, {:tx_failed, hash}, [])
  end

  defp check_confirmation(
         job = %{block_number: block_number},
         %{
           current_block: current_block,
           confirmation_block_count: confirmation_block_count
         }
       )
       when current_block - block_number >= confirmation_block_count do
    job
    |> Job.add_attempt()
    |> Job.mark(:confirmed)
  end

  defp check_confirmation(
         job = %Job{attempts: attempts},
         %{max_attempts: max_attempts}
       )
       when attempts >= max_attempts do
    job
    |> Job.add_attempt()
    |> Job.mark(:failed)
  end

  defp check_confirmation(job = %Job{block_number: nil}, opts) do
    case Config.rpc_client().eth_get_transaction_receipt(job.hash, []) do
      {:ok, %{"blockNumber" => block_hex}} ->
        check_confirmation(
          Job.set_block_number(job, hex_to_number(block_hex)),
          opts
        )

      _ ->
        job
        |> Job.add_attempt()
        |> Job.mark(:pending)
    end
  end

  defp check_confirmation(
         job = %Job{block_number: block_number},
         %{
           current_block: current_block,
           confirmation_block_count: confirmation_block_count
         }
       )
       when current_block - block_number < confirmation_block_count do
    job
    |> Job.add_attempt()
    |> Job.mark(:pending)
  end

  defp schedule_next_check() do
    Process.send_after(self(), :check, Config.confirmation_interval())
  end
end
