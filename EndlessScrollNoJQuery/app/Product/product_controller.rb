require 'rho/rhocontroller'
require 'helpers/browser_helper'
require 'time'

$pagesize = 500
$searchsize = 50

class ProductController < Rho::RhoController
  include BrowserHelper

  def generate_off
      (0..20000).each do |i|
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
    Rhom::Rhom.database_full_reset(false,true)
    puts 'Generating items'

    require_source 'Product'
    db = ::Rho::RHO.get_src_db('Product')
    db.start_transaction
    begin
      (0..20000).each do |i|
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
    $pagesize = 500
    before = Time.now.to_f
    @products = Product.find(:all, :per_page => $pagesize)
    after = Time.now.to_f
    puts "DB Time: #{after - before}"
    render :back => '/app'
  end
  
  def indexSearch
    $pagesize = 500
    $searchsize = 50
    before = Time.now.to_f
    @products = Product.find(:all, :per_page => $pagesize)
    after = Time.now.to_f
    puts "DB Time: #{after - before}"
    render :back => '/app'
  end
  
  def indexSearch100
    $pagesize = 100
    $searchsize = 100
    before = Time.now.to_f
    @products = Product.find(:all, :per_page => $pagesize)
    after = Time.now.to_f
    puts "DB Time: #{after - before}"
    render :action => :indexSearch, :back => '/app'
  end
  
  def indexSearch500
    $pagesize = 500
    $searchsize = 500
    before = Time.now.to_f
    @products = Product.find(:all, :per_page => $pagesize)
    after = Time.now.to_f
    puts "DB Time: #{after - before}"
    render :action => :indexSearch, :back => '/app'
  end

  def search
    pagesize = @params['q'] == "" ? $pagesize : $searchsize
    query = "%#{@params['q']}%"
    before = Time.now.to_f
    @products = Product.find(:all, :per_page => $searchsize, :conditions => { 
      {
        :func => 'LOWER',
       :name => 'name', 
        :op => 'LIKE'
      } => query
    })
    after = Time.now.to_f
    puts "DB Time: #{after - before}"
    render :layout => false, :use_layout_on_ajax => true
  end

  def slow
    sleep 5
    render :string => @params['q']
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
