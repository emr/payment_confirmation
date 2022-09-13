defmodule Eth.Config do
  @spec confirmation_block_count :: integer()
  def confirmation_block_count() do
    Application.fetch_env!(:eth, :confirmation_block_count)
  end

  @spec send_simulation_duration :: integer()
  def send_simulation_duration() do
    Application.fetch_env!(:eth, :send_simulation_duration)
  end

  @spec confirmation_interval :: integer()
  def confirmation_interval() do
    Application.fetch_env!(:eth, :confirmation_interval)
  end

  @spec confirmation_max_attempts :: integer()
  def confirmation_max_attempts() do
    Application.fetch_env!(:eth, :confirmation_max_attempts)
  end

  @spec rpc_client() :: module()
  def rpc_client() do
    Application.fetch_env!(:eth, :rpc_client)
  end
end
