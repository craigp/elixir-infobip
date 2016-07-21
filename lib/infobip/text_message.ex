defmodule Infobip.TextMessage do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, Map.new, name: __MODULE__)
  end

  def init(state) do
    {:ok, state}
  end

end
