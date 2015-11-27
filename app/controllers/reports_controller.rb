class ReportsController < ApplicationController
  def index
    report = {
      'total user count': User.count,
      'users': User.where(created_at: 1.months.ago..Time.now).group('DATE(created_at)').count,
      'total pages': Page.count,
      'active pages': Page.where(stop_fetch: false).count
    }

    render json: report
  end
end
