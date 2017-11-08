defmodule Infobip.Message do

  @moduledoc """
  Builds the XML message to send to the Infobip API.
  """

  import Infobip.Helper, only: [http_config: 0]

  @doc """
  Builds valid XML for the Infobip text message API.
  """
  @spec build_message(String.t, String.t) :: String.t
  def build_message(recipient, message) do
    %{
      sender: sender,
      system_id: system_id,
      password: password,
      source_ton: source_ton,
      source_npi: source_npi,
      destination_ton: destination_ton,
      destination_npi: destination_npi
    } = http_config()

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

  @spec build_message(String.t, String.t, String.t) :: String.t
  def build_message(recipient, message, message_id) do
    %{
      sender: sender,
      system_id: system_id,
      password: password,
      source_ton: source_ton,
      source_npi: source_npi,
      destination_ton: destination_ton,
      destination_npi: destination_npi
    } = http_config()
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
end
