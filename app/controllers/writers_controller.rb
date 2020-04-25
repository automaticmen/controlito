class WritersController < ApplicationController
    #Before action. Significa que antes de ejectura ninguno de los metodos del controlador se debe hacer lo que se
    #especifica. En este caso :require_loguin . Este es un metodo implementado por nosotros en application controller
    #el cual se encarga de verificar si estamos en sesion o no.
    before_action :require_login
    def index
      @writers = Writer.all
    end
end
