class ReportsController < ApplicationController
  def index
    report = {
      users: User.where(:created_at=> 1.months.ago..Time.now).group('DATE(created_at)').count
    }

    render json: report
  end
end
