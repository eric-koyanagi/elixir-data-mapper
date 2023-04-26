defmodule ProductMapper do
  require Logger

  @productMap %{}


  @doc """
      Builds a map of data with usable shopify or custom data - used to update product, inventory item, or category
      Reminders about & and &1 in elixir; this defines a virtual function, e.g. "For each variant, call map.get to extract a key" 
  """
  def buildProductMap(productData, customData) do
    tags = customData["categories"] <> customData["tags"]
    publishedAt = get_published_at(tags, customData["publishDate"])

    %{
      "id" => productData["id"],
      "product_data" => %{
        "product" => %{
          "vendor" => HtmlEntities.decode(customData["brand"]),
          "tags" => HtmlEntities.decode(tags),
          "published_at" => publishedAt,
        }
      },
      "images" => productData["images"],
      "inventory_item_data" => %{
        "inventory_item_ids" => productData["variants"] |> Enum.map(&Map.get(&1, "inventory_item_id")), 
        "country_of_origin" => customData["country_of_origin"],        
      },
      "variant_data" => %{
        "variant_ids" => productData["variants"] |> Enum.map(&Map.get(&1, "id")), 
        "weight" => customData["weight"] |> blankOrNullToNil
      },
      "category_data" => %{
        "category" => customData["tax_class"]
      }
    }
  end 

  @doc """
      builds a map of data when each variant has distinct data; unlike "weight" above, where every variant in Shop is set based on product-level data
      
  """
  def buildVariantMap(variantData, customData) do 
    %{ 
      "shop_data" => variantData,
      "custom_data" => customData
    }
  end 

  def blankOrNullToNil(""), do: nil
  def blankOrNullToNil("NULL"), do: nil 
  def blankOrNullToNil(a), do: a

  def get_mapped_field(field_name) do 
    @productMap[field_name]
  end 

  def get_published_at(tags, publishedAt) do 
    if String.contains?(tags, ["Archived", "do not display"]) do 
      nil 
    else 
      publishedAt
    end 
  end 

end 