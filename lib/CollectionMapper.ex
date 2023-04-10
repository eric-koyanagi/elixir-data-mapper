defmodule CollectionMapper do
  require Logger

  @doc """
  Given shop Data, all custom Data, and mapped collection IDs, return a list of collections to add to the given product 

  ## Parameters
    - shopData: single SKU's data map from Shopify
    - customData: custom source data for a single SKU
    - all collectionIDs in Shopify mapped via the collection name 
  """
  def buildCollectionMap(shopData, customData, collectionData) do 

    getCustomCategories(customData) 
      |> findMatchingCollectionIds(shopData["id"], collectionData)

  end 

  @doc """
  Returns (as a list the categories) present in custom data, but only those that are non-empty 
  """
  def getCustomCategories(customData) do 
    keys_to_include = ["cat1", "cat2", "cat3", "cat4", "cat5", "cat6", "cat7", "cat8", "cat9", "cat10"]
    customData 
      |> Map.take(keys_to_include) 
      |> Map.values()
      |> Enum.reject(&is_nil/1)
      |> Enum.reject(&(&1 == ""))
  end 

  @doc """
    For each custom category, find its mapped shopify Collection ID. Return a list of {product_id: collection_id} for the API
  """
  def findMatchingCollectionIds(customCategories, productId, collectionData) do 
    for category <- customCategories do 
      if Map.has_key?(collectionData, category) do 
        %{ :product_id => productId, :collection_id => collectionData[category]}
      end 
    end 
  end 


end 