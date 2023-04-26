defmodule VariantData do 

	def update_country_of_origin(nil, nil), do: nil
	def update_country_of_origin(nil, _a), do: nil

	def update_country_of_origin(ids, country) do
		for id <- ids do 
			ShopifyClient.update_country_of_origin(id, country)
		end 
	end 

	def update_variants(nil, nil), do: nil

	@doc """
	  Given shop Data, all custom Data, and mapped collection IDs, return a list of collections to add to the given product 

	  ## Parameters
	    - product data: source data 
	    - data: mapped container-level data -- for variant properties that are set based on container-level source data (1:many mapping)
	    - variantDataContainer: ALL variant-level custom data for this product, for variants in Shopify that must be updated based on variants in source data (1:1 mapping)
  """
	def update_variants(mappedProductData, variantDataContainer) do 
		pid = mappedProductData["id"]

		IO.puts "Updating variants for pid #{pid}: "
		IO.inspect variantDataContainer
		IO.inspect mappedProductData

		for id when id != nil <- mappedProductData["variant_data"]["variant_ids"] do 
			variantData = variantDataContainer[id]

			#IO.inspect variantData
			#IO.inspect get_thumbnail_map(mappedProductData["images"], variantData["custom_data"]["variation_image_url"])
			#IO.inspect get_weight_map(id, mappedProductData["weight"])

			ShopifyClient.update_variant(pid, id,  
				get_variant_resource(
					get_weight_map(id, mappedProductData["weight"]),
					get_thumbnail_map(mappedProductData["images"], variantData["custom_data"]["variation_image_url"])
				)
			)
		end
	end 

	def get_variant_resource(nil, nil), do: nil
	def get_variant_resource(weight_map, nil), do: weight_map
	def get_variant_resource(nil, thumbnail_map), do: thumbnail_map
	def get_variant_resource(weight_map, thumbnail_map) do 
		Map.merge(
			weight_map,
			thumbnail_map
		)
	end 

	def get_weight_map(_id, nil), do: nil
	def get_weight_map(id, weight) do 
		%{
			"weight" => weight,
			"weight_unit" => "lb"	
		}

		"""
		ShopifyClient.update_variant(pid, id, %{
				"variant" => %{
				"id" => id,
				"weight" => weight,
				"weight_unit" => "lb"
				}
			})
		"""
	end 

	def get_thumbnail_map(nil, nil), do: %{}
	def get_thumbnail_map(images, nil), do: %{}
	def get_thumbnail_map(images, "NULL"), do: %{} 		
	def get_thumbnail_map(images, image_url) do
		IO.puts "Getting image thumbnail map, target URL: #{image_url}"
		#IO.inspect images
		#IO.inspect image_url

		target_url = Path.basename(image_url)
		IO.puts " basepath of target url is #{target_url}"

		for image <- images do 
			imSrc = Path.basename(image["src"])
			IO.puts " --> src of image is #{imSrc}"
		end 

		# the goal is to find the ID of the image src that matches with the image_url
		image_id = images
			|> Enum.find_value(nil, fn map -> 
				if Path.basename(map["src"]) |> String.split("?") |> List.first == target_url, do: map["id"]
			 end)

		%{ 
			"image_id" => image_id
		}
	end 

end 