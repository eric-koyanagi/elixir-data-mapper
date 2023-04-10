defmodule ShopifyClientGraphQL do 

	def update_category(nil, nil), do: nil
	def update_category(nil, _a), do: nil
	def update_category(_a, nil), do: nil
	def update_category(id, category) do 
		IO.puts "Updating #{id} with category #{category}"

		# get the shopify category ID from the category populated via custom data
		get_update_category_query(id, CategoryMapper.getShopCategory(category))
			|> Shopify.GraphQL.send(access_token: Application.get_env(:elixir_data_mapper, :access_token), shop: Application.get_env(:elixir_data_mapper, :shop_name))


	end 

	def get_update_category_query(id, categoryId) do 
		"""
		mutation {
			  productUpdate(input: {
			    id: "gid://shopify/Product/#{id}",
			    standardizedProductType: {
			      productTaxonomyNodeId: "gid://shopify/ProductTaxonomyNode/#{categoryId}"
			    }
			  }) {
			    product {
			      id			      
			    }
			  }
			}
		"""
	end 

end 