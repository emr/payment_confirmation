defmodule PaymentConfirmation.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    Supervisor.start_link(children(Application.fetch_env!(:payment_confirmation, :env)),
      strategy: :one_for_one,
      name: PaymentConfirmation.Supervisor
    )
  end

  defp children(:test), do: []

  defp children(_),
    do: [
      # Start the PubSub system
      {Phoenix.PubSub, name: PaymentConfirmation.PubSub},
      Eth.Network,
      Eth.Confirmation.Tracker,
      {PaymentConfirmation.Transactions, name: PaymentConfirmation.Transactions}
    ]
end
