ExUnit.start

defmodule Infobip.TextMessageTest do

  use ExUnit.Case

  setup do
    message_id = 1234
    recipient = "27821115555"
    message = "This is a test message"
    bypass = Bypass.open
    Application.put_env :infobip, :http, [
      url: "http://localhost:#{bypass.port}/infobip/",
      source_msisdn: "",
      host: "smpp3.infobip.com",
      port: 8888,
      system_id: "PayDNA",
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
      valid_response: """
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

  test "builds valid XML for the Infobip API, without a message ID", %{
    recipient: recipient,
    message: message
  } do
    xml = Infobip.TextMessage.build_message(recipient, message)
    xml = String.replace(xml, ~r/[\n\t\s]/, "")
    valid_xml = """
<SMS>
  <authentification>
    <username>PayDNA</username>
    <password>password</password>
  </authentification>
  <message>
    <sender>paydna</sender>
    <text>#{message}</text>
    <Srcton>0</Srcton>
    <Srcnpi>1</Srcnpi>
    <Destton>1</Destton>
    <Destnpi>1</Destnpi>
  </message>
  <recipients>
    <gsm>
      #{recipient}
    </gsm>
  </recipients>
</SMS>
"""
    valid_xml = String.replace(valid_xml, ~r/[\n\t\s]/, "")
    assert xml == valid_xml
  end

  test "builds valid XML for the Infobip API, with a message ID", %{
    message_id: message_id,
    recipient: recipient,
    message: message
  } do
    xml = Infobip.TextMessage.build_message(recipient, message, message_id)
    xml = String.replace(xml, ~r/[\n\t\s]/, "")
    valid_xml = """
<SMS>
  <authentification>
    <username>PayDNA</username>
    <password>password</password>
  </authentification>
  <message>
    <sender>paydna</sender>
    <text>#{message}</text>
    <Srcton>0</Srcton>
    <Srcnpi>1</Srcnpi>
    <Destton>1</Destton>
    <Destnpi>1</Destnpi>
  </message>
  <recipients>
    <gsm messageId="#{message_id}">
      #{recipient}
    </gsm>
  </recipients>
</SMS>
"""
    valid_xml = String.replace(valid_xml, ~r/[\n\t\s]/, "")
    assert xml == valid_xml
  end

  test "fails properly when Infobip API cannot be reached", %{
    bypass: bypass,
    recipient: recipient,
    message: message
  } do
    Bypass.down(bypass)
    {:error, "Could not reach Infobip API"} =
      Infobip.TextMessage.build_message(recipient, message)
      |> Infobip.Helper.send
  end

  test "responds properly to auth_failed error", %{
    bypass: bypass,
    recipient: recipient,
    message: message,
    auth_failed_response: auth_failed_response
  } do
    Bypass.expect bypass, fn conn ->
      assert "/infobip/" == conn.request_path
      assert "" == conn.query_string
      assert "POST" == conn.method
      Plug.Conn.resp(conn, 200, auth_failed_response)
    end
    retries = 0
    {:error, :auth_failed} =
      Infobip.TextMessage.build_message(recipient, message)
      |> Infobip.Helper.send
    {:error, :auth_failed} = Infobip.TextMessage.do_send(recipient, message, retries)
  end

  test "responds properly to general_error, no more retries" do

  end

  test "sends a text message successfully" do

  end

end

