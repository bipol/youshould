defmodule Youshould.Router do
    use Plug.Router
    import Youshould.Utils

    plug :match
    plug :dispatch

    def start_link do
        {:ok, _} = Plug.Adapters.Cowboy.http(Youshould.Router, [])
    end

    # query params:
    # date/time : date time local to the user
    # latitude : lat of user position
    # longitude: long of user position
    get "/api/getEvents" do
        conn = fetch_query_params(conn)
        case check_params(conn.params) do
            {:ok, _} ->
                resp = get_something_to_do(conn.params["latitude"], conn.params["longitude"])
                       |> Poison.encode!()
                conn
                |> put_resp_header("Access-Control-Allow-Origin", "*")
                |> send_resp(200, resp)
            {:error, body} ->
                conn
                |> send_resp(400, body)
        end
    end

    # match anything else with a 404
    match _ do
        conn
        |> send_resp(404, "Nothing here.")
    end
end
