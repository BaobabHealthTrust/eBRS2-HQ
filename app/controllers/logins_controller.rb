class LoginsController < ApplicationController
  skip_before_filter :perform_basic_auth, :only => :logout

  def login
    #@coa = icoFolder("coa")
    render :layout => false
  end

  def create
    username = params[:user][:username]
    password = params[:user][:password]
    user = User.get_active_user(username)
    if user and user.password_matches?(password)
      
      login! user

      if (Time.now.to_date - (user.last_password_date.to_date rescue Date.today)).to_i >= 90
         if user.password_attempt >= 5 && username.downcase != 'admin'
           logout!
           flash[:error] = 'Your password has expired.Please contact your System Administrator.'
           redirect_to "/", referrer_param => referrer_path
         else
           user.update_attributes(:password_attempt => user.password_attempt + 1)
           flash[:error] = 'Your password has expired.Please change it!!!'
           redirect_to "/change_password"
         end
      else
      
         if (Time.now.to_date - (user.last_password_date.to_date rescue Date.today)).to_i >= 85 && (Time.now.to_date - user.last_password_date.to_date).to_i < 90
            flash[:info] = 'Your password will expire soon. Please change it.'
         end
          
         redirect_to default_path and return if back_or_default.match(/login/)

         redirect_to back_or_default and return
      end   
      
    else
      flash[:error] = 'That username and/or password is not valid.'
      redirect_to "/login"
    end

  end

  def logout
    logout!
    redirect_to "/", referrer_param => referrer_path
  end

  def set_context
    session[:touchcontext] = params[:id]

    render :text => "OK"
  end

  protected

  def default_path
    '/'
  end

  def perform_basic_auth
    authorize! :access, :login
  end

  def access_denied
    redirect_to default_path
  end

end

