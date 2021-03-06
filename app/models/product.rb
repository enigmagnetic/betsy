class Product < ApplicationRecord
  has_and_belongs_to_many :categories
  belongs_to :user
  has_many :order_products, dependent: :destroy
  has_many :reviews, dependent: :destroy

  validates :name, presence: true
  validates :name, uniqueness: true
  validates :price, presence: true
  validates :price, numericality: {greater_than: 0}
  validates :stock, presence: true, numericality: {only_integer: true, greater_than_or_equal_to: 0}

  def self.search(search)
    where("name ILIKE ?", "%#{search}%") 
  end
end
