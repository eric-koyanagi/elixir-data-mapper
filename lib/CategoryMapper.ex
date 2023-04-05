defmodule CategoryMapper do
  require Logger

  # see https://help.shopify.com/txt/product_taxonomy/en.txt
  @categoryMap %{"clothing-pajamas-or-nightshirts-or-robes-53102600a0000" => 181,
    "clothing-sweaters-53101700a0000" => 127,
    "clothing-20010" => 127,
    "clothing-dresses-or-skirts-or-saris-or-kimonos-53102000a0000" => 160,
    "bedding-52121500a0000" => 3998,
    "clothing-bib-53102521a0000" => 922,
    "clothing-slacks-or-trousers-or-shorts-53101500a0000" => 173,
    "clothing-infant-swaddles-or-buntings-or-receiving-blankets-53102608a0000" => 936,
    "bookbags-backpacks-student-53121603a0001" => 4074,
    "skin-care-products-51241200a0002" => 2880,
    "books-81100" => 4134,
    "clothing-hair-accessories-53102500a0001" => 266,
    "clothing-coats-or-jackets-53101800a0000" => 165,
    "clothing-hats-53102503a0000" => 286,
    "bicycle-helmets-youth-46181704a0002" => 4945,
    "infant-child-car-seat-56101805a0000" => 887,
    "handbags-purses-53121600a0000" => 326,
    "bath-towels-52121700a0000" => 4020,
    "baby-feeding-bottles-nipples-42311808a0000" => 917,
    "diaper-cream-51241859a0001" => 906,
    "breast-pumps-42231901a0000" => 926,
    "bath-mats-rugs-52101507a0000" => 3041,
    "jewelry-54100000a0000" => 331,
    "cloth-face-masks-reusable-42131713a0002" => 1157,
    "toothbrushes-53131503a0000" => 2990,
    "clothing-underpants-53102303a0000" => 217,
    "sunglasses-nonrx-42142905a0001" => 301,
    "gift-cards-14111803a0001" => 5582,
  }

  def get_shopify_category(category_name) do 
    @categoryMap[category_name]
  end 

end 