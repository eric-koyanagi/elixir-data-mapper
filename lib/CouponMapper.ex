defmodule CouponMapper do

	def sync_all do

		# 1. Load coupon data from a CSV
		# 2. load additional codes to exclude (provided as separate CSV is unfortunate)
		couponData = CouponData.load()
		excludedCoupons = CouponData.load_exclusions()

		# TODO load all price rules into a mppping
		mapping = sync_page(nil)

		# 3. Iterate CSV data --> for GCs, create a simple GC
		# 4. For discounts -> Create a discount rule, then create the discount 
		
		for {code, coupon} <- couponData do 
			if !Map.has_key?(excludedCoupons, code) and is_code_valid(coupon) do 
				# IO.puts "Importing coupon " <> coupon["code"]

				if String.starts_with?(coupon["code"], ["gc-", "gift-"]) do 
					#make_gift_card(coupon)
				else 
					make_discount_code(mapping, coupon)
				end 

			end 
		end 
		

	end 

	# these have to be made in advance of discounts, not idempotent, so run this carefully
	def make_price_rules do

		couponData = CouponData.load()
		excludedCoupons = CouponData.load_exclusions()
		for {code, coupon} <- couponData do 
			if !Map.has_key?(excludedCoupons, code) and is_code_valid(coupon) do 

				if !String.starts_with?(coupon["code"], ["gc-", "gift-"]) do 
					make_price_rule(coupon)
				end 

			end 
		end 

	end 

	def make_gift_card(row) do 
		# IO.inspect row 
		if row["usage count"] == "NULL" or row["usage count"] == "0" do 
			#IO.puts "Importing gift card " <> row["code"]

			ShopifyClient.create_gift_card(
				row["code"], 
				get_expiration(row["expiration"]), 
				row["discount value"]
			)

		end 
	end 

	def is_code_valid(row) do 
		cond do 
			# never been used, so code must be valid if non-expired
			is_unset(row["usage count"]) -> 
				true 

			# no usage limits
			is_unset(row["usage limit"]) and is_unset(row["usage limit per user"])	->
				true 

			# has limit per user set; therefore, is still valid no matter usg cnt
			is_unset(row["usage limit"]) and !is_unset(row["usage limit per user"])	->
				true 

			# all other cases are invalid
			true -> 
				false
		end 
	end 

	def is_unset("NULL"), do: true 
	def is_unset("0"), do: true 
	def is_unset(""), do: true 
	def is_unset(_a), do: false

	def make_discount_code(priceRuleMap, row) do 
		if Map.has_key?(priceRuleMap, row["code"]) do 
			priceRule = priceRuleMap[row["code"]]
			ShopifyClient.create_discount(priceRule["id"], row["code"])
		end 
	end

	def make_price_rule(row) do
		value_type = get_value_type(row["discount type"])
		
		ShopifyClient.create_price_rule(
			value_type, 
			row["code"],
			get_coupon_expiration(row["expiration"]), 
			row["discount value"],
			!is_unset(row["usage limit per user"])
		)
	end

	def get_value_type("fixed_cart"), do: "fixed_amount"
	def get_value_type("percent"), do: "percentage"
	def get_value_type("percent_product"), do: "percentage"
	def get_value_type("smart_coupon"), do: nil # only one of these
	def get_value_type("NULL"), do: nil 

	def get_expiration("NULL"), do: nil 
	def get_expiration(nil), do: nil 
	def get_expiration(expiration) do 
		# this is a bit hacky but also a valid assumption unless we time travel
		if String.starts_with?(expiration, "1") do 
			convert_unix_timestamp(String.to_integer(expiration))
		else 
			expiration
		end 
	end  

	def get_coupon_expiration(expiration) do 
		exp = get_expiration(expiration)
		if exp do 
			exp <> "T23:59:59Z"
		else 
			nil
		end 
	end 

	def convert_unix_timestamp(unix_timestamp) do
	    datetime = DateTime.from_unix!(unix_timestamp)
	    formatted_date = "#{datetime.year()}-#{format_number(datetime.month())}-#{format_number(datetime.day())}"
	    formatted_date
  	end

  	defp format_number(number) do
	    if number < 10 do
	      "0#{number}"
	    else
	      "#{number}"
	    end
  	end

  	@doc """
	Iterates all price rules in Shopify
	"""
	def sync_page(pageInfo) do

		# Get the next (or first) page of products
		product_response =  ShopifyClient.get_price_rules(pageInfo)

		test = for price_rule <- product_response.body["price_rules"] do 
		  %{ price_rule["title"] => %{
		        :id => price_rule["id"]
		      }
		   }

		   # Can uncomment to clear out all price rules
		   #ShopifyClient.delete_price_rule(price_rule["id"])		   
		end 

		result = test
		  |> List.flatten()
		  |> Enum.reduce(Map.new(), fn map, acc ->
		    Map.merge(acc, map)
		end)

		# Iterate each next page until there's no pages left
		Map.merge(result, sync_next_page(product_response) || %{})    
	end 


	@doc """
	Calls sync_page on the next page of data, if one exists
	"""
	def sync_next_page(product_response) do 
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
		      sync_page
		  end
		rescue 
		  MatchError -> %{}
		  KeyError -> %{}  
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