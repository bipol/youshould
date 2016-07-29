defmodule Youshould.Utils do

    # check the parameters to ensure they are okay
    def check_params(params) do
        case params do
            %{"date" => _, "latitude" => _, "longitude" => _} -> {:ok, params}
            _ -> {:error, "Response must have date, latitude, and longitude, received: #{params}"}
        end
    end

    def atomize_response(json) do
        Poison.Parser.parse!(json, keys: :atoms)
    end

    def query_weather(lat, lon) do
        atomize_response(
          HTTPotion.get("api.openweathermap.org/data/2.5/weather",
              query: %{lat: lat, lon: lon, APPID: Application.get_env(:youshould, :owm_api_key)}).body
        )
    end

    def query_events(lat, lon) do
        atomize_response(
          HTTPotion.get("http://api.eventful.com/json/events/search",
            query: %{location: lat <> "," <> lon, within: 10, date: "Today", app_key: Application.get_env(:youshould, :eventful_api_key)}).body
        )
    end

    defmodule Response do
        defstruct weather: %{ type: nil, temperature: nil},
                  event: %{ title: nil, description: nil, address: nil, start_time: nil, stop_time: nil}
    end

    def convertKtoF(temp) do
        Float.round((((temp - 273.15) * 1.8) + 32))
    end

    def get_something_to_do(lat, lon) do
        weather = query_weather(lat, lon)
        events = query_events(lat, lon)
        event = hd(events.events.event)
        %Response{
          weather: %{ type: hd(weather.weather).main, temperature: convertKtoF(weather.main.temp)  },
          event: %{ title: event.title, description: event.description, address: event.venue_address, start_time: event.start_time, stop_time: event.stop_time }
        }
    end
end
