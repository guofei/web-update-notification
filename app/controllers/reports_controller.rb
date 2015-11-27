class ReportsController < ApplicationController
  def index
    sec = 3 * 60 * 60
    report = {
      'total user count': User.count,
      'users': User.where(created_at: 1.months.ago..Time.now).group('DATE(created_at)').count,
      'total pages': Page.count,
      'active pages': Page.where(stop_fetch: false).count,
      'paid pages': Page.where('sec < ?', sec).count,
      'paid active pages': Page.where('sec < ?', sec).where(stop_fetch: false).count
    }

    render json: report
  end
end
