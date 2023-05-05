defmodule CriteriaData do

  @moduledoc """
  Criteria data module; Given a CSV of criterias, create a metafield for products for each

  """

  @doc """
  Loads custom blog data from a source; in this case, JSON
  """
  def load do
    CSV.decode!(File.stream!("data/criterias.csv"), headers: true) 
  end

  def create_all(criteria) do     
    for row <- criteria do    
      IO.puts "Creating metafield..."
      IO.inspect row 

      if(row["count"] > 1) do 
        ProductMapper.sanitize_criteria(row["criteria"]) |>
          ShopifyClientGraphQL.create_criteria_metafield(row["criteria"])
      end 
    end
  
  end 
end