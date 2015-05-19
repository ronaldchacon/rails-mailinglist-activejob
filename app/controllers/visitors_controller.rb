class VisitorsController < ApplicationController
  protect_from_forgery except: :create

  def new
    @visitor = Visitor.new
    session[:referrer] ||= request.env['HTTP_REFERER'] || 'none'
    @visitor.referrer ||= session[:referrer] || 'none'
  end

  def create
    @visitor = Visitor.new(visitor_params)
    if @visitor.save
      redirect_to root_url, notice: "Signed up #{@visitor.email}"
    else
      render :new
    end
  end

  private

    def visitor_params
      params.require(:visitor).permit(:email, :affinity, :referrer)
    end

end
