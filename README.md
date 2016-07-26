elixir-infobip 
============
[![Build Status](https://secure.travis-ci.org/craigp/elixir-infobip.png?branch=master "Build Status")](http://travis-ci.org/craigp/elixir-infobip) 
[![Coverage Status](https://coveralls.io/repos/craigp/elixir-infobip/badge.svg?branch=master&service=github)](https://coveralls.io/github/craigp/elixir-infobip?branch=master) 
[![hex.pm version](https://img.shields.io/hexpm/v/infobip.svg)](https://hex.pm/packages/infobip) 
[![hex.pm downloads](https://img.shields.io/hexpm/dt/infobip.svg)](https://hex.pm/packages/infobip)
[![Inline docs](http://inch-ci.org/github/craigp/elixir-infobip.svg?branch=master&style=flat)](http://inch-ci.org/github/craigp/elixir-infobip)

A simple Infobip REST API client for Elixir.

You can find the hex package [here](https://hex.pm/packages/infobip), and the docs [here](http://hexdocs.pm/infobip).

## Usage

```elixir
def deps do
  [{:infobip, "~> 0.1"}]
end
```

Then run `$ mix do deps.get, compile` to download and compile your dependencies.

Finally, add the `:infobip` application as your list of applications in `mix.exs`:

```elixir
def application do
  [applications: [:logger, :infobip]]
end
```

You'll need to set a few config parameters, take a look in the `dev.exs.sample` file for 
an example of what is required.

Then sending a text message is as easy as:

```elixir
{:ok, pid} = Infobip.TextMessage.send("27820001111", "Test message")
```

You need to pass a valid international mobile number to the `send/2` method.

## TODO

* [x] Send text messages
* [ ] Fetch delivery reports
* [ ] SMPP interface
