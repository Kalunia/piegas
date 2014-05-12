class ApplicationController < ActionController::Base

require 'rubygems'
require 'open-uri'

	def twitter_reader( product )
		doc = Nokogiri::HTML(open("https://twitter.com/search?q="+txt(product)+"%20lang%3Apt&src=typd"))
		items = doc.css ".content"
		list = Array.new

		items.each do |item|
			autor = item.css(".fullname").first.content
			tweet = item.css(".js-tweet-text").first.content

			list << autor
			list << tweet
		end

		@productImageURL = product_image(product)
		list
	end

	def product_image (product)
	  suckr = ImageSuckr::GoogleSuckr.new

	  suckr.get_image_url({"q" => product, "as_filetype" => "png"})

	end

	def txt (str)
		str.sub(" ", "_")
	end

	# Prevent CSRF attacks by raising an exception.
	# For APIs, you may want to use :null_session instead.
	protect_from_forgery with: :exception

end
