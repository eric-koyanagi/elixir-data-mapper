defmodule ProductMapper do
  require Logger

  @productMap %{}


  @doc """
      Builds a map of data with usable shopify or custom data - used to update product, inventory item, or category
      Reminders about & and &1 in elixir; this defines a virtual function, e.g. "For each variant, call map.get to extract a key" 
  """
  def buildProductMap(productData, customData, dropshipDataContainer, cin7Data) do

    # Build a list of valid tags
    finalSale = if customData["final_sale"] == "yes", do: "Final Sale", else: nil
    tags = Enum.join([
      customData["categories"],
      customData["tags"],
      finalSale
    ], ",")

    # Set the published date / flag, but only if tags allow for it
    publishedAt = get_published_at(tags, customData["publishDate"])    

    # get single row of dropship data from the container
    dropship_data = get_dropship_data(dropshipDataContainer, customData["dropshipper"])

    # get a barcpde code from Cin7 data
    barcode = get_barcode(cin7Data, customData["style"])

    %{
      "id" => productData["id"],
      "product_data" => %{
        "product" => %{
          "title" => productData["title"] |> String.replace("&Amp;", "&"),
          "vendor" => HtmlEntities.decode(customData["brand"]),
          "tags" => HtmlEntities.decode(tags),
          "published_at" => nil,#publishedAt,
          "metafields" => [
            %{ 
              :key => "dropshipper", 
              :type => "single_line_text_field", 
              :value => get_dropshipper(customData["dropshipper"]),
              :namespace => "global" 
            },
            %{ 
              :key => "processing_time", 
              :type => "number_integer", 
              :value => get_processing_time(dropship_data),
              :namespace => "global"
            },
            %{ 
              :key => "gender_filter", 
              :type => "list.single_line_text_field", 
              :value => customData["gender"] |> blankOrNullToNil |> splitIntoArray,
              :namespace => "filters"
            },
            %{ 
              :key => "age_filter", 
              :type => "list.single_line_text_field", 
              :value => customData["age"] |> blankOrNullToNil |> splitIntoArray,
              :namespace => "filters"
            }
          ] ++ get_criteria_list(customData["criteria"])
        }
      },
      "images" => productData["images"],
      "inventory_item_data" => %{
        "inventory_item_ids" => productData["variants"] |> Enum.map(&Map.get(&1, "inventory_item_id")), 
        "country_of_origin" => customData["country_of_origin"],        
      },
      "variant_data" => %{
        "variant_ids" => productData["variants"] |> Enum.map(&Map.get(&1, "id")), 
        "weight" => customData["weight"] |> blankOrNullToNil,
        "barcode" => barcode
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

  def get_processing_time(nil), do: nil
  def get_processing_time(dropshipData) do 
    dropshipData["estimated_processing_time"]
  end 

  def get_dropshipper(nil), do: nil 
  def get_dropshipper("0"), do: nil 
  def get_dropshipper(dropshipper) do 
    dropshipper
  end 

  @doc """
    For each criteira, set it as a boolean flag, but convert the criteria name to a slugified version (shop doesn't support special characters)
  """
  def get_criteria_list(nil), do: []
  def get_criteria_list(""), do: [] 
  def get_criteria_list(criteriaData) do 
    for criteria <- String.split(criteriaData, [","]) do 
      %{
        :key => criteria |> sanitize_criteria, 
        :type => "boolean",
        :value => true,
        :namespace => "woocommerce"
      }
    end 
  end 

  @doc """
    Converts a comma separated field to an array of strings
  """
  def splitIntoArray(nil), do: nil
  def splitIntoArray(string) do
    string |> String.split(",") |> Poison.encode!
  end

  @doc """
    Given a style code as a "map", find the matching cin7 barcode
  """
  def get_barcode(nil), do: nil 
  def get_barcode(""), do: nil 
  def get_barcode(cin7Data, style) do 
    if Map.has_key?(cin7Data, style) do
      cin7Data[style]["Barcode"]
    end 
  end 


  @doc """
    Given a critiera's name, strip spaces and replace with underscores and remove special characters (shopify doesn't allow for key names...
    well....they do accept the data, but won't allow definitions based on it
  """
  def sanitize_criteria(name) do 
    name 
      |> String.replace(~r/\s+/, "_") 
      |> String.replace(~r/[^A-Za-z0-9_]/, "")
  end 

  def get_dropship_data(_dropshipData, ""), do: nil
  def get_dropship_data(_dropshipData, nil), do: nil
  def get_dropship_data(dropshipData, dropshipper) do 
    dropshipData[dropshipper]
  end 

end 