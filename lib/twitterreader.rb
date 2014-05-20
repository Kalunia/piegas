class TwitterReader

require 'open-uri'
require 'classifierclass'

	def self.reader( product )
		doc = Nokogiri::HTML(open("https://twitter.com/search?q="+self.sub(product)+"%20lang%3Apt&src=typd"))
		items = doc.css ".content"
		list = Array.new

		items.each do |item|
			autor = item.css(".fullname").first.content
			tweet = item.css(".js-tweet-text").first.content

			list << autor
			list << tweet
		end

		ClassifierClass.initialize_classifier

		@productImageURL = self.product_image(product)
		list
	end

	def self.product_image (product)
	  	suckr = ImageSuckr::GoogleSuckr.new

	  	suckr.get_image_url({q: product, as_filetype: "png", safe: "moderate"})
	end

	def self.sub (str)
		str.sub(" ", "_")
	end
end