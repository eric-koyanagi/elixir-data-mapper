defmodule VariantData do 

	def update_country_of_origin(nil, nil), do: nil
	def update_country_of_origin(nil, a), do: nil

	def update_country_of_origin(ids, country) do
		for id <- ids do 
			ShopifyClient.update_country_of_origin(id, country)
		end 
	end 

end 