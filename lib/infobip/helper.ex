defmodule Infobip.Helper do
  require Logger

  @headers [{"content-type", "text/xml; charset=utf-8"}]

  @doc """
  Send the text message through Infobip's HTTP API.
  """
  def send(payload) do
    extract_config
    |> Map.get(:url)
    |> HTTPoison.post(payload, @headers)
    |> handle_infobip_response(payload)
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

  defp handle_infobip_response({:ok, response}, payload) do
    case :erlsom.simple_form(response.body) do
      {:ok, xml, _} ->
        parse_valid_xml(xml, response.body, payload)
      {:error, reason} ->
        {:error, "Infobip XML response could not be parsed: #{reason}"}
    end
  end

  defp handle_infobip_response({:error, %HTTPoison.Error{id: _id, reason: reason}}, _payload) do
    case reason do
      :nxdomain ->
        {:error, "Could not reach Infobip API"}
      :econnrefused ->
        {:error, "Could not reach Infobip API"}
      reason ->
        {:error, reason}
    end
  end

  defp parse_valid_xml(xml, response, payload) do
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

end
