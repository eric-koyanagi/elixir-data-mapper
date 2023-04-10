defmodule ProductMapper do
  require Logger

  @productMap %{}

  def buildProductMap(productData, customData) do     
    """
      Reminders about & and &1 in elixir; this defines a virtual function, e.g. "For each variant, call map.get to extract a key" 
    """

    #first_variant = Enum.at(productData["variants"], 0)
    %{
      "id" => productData["id"],
      "product_data" => %{
        "product" => %{
          "vendor" => customData["brand"],
          "tags" => customData["tags"],
          "published_at" => customData["publishDate"],          
        }
      },
      "inventory_item_data" => %{
        "inventory_item_ids" => productData["variants"] |> Enum.map(&Map.get(&1, "inventory_item_id")), 
        "country_of_origin" => customData["country_of_origin"]
      }
    }
  end 

  def buildInventoryMap(productData, customData) do 
    %{}
  end 

  def get_mapped_field(field_name) do 
    @productMap[field_name]
  end 

end 