class SessionsController < ApplicationController
    def create
        user = User.find_by(email: params[:email])
        if user && user.authenticate(params[:password])
            session[:user_id] = user.id
            redirect_to writers_path
        else
            flash[:errors] = ["Invalid Combination"]
            redirect_to :root
        end
    end

    def destroy
        reset_session
        redirect_to :root
    end
end