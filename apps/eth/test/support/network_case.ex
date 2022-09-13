defmodule Eth.NetworkCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      use ExUnit.Case
      import Hammox

      setup :set_mox_from_context
      setup :verify_on_exit!

      setup do
        start_supervised!(Eth.Network)
        :ok
      end

      def eth_stub(:eth_block_number, block) do
        # mock eth_block_number response
        stub(Ethereumex.Client.BehaviourMock, :eth_block_number, fn _ ->
          {:ok, block}
        end)
      end

      def eth_stub(:eth_get_transaction_receipt, hash, block) do
        stub(Ethereumex.Client.BehaviourMock, :eth_get_transaction_receipt, fn ^hash, _ ->
          {:ok,
           %{
             # ...
             "transactionHash" => hash,
             "blockNumber" => block
             # ...
           }}
        end)
      end
    end
  end
end
