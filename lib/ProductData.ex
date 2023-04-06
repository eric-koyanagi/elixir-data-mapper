defmodule ProductData do

  @moduledoc """
  Product data module; this loads "source" data from a CSV and holds it in memory 
  We then pull products from Shopify and enrich it using this source data
  """

  @doc """
  Loads custom product data from a source; in this case, a CSV...but you could replace this if you wanted

  ## Examples

      iex> ProductData.load()

  """
  def load do
    
  end

  @doc """
  Obtains all existing custom collections from Shopify, then maps their "name" to the collection ID so that we can easily add products to a given collection by name/handle

  ## Examples

      iex> ProductData.mapCollections()

  """
  def mapCollections do
    for collection <- ShopifyClient.get_collections.body["custom_collections"] do 
      {collection["title"], collection["id"]}
    end
  end
end
