defmodule Infobip.Helper do
  require Logger

  @doc """
  Send the text message through Infobip's HTTP API.
  """
  def send(payload) do
    %{url: url} = extract_config
    headers = [{"content-type", "text/xml; charset=utf-8"}]
    case HTTPoison.post(url, payload, headers) do
      {:ok, response} ->
        case :erlsom.simple_form(response.body) do
          {:ok, xml, _} ->
            case xml do
              {'RESPONSE', [], [{'status', [], [status_code]}, {'credits', [], [_credits]}]} ->
                case to_string(status_code) do
                  "-1" ->
                    {:error, :auth_failed}
                  "-2" ->
                    Logger.error("Failed text message XML: #{response.body}")
                    {:error, :xml_error}
                  "-3" ->
                    {:error, :not_enough_credits}
                  "-4" ->
                    Logger.error("Failed text message XML: #{response.body}")
                    {:error, :no_recipients}
                  "-5" ->
                    {:error, :general_error}
                  message_count ->
                    {:ok, String.to_integer(message_count)}
                end
              _else ->
                {:error, "Unrecognised response: #{response.body}"}
            end
          {:error, reason} ->
            {:error, "Infobip XML response could not be parsed: #{reason}"}
        end
      {:error, %HTTPoison.Error{id: _id, reason: reason}} ->
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

  @doc """
  Loads the Infobip config.
  """
  def extract_config do
    Enum.into(Application.get_env(:infobip, :http), %{})
  end

end
