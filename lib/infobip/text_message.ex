defmodule Infobip.TextMessage do
  use GenServer
  require Logger

  @max_retries 3
  @retry_intervals [10_000, 30_000, 60_000]
  @send_interval 100

  #  Server API {{{ #

  @doc false
  def start_link(recipient, message) do
    Logger.debug "Starting server to send text message to #{recipient}"
    GenServer.start_link(__MODULE__, [recipient, message])
  end

  @doc false
  def init([recipient, message]) do
    Process.send_after(self, :send, @send_interval)
    {:ok, %{recipient: recipient, message: message, retries: 0}}
  end

  @doc false
  def handle_info(:send, state) do
    GenServer.cast(self, :send)
    {:noreply, state}
  end

  @doc false
  def handle_cast(:send, %{
    recipient: recipient,
    message: message,
    retries: retries
  } = state) do
    case do_send(recipient, message, retries) do
      :done ->
        {:stop, :normal, state}
      :retry ->
        {:noreply, %{state | retries: retries + 1}}
    end
  end

  #  }}} Server API #

  #  Client API {{{ #

  @doc """
  Builds valid XML for the Infobip text message API.
  """
  def build_message(recipient, message) do
    Logger.debug "Building XML for text message to #{recipient}"
    %{
      system_id: system_id,
      password: password,
      source_ton: source_ton,
      source_npi: source_npi,
      destination_ton: destination_ton,
      destination_npi: destination_npi
    } = Infobip.Helper.extract_config

    {:SMS, nil, [
      {:authentification, nil, [
        {:username, nil, system_id},
        {:password, nil, password}
      ]}, {:message, nil, [
        {:sender, nil, "paydna"},
        {:text, nil, message},
        {:Srcton, nil, source_ton},
        {:Srcnpi, nil, source_npi},
        {:Destton, nil, destination_ton},
        {:Destnpi, nil, destination_npi}
      ]}, {:recipients, nil, [
        {:gsm, nil, recipient}
      ]}
    ]} |> XmlBuilder.generate
  end

  def build_message(message_id, recipient, message) do
    Logger.debug "Building XML for text message #{message_id} to #{recipient}"
    %{
      system_id: system_id,
      password: password,
      source_ton: source_ton,
      source_npi: source_npi,
      destination_ton: destination_ton,
      destination_npi: destination_npi
    } = Infobip.Helper.extract_config

    {:SMS, nil, [
      {:authentification, nil, [
        {:username, nil, system_id},
        {:password, nil, password}
      ]}, {:message, nil, [
        {:sender, nil, "paydna"},
        {:text, nil, message},
        {:Srcton, nil, source_ton},
        {:Srcnpi, nil, source_npi},
        {:Destton, nil, destination_ton},
        {:Destnpi, nil, destination_npi}
      ]}, {:recipients, nil, [
        {:gsm, %{messageId: message_id}, recipient}
      ]}
    ]} |> XmlBuilder.generate
  end

  @doc """
  Sends a text message to the recipient.
  """
  def send(recipient, message) do
    {:ok, _pid} = Supervisor.start_child(Infobip.TextMessageSupervisor, [recipient, message])
  end

  #  }}} Client API #

  #  Private functions {{{ #

  def do_send(recipient, message, retries) do
    Logger.debug "Sending text message to #{recipient}"
    build_message(recipient, message)
    |> Infobip.Helper.send
    |> case do
      {:error, reason} ->
        Logger.error "Failed to send text message to #{recipient} (#{reason})"
        cond do
          retries >= @max_retries ->
            Logger.debug "No more retries for text message to #{recipient}, giving up"
            :done
          true ->
            Logger.debug "Text message to #{recipient} retry #{retries}/#{@max_retries}"
            Process.send_after(self, :send, Enum.at(@retry_intervals, retries))
            :retry
        end
      {:ok, _count} ->
        Logger.debug "Successfully send text message to #{recipient}"
        :done
    end
  end

  #  }}} Private functions #
end
