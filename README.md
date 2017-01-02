# Imitate

Imitate provides macros to easily create fake versions of actual modules. These
modules can be injected into code during tests, and report back to the test
process what calls were made.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `imitate` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:imitate, "~> 0.1.0", only: [:test]}]
    end
    ```
    
## Usage

Lets say you have a module named `Client` that makes use of `HTTPoison`. If you
write the `Client` module in such a way that the `HTTPoison` module is a
parameter that you pass in, then you are free to pass in a test implementation
during tests.

It is simple to use `Imitate` to generate that module:

```
defmodule FakeHTTPoison do
  require Imitate
  Imitate.module(HTTPoison)
end
```

It's recommended to do this inside the test module itself, and not share these
fakes between modules.

In your setup function you should start FakeHTTPoison module:

```
setup do
  {:ok, _} = Imitate.start_link(fakeHTTPoison)
end
```

Now any calls made to `FakeHTTPoison` will result in messages being sent to the
test process:

```
FakeHTTPoison.get("http://www.example.com")
assert_receive {Imitate.Call, :get, {"http://www.example.com"}}
```

### Limitations

- It is not currently possible to control what the fake module returns.
- Only one version of a fake module can be used at a time. This means that
  sharing fakes between different test modules could break when using async
  tests.
- Probably other things?
