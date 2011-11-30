require 'rho/rhocontroller'
require 'helpers/browser_helper'

$pagesize = 500

class ProductController < Rho::RhoController
  include BrowserHelper

  def generate_off
      (0..2000).each do |i|
        Product.create({
         'id' => i.to_s,
           'name' => "Test#{i}",
           'brand' => "Brand#{i}",
           'price' => "$#{i}.00"
        })
        puts i
      end
    Alert.show_popup "items generated"
    redirect "/app"
  end

  def generate

    puts 'Generating items'

    require_source 'Product'
    db = ::Rho::RHO.get_src_db('Product')
    db.start_transaction
    begin
      (0..2000).each do |i|
          Product.create({
           'id' => i.to_s,
             'name' => "Test#{i}",
             'brand' => "Brand#{i}",
             'price' => "$#{i}.00"
            })
          #puts i
      end
      db.commit
      puts 'Generating DONE'
    rescue
      db.rollback
      puts 'Generating failed'
    end

    Alert.show_popup "items generated"
    redirect "/app"
  end
  
  # GET /Product
  def index
    @products = Product.find(:all, :per_page => $pagesize)
    render :back => '/app'
  end

  def getpage
    page = @params['page'].nil? ? 1 : @params['page'].to_i
    @products = Product.find(:all, :per_page => $pagesize, :offset => page * $pagesize)
    render :layout => false, :use_layout_on_ajax => true
  end

  
  # GET /Product/{1}
  def show
    @product = Product.find(@params['id'])
    if @product
      render :action => :show, :back => url_for(:action => :index)
    else
      redirect :action => :index
    end
  end

  # GET /Product/new
  def new
    @product = Product.new
    render :action => :new, :back => url_for(:action => :index)
  end

  # GET /Product/{1}/edit
  def edit
    @product = Product.find(@params['id'])
    if @product
      render :action => :edit, :back => url_for(:action => :index)
    else
      redirect :action => :index
    end
  end

  # POST /Product/create
  def create
    @product = Product.create(@params['product'])
    redirect :action => :index
  end

  # POST /Product/{1}/update
  def update
    @product = Product.find(@params['id'])
    @product.update_attributes(@params['product']) if @product
    redirect :action => :index
  end

  # POST /Product/{1}/delete
  def delete
    @product = Product.find(@params['id'])
    @product.destroy if @product
    redirect :action => :index  
  end
end
