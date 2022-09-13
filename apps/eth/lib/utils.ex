defmodule Eth.Utils do
  @moduledoc """
  Utils that can be used in Eth module.
  """

  @doc """
  Converts given hex string to an integer value

  ## Examples

  ```
  iex> Eth.Utils.hex_to_number("0xa")
  10
  iex> Eth.Utils.hex_to_number("b")
  11
  ```
  """
  @spec hex_to_number(String.t()) :: integer()
  def hex_to_number(value) do
    hex_value =
      case value do
        "0x" <> hex -> hex
        _ -> value
      end

    {result, _} = Integer.parse(hex_value, 16)
    result
  end
end
