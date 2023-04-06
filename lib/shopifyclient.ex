defmodule ShopifyClient do
  require Logger
  
  def get_products do
    with {:ok, products} <- Shopify.Product.list() |> Shopify.request(get_session())
    do
      products
    else 
      error ->
        Logger.error("Error retrieving products from Shopify: #{inspect(error)}")
        []
    end
  end

  def get_product(product_id) do 

    with {:ok, product} <- Shopify.Product.get(product_id) |> Shopify.request(get_session())
    do
      product
    else 
      error ->
        Logger.error("Error retrieving product from Shopify: #{inspect(error)}")
        []
    end

  end 

  def update_product(product_id, data) do 
    with {:ok, resp} <- Shopify.Product.update(product_id, data) |> Shopify.request(get_session())
    do
      resp
    else 
      error ->
        Logger.error("Error updating product to Shopify: #{inspect(error)}")
        []
    end
  end 

  def get_collections do 
    with {:ok, resp} <- Shopify.CustomCollection.list() |> Shopify.request(get_session())
    do
      resp
    else 
      error ->
        Logger.error("Error getting collections from Shopify: #{inspect(error)}")
        []
    end
  end 


  def get_session do
    config = Application.get_all_env(:elixir_data_mapper)
    Shopify.new_public_session(config[:shop_name], config[:access_token])
  end 
end