require Logger
Mix.install([{:sizeable, "~> 1.0"}])
{opts, [], []} = OptionParser.parse(System.argv(), strict: [root_dir: :string, remove: :boolean])
root_dir = Keyword.fetch!(opts, :root_dir)
remove = Keyword.get(opts, :remove, false)

Logger.info("Root dir: #{root_dir} remove: #{remove}")

Logger.info("Root directory: #{root_dir}")

defmodule Traverse do
  defp dir_size(path) do
    {output, 0} = System.cmd("du", ["-sk", path])
    output
    |> String.trim()
    |> String.split("\t")
    |> List.first()
    |> String.to_integer()
    |> then(&(&1 * 1024))
  end

  defp elixir_project?(path) do
    File.dir?(path) and File.exists?(Path.join(path, "mix.exs"))
  end

  defp rust_project?(path) do
    File.dir?(path) and File.exists?(Path.join(path, "target")) and
      File.exists?(Path.join(path, "Cargo.toml"))
  end

  defp node_project?(path) do
    File.dir?(path) and File.exists?(Path.join(path, "node_modules"))
  end

  defp virtual_env?(path) do
    File.dir?(path) and File.exists?(Path.join(path, "pyvenv.cfg")) and
      File.exists?(Path.join(path, ".Python"))
  end

  defp remove(path, opts) do
    remove? = Keyword.fetch!(opts, :remove)

    if File.exists?(path) do
      dir_size_bytes = dir_size(path)
      Agent.update(:size, &(&1 + dir_size_bytes))
      Logger.warning("removing #{path} #{Sizeable.filesize(dir_size_bytes)}")
      if remove?, do: File.rm_rf(path)
    end
  end

  def traverse(path, opts) do
    cond do
      elixir_project?(path) ->
        # remove the deps folder
        remove(Path.join(path, "deps"), opts)
        remove(Path.join(path, "_build"), opts)

      rust_project?(path) ->
        # remove the deps folder
        remove(Path.join(path, "target"), opts)

      node_project?(path) ->
        remove(Path.join(path, "node_modules"), opts)

      virtual_env?(path) ->
        remove(path, opts)

      File.dir?(path) ->
        case File.ls(path) do
          {:ok, paths} ->
            paths
            |> Enum.map(&Path.join(path, &1))
            |> Enum.each(&traverse(&1, opts))

          err ->
            Logger.error("failed to ls dir #{path} #{inspect err}")
        end

      true ->
        :ok
    end
  end
end

Agent.start(fn -> 0 end, name: :size)
Traverse.traverse(root_dir, remove: remove)

total = Agent.get(:size, & &1)
Logger.info("removed #{Sizeable.filesize(total)}")
