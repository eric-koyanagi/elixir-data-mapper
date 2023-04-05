defmodule ShopifyClient do
  require Logger
  
  def get_products do
 
    config = Application.get_all_env(:elixir_data_mapper)
    session = Shopify.new_public_session(config[:shop_name], config[:access_token])

    with {:ok, products} <- Shopify.Product.list() |> Shopify.request(session)
    do
      products
    else 
      error ->
        Logger.error("Error retrieving products from Shopify: #{inspect(error)}")
        []
    end
  end

  def get_product do 

  end 

  def update_product do 

  end 
end