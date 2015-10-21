class ReportsController < ApplicationController
  def index
    report = { users: User.group_by_day(:created_at, last: 7, time_zone: 'Tokyo').count }

    render json: report
  end
end
