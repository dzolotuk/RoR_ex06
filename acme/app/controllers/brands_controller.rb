class BrandsController < ApplicationController
  def index
    @brands = Brand.left_joins(:products).select('brands.*, COUNT(products.id) AS products_count')
                   .group('brands.id').order(:name, :id)
  end

  def show
    @brand = Brand.find(params[:id])
    @paginator = Paginator.new(@brand.products.includes(:brand).order(:id), params[:page])
  end
end
