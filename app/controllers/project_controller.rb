class ProjectController < ApplicationController

# Prevent CSRF attacks by raising an exception.
# For APIs, you may want to use :null_session instead.
protect_from_forgery with: :exception
layout false

require 'classifierclass'
require 'twitterreader'
require 'open-uri'
require 'classifierclass'

helper_method :get_info
helper_method :get_posts
helper_method :product_image
helper_method :classify_spam
helper_method :list_spams
helper_method :add_spam

#before_filter :get_product

respond_to :html

	# # Reforca o produto em foco
	# def get_product

	# 	@product = params[:product]
	# end

	# Resgata os posts do Twitter em relacao ao produto no momento
	def get_info

		info = Nokogiri::HTML(open("http://pt.wikipedia.org/wiki/"+txt(session[:product])))
		text = info.css('div#mw-content-text p')[2].text 

		text
	end


	# Resgata os posts do Twitter em relacao ao produto no momento
	def get_posts (product)

		doc = Nokogiri::HTML(open("https://twitter.com/search?q="+txt(product)+"%20lang%3Apt&src=typd"))
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


	# Obtem a URL do produto pesquisado
	def product_image

	  	suckr = ImageSuckr::GoogleSuckr.new

	  	suckr.get_image_url({"q" => session[:product], as_filetype: "png", safe: "active"})
	end


	# Gera o arquivo PDF
	def pdf
		# Creates a new PDF document
	    pdf = Prawn::Document.new
	    
	    # Draw formated text with multiple options  
	    pdf.formatted_text([
	          { :text => "Bold and Italic!", :styles => [:bold, :italic] },
	          # Gotcha Arial is not known by default
	          { :text => " Colored Helvetica.", :font => "Helvetica", :color => "#FF0000" },
	          { :text => " GO big Runnable!", :size => 20 }
	        ])
	        
	    # Force padding all round
	    pdf.pad(20) { pdf.text "Text padded both before and after." }

	    # Move cursor 200px below
	    pdf.move_down(200)
	    
	    # Simple text draw
	    pdf.text "It is easy to draw text in other places"
	    
	    # Sends the PDF as inline document with name x.pdf
	    send_data pdf.render, :filename => "x.pdf", :type => "application/pdf", :disposition => 'inline'
	end
	
	# Classifica o post em "Spam" ou "Nao Spam"
	def classify_spam (post)

		ClassifierClass.classify_tweet(post)
	end


	# Adiciona post à lista de Spams
	def add_spam

		#respond_to do |format|
			ClassifierClass.add_spam (params[:post])
		#	format.js
		#end
	end

end

