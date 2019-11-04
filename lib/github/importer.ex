defmodule AwesomeBatteries.GitHub.Importer do

  @timeout 60_000

  # API
  def fetch_repos(repos, async \\ false) do
    f = &fetch_repo/1
    map_to_tasks = &(if async, do: Enum.map(&1, f), else: Stream.map(&1, f))
    # Task.async fails on Arch for some reason
    repos
    |> map_to_tasks.()
    |> Enum.map(fn task -> task |> Task.await(@timeout) end)
  end

  defp fetch_repo(repo) do
    Task.async(fn ->
      :poolboy.transaction(
        :importer_worker,
        fn pid -> GenServer.call(pid, {:fetch, repo, request_options()}, @timeout) end,
        @timeout
      )
    end)
  end

  defp request_options do
    [
      basic_auth: {System.get_env("GITHUB_USER"), System.get_env("GITHUB_PASS")},
      headers: ["User-Agent": "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/77.0.3865.120 Safari/537.36"],
      timeout: @timeout,
      follow_redirects: true
    ]
  end

  defp rate_limit do
    HTTPotion.get(
      "https://api.github.com/rate_limit",
      request_options()
    )
  end

end
