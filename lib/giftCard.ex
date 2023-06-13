defmodule Shopify.GiftCard do
  @moduledoc """
  https://shopify.dev/docs/api/admin-rest/2022-04/resources/gift-card#put-gift-cards-gift-card-id
  """

  @doc """
  Create a gift card.
  """
  @spec create(map) :: Shopify.Operation.t()
  def create(params) do
    %Shopify.Operation{
      http_method: :post,
      params: params,
      path: "/gift_cards.json"
    }
  end

  @doc """
  Delete a gift card.
  """
  @spec delete(binary) :: Shopify.Operation.t()
  def delete(gift_card_id) do
    %Shopify.Operation{
      http_method: :delete,
      path: "/gift_cards.json"
    }
  end

end
