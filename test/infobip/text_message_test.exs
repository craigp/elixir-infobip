ExUnit.start

defmodule Infobip.TextMessageTest do

  use ExUnit.Case
  alias Infobip.TextMessage

  setup do
    message_id = "1234"
    recipient = "27821115555"
    message = "This is a test message"
    bypass = Bypass.open
    Application.put_env :infobip, :http, [
      send_url: "http://localhost:#{bypass.port}/api/sendsms/xml",
      delivery_report_url: "http://localhost:#{bypass.port}/api/dlrpull",
      source_msisdn: "",
      sender: "infobip",
      host: "smpp3.infobip.com",
      port: 8888,
      system_id: "Infobip",
      password: "password",
      system_type: "",
      interface_version: 52,
      source_ton: 0,
      source_npi: 1,
      destination_ton: 1,
      destination_npi: 1,
      source_address_range: "",
      destination_address_range: "",
      enquire_link_delay_secs: 10
    ]
    {:ok, %{
      message_id: message_id,
      bypass: bypass,
      message: message,
      recipient: recipient,
      valid_send_response: """
<RESPONSE>
  <status>1</status>
  <credits>100</credits>
</RESPONSE>
      """,
      auth_failed_response: """
<RESPONSE>
  <status>-1</status>
  <credits>100</credits>
</RESPONSE>
      """
    }}
  end

  test "fails properly when Infobip API cannot be reached", %{
    bypass: bypass,
    recipient: recipient,
    message: message
  } do
    Bypass.down(bypass)
    {:error, {:http, "Could not reach Infobip API"}} = TextMessage.send(recipient, message)
  end

  test "responds properly to auth_failed error", %{
    bypass: bypass,
    recipient: recipient,
    message: message,
    auth_failed_response: auth_failed_response
  } do
    Bypass.expect bypass, fn conn ->
      assert "/api/sendsms/xml" == conn.request_path
      assert "" == conn.query_string
      assert "POST" == conn.method
      Plug.Conn.resp(conn, 200, auth_failed_response)
    end
    assert {:error, {:infobip, :auth_failed}} == Infobip.send(recipient, message)
    assert {:error, {:infobip, :auth_failed}} == TextMessage.send(recipient, message)
  end

  test "responds properly to general_error, no more retries" do

  end

  test "sends a text message successfully", %{
    recipient: recipient,
    bypass: bypass,
    valid_send_response: valid_send_response,
    message: message,
    message_id: message_id
  } do
    Bypass.expect bypass, fn conn ->
      assert "/api/sendsms/xml" == conn.request_path
      assert "" == conn.query_string
      assert "POST" == conn.method
      Plug.Conn.resp(conn, 200, valid_send_response)
    end
    {:ok, 1} =
      recipient
      |> Infobip.send(message)
    {:ok, 1} =
      recipient
      |> Infobip.send(message, message_id)
  end

end

