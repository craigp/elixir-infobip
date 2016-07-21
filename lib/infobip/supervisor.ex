defmodule Infobip.Supervisor do

  @moduledoc """
  Paste the README here
  """

  use Supervisor

  @doc false
  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @doc false
  def init(:ok) do
    children = [
      supervisor(Infobip.TextMessageSupervisor, [])
    ]
    supervise(children, strategy: :one_for_one)
  end

end
