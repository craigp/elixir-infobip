defmodule Infobip do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    children = [worker(Infobip.TextMessage, [], restart: :transient)]
    opts = [strategy: :simple_one_for_one, name: Infobip.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def stop(_args) do
    # noop
  end

  def send(recipient, message, message_id \\ nil) do
    {:ok, pid} = Supervisor.start_child(Infobip.Supervisor, [recipient, message, message_id])
    GenServer.call(pid, :send)
  end

end
