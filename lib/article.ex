defmodule Shopify.Article do
  @moduledoc """
  [https://shopify.dev/docs/api/admin-rest/2023-04/resources/article#post-blogs-blog-id-articles](https://shopify.dev/docs/api/admin-rest/2023-04/resources/article#post-blogs-blog-id-articles)
  """

  @doc """
  Create an article.
  """
  @spec create(binary, map) :: Shopify.Operation.t()
  def create(blog_id, params) do
    %Shopify.Operation{
      http_method: :post,
      params: params,
      path: "/blogs/#{blog_id}/articles.json"
    }
  end

  @doc """
  Delete an article.
  """
  @spec delete(binary) :: Shopify.Operation.t()
  def delete(blog_id) do
    %Shopify.Operation{
      http_method: :delete,
      path: "/blogs/#{blog_id}/articles.json"
    }
  end

  @doc """
  Update a article.
  """
  @spec update(binary, map) :: Shopify.Operation.t()
  def update(blog_id, params) do
    %Shopify.Operation{
      http_method: :put,
      params: params,
      path: "/blogs/#{blog_id}/articles.json"
    }
  end
end
