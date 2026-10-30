class ProductsController < ApplicationController
  def index
    @paginator = Paginator.new(Product.includes(:brand).order(:id), params[:page])
  end

  def show
    @product = Product.includes(:brand).find(params[:id])
  end
end
