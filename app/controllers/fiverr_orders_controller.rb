class FiverrOrdersController < ApplicationController
    #Before action. Significa que antes de ejectura ninguno de los metodos del controlador se debe hacer lo que se
    #especifica. En este caso :require_loguin . Este es un metodo implementado por nosotros en application controller
    #el cual se encarga de verificar si estamos en sesion o no.
    before_action :require_login

    #Cuando actualziamos la informacion de una orden queremos que hayan dos opciones. Una de ellas es que se actualice
    #la INFO y se quede en el mismo formulario por si queiremos seguir haciendo cosas. La otra opcion es redireccionar
    #a la lista de ordenes con los mismos filtros aplciados previamente. Para ello estamos creando estas dos posibiliddes.
    #De ser necesarias mas pues se peuden añadir aqui. Entonces en el formulario se van a crear de moemnto dos SUBMIT
    #Buttons.
    UPDATE_ACTIONS = {
    :UPDATE_AND_STAY => "UPDATE",
    :UPDATE_AND_GOT_TO_ORDER_LIST => "UPDATE AND LEAVE"
  }

    #Esto lo estoy creadno para tener diferentes tipos de busqueda. Por ejmplo busqueda por filtro y una busqueda que revise
    #todos los campos de la base de datos utilizando LIKE. Bueno quien dice todos no serán todos solo los campos en los cuales
    #tenga sentido buscar.
    SEARCH_ACTIONS = {
    :SEARCH_BY_FILTER => "Filtrar",
    :FULL_SEARCH => "Buscar"
  }
    def index
      #esto para definir el espacio se que esto se hace mejor con CSS pero no se como ver despues
        @left_padding = "2px"
        @right_padding = "2px"
        @top_padding = "0px"
        @bottom_padding = "0px"

        @fiverr_orders = FiverrOrder.all
        @order_types_list = OrderType.all
        @order_statuses_list = OrderStatus.all

      #En dependencia de las busquedas realizadas seran los resultados que se muestren en la pagina del index
      #Entocnes de momento estoy teniendo dos formas principales de mostrar resultados. Resultados que se solicitan
      #por un filtrado y resutlados que se solicitan de una busqueda general. En dependecia de la solicitud serán
      #los resultados mostrados.
      if params[:commit] == SEARCH_ACTIONS[:SEARCH_BY_FILTER]
        #este metodo es el encargado de buscar los resultados segun los valores del filtro
        search_by_filter
      elsif params[:commit] == SEARCH_ACTIONS[:FULL_SEARCH]
        #este metodo es el encargado de realizar la busqueda general en la BD.
        full_search
      #No hay filtro de ningun tipo entonces vamos a lo que vamos a mostrar solo ordenes no entregadas ni canceladas
      else
        @fiverr_orders = @fiverr_orders.where.not(order_status_id:10)#no canceladas
        @fiverr_orders = @fiverr_orders.where.not(order_status_id:6)#no entregadas
        #Organizando el resultado de la busqueda de orden mas prioritaria a menos prioritaria guiandonos por la fecha
        #de vencimiento.
        @fiverr_orders = @fiverr_orders.order("due_date ASC")
      end
    end
    def new
        @fiverr_order = FiverrOrder.new
        6.times { @fiverr_order.article.build }
    end
    def create
        fiverr_order = FiverrOrder.new(fiverr_order_params)
        if fiverr_order.save
            #redirect_to "/players"
            redirect_to new_fiverr_order_path
        else
            @current_order_no=params[:fiverr_order][:order_no]
            @current_username=params[:fiverr_order][:username]
            @current_due_date=params[:fiverr_order][:due_date]
            @current_order_type=params[:fiverr_order][:order_type_id]

            flash[:errors] = fiverr_order.errors.full_messages
            flash[:current_order_no] = [@current_order_no]
            flash[:current_username] = [@current_username]
            flash[:current_due_date] = [@current_due_date]
            flash[:current_order_type] = [@current_order_type]

            redirect_to new_fiverr_order_path
            #redirect_to :back
        end
    end
    def edit
        @servers = Server.all
        @fiverr_order = FiverrOrder.find(params[:id])
        @articles = Article.where(fiverr_order_id:params["id"])
    end
    #Esta accion no se espera que muestre ninguna vista ni nada por el estilo. Es solo para actualizar el jugador.
    def update
        @order_type_filter_status = session[:passed_order_type_filter_status]
        @server_filter_status = session[:passed_server_filter_status]#aqui estoy leyendo el valor pasado en la sesion para usarlo y general la url con filtro
        @order_status_filter_status = session[:passed_order_status_filter_status]#aqui estoy leyendo el valor pasado en la sesion para usarlo y general la url con filtro
        @traffic_filter_status = session[:passed_traffic_filter_status]#aqui estoy leyendo el valor pasado en la sesion para usarlo y general la url con filtro
        @site_audit_filter_status = session[:passed_site_audit_filter_status]
        @rank_tracker_filter_status = session[:passed_rank_tracker_filter_status]
        #Primero creamos un jugador para operar con el. El parametro :id es un contenedor que es pasado a traves de la ruta
        #para que pomdamos saber de jugador estamos hablando. por eso podemos hacer find(params[:id])
        fiverr_order = FiverrOrder.find(params[:id])
        #Luego si se puede actualizar el el jugador? y como datos llamamos al metodo player_params que se encarga de validar los datos necesarios
        if fiverr_order.update(fiverr_order_params)
          #En dependencia del valor que tenga este parametro entonces se va de la orden para la lista o se queda en la misma despues de actualizar
          if params[:commit] == UPDATE_ACTIONS[:UPDATE_AND_STAY]
            redirect_to "/fiverr_orders/#{fiverr_order.id}/edit"
          elsif params[:commit] == UPDATE_ACTIONS[:UPDATE_AND_GOT_TO_ORDER_LIST]
            redirect_to "/fiverr_orders?utf8=✓&order_type[order_type_id]=#{@order_type_filter_status}&order_status[order_status_id]=#{@order_status_filter_status}&server[server_id]=#{@server_filter_status}&site_traffic_status[site_traffic_status_id]=#{@traffic_filter_status}&site_audit_status[site_audit_status_id]=#{@site_audit_filter_status}&rank_tracker=#{@rank_tracker_filter_status}&order_no=}&commit=Filtrar",turbolinks: false
          else
            flash[:error] = "NON VALID UPDATE ACTION"
          end
        else
            flash[:errors] = fiverr_order.errors.full_messages
            redirect_to "/fiverr_orders/#{fiverr_order.id}/edit"
            #redirect_to :back #es lo mismo que arriba pero mas sencillo de leer bueno mas bien de programar.
        end
    end
    def show
      if params["order_type"] == "PR9_GIG"
        @basic_type_id = OrderType.find_by(name:"PR9_BASIC").id#Esto es porque el id puede cambair cuando cambias de un lugar a Otro lo que debes garantizar es que el nombre sea el mismo
        @std_type_id = OrderType.find_by(name:"PR9_STANDARD").id
        @prem_type_id = OrderType.find_by(name:"PR9_PREMIUM").id

        #Basic
        @basic_orders = FiverrOrder.where(:order_type_id=>@basic_type_id)
        @basic_stats = @basic_orders.group(:order_status_id).count
        @basic_site_audit_order = @basic_orders.where(:site_audit=>true)
        @basic_site_audit_stats = @basic_site_audit_order.group(:site_audit_status).count
        @basic_traffic_order = @basic_orders.where(:traffic=>true)
        @basic_traffic_order_stats = @basic_traffic_order.group(:site_traffic_status).count

        #Standard
        @std_orders = FiverrOrder.where(:order_type_id=>@std_type_id)
        @std_stats = @std_orders.group(:order_status_id).count
        @std_site_audit_order = @std_orders.where(:site_audit=>true)
        @std_site_audit_stats = @std_site_audit_order.group(:site_audit_status).count
        @std_traffic_order = @std_orders.where(:traffic=>true)
        @std_traffic_order_stats = @std_traffic_order.group(:site_traffic_status).count

        #Premium
        @prem_orders = FiverrOrder.where(:order_type_id=>@prem_type_id)
        @prem_stats = @prem_orders.group(:order_status_id).count
        @prem_site_audit_order = @prem_orders.where(:site_audit=>true)
        @prem_site_audit_stats = @prem_site_audit_order.group(:site_audit_status).count
        @prem_traffic_order = @prem_orders.where(:traffic=>true)
        @prem_traffic_order_stats = @prem_traffic_order.group(:site_traffic_status).count


        render "pr9_gig_summary"
      end
      if params["order_type"] == "PR9_TRAFFIC"
        @basic_type_id = OrderType.find_by(name:"TRAFFIC_BASIC").id
        @std_type_id = OrderType.find_by(name:"TRAFFIC_STANDARD").id
        @prem_type_id = OrderType.find_by(name:"TRAFFIC_PREMIUM").id
        #Basic
        @basic_orders = FiverrOrder.where(:order_type_id=>@basic_type_id)
        @basic_stats = @basic_orders.group(:order_status_id).count
        #Standard
        @std_orders = FiverrOrder.where(:order_type_id=>@std_type_id)
        @std_stats = @std_orders.group(:order_status_id).count
        #Premium
        @prem_orders = FiverrOrder.where(:order_type_id=>@prem_type_id)
        @prem_stats = @prem_orders.group(:order_status_id).count
        render "traffic_gig_summary"
      end
    end
    private
    #Buscar despues bien porque se hizo este metodo y que hace porque me dejo botao
    def fiverr_order_params
        params.require(:fiverr_order).permit(:order_no, :username,:order_type_id,:order_status_id,:server_id,:custom_offer,:site_audit,:site_audit_status,:articles,:traffic,:site_traffic_status,:login_data,:login_data_status,:start_date,:rank_tracker,:comments,:due_date,article_attributes: [:fiverr_order_id,:due_date,:order_type_id,:writers_id,:price,:writingstatus_id,:comments,:url,:key_word,:writing_code,:article_amount,:word_count,:payment_status_id,:payment_date,:payment_details,:created_at,:updated_at,:fiverr_order_id,:order_type_id,:payment_status_id,:writers_id,:writingstatus_id,:_destroy])
    end

    #Este metodo lo voy a utilizar para devolver el resultado de una busqueda por filtros
    def search_by_filter
      #Primero necesito tener un analisis de todos los parametros para saber si estan tratando de filtrar algo
      #o solamente es el index sin ningun filtro aplicado. Si hay filtro aplicado pues entonces ejecutar el filtro
      #tal cual. Si no hay filtro aplicado entonces mostrar solo ordenes que no esten entregadas o canceladas.
      @search_order_type = params["order_type"]
      @search_order_status = params["order_status"]
      @search_server = params["server"]
      @search_traffic = params["site_traffic_status"]
      @search_site_audit = params["site_audit_status"]
      @search_order_no = params["order_no"]
      @search_rank_tracker = params["rank_tracker"]
      #Si al menos hay presencia de uno de los filtros entonces a filtrar.
      if  @search_order_type.present? || @search_order_status.present? || @search_server.present? || @search_traffic.present? || @search_site_audit.present? || @search_order_no.present?

        if @search_order_type.present?
            @order_type_value = @search_order_type["order_type_id"]
            #Aqui estoy creando una variable del estado del filtro para poder usarla en ontra sesion. El objetivo de esto es que cuando este editando una orden y le de
            #update entonces regrese a la pagina de donde vino y aplique los mismos filtros que tenia ella misma. Entonces para esto tengo que compartir su valor en una
            #sesion para que despues cuando vaya a la parte de update del cntrolador poder utilizarla y pasarla como parametro en la url para que este el mismo filtro
            # de donde salio activo.
            @order_type_filter_status = @order_type_value#guardando el valor del filtro
            session[:passed_order_type_filter_status] = @order_type_filter_status#almacenando el valor para que este disponible en la session
            unless  @order_type_value.length==0
                @fiverr_orders = @fiverr_orders.where(order_type_id: @order_type_value)
            end
        end

        if @search_order_status.present?
            @order_status_value = @search_order_status["order_status_id"]
            #Aqui estoy creando una variable del estado del filtro para poder usarla en ontra sesion. El objetivo de esto es que cuando este editando una orden y le de
            #update entonces regrese a la pagina de donde vino y aplique los mismos filtros que tenia ella misma. Entonces para esto tengo que compartir su valor en una
            #sesion para que despues cuando vaya a la parte de update del cntrolador poder utilizarla y pasarla como parametro en la url para que este el mismo filtro
            # de donde salio activo.
            @order_status_filter_status = @order_status_value#guardando el valor del filtro
            session[:passed_order_status_filter_status] = @order_status_filter_status#almacenando el valor para que este disponible en la session
            unless @order_status_value.length==0
                @fiverr_orders = @fiverr_orders.where(order_status_id: @order_status_value)
            end
        end

        if @search_server.present?
            @server_value = @search_server["server_id"]
            #Aqui estoy creando una variable del estado del filtro para poder usarla en ontra sesion. El objetivo de esto es que cuando este editando una orden y le de
            #update entonces regrese a la pagina de donde vino y aplique los mismos filtros que tenia ella misma. Entonces para esto tengo que compartir su valor en una
            #sesion para que despues cuando vaya a la parte de update del cntrolador poder utilizarla y pasarla como parametro en la url para que este el mismo filtro
            # de donde salio activo.
            @server_filter_status = @server_value#guardando el valor del filtro
            session[:passed_server_filter_status] = @server_filter_status#almacenando el valor para que este disponible en la session
            unless @server_value.length==0
                @fiverr_orders = @fiverr_orders.where(server_id: @server_value)
            end
        end

        if @search_traffic.present?
            @traffic_value = @search_traffic["site_traffic_status_id"]
            #Aqui estoy creando una variable del estado del filtro para poder usarla en ontra sesion. El objetivo de esto es que cuando este editando una orden y le de
            #update entonces regrese a la pagina de donde vino y aplique los mismos filtros que tenia ella misma. Entonces para esto tengo que compartir su valor en una
            #sesion para que despues cuando vaya a la parte de update del cntrolador poder utilizarla y pasarla como parametro en la url para que este el mismo filtro
            # de donde salio activo.
            @traffic_filter_status = @traffic_value#guardando el valor del filtro
            session[:passed_traffic_filter_status] = @traffic_filter_status#almacenando el valor para que este disponible en la session
            unless @traffic_value.length==0
                @fiverr_orders = @fiverr_orders.where(traffic:true)
                @fiverr_orders = @fiverr_orders.where(site_traffic_status: @traffic_value)
            end
        end

        if @search_site_audit.present?
            @site_audit_value = @search_site_audit["site_audit_status_id"]
            #Aqui estoy creando una variable del estado del filtro para poder usarla en ontra sesion. El objetivo de esto es que cuando este editando una orden y le de
            #update entonces regrese a la pagina de donde vino y aplique los mismos filtros que tenia ella misma. Entonces para esto tengo que compartir su valor en una
            #sesion para que despues cuando vaya a la parte de update del cntrolador poder utilizarla y pasarla como parametro en la url para que este el mismo filtro
            # de donde salio activo.
            @site_audit_filter_status = @site_audit_value#guardando el valor del filtro
            session[:passed_site_audit_filter_status] = @site_audit_filter_status#almacenando el valor para que este disponible en la session
            unless @site_audit_value.length==0
                @fiverr_orders = @fiverr_orders.where(site_audit:true)
                @fiverr_orders = @fiverr_orders.where(site_audit_status: @site_audit_value)
            end
        end

        if @search_order_no.present?
            unless @search_order_no.length==0
                @fiverr_orders = @fiverr_orders.where(order_no: @search_order_no)
                if @fiverr_orders.count==1
                  redirect_to "/fiverr_orders/#{@fiverr_orders.first.id}/edit"
                end
            end
        end
        if @search_rank_tracker.present?
          @rank_tracker_value = params[:rank_tracker] == "1" ? true : false
          #Aqui estoy creando una variable del estado del filtro para poder usarla en ontra sesion. El objetivo de esto es que cuando este editando una orden y le de
          #update entonces regrese a la pagina de donde vino y aplique los mismos filtros que tenia ella misma. Entonces para esto tengo que compartir su valor en una
          #sesion para que despues cuando vaya a la parte de update del cntrolador poder utilizarla y pasarla como parametro en la url para que este el mismo filtro
          # de donde salio activo.
          @rank_tracker_filter_status = params[:rank_tracker]#guardando el valor del filtro
          session[:passed_rank_tracker_filter_status] = @rank_tracker_filter_status#almacenando el valor para que este disponible en la session
            @fiverr_orders = @fiverr_orders.where(rank_tracker: @rank_tracker_value)
        end
      end

      #Organizando el resultado de la busqueda de orden mas prioritaria a menos prioritaria guiandonos por la fecha
      #de vencimiento.
      @fiverr_orders = @fiverr_orders.order("due_date ASC")
    end

    #Este metodo lo voy a utilizar para devolver el resultado de una busqueda por los campos de la base de datos que
    #me interesen
    def full_search
      #Obteniendo resultados en el campo order_no
      @fiverr_orders_1 = @fiverr_orders.where("order_no LIKE ?", "%" + params["order_no"] + "%")
      #Obteniendo resultados en el campo comments
      @fiverr_orders_2 = @fiverr_orders.where("comments LIKE ?", "%" + params["order_no"] + "%")
      #Obteniendo resultados en el campo username
      @fiverr_orders_3 = @fiverr_orders.where("username LIKE ?", "%" + params["order_no"] + "%")
      #Añadiendo los resultados obtenidos para resumirlos.
      @fiverr_orders = @fiverr_orders_1 + @fiverr_orders_2 + @fiverr_orders_3
      @fiverr_orders = @fiverr_orders.uniq
    end
end
