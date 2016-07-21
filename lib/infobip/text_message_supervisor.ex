defmodule Infobip.TextMessageSupervisor do

  @moduledoc """
  Supervises text message processes.
  """

  use Supervisor

  @doc false
  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @doc false
  def init(:ok) do
    [worker(Infobip.TextMessage, [], restart: :transient)]
    |> supervise(strategy: :simple_one_for_one)
  end

end

