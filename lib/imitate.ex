defmodule Imitate do
  @moduledoc """
  Imitate provides a way of generating mock modules for injecting into tests.

  These modules will have all of the functions of the original module, but
  record their calls by passing messages back to the test process.
  """

  @doc """
  Creates mock functions for each of the functions defined in `module_name`.
  """
  defmacro module(module) do
    {:__aliases__, _, module_path} = module
    module_info = Module.concat(module_path).module_info

    exports =
      module_info
      |> Keyword.get(:exports)
      |> Enum.reject(fn ({name, _}) -> name in [:__info__, :module_info] end)

    for {name, arity} <- exports do
      args = for num <- 1..arity do
        "arg#{num}" |> String.to_atom |> Macro.var(__MODULE__)
      end

      quote do
        def unquote(name)(unquote_splicing(args)) do
          Agent.get(__MODULE__, fn (parent) -> parent end)
          |> send({__MODULE__, unquote(name), {unquote_splicing(args)}})
        end
      end
    end
  end

  @doc """
  Starts the process needed for an imitation module to work properly.

  This should be called once for each imitation involved in a test, and should
  be called from the test process.
  """
  def start_link(module) do
    parent = self
    Agent.start_link(fn -> parent end, name: module)
  end
end
