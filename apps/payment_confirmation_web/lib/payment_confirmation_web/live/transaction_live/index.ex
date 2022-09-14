defmodule PaymentConfirmationWeb.TransactionLive.Index do
  use PaymentConfirmationWeb, :live_view

  alias PaymentConfirmation.Transaction
  alias PaymentConfirmation.Transactions

  @impl true
  def mount(_params, _session, socket) do
    Transactions.subscribe()
    {:ok, update_transactions(socket)}
  end

  @impl true
  def handle_info({Transactions, _event, tx}, socket) do
    {:noreply, update_transactions(socket, tx)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Transaction")
    |> assign(:transaction, %Transaction{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Transactions")
    |> assign(:transaction, nil)
  end

  defp update_transactions(socket) do
    assign(
      socket,
      :transactions,
      Map.new(Transactions.list(), &{&1.hash, &1})
    )
  end

  defp update_transactions(socket, tx) do
    assign(
      socket,
      :transactions,
      Map.put(socket.assigns.transactions, tx.hash, tx)
    )
  end
end
