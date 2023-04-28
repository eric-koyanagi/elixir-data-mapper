defmodule DM do

  @moduledoc """
  Entry point for data mapper; high level controller for pushing custom data to Shopify
  Use sync_all to sync everything
  """

  @doc """
  Sycns all products in Shopify using data mapped from another source

  ## Examples

      iex> DM.sync_all()

  """
  def sync_all do
    # Load product data that we want to "merge" into shopify
    productData = ProductData.load()

    # Return a map of Shopify collections, keyed by name, so I can use collection IDs to add to products
    collectionMap = ProductData.mapCollections()  

    # Return a map of dropship data
    dropshipData = DropshipData.load()

    # Start syncing all products, using pagination to fetch results
    sync_page(nil, productData, collectionMap, dropshipData)

  end

  @doc """
  Iterates all blogs from a data source and pushes them into Shopify 

  ## Examples

      iex> DM.sync_blogs(blog_id)
  """
  def sync_blogs(blog_id) do 
    BlogData.load |> BlogData.create_all(blog_id)
  end 

  @doc """
  Iterates all products in Shopify using data mapped from another source

  ## Examples

      iex> DM.sync_all()
  """
  def sync_page(pageInfo, productData, collectionMap, dropshipData) do

    # Get the next page of products
    product_response =  ShopifyClient.get_products(pageInfo)    

    for product <- product_response.body["products"] do 
      
      # Map custom data to Shopify product, then push Product level updates
      mappedProductData = ProductData.map_product_data(product, productData, dropshipData) 
      mappedVariantData = ProductData.map_variant_data(product, productData)

      sync_product_data(mappedProductData)
      sync_variant_data(mappedProductData, mappedVariantData)
      
    end 

    # Iterate each next page until there's no pages left
    sync_next_page(product_response, productData, collectionMap, dropshipData)    
  end 

  @doc """
  Given a mapping of data, push product-level updates to Shopify; called by sync_all
  """
  def sync_product_data(nil), do: nil 
  def sync_product_data(mappedProductData) do 
      # Basic product level updates
      ShopifyClient.update_product(mappedProductData)
      
      # For each variant, update the country of origin (via InventoryItem resource)
      VariantData.update_country_of_origin(mappedProductData["inventory_item_data"]["inventory_item_ids"], mappedProductData["inventory_item_data"]["country_of_origin"])

      # Set the shopify category, which is used for taxes (cannot be done via REST)
      ShopifyClientGraphQL.update_category(mappedProductData["id"], mappedProductData["category_data"]["category"])

      # Add the product to every collection mapped from the source data
      # Note: this isn't used due to biz logic changes, but does work as an example of how to do this!
      #ProductData.map_categories(product, mappedProductData, collectionMap)
      #  |> ProductData.addToCollections()
  end 

  @doc """
  Given a mapping of data, push variant-level updates to Shopify; called by sync_all
  """
  def sync_variant_data(nil, a), do: nil
  def sync_variant_data(b, nil), do: nil
  def sync_variant_data(nil, nil), do: nil
  def sync_variant_data(mappedProductData, mappedVariantData) do
    # Update variant resource data
      VariantData.update_variants(mappedProductData, mappedVariantData)
  end

  @doc """
  Calls sync_page on the next page of data, if one exists
  """
  def sync_next_page(product_response, productData, collectionMap, dropshipData) do 
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
          sync_page(productData, collectionMap, dropshipData)
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
