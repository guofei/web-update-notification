# coding: utf-8

require 'timeout'
require 'open-uri'
require 'tempfile'
require 'addressable/uri'
require 'json'

# crawl web page module
# must have url(:string)
module Crawlable
  TIME_OUT = 30

  def self.included(base)
    base.extend ClassMethods
  end

  # class methods
  module ClassMethods
  end

  # instance methods
  def crawl(url)
    get_title_and_content url
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
