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
  Iterates all blogs from a data source and pushes them into Shopify 

  ## Examples

      iex> DM.sync_blogs()
  """
  def sync_blogs do 
    #blogData = BlogData.load()
    
  end 

  @doc """
  Iterates all products in Shopify using data mapped from another source

  ## Examples

      iex> DM.sync_all()
  """
  def sync_page(pageInfo, productData, collectionMap) do

    product_response =  ShopifyClient.get_products(pageInfo)
    IO.puts "Getting Next Page; page info: "
    IO.inspect pageInfo

    for product <- product_response.body["products"] do 
      
      # Map custom data to Shopify product, then push Product level updates
      mappedData = ProductData.mapProductData(product, productData) 
      ShopifyClient.update_product(mappedData)
      
      # For each variant, update the country of origin (via InventoryItem resource)
      VariantData.update_country_of_origin(mappedData["inventory_item_data"]["inventory_item_ids"], mappedData["inventory_item_data"]["country_of_origin"])

      # Update variant resource data
      VariantData.update_variants(mappedData["id"], mappedData["variant_data"])

      # Add the product to every collection mapped from the source data
      # Note: this isn't used due to biz logic, but does work as an example of how to do this
      #ProductData.mapCategories(product, productData, collectionMap)
      #  |> ProductData.addToCollections()

      # Set the shopify category, which is used for taxes
      ShopifyClientGraphQL.update_category(mappedData["id"], mappedData["category_data"]["category"])

    end 

    # Extract the Link touple from the headers
    try do 
      IO.inspect product_response.headers
 
      {"Link", linkHeader} = product_response.headers 
        |> Enum.find(fn {key, value} -> key == "Link" end)

      # Extract only the last value in a list of links, which will point to the rel=next page
      linkValue = linkHeader 
        |> String.split(",")
        |> List.last

      if linkValue != nil and String.contains?(linkValue, "next") do 
        get_page_info(linkValue) |> 
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
