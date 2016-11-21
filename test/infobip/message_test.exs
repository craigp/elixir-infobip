ExUnit.start

defmodule Infobip.MessageTest do

  use ExUnit.Case

  setup do
    message_id = 1234
    recipient = "27821115555"
    message = "This is a test message"
    Application.put_env :infobip, :http, [
      send_url: "http://localhost:1234/api/sendsms/xml",
      delivery_report_url: "http://localhost:1234/api/dlrpull",
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
      recipient: recipient,
      message: message
    }}
  end

  test "builds valid XML for the Infobip API, without a message ID", %{
    recipient: recipient,
    message: message
  } do
    xml = Infobip.Message.build_message(recipient, message)
    xml = String.replace(xml, ~r/[\n\t\s]/, "")
    valid_xml = ~s"""
<SMS>
  <authentification>
    <username>Infobip</username>
    <password>password</password>
  </authentification>
  <message>
    <sender>infobip</sender>
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
    xml = Infobip.Message.build_message(recipient, message, message_id)
    xml = String.replace(xml, ~r/[\n\t\s]/, "")
    valid_xml = ~s"""
<SMS>
  <authentification>
    <username>Infobip</username>
    <password>password</password>
  </authentification>
  <message>
    <sender>infobip</sender>
    <text>#{message}</text>
    <Srcton>0</Srcton>
    <Srcnpi>1</Srcnpi>
    <Destton>1</Destton>
    <Destnpi>1</Destnpi>
  </message>
  <recipients>
    <gsm messageId=\"#{message_id}\">
      #{recipient}
    </gsm>
  </recipients>
</SMS>
"""
    valid_xml = String.replace(valid_xml, ~r/[\n\t\s]/, "")
    assert xml == valid_xml
  end

end
