defmodule Eth.Confirmation.TrackerTest do
  use Eth.NetworkCase
  doctest Eth.Confirmation.Tracker

  setup do
    # define current block number
    eth_stub(:eth_block_number, "0xecdf0b")
    # called in doctest (tx from 5 blocks behind)
    eth_stub(:eth_get_transaction_receipt, "0x1a...", "0xecdf06")
    start_supervised!(Eth.Confirmation.Tracker)
    :ok
  end

  # durations used in tests are set according to parameters in `config/test.ex`
  # confirmation_interval: 100
  # confirmation_block_count: 2
  # confirmation_max_attempts: 2

  test "tx from 5 blocks behind should be confirmed" do
    # tx from 5 blocks behind
    eth_stub(:eth_get_transaction_receipt, "0x2b...", "0xecdf06")
    :ok = Eth.Confirmation.Tracker.add("0x2b...")
    assert_receive {:tx_confirmed, "0x2b..."}, 110
  end

  test "tx from last block should be failed when no new block is added" do
    # tx from the current block
    eth_stub(:eth_get_transaction_receipt, "0x2b...", "0xecdf0b")
    :ok = Eth.Confirmation.Tracker.add("0x2b...")
    assert_receive {:tx_failed, "0x2b..."}, 310
  end

  test "tx from last block should be confirmed when a new block is added" do
    # tx from the current block
    eth_stub(:eth_get_transaction_receipt, "0x2b...", "0xecdf0b")
    :ok = Eth.Confirmation.Tracker.add("0x2b...")

    # simulate new block
    Process.send_after(self(), :new_block, 100)

    receive do
      :new_block ->
        eth_stub(:eth_block_number, "0xecdf0b")
    end

    assert_receive {:tx_failed, "0x2b..."}, 310
  end
end
