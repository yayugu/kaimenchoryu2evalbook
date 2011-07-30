# coding: utf-8
require 'pp'
require 'open-uri'
require 'haml'
require 'nokogiri'
require 'sinatra'


helpers do
  include Rack::Utils
  alias_method :h, :escape_html

  def base_url
    default_port = (request.scheme == "http") ? 80 : 443
    port = (request.port == default_port) ? "" : ":#{request.port.to_s}"
    "#{request.scheme}://#{request.host}#{port}"
  end
end

configure do
  enable :sessions
end

get '/' do
  haml <<-EOF
%html
  %title
    kaimenchoryu2evalbook
  界面潮流 to evalbook
  %br
  source: 
  %a{href: 'http://wiredvision.jp/blog/masui/'}
    http://wiredvision.jp/blog/masui/
  %br
  %a{href: 'http://evalbook.yayugu.net/view?source_url=#{base_url}/eval'}
    変換する
  EOF
end

get '/eval' do
  if @cache
    @cache
  else
    index = Nokogiri::HTML(open("http://wiredvision.jp/blog/masui/"))
    text = index.css('.link a').reverse.map do |a|
      title = "<h2>#{a.content}</h2>\n"
      page = Nokogiri::HTML(open(a.attr('href')))
      page.css('script').unlink
      page.css('h2').each{|node| node.name = 'h3'}
      body = page.css('#entryBody').to_xml
      title + body
    end.join("\n<pagebreak />\n")
    text = haml(<<-EOF) + text
%set{force_kansuji: 'true'}
%title
  界面潮流
%author
  増井俊之
    EOF
    @cache = text
  end
end
