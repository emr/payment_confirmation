defmodule PaymentConfirmationWeb.PageController do
  use PaymentConfirmationWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
