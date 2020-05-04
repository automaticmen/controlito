class ArticlesController < ApplicationController
  def index
    @articles = Article.all
    @order_types = OrderType.all
    @search_writer = params["writer"]
    if @search_writer.present?
        @writer_id_value = @search_writer["writer_id"]
        unless  @writer_id_value.length==0
            @articles = @articles.where(writers_id: @writer_id_value)
        end
    end

    @search_writing_status = params["writingstatus"]
    if @search_writing_status.present?
        @writing_status_value = @search_writing_status["writingstatus_id"]
        unless @writing_status_value.length==0
            @articles = @articles.where(writingstatus_id: @writing_status_value)
        end
    end

    @search_payment_status = params["payment_status"]
    if @search_payment_status.present?
        @payment_status_value = @search_payment_status["payment_status_id"]
        unless @payment_status_value.length==0
            @articles = @articles.where(payment_status_id: @payment_status_value)
        end
    end
    @articles = @articles.order("due_date ASC")
  end
  def new
    @article = Article.new
  end
  def create
    #El cliente no tiene porque saber el ID de la orden de Fiverr. Por lo tanto
    #Voy a hacer una busqueda primero para ver si con el no de orden que ha metido
    #el cliente existe alguna orden de fiverr_order, si no existe pues no se hace
    #nada. Pero si existe se procede a crear el articulo.
    found_fiverr_order = FiverrOrder.find_by(order_no:params["article"]["fiverr_order_id"])
    if found_fiverr_order
      params["article"]["fiverr_order_id"] = found_fiverr_order.id
      article = Article.new(article_params)
      if article.save
          #redirect_to "/players"
          redirect_to new_article_path
        else
          @current_fiverr_order_id=found_fiverr_order.order_no

          flash[:errors] = article.errors.full_messages
          flash[:current_fiverr_order_id] = [@current_fiverr_order_id]

          redirect_to new_article_path
        end
      else
        flash[:errors] = ["Este numero de Orden no existe"]
        redirect_to new_article_path
    end
  end
  def edit
      @articles = Article.all
      @article = Article.find(params[:id])
  end
  #Esta accion no se espera que muestre ninguna vista ni nada por el estilo. Es solo para actualizar el jugador.
  def update
      #El cliente no tiene porque saber el ID de la orden de Fiverr. Por lo tanto
      #Voy a hacer una busqueda primero para ver si con el no de orden que ha metido
      #el cliente existe alguna orden de fiverr_order, si no existe pues no se hace
      #nada. Pero si existe se procede a crear el articulo.
      found_fiverr_order = FiverrOrder.find_by(order_no:params["article"]["fiverr_order_id"])
      article = Article.find(params[:id])
      if found_fiverr_order
        params["article"]["fiverr_order_id"] = found_fiverr_order.id
        #Luego si se puede actualizar el el jugador? y como datos llamamos al metodo player_params que se encarga de validar los datos necesarios
        if article.update(article_params)
            redirect_to "/articles"
        else
            flash[:errors] = article.errors.full_messages
            redirect_to "/articles/#{article.id}/edit"
            #redirect_to :back #es lo mismo que arriba pero mas sencillo de leer bueno mas bien de programar.
        end
      else
        flash[:errors] = ["Este numero de Orden no existe"]
        redirect_to "/articles/#{article.id}/edit"
      end
  end
  private
  #Buscar despues bien porque se hizo este metodo y que hace porque me dejo botao
  def article_params
      params.require(:article).permit(:fiverr_order_id,:due_date,:order_type_id,:writers_id,:price,:writingstatus_id,:comments,:url,:key_word,:writing_code,:article_amount,:word_count,:payment_status_id,:payment_date,:payment_details,:created_at,:updated_at,:fiverr_order_id,:order_type_id,:payment_status_id,:writers_id,:writingstatus_id)
  end
end
