defmodule BlogData do
  require Jason

  @moduledoc """
  Blog data module; this loads "source" data from a JSON file and holds it in memory 
  We then push to Shopify as new blogs (in some idempotent way)
  """

  @doc """
  Loads custom blog data from a source; in this case, JSON
  """
  def load do

    file_contents = File.read!("data/blog_data.json")
    Jason.decode!(file_contents)
  end

  def create_all(data, blog_id) do 
    #IO.inspect data

    for row <- data do    
      IO.puts "Creating article..."
      IO.inspect %{
        "title" => row["post_title"],
        "author" => row["author"],
        "tags" => row["tags"],
        "published_at" => row["post_date"]
      }

      ShopifyClient.create_article(blog_id, %{
        "title" => row["post_title"],
        "author" => row["author"],
        "tags" => HtmlEntities.decode(row["tags"]),
        "body_html" => row["body_html"],
        "published_at" => row["post_date"]
      })
    end  


  end 
end