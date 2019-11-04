defmodule AwesomeBatteries.GitHub.Importer.Worker do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, [])
  end

  def init(_) do
    {:ok, nil}
  end

  def handle_call({:fetch, repo, request_options}, _from, state) do
    repo_info = case fetch_repo_info(repo, request_options) do
      %{ status_code: 200, body: body } ->
        body
        |> Jason.decode!()
        |> Map.take(["updated_at", "stargazers_count"])
        |> case do
          data ->
            case fetch_commits(repo, request_options) do
              %{ status_code: 200, body: body } ->

                [updated_at] = body
                  |> Jason.decode!()
                  |> Stream.map(fn commit ->
                    {:ok, datetime, 0} = get_in(commit, ["commit", "author", "date"]) |> DateTime.from_iso8601()
                    datetime
                  end)
                  |> Enum.sort_by(fn date -> {date.year, date.month, date.day} end, &>=/2)
                  |> Enum.take(1)

                %{ status: :ok, data: %{data | "updated_at" => updated_at}, repo: repo }

              data -> %{ status: :error, data: data, repo: repo }
            end
        end

      data -> %{ status: :error, data: data, repo: repo }

    end
    IO.puts inspect repo_info
    {:reply, repo_info, state}
  end

  defp fetch_commits(%{ "owner" => owner, "name" => name }, request_options) do
    HTTPotion.get(
      "https://api.github.com/repos/#{owner}/#{name}/commits",
      request_options
    )
  end

  defp fetch_repo_info(%{ "owner" => owner, "name" => name }, request_options) do
    HTTPotion.get(
      "https://api.github.com/repos/#{owner}/#{name}",
      request_options
    )
  end

end
