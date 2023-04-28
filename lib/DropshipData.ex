defmodule DropshipData do

  @doc """
  Loads custom dropshipper data from a CSV; ideally this would be in the DB (and part of products export), but this is unusual business logic that only exists in a CSV
  """
  def load do
    rows = CSV.decode!(File.stream!("data/dropship_data.csv"), headers: true) 
    Map.new(rows, fn row ->
      # Map imported data by key "name"
      {row["name"], row}
    end)
  end
end