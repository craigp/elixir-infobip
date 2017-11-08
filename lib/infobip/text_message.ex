defmodule Infobip.TextMessage do

  @moduledoc """
  Builds and sends a text message.
  """

  alias Infobip.{Helper, Message}
  alias HTTPoison.{Response, Error}
  import Message
  import Helper, only: [http_config: 0, handle_http_error: 1]
  import HTTPoison, only: [post: 3]

  @headers [{"content-type", "text/xml; charset=utf-8"}]

  @type send_response :: {:ok, integer | {atom, any}} | {:error, any}

  @doc """
  Sends a text message.
  """
  @spec send(String.t, String.t) :: send_response
  def send(recipient, message)
  when is_binary(recipient)
  and is_binary(message)
  do
    recipient
    |> build_message(message)
    |> do_send
  end

  @spec send(String.t, String.t, String.t) :: send_response
  def send(recipient, message, message_id)
  when is_binary(recipient)
  and is_binary(message)
  and is_binary(message_id)
  do
    recipient
    |> build_message(message, message_id)
    |> do_send
  end

  @spec do_send(String.t) :: send_response
  defp do_send(payload) when is_binary(payload) do
    http_config()
    |> Map.get(:send_url)
    |> post(payload, @headers)
    |> handle_send_reponse
  end

  @spec handle_send_reponse({atom, map}) :: send_response
  defp handle_send_reponse({:ok, %Response{body: body}}) do
    case :erlsom.simple_form(body) do
      {:ok, xml, _} ->
        parse_valid_send(xml)
      {:error, reason} ->
        {:error, {:erlsom, reason}}
    end
  end

  defp handle_send_reponse({:error, %Error{id: _id, reason: reason}}) do
    handle_http_error(reason)
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
          message_count ->
            {:ok, String.to_integer(message_count)}
        end
      _else ->
        {:error, {:parse, "Unrecognised response"}}
    end
  end

end
