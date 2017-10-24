class ProductsController < ApplicationController
  before_action :find_product , only: [:show, :edit, :update]
  def root
    @top_products =  Product.select("products.id, avg(reviews.rating) as average_rating").where(active: true).joins("LEFT JOIN reviews ON products.id = reviews.product_id").group("products.id").order("average_rating DESC NULLS LAST").limit(6)
    #Product.joins("LEFT JOIN order_products ON products.id = order_products.product_id").group(:id).order("count(order_products.id)  DESC").limit(10)
    @recent_products =  Product.where(active: true).order(created_at: :desc).limit(6)
  end

  def index
    @categories = Category.order(:name)

    if params[:category_id]
      if Category.find_by(id: params[:category_id]) == nil
        render_404
      else
        @products = Product.includes(:categories).where(active: true, categories: { id: params[:category_id]})
      end
    elsif params[:user_id]
      if User.find_by(id: params[:user_id]) == nil
        render_404
      else
        @products = Product.includes(:user).where(active: true, products: {user_id: params[:user_id]})
      end
    else
      @products = Product.where(active: true).order(:id)
    end
  end

  def show
    @order_product = OrderProduct.new
  end

  def new
    #is currently set to choose user to add product to
    @product = Product.new
  end

  def create
    @product = Product.new(product_params)
    temp = @product.categories.map {|c| c.id }
    store_params = params[:product][:category_ids]
    if store_params
      store_params.each do |category|
        if !temp.include?(category) && category != ""
          @product.categories << Category.find(category)
        end
      end
    end
    if @product.save
      flash[:status] = :success
      flash[:result_text] = "Successfully created #{@product.name}!"
      redirect_to product_path(@product)
    else
      flash.now[:status] = :error
      flash.now[:result_text] = "#{@product.name} could not be created"
      render :new, status: :bad_request
    end
  end

  def edit
  end

  def update
    @product.categories = []
    # note: clears categories

    store_params = params[:product][:category_ids]
    if store_params
      store_params.each do |category|
        unless category == ""
          @product.categories << Category.find(category)
        end
      end
    end
    @product.update_attributes(product_params)

    if @product.save
      flash[:status] = :success
      flash[:result_text] = "Successfully updated #{@product.name}!"
      redirect_to product_path
    else
      flash.now[:status] = :error
      flash.now[:result_text] = "#{@product.name} could not be updated"
      render :edit, status: :bad_request
    end
  end

  def destroy
  end

  def toggle_active
    @product = Product.find_by(id: params[:id])
    # @product.active = params[:product][:active].to_i
    if @product.active
      @product.active = false
    else
      @product.active = true
    end

    @product.save
      redirect_to user_path(@product.user)
    # else
    #   flash[:status] = :failure
    #   flash[:result_text] = "Active status cannot be loaded"
    # end
  end

  private
  def find_product
    @product = Product.find_by(id: params[:id])
    render_404 unless @product
  end

  def product_params
    return params.require(:product).permit(:user_id, :name, :price, :stock, :description, :image, :active)
  end

  # def render_404
  #   render file: "/public/404.html", status: 404
  # end
end
