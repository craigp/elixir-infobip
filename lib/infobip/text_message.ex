alias Infobip.{TextMessage, Message, Common}

defmodule TextMessage do

  @moduledoc """
  Builds and sends a text message.
  """

  @headers [{"content-type", "text/xml; charset=utf-8"}]

  @type send_response :: :ok | {:error, {:xml, term} | {:infobip, term}}

  @doc """
  Sends a text message.
  """
  @spec send(binary, binary) :: send_response
  def send(recipient, message)
  when is_binary(recipient)
  and is_binary(message)
  do
    recipient
    |> Message.build(message)
    |> do_send
  end

  @spec send(binary, binary, binary) :: send_response
  def send(recipient, message, message_id)
  when is_binary(recipient)
  and is_binary(message)
  and is_binary(message_id)
  do
    recipient
    |> Message.build(message, message_id)
    |> do_send
  end

  @spec do_send(binary) :: send_response
  defp do_send(payload) when is_binary(payload) do
    Common.http_config()
    |> Map.get(:send_url)
    |> HTTPoison.post(payload, @headers)
    |> handle_send_reponse
  end

  @spec handle_send_reponse({atom, map}) :: send_response
  defp handle_send_reponse({:ok, %HTTPoison.Response{body: body}}) do
    case :erlsom.simple_form(body) do
      {:ok, xml, _} ->
        parse_valid_send(xml)
      {:error, reason} ->
        {:error, {:erlsom, reason}}
    end
  end

  defp handle_send_reponse({:error, %HTTPoison.Error{id: _id, reason: reason}}) do
    Common.handle_http_error(reason)
  end

  @spec parse_valid_send(tuple) :: send_response
  defp parse_valid_send(xml) do
    case xml do
      {
        'RESPONSE', [],
        [{'status', [], [status_code]}, {'credits', [], [_credits]}]
      } ->
        case to_string(status_code) do
          "-1" ->
            {:error, {:infobip, :auth_failed}}
          "-2" ->
            {:error, {:infobip, :xml_error}}
          "-3" ->
            {:error, {:infobip, :not_enough_credits}}
          "-4" ->
            {:error, {:infobip, :no_recipients}}
          "-5" ->
            {:error, {:infobip, :general_error}}
          _message_count ->
            :ok
        end
      resp ->
        {:error, {:infobip, "Unrecognised response: #{inspect(resp)}"}}
    end
  end

end
