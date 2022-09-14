defmodule PaymentConfirmation.Transaction do
  @type status :: :sending | :pending | :confirmed | :failed
  @type hash :: String.t()
  @type t :: %__MODULE__{
          status: nil | status(),
          hash: nil | hash()
        }
  defstruct [:hash, :status]

  import Ecto.Changeset

  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(%__MODULE__{} = tx, attrs) do
    {tx, %{hash: :string}}
    |> cast(attrs, [:hash])
    |> validate_required(:hash)
    |> validate_hash(:hash)
  end

  defp validate_hash(changeset, field) do
    validate_change(changeset, field, fn field, value ->
      case String.match?(value, ~r/^0x([A-Fa-f0-9]{64})$/) do
        true ->
          []

        _ ->
          [{field, "transaction hash must be a 64 length hex after \"0x\""}]
      end
    end)
  end
end
