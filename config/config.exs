import Config

config :elixir_data_mapper, [
  shop_name: "my-shop",
  api_key: "",
  password: ""
]

# overwrite the above with env-specific config files, like dev.exs
import_config "#{config_env()}.exs"