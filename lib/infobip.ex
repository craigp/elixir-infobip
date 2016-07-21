defmodule Infobip do
  use Application

  def start(_type, _args) do
    Infobip.Supervisor.start_link
  end

  def stop(_args) do
    # noop
  end

end
