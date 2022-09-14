defmodule PaymentConfirmationWeb.TransactionLive.FormComponent do
  use PaymentConfirmationWeb, :live_component
  alias PaymentConfirmation.Transaction
  alias PaymentConfirmation.Transactions

  @impl true
  def update(%{transaction: transaction} = assigns, socket) do
    changeset = Transaction.changeset(transaction, %{})

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"transaction" => transaction_params}, socket) do
    changeset =
      socket.assigns.transaction
      |> Transaction.changeset(transaction_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("send", %{"transaction" => transaction_params}, socket) do
    send_transaction(socket, transaction_params)
  end

  defp send_transaction(socket, transaction_params) do
    case Transactions.create(transaction_params) do
      {:ok, _transaction} ->
        {:noreply, push_redirect(socket, to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
