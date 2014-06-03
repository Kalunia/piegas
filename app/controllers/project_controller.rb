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
helper_method :get_spams_detected

#before_filter :get_product

respond_to :html

	# # Reforca o produto em foco
	# def get_product

	# 	@product = params[:product]
	# end

	# Resgata os posts do Twitter em relacao ao produto no momento
	def get_info

		text = String.new
		doc = Nokogiri::HTML(open("http://pt.wikipedia.org/wiki/"+txt(session[:product])))
		
		for i in (0..3)
			info = doc.css('div#mw-content-text p')[i].text 

			if info.downcase.include? session[:product]
					text = text + info
			end
		end

		text
	end


	# Resgata os posts do Twitter em relacao ao produto no momento
	def get_posts

		doc = Nokogiri::HTML(open("https://twitter.com/search?q="+txt(session[:product])+"%20lang%3Apt&src=typd"))
		items = doc.css ".content"
		list = Array.new

		items.each do |item|
			autor = item.css(".fullname").first.content
			tweet = item.css(".js-tweet-text").first.content
			time = item.css(".stream-item-header small a")[0]['title']
			avatar = item.css(".avatar").first['src']

			list << autor
			list << tweet
			list << time
			list << avatar
		end

		ClassifierClass.initialize_classifier

		session[:posts] = list
	end

	def refresh_posts

		get_posts

		respond_to do |format|
			format.html { redirect_to :action => params[:path] }
			format.html { render :layout => false }
		end
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
	def classify_spam

		@spams_detected = 0
		@tweets = Array.new

		for i in (0..30).step(4)

          if ClassifierClass.classify_tweet(session[:posts][i+1]) != 'Spam'

                @tweets << session[:posts][i]
				@tweets << session[:posts][i+1]
				@tweets << session[:posts][i+2]
				@tweets << session[:posts][i+3]

          else
             	@spams_detected += 1
          end
          
        end

        @tweets
	end

	def get_spams_detected
		@spams_detected
	end


	# Adiciona post à lista de Spams
	def add_spam

		#respond_to do |format|
			ClassifierClass.add_spam (filter(params[:post]))
		#	format.js
		#end
	end

end

