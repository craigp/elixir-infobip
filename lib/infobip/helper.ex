defmodule Infobip.Helper do
  require Logger

  @headers [{"content-type", "text/xml; charset=utf-8"}]

  @doc """
  Send the text message through Infobip's HTTP API.
  """
  def send(payload) do
    extract_config
    |> Map.get(:send_url)
    |> HTTPoison.post(payload, @headers)
    |> handle_send_reponse(payload)
  end

  def delivery_report(message_id) do
    %{
      delivery_report_url: url,
      system_id: id,
      password: pass
    } = extract_config
    "#{url}?user=#{id}&password=#{pass}&messageId=#{message_id}"
    |> HTTPoison.get
    |> handle_delivery_report_response
  end

  @doc """
  Loads the Infobip config.
  """
  def extract_config do
    case Application.get_env(:infobip, :http) do
      nil ->
        raise "No :infobip config for env #{Mix.env}"
      config ->
        config
        |> Enum.into(%{})
    end
  end

  defp handle_delivery_report_response({:ok, %HTTPoison.Response{body: "NO_DATA", status_code: 200}}) do
    :unknown
  end

  defp handle_delivery_report_response({:ok, %HTTPoison.Response{body: body, status_code: 200}}) do
    case :erlsom.simple_form(body) do
      {:ok, xml, _} ->
        parse_valid_delivery_response(xml, body)
      {:error, reason} ->
        {:error, "Infobip XML response count not be parsed: #{reason}"}
    end
  end

  defp handle_delivery_report_response({:ok, %HTTPoison.Response{status_code: status_code}}) do
    {:error, {:http, status_code}}
  end

  defp handle_delivery_report_response({:error, %HTTPoison.Error{id: _id, reason: reason}}) do
    handle_http_error(reason)
  end

  defp parse_valid_delivery_response(xml, response) do
    case xml do
      {'DeliveryReport', [],
       [{'message',
         [{'pducount', _}, {'price', _}, {'gsmerror', _},
          {'status', status}, {'donedate', delivery_date},
      {'sentdate', _}, {'id', _}], []}]} ->
        status =
          status
          |> to_string
          |> String.downcase
          |> String.to_atom
        {:ok, status, to_string(delivery_date)}
      _else ->
        {:error, "Unrecognised response: #{response}"}
    end
  end

  defp handle_send_reponse({:ok, %HTTPoison.Response{body: body}}, payload) do
    case :erlsom.simple_form(body) do
      {:ok, xml, _} ->
        parse_valid_send(xml, body, payload)
      {:error, reason} ->
        {:error, "Infobip XML response could not be parsed: #{reason}"}
    end
  end

  defp handle_send_reponse({:error, %HTTPoison.Error{id: _id, reason: reason}}, _payload) do
    handle_http_error(reason)
  end

  defp parse_valid_send(xml, response, payload) do
    case xml do
      {'RESPONSE', [], [{'status', [], [status_code]}, {'credits', [], [_credits]}]} ->
        case to_string(status_code) do
          "-1" ->
            {:error, :auth_failed}
          "-2" ->
            Logger.error("Failed text message XML: #{payload}")
            {:error, :xml_error}
          "-3" ->
            {:error, :not_enough_credits, response}
          "-4" ->
            Logger.error("Failed text message XML: #{payload}")
            {:error, :no_recipients}
          "-5" ->
            {:error, :general_error}
          message_count ->
            {:ok, String.to_integer(message_count)}
        end
      _else ->
        {:error, "Unrecognised response: #{response}"}
    end
  end

  defp handle_http_error(reason) do
    case reason do
      :nxdomain ->
        {:error, "Could not reach Infobip API"}
      :econnrefused ->
        {:error, "Could not reach Infobip API"}
      reason ->
        {:error, reason}
    end
  end

end
