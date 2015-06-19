class HealthController < ApplicationController
  def live
    render :file => 'public/health/live.html'
  end
end
