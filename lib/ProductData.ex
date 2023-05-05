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

  def load_styles do
    rows = CSV.decode!(File.stream!("data/cin7_data.csv"), headers: true) 
    Map.new(rows, fn row ->
      # Map imported data by key "sku"
      {row["Code"], row}
    end)
  end

  @doc """
  Given a shopify product, map product data from the custom data store
  Use only the first variant's SKU to only run once per product container
  """
  def map_product_data(shopData, customData, dropshipData, cin7Data) do
    sku = getFirstSku(shopData)
    if Map.has_key?(customData, sku) do
      IO.puts "Found SKU #{sku}! Starting product update..."
      ProductMapper.buildProductMap(shopData, customData[sku], dropshipData, cin7Data)
    end
  end

  @doc """
  Given a shopify product, iterate each variant; map new data from custom data to
  update each variant 
  """
  def map_variant_data(shopData, customData) do
    if Map.has_key?(shopData, "variants") do 
      # Map variant-level data, using variant ID as a key
      Map.new(shopData["variants"], fn row ->        
        {row["id"], ProductMapper.buildVariantMap(row, customData[row["sku"]])}
      end)
    end 
  end


  def map_categories(shopData, customData, collectionData) do 
    sku = getFirstSku(shopData)
    if Map.has_key?(customData, sku) do
      IO.puts "In mapCategories "
      CollectionMapper.buildCollectionMap(shopData, customData[sku], collectionData)
    end 
  end 

  def addToCollections(nil), do: nil
  def addToCollections([]), do: nil
  def addToCollections(collects) do
    IO.inspect collects
    for collect <- collects do 
      ShopifyClient.add_to_collection(collect.product_id, collect.collection_id)
    end 
  end 


  @doc """
  Given a shopify product map, return the first SKU (either at parent or variant level); note that shop products with no variants still return a variant 
  """
  def getFirstSku(shopData) do 
    if Map.has_key?(shopData, "variants") do 
      Enum.at(shopData["variants"], 0)["sku"]
    else 
      IO.puts "Simple product:"
      IO.inspect shopData 
      shopData["sku"]
    end
  end 


  @doc """
  Obtains all existing custom collections from Shopify, then maps their "name" to the collection ID so that we can easily add products to a given collection by name/handle

  ## Examples

      iex> ProductData.mapCollections()

  """
  def mapCollections do
    for collection <- ShopifyClient.get_collections.body["custom_collections"], into: %{} do 
      {collection["title"], collection["id"]}
    end
  end

end