require 'open-uri'
require 'tempfile'
require 'addressable/uri'

# crawl web page module
# must have url(:string)
module Crawlable
  def self.included(base)
    base.extend ClassMethods
  end

  # class methods
  module ClassMethods
  end

  # instance methods
  def crawl
    get_content url
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

  # @param url URI or String
  # @return String
  def get_content(url)
    doc = doc url
    return nil if doc.nil?

    doc.search('script').each do |script|
      script.content = ''
    end
    doc.search('style').each do |style|
      style.content = ''
    end
    doc.text.scrub
  end

  # @param url URI or String
  # @return Nokogiri::HTML::Document
  def doc(url)
    uri = get_uri url
    return nil if uri.nil?

    file = open(uri, 'User-Agent' => 'Googlebot/2.1')
    doc = Nokogiri::HTML(file, &:noblanks)
    file.close
    doc
  rescue
    file.close if file.class == Tempfile
    nil
  end
end
