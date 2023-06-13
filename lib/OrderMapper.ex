defmodule OrderMapper do

  @moduledoc """
  Entry point for data mapper; high level controller for pushing custom data to Shopify
  Use sync_all to sync everything
  """

  @doc """
  Sycns all products in Shopify using data mapped from another source

  ## Examples

      iex> OrderMapper.sync_all()

  """
  def sync_all do
    # Load product data that we want to "merge" into shopify
    #productData = ProductData.load()
    orderData = OrderData.load()

    # A mapping of every SKU in Shopify to a shopify variant ID
    # Do this by iterating all pages of product data
    # --> This will either be used in-memory or output to CSV
    mapping = sync_page(nil, orderData)

    # create orders in Shopify
    #IO.inspect mapping
    create_orders(orderData, mapping)

  end

  def sync_redirects do 
    # A mapping of every SKU in Shopify to a shopify variant ID
    mapping = sync_page(nil, nil)
    create_redirects(mapping)
  end 

  def create_orders(orders, mapping) do 
    # iterates all orders and lines within those orders
    for {order_id, order} <- orders do 
      # get line items
      lineItems = for line <- order do 
        lineMap = get_from_mapping(line["sku"], mapping)
        get_line_items(line, lineMap)
      end

      # get and create order, filtering out nil line item entries
      get_order(order, lineItems |> Enum.filter(& !is_nil(&1)))
        |> ShopifyClient.create_order

    end 
  end 

  def create_redirects(mapping) do 
    productData = ProductData.load()
    for {sku, line} <- mapping do 
      product = get_from_mapping(sku, productData)
      IO.puts "Creating redirect from #{product["handle"]} to #{line[:handle]}!"
      ShopifyClient.create_redirect("/product/#{product["handle"]}", "/products/#{line[:handle]}")
    end 
  end 

  def get_from_mapping(sku, mapping) do 
    if Map.has_key?(mapping, sku) do
      mapping[sku]
    end
  end 

  def get_line_items(line, nil), do: nil 
  def get_line_items(line, lineMap) when map_size(lineMap) > 0 do 
    %{
      :variant_id => lineMap[:id],
      :quantity => line["qty"]
    }
  end 

  def get_order(order, nil), do: nil
  def get_order(order, lineItems) when length(lineItems) == 0, do: nil
  def get_order(order, lineItems) when length(lineItems) > 0 do 

    config = Application.get_all_env(:elixir_data_mapper)

    #IO.inspect order
    %{ 
        :email => List.first(order)["customer_email"], 
        :fulfillment_status => "fulfilled", 
        :fulfillments => [%{:location_id => config[:location_id]}],
        :created_at => List.first(order)["created_at"], 
        :line_items => lineItems,
        :source_identifier => "Legacy Import",
        :note => "Woo Order " <> List.first(order)["order_id"]
      }
  end 


  @doc """
  Iterates all products in Shopify using data mapped from another source

  ## Examples

      iex> DataMapper.sync_all()
  """
  def sync_page(pageInfo, orderData) do

    # Get the next (or first) page of products
    product_response =  ShopifyClient.get_products(pageInfo)

    # To test a specific product(s), get products by comma separated IDs     
    #product_response = ShopifyClient.get_test_products("8218294452517")

    test = for product <- product_response.body["products"] do 
      
      # For each variant in the product
      for variant <- product["variants"] do               
        %{ variant["sku"] => %{
            :id => variant["id"],
            :handle => product["handle"]
          }
        }
      end 
    end 

    result = test
      |> List.flatten()
      |> Enum.reduce(Map.new(), fn map, acc ->
        Map.merge(acc, map)
    end)

    # Iterate each next page until there's no pages left
    Map.merge(result, sync_next_page(product_response, orderData) || %{})    
  end 


  @doc """
  Calls sync_page on the next page of data, if one exists
  """
  def sync_next_page(product_response, orderData) do 
    # Extract the Link touple from the headers
    try do 
      {"Link", linkHeader} = product_response.headers 
        |> Enum.find(fn {key, value} -> key == "Link" end)

      # Extract only the last value in a list of links, which will point to the rel=next page
      linkValue = linkHeader 
        |> String.split(",")
        |> List.last

      if linkValue != nil and String.contains?(linkValue, "next") do 
        get_page_info(linkValue) |> 
          sync_page(orderData)
      end
    rescue 
      MatchError -> %{}
      KeyError -> %{}  
    end 
  end 

  @doc """
  Given a link header per Shopify's format (https://shopify.dev/docs/api/usage/pagination-rest), extract the page_info element
  """
  def get_page_info(link) do
    regex_pattern = ~r/page_info=([^&>]+)/   
    Regex.run(regex_pattern, link) |> List.last
  end
end
