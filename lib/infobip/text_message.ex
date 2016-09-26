defmodule Infobip.TextMessage do
  use GenServer
  require Logger

  #  Server API {{{ #

  @doc false
  def start_link(recipient, message, message_id) do
    Logger.debug "Starting server to send text message to #{recipient}"
    GenServer.start_link(__MODULE__, {recipient, message, message_id})
  end

  @doc false
  def init({recipient, message, message_id}) do
    {:ok, %{recipient: recipient, message: message, message_id: message_id}}
  end

  @doc false
  def handle_call(:send, _from, %{
    recipient: recipient,
    message: message,
    message_id: message_id
  } = state) do
    case do_send(recipient, message, message_id) do
      {:ok, count} ->
        {:stop, :normal, {:ok, count}, state}
      {:error, reason} ->
        {:stop, :normal, {:error, reason}, state}
    end
  end

  #  }}} Server API #

  #  Client API {{{ #

  @doc """
  Builds valid XML for the Infobip text message API.
  """
  def build_message(recipient, message), do: build_message(recipient, message, nil)

  def build_message(recipient, message, nil) do
    %{
      sender: sender,
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
        {:sender, nil, sender},
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

  def build_message(recipient, message, message_id) do
    %{
      sender: sender,
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
        {:sender, nil, sender},
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

  #  }}} Client API #

  #  Private functions {{{ #

  def do_send(recipient, message, message_id) do
    recipient
    |> build_message(message, message_id)
    |> Infobip.Helper.send
  end

  #  }}} Private functions #
end
