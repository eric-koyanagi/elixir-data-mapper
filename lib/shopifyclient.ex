defmodule ShopifyClient do
  require Logger
  
  @maxPerPage 250

  def get_products(pageInfo) do
    params = %{ limit: @maxPerPage, pageInfo: pageInfo }

    with {:ok, products} <- Shopify.Product.list(params) |> Shopify.request(get_session())
    do
      products
    else 
      error ->
        Logger.error("Error retrieving products from Shopify: #{inspect(error)}")
        []
    end
  end

  def get_page_count() do 
    with {:ok, count} <- Shopify.Product.count |> Shopify.request(get_session())
    do      
      ceil(count.body["count"] / @maxPerPage)
    else 
      error ->
        Logger.error("Error retrieving product count from Shopify: #{inspect(error)}")
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

  # Does nothing if product data is nil
  def update_product(nil), do: nil
  def update_product(data) do 
    IO.puts "Updating product: "
    IO.inspect data["data"]

    with {:ok, resp} <- Shopify.Product.update(data["id"], data["product_data"]) |> Shopify.request(get_session())
    do
      resp
    else 
      error ->
        Logger.error("Error updating product to Shopify: #{inspect(error)}")
        []
    end
  end 


  def update_variant(variant_id, data) do 
    %{}
  end 

  def update_country_of_origin(nil, nil), do: nil
  def update_country_of_origin(a, nil), do: IO.puts "No country set for item id #{a}"
  def update_country_of_origin(nil, a), do: IO.puts "No item ID set for country #{a}" 
  def update_country_of_origin(item_id, country) do 
    IO.puts "Updating inventory item #{item_id} country of origin to #{country} "

    with {:ok, resp} <- Shopify.InventoryItem.update(item_id, %{ :inventory_item => %{ :country_code_of_origin => country }}) |> Shopify.request(get_session())
    do
      resp
    else 
      error ->
        Logger.error("Error updating inventory item to Shopify: #{inspect(error)}")
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

  def add_to_collection(a, nil), do: IO.puts "Product #{a} has no matching collection."
  def add_to_collection(product_id, collection_id) do 
    IO.puts "Adding product #{product_id} to collection #{collection_id}"
    with {:ok, resp} <- Shopify.Collect.add_product(%{ :collect => %{:product_id => product_id, :collection_id => collection_id}}) |> Shopify.request(get_session())
    do
      resp
    else 
      error ->
        Logger.error("Error adding to collection from Shopify: #{inspect(error)}")
        []
    end
  end 


  def get_session do
    config = Application.get_all_env(:elixir_data_mapper)
    Shopify.new_public_session(config[:shop_name], config[:access_token])
  end 
end