class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  
  #Estos metodos son los que garantizan que no se entre a las paginas sin que se este logueado en el sistema primero.
  #Se ponen aqui porque este es el controlador de la aplicacion para que esten disponibles para el resto de los controladores.
  #Esto es sencillo. Si se fijan cada controlador hereda de este controlador, por lo tanto por herencia estan disponibles para su uso.
  #Entonces para proteger las paginas con un sesion lo unico que hay que hacer es llamar a estos metodos para verificar que estas
  #logueado en el sistema.
  def current_user
    User.find(session[:user_id]) if session[:user_id]
  end

  def require_login
    unless session[:user_id]
      flash[:errors] = ["You must login first"]
      redirect_to root_path
    end
  end
end
