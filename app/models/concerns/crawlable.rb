# coding: utf-8

require 'timeout'
require 'open-uri'
require 'tempfile'
require 'addressable/uri'
require 'faraday'
require 'json'

# crawl web page module
# must have url(:string)
module Crawlable
  TIME_OUT = 30
  USE_API = false

  def self.included(base)
    base.extend ClassMethods
  end

  # class methods
  module ClassMethods
  end

  # instance methods
  def crawl(url)
    if USE_API
      get_title_and_content_by_node_api url
    else
      get_title_and_content url
    end
  end

  private

  # @param url URI or String
  # @return URI or nil
  def get_uri(url)
    uri = url.class == Addressable::URI ? url.normalize : Addressable::URI.parse(url).normalize
    return uri if uri.scheme == 'http' || uri.scheme == 'https'
    nil
  rescue
    nil
  end

  # @param url String
  # @return String
  def get_title_and_content_by_node_api(url_param)
    host = Rails.application.secrets.crawler_api_host
    uri = get_uri(url_param)
    return nil if uri.nil?
    url = "#{host}/api/articles?url=#{uri}"
    res = Faraday.get url
    return get_title_and_content_by_res(res) if res.status == 200
  rescue
    nil
  end

  def get_title_and_content_by_res(res)
    json = JSON.parse(res.body)
    title = json['title']
    text = json['text']
    [title, multiline_squish(text)]
  end

  def multiline_squish(text)
    text.lines.collect(&:squish).reject(&:empty?).join("\n")
  end

  # @param url URI or String
  # @return String
  def get_title_and_content(url)
    doc = doc url
    return nil if doc.nil?

    doc.search('script').each do |script|
      script.content = ''
    end
    doc.search('style').each do |style|
      style.content = ''
    end
    title = doc.title ? doc.title.scrub : doc.title
    text = doc.text ? doc.text.scrub : doc.text
    [title, text]
  end

  # @param url URI or String
  # @return Nokogiri::HTML::Document
  def doc(url)
    uri = get_uri url
    return nil if uri.nil?

    file = nil
    Timeout.timeout(TIME_OUT) do
      user_agent = 'Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.1; Trident/4.0)'
      file = open(uri, 'User-Agent' => user_agent)
    end
    doc = Nokogiri::HTML(file, &:noblanks)
    file.close
    doc
  rescue OpenURI::HTTPError => e
    file.close if file.class == Tempfile
    status = e.io.status.first
    raise if %(403, 404).include?(status)
    nil
  rescue
    file.close if file.class == Tempfile
    nil
  end
end
