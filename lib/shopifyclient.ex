defmodule ShopifyClient do
  require Logger
  
  @maxPerPage 250

  def get_products(pageInfo) do

    params = get_list_params(pageInfo)
    IO.inspect params

    with {:ok, products} <- Shopify.Product.list(params) |> Shopify.request(get_session(), get_config())
    do
      products
    else 
      error ->
        Logger.error("Error retrieving products from Shopify: #{inspect(error)}")
        []
    end
  end

  # This can be used to start product pulls from a speicifc ID, in case an import is interupted
  # This is a lazy hack and needs to be commented out or refactored to make it a real feature
  def get_list_params(nil) do 

    #%{ limit: @maxPerPage, since_id: 8129821245741}
    %{ limit: @maxPerPage }
  end 

  def get_list_params(pageInfo) do 
    %{ limit: @maxPerPage, page_info: pageInfo }
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

  def get_price_rules(pageInfo) do

    params = get_list_params(pageInfo)
    IO.inspect params

    with {:ok, price_rules} <- Shopify.PriceRule.list(params) |> Shopify.request(get_session(), get_config())
    do
      price_rules
    else 
      error ->
        Logger.error("Error retrieving price rules from Shopify: #{inspect(error)}")
        []
    end
  end

  def delete_price_rule(nil), do: nil 
  def delete_price_rule(id) do 
    with {:ok, price_rules} <- Shopify.PriceRule.delete(id) |> Shopify.request(get_session(), get_config())
    do
      price_rules
    else 
      error ->
        Logger.error("Error deleting price rules from Shopify: #{inspect(error)}")
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

  def create_gift_card(code, expires, 0), do: nil
  def create_gift_card(code, expires, amount) do
    params = %{
      "code" => code,
      "expires_on" => expires,
      "initial_value" => amount
    }

    IO.puts "Creating gift card: #{code}"

    with {:ok, resp} <- Shopify.GiftCard.create(%{ :gift_card => params }) |> Shopify.request(get_session(), get_config())
    do
      resp
    else 
      error ->
        Logger.error("Error creating gift card on Shopify: #{inspect(error)}")
        []
    end
    
  end 

  def create_price_rule(nil, code, expires, amount, once_per_customer), do: nil
  def create_price_rule(type, code, expires, 0, once_per_customer), do: nil
  def create_price_rule(type, code, expires, amount, once_per_customer) do 
    IO.puts "Creating a price rule !"
    params = %{
      "title" => code,
      "target_type" => "line_item",
      "target_selection" => "all",
      "allocation_method" => "across",            
      "value_type" => type,
      "value" => "-"<>amount,
      "customer_selection" => "all",
      "starts_at" => "2023-06-12T01:00:00",
      "ends_at" => expires,
      "usage_limit" => get_usage_limit(once_per_customer),
      "once_per_customer" => once_per_customer
    }

    IO.inspect params

    with {:ok, resp} <- Shopify.PriceRule.create(%{ :price_rule => params }) |> Shopify.request(get_session(), get_config())
    do
      resp
    else 
      error ->
        Logger.error("Error creating price rule on Shopify: #{inspect(error)}")
        []
    end
  end 

  def create_discount(price_rule_id, code) do 
    with {:ok, resp} <- Shopify.PriceRule.create_discount(price_rule_id, code) |> Shopify.request(get_session(), get_config())
    do
      resp
    else 
      error ->
        Logger.error("Error creating discount from price rule on Shopify: #{inspect(error)}")
        []
    end
  end 

  # if once_per_customer is set, don't set a usage limit; otherwise it's 1 time use coupon
  def get_usage_limit(false), do: 1
  def get_usage_limit(true), do: nil
  

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

  def create_redirect("", _a), do: nil
  def create_redirect(_a, ""), do: nil
  def create_redirect("", ""), do: nil
  def create_redirect(nil, nil), do: nil
  def create_redirect(from, to) do 

    IO.puts "Creating a redirect from #{from} to #{to}"

    with {:ok, resp} <- Shopify.Redirect.create(%{ :redirect => %{:path => from, :target => to} }) 
      |> Shopify.request(get_session(), get_config())
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