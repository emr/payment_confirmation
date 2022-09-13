defmodule Eth do
  @moduledoc false
end

defmodule Eth.Transaction do
  @type hash :: String.t()
  @type t :: %__MODULE__{
          hash: hash()
        }
  defstruct [:hash]
end
