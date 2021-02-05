defmodule Infobip.CommonTest do

  use ExUnit.Case, async: true

  alias Infobip.Common

  doctest Infobip.Common, import: true

  describe "http_config/0" do

    test "raise an error if config missing" do
      conf = Application.get_env(:infobip, :api)
      Application.put_env(:infobip, :api, nil)
      assert_raise RuntimeError, "No Infobip config available", fn ->
        Common.http_config()
      end
      Application.put_env(:infobip, :api, conf)
    end

  end


end
