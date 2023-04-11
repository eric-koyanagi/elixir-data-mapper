defmodule DM do

  @moduledoc """
  Entry point for data mapper; high level controller for pushing custom data to Shopify
  Use sync_all to sync everything
  """

  @doc """
  Iterates all products in Shopify using data mapped from another source

  ## Examples

      iex> DM.sync_all()

  """
  def sync_all do
    # Load product data that we want to "merge" into shopify
    productData = ProductData.load()
    #IO.puts "All Custom Product Data:"
    #IO.inspect productData

    # Return a map of Shopify collections, keyed by name, so I can use collection IDs to add to products
    collectionMap = ProductData.mapCollections()
    IO.puts "Shopify Collection Map: "
    IO.inspect collectionMap    

    # Start syncing all products, using pagination to fetch results
    sync_page(nil, productData, collectionMap)

  end

  @doc """
  Iterates all products in Shopify using data mapped from another source

  ## Examples

      iex> DM.sync_all()
  """
  def sync_page(pageInfo, productData, collectionMap) do

    product_response =  ShopifyClient.get_products(pageInfo)
    #IO.inspect product_response

    for product <- product_response.body["products"] do 
      
      # Map custom data to Shopify product, then push Product level updates
      mappedData = ProductData.mapProductData(product, productData) 
      ShopifyClient.update_product(mappedData)
      
      # For each variant, update the country of origin 
      VariantData.update_country_of_origin(mappedData["inventory_item_data"]["inventory_item_ids"], mappedData["inventory_item_data"]["country_of_origin"])            

      # Add the product to every collection mapped from the source data
      # TODO: either see if I can check for current collections or swallow the error for "already added to collection"
      ProductData.mapCategories(product, productData, collectionMap)
        |> ProductData.addToCollections()

      # Set the shopify category, which is used for taxes
      ShopifyClientGraphQL.update_category(mappedData["id"], mappedData["category_data"]["category"])
      
      # TODO replace with proper rate limiting features 
      Process.sleep(200)

    end 

    # Extract the Link touple from the headers
    try do 
      {"Link", linkHeader} = product_response.headers 
        |> Enum.find(fn {key, _value} -> key == "Link" end)

      if linkHeader do 
        get_page_info(linkHeader) |> 
          sync_page(productData, collectionMap)
      end  
    rescue 
      MatchError -> {:ok, "Done"}
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
