class PageSerializer < ActiveModel::Serializer
  attributes :id, :digest, :url, :sec, :created_at, :updated_at, :push_channel, :stop_fetch
end
