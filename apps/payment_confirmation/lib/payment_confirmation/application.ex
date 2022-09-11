defmodule PaymentConfirmation.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the PubSub system
      {Phoenix.PubSub, name: PaymentConfirmation.PubSub}
      # Start a worker by calling: PaymentConfirmation.Worker.start_link(arg)
      # {PaymentConfirmation.Worker, arg}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: PaymentConfirmation.Supervisor)
  end
end
