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
    |> handle_infobip_response
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

  defp handle_infobip_response({:ok, response}) do
    case :erlsom.simple_form(response.body) do
      {:ok, xml, _} ->
        parse_valid_xml(xml, response)
      {:error, reason} ->
        {:error, "Infobip XML response could not be parsed: #{reason}", response.body}
    end
  end

  defp handle_infobip_response({:error, %HTTPoison.Error{id: _id, reason: reason}}) do
    case reason do
      :nxdomain ->
        {:error, "Could not reach Infobip API"}
      :econnrefused ->
        {:error, "Could not reach Infobip API"}
      reason ->
        {:error, reason}
    end
  end

  defp parse_valid_xml(xml, response) do
    case xml do
      {'RESPONSE', [], [{'status', [], [status_code]}, {'credits', [], [_credits]}]} ->
        case to_string(status_code) do
          "-1" ->
            {:error, :auth_failed, response.body}
          "-2" ->
            Logger.error("Failed text message XML: #{response.body}")
            {:error, :xml_error, response.body}
          "-3" ->
            {:error, :not_enough_credits, response.body}
          "-4" ->
            Logger.error("Failed text message XML: #{response.body}")
            {:error, :no_recipients, response.body}
          "-5" ->
            {:error, :general_error, response.body}
          message_count ->
            {:ok, String.to_integer(message_count)}
        end
      _else ->
        {:error, "Unrecognised response: #{response.body}", response.body}
    end
  end

end
