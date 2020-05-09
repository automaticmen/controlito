class FiverrOrdersController < ApplicationController
    #Before action. Significa que antes de ejectura ninguno de los metodos del controlador se debe hacer lo que se
    #especifica. En este caso :require_loguin . Este es un metodo implementado por nosotros en application controller
    #el cual se encarga de verificar si estamos en sesion o no.
    before_action :require_login
    def index
      #esto para definir el espacio se que esto se hace mejor con CSS pero no se como ver despues
        @left_padding = "2px"
        @right_padding = "2px"
        @top_padding = "0px"
        @bottom_padding = "0px"

        @fiverr_orders = FiverrOrder.all
        @order_types_list = OrderType.all
        @order_statuses_list = OrderStatus.all

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
              unless  @order_type_value.length==0
                  @fiverr_orders = @fiverr_orders.where(order_type_id: @order_type_value)
              end
          end

          if @search_order_status.present?
              @order_status_value = @search_order_status["order_status_id"]
              unless @order_status_value.length==0
                  @fiverr_orders = @fiverr_orders.where(order_status_id: @order_status_value)
              end
          end

          if @search_server.present?
              @server_value = @search_server["server_id"]
              unless @server_value.length==0
                  @fiverr_orders = @fiverr_orders.where(server_id: @server_value)
              end
          end

          if @search_traffic.present?
              @traffic_value = @search_traffic["site_traffic_status_id"]
              unless @traffic_value.length==0
                  @fiverr_orders = @fiverr_orders.where(traffic:true)
                  @fiverr_orders = @fiverr_orders.where(site_traffic_status: @traffic_value)
              end
          end

          if @search_site_audit.present?
              @site_audit_value = @search_site_audit["site_audit_status_id"]
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
              @fiverr_orders = @fiverr_orders.where(rank_tracker: @rank_tracker_value)
          end
        #No hay filtro de ningun tipo entonces vamos a lo que vamos a mostrar solo ordenes no entregadas ni canceladas
        else
          @fiverr_orders = @fiverr_orders.where.not(order_status_id:10)#no canceladas
          @fiverr_orders = @fiverr_orders.where.not(order_status_id:6)#no entregadas
        end


        @fiverr_orders = @fiverr_orders.order("due_date ASC")
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
        #Primero creamos un jugador para operar con el. El parametro :id es un contenedor que es pasado a traves de la ruta
        #para que pomdamos saber de jugador estamos hablando. por eso podemos hacer find(params[:id])
        fiverr_order = FiverrOrder.find(params[:id])
        #Luego si se puede actualizar el el jugador? y como datos llamamos al metodo player_params que se encarga de validar los datos necesarios
        if fiverr_order.update(fiverr_order_params)
            redirect_to "/fiverr_orders"
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
end
