defmodule Eth.Confirmation.Job do
  @moduledoc """
  Represents active job of Eth.Confirmation.Tracker
  """

  alias Eth.Transaction

  @enforce_keys [:hash, :client]
  defstruct hash: nil,
            client: nil,
            attempts: 0,
            block_number: nil,
            status: :none

  @type status :: :none | :pending | :failed | :confirmed
  @type t :: %__MODULE__{
          hash: Transaction.hash(),
          client: pid(),
          attempts: non_neg_integer(),
          block_number: nil | non_neg_integer(),
          status: status()
        }

  @spec create(Transaction.hash(), pid()) :: t()
  def create(hash, client) do
    %__MODULE__{
      hash: hash,
      client: client
    }
  end

  @spec add_attempt(t()) :: t()
  def add_attempt(job = %__MODULE__{attempts: attempts}) do
    Map.put(job, :attempts, attempts + 1)
  end

  @spec set_block_number(t(), non_neg_integer()) :: t()
  def set_block_number(job, block_number) do
    Map.put(job, :block_number, block_number)
  end

  @spec mark(t(), status()) :: t()
  def mark(job, status) do
    Map.put(job, :status, status)
  end
end
