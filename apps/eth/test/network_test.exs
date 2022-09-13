defmodule Eth.NetworkTest do
  use Eth.NetworkCase
  doctest Eth.Network

  setup do
    eth_stub(:eth_block_number, "0xecdf0b")
    :ok
  end

  test "get current block number" do
    assert 15_523_595 == Eth.Network.current_block_number()
  end

  test "send the transaction and receive the response" do
    test_tx = %Eth.Transaction{hash: "0x01"}
    :ok = Eth.Network.send(test_tx)
    assert_receive {:tx_sent, "0x01"}, 200
  end
end
