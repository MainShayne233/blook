defmodule Mix.Tasks.Assets.Install do
  use Mix.Task

  def run(_args) do
    File.cd!("assets")
    Mix.Shell.IO.info("Running npm i")
    Mix.Shell.IO.cmd("npm i")
    Mix.Shell.IO.info("Running elm package install")
    Mix.Shell.IO.cmd("elm package install -y")
    File.cd!("..")
    Mix.Shell.IO.info([:green, "Assets have been installed"])
  end
end
