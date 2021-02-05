alias Infobip.{Message, Common}

defmodule Message do

  @moduledoc """
  Builds the XML message to send to the Infobip API.
  """

  @doc """
  Builds valid XML for the Infobip text message API.
  """
  @spec build(binary, binary) :: binary
  def build(recipient, message) do
    do_build(recipient, message, nil)
  end

  @spec build(binary, binary, binary) :: binary
  def build(recipient, message, message_id) do
    do_build(recipient, message, %{messageId: message_id})
  end

  @spec do_build(binary, binary, map | nil) :: binary
  defp do_build(recipient, message, message_id) do
    %{
      sender: sender,
      system_id: system_id,
      password: password,
      source_ton: source_ton,
      source_npi: source_npi,
      destination_ton: destination_ton,
      destination_npi: destination_npi
    } = Common.http_config()
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
        {:gsm, message_id, recipient}
      ]}
    ]} |> XmlBuilder.generate
  end

end
