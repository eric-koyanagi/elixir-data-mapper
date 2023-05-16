defmodule ShopifyClient do
  require Logger
  
  @maxPerPage 250

  def get_products(pageInfo) do
    params = %{ limit: @maxPerPage, page_info: pageInfo }

    with {:ok, products} <- Shopify.Product.list(params) |> Shopify.request(get_session(), get_config())
    do
      products
    else 
      error ->
        Logger.error("Error retrieving products from Shopify: #{inspect(error)}")
        []
    end
  end

  def get_test_products(ids) do
    params = %{ limit: @maxPerPage, ids: ids }

    with {:ok, products} <- Shopify.Product.list(params) |> Shopify.request(get_session(), get_config())
    do
      products
    else 
      error ->
        Logger.error("Error retrieving products from Shopify: #{inspect(error)}")
        []
    end
  end

  def get_page_count() do 
    with {:ok, count} <- Shopify.Product.count |> Shopify.request(get_session(), get_config())
    do      
      ceil(count.body["count"] / @maxPerPage)
    else 
      error ->
        Logger.error("Error retrieving product count from Shopify: #{inspect(error)}")
        []
    end  
  end 

  def get_product(product_id) do 

    with {:ok, product} <- Shopify.Product.get(product_id) |> Shopify.request(get_session(), get_config())
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
    #IO.puts "Updating product: "
    #IO.inspect data["product_data"]

    with {:ok, resp} <- Shopify.Product.update(data["id"], data["product_data"]) |> Shopify.request(get_session(), get_config())
    do
      resp
    else 
      error ->
        Logger.error("Error updating product to Shopify: #{inspect(error)}")
        []
    end
  end 


  def update_variant(product_id, variant_id, data) when data == %{} do
    IO.puts "No variant data to update for variant ID# #{variant_id}"
  end 

  def update_variant(product_id, variant_id, data) do 
    IO.puts "Updating variant: "
    IO.inspect data

    with {:ok, resp} <- Shopify.ProductVariant.update(product_id, variant_id, %{ "variant" => data }) |> Shopify.request(get_session(), get_config())
    do
      resp
    else 
      error ->
        Logger.error("Error updating variant to Shopify: #{inspect(error)}")
        []
    end
  end 

  def update_country_of_origin(nil, nil), do: nil
  def update_country_of_origin(a, nil), do: IO.puts "No country set for item id #{a}"
  def update_country_of_origin(nil, a), do: IO.puts "No item ID set for country #{a}" 
  def update_country_of_origin(item_id, country) do 
    IO.puts "Updating inventory item #{item_id} country of origin to #{country} "

    with {:ok, resp} <- Shopify.InventoryItem.update(item_id, %{ :inventory_item => %{ :country_code_of_origin => country }}) |> Shopify.request(get_session(), get_config())
    do
      resp
    else 
      error ->
        Logger.error("Error updating inventory item to Shopify: #{inspect(error)}")
        []
    end
  end 

  def get_and_delete_metafields(product_id, namespace) do 
    with {:ok, resp} <- Shopify.Metafield.list(product_id, %{}) |> Shopify.request(get_session(), get_config())
    do
      for metafield <- resp.body["metafields"] do 
        if metafield["namespace"] == namespace do 
          delete_metafield(product_id, metafield["id"])
        end  
      end 
    else 
      error ->
        Logger.error("Error getting metafields from Shopify: #{inspect(error)}")
        []
    end
  end 

  def delete_metafield(product_id, metafield_id) do 
    with {:ok, resp} <- Shopify.Metafield.delete(product_id, metafield_id) |> Shopify.request(get_session(), get_config())
    do
      resp
    else 
      error ->
        Logger.error("Error deleting metafield from Shopify: #{inspect(error)}")
        []
    end
  end 

  def get_collections do 
    with {:ok, resp} <- Shopify.CustomCollection.list() |> Shopify.request(get_session(), get_config())
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
    with {:ok, resp} <- Shopify.Collect.add_product(%{ :collect => %{:product_id => product_id, :collection_id => collection_id}}) |> Shopify.request(get_session(), get_config())
    do
      resp
    else 
      error ->
        Logger.error("Error adding to collection from Shopify: #{inspect(error)}")
        []
    end
  end 

  def create_article(blog_id, params) do 
    with {:ok, resp} <- Shopify.Article.create(blog_id, %{ :article => params }) |> Shopify.request(get_session(), get_config())
    do
      resp
    else 
      error ->
        Logger.error("Error creating articles on Shopify: #{inspect(error)}")
        []
    end
  end 

  def create_order(nil), do: nil
  def create_order(params) do 

    IO.puts "Creating an Order ! "
    IO.inspect params

    with {:ok, resp} <- Shopify.Order.create(%{ :order => params }) |> Shopify.request(get_session(), get_config())
    do
      resp
    else 
      error ->
        Logger.error("Error creating order on Shopify: #{inspect(error)}")
        []
    end
  end 


  def get_session do
    config = Application.get_all_env(:elixir_data_mapper)
    Shopify.new_public_session(config[:shop_name], config[:access_token])
  end 

  def get_config do 
     %{
        http_client: Shopify.Client.RateLimit,
        http_client_opts: [
          http_client: Shopify.Client.Hackney,
          http_client_opts: [] # optional
        ]
      }
  end 
end