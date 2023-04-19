defmodule VariantData do 

	def update_country_of_origin(nil, nil), do: nil
	def update_country_of_origin(nil, _a), do: nil

	def update_country_of_origin(ids, country) do
		for id <- ids do 
			ShopifyClient.update_country_of_origin(id, country)
		end 
	end 

	def update_variants(nil, nil), do: nil
	def update_variants(pid, data) do 
		IO.puts "Updating variants for pid #{pid}: "

		for id when id != nil <- data["variant_ids"] do 
			set_weight(pid, id, data["weight"])
		end
	end 

	def set_weight(_pid, _id, nil), do: nil
	def set_weight(pid, id, weight) do 
		ShopifyClient.update_variant(pid, id, %{
				"variant" => %{
				"id" => id,
				"weight" => weight,
				"weight_unit" => "lb"
				}
			})
	end 

end 