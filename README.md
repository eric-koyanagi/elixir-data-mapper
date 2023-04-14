# DM

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `elixir_data_mapper` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:elixir_data_mapper, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/elixir_data_mapper>.


## Purpose

This application takes a flattened export of data (in this case, a CSV) and maps it to various objects in Shopify. It uses the product SKU to associate data. 

For example, adding each product to many collections in Shopify, associating it to a Shopify product taxonomy, setting the "vendor" field, or setting each variant's InventoryItem country of origin. 

This can be expanded for more specific mappings or data.

This application respects Shopify's rate limits. 


## Usage

This is not really intended to be easy to adapt to every use case. It is a good starting point for your specific business logic if you need a reference for using Shopify's APIs with Elixir. 

```
DM.Supervisor.start_links([])
DM.sync_all
```

DM.Supervisor.start_links([]) will start the data mapper's shopify rate limiter supervisors for both the rest API and graphQL, using gen_source. 

DM.sync_all will run the entire product sync -- it will map data from a CSV located in the /data folder and use that to push updates to matching productes or variants in Shopify. 

It works by paginating products in Shopify -- it assumes products already exist there from a more basic import and need to be enriched with other data.