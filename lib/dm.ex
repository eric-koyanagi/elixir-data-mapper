defmodule DM do
  @moduledoc """
  Entry point for data mapper; high level controller for pushing custom data to Shopify
  """

  @doc """
  Iterates all products in Shopify using data mapped from another source

  ## Examples

      iex> DM.sync()

  """
  def sync do
    #customData = ProductData.load()
    #ProductData.mapCollections()

    for product <- ShopifyClient.get_products() do 
      IO.inspect product
      # do a basic shopify update for simple things we can update via rest api 
      #ProductData.enrich(customData, product[:id]) |> ShopifyClient.update_product(product[:id])

      # add to collections 
      #ProductData.getCollections(customData, product[:id]) |> ShopifyClient.add_to_collections(product[:id])

      # use graphQL api to add proper category
      # ProductData.getTaxClass(product[:id]) |> CategoryMapper.get_shopify_category |> ShopifyGraphQLClient.updateTaxonomy
    end 

  end
end
