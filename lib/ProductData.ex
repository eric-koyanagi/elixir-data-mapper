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
    rows = CSV.decode!(File.stream!("data/data.csv"), headers: true) 
    Map.new(rows, fn row ->
      # Map imported data by key "sku"
      {row["sku"], row}
    end)
  end

  @doc """
  Given a shopify product, map product data from the custom data store
  Use only the first variant's SKU to only run once per product container
  """
  def mapProductData(shopData, customData) do
    sku = getFirstSku(shopData)
    if Map.has_key?(customData, sku) do
      IO.puts "Found SKU #{sku}! Returning product level changes for product API"
      ProductMapper.buildMap(shopData, customData[sku])
    else
      IO.puts "Cannot find source data for SKU #{sku}"
    end 
  end

  @doc """
  Given a shopify product, iterate each variant; map new data from custom data to
  update each variant 
  """
  def mapVariantData(shopData, customData) do
    if Map.has_key?(shopData, "variants") do 
      for variant <- shopData["variants"] do
        nil
        #IO.inspect variant 
      end 
    end 
  end 


  @doc """
  Given a shopify product map, return the first SKU (either at parent or variant level)  
  """
  def getFirstSku(shopData) do 
    if Map.has_key?(shopData, "variants") do 
      Enum.at(shopData["variants"], 0)["sku"]
    else 
      shopData["sku"]
    end
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