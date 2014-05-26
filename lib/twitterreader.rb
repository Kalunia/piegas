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

		list
	end

	def self.sub (str)
		str.sub(" ", "_")
	end
end