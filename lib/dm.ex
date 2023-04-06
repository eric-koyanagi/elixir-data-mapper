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
    # Load product data that we want to "merge" into shopify
    productData = ProductData.load()
    IO.puts "All Custom Product Data:"
    IO.inspect productData

    # Return a map of Shopify collections, keyed by name, so I can use collection IDs to add to products
    collectionMap = ProductData.mapCollections()

    for product <- ShopifyClient.get_products().body["products"] do 
      #IO.puts "Shopify Product Data:"
      #IO.inspect product
      #IO.puts "----"

      # Map custom data to Shopify product, then update the product
      ProductData.mapProductData(product, productData) #|> ShopifyClient.update_product
      #ProductData.mapVariantData(product, productData)
      
      #ProductData.enrich(product, productData, product[:id]) 
      #  |> ShopifyClient.update_product(product[:id])

      # add to collections 
      #ProductData.getCollections(productData, product[:id]) |> ShopifyClient.add_to_collections(product[:id], collectionMap)

      # use graphQL api to add proper category; this can't be done with the rest API 
      # why not use graphQL for everything? Because there's no pre-built client and that's out of scope for this task (for now)
      # ProductData.getTaxClass(product[:id]) |> CategoryMapper.get_shopify_category |> ShopifyGraphQLClient.updateTaxonomy
    end 

  end
end
