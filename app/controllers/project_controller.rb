class ProjectController < ApplicationController

# Prevent CSRF attacks by raising an exception.
# For APIs, you may want to use :null_session instead.
protect_from_forgery with: :exception

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
		product = session[:product].split.map(&:capitalize).join('_')

		begin 
			doc = Nokogiri::HTML(open("http://pt.wikipedia.org/wiki/"+product)) 
		
			for i in (0..3)
				if doc.css('div#mw-content-text p')[i]
					info = doc.css('div#mw-content-text p')[i].text 

					if info.downcase.include? session[:product]
							text = text + info
					end
				end
			end

			if text.include? "podem referir-se a"
				return "Foram encontrados mais de um resultado esperado..."
			else
				return text
			end

		rescue OpenURI::HTTPError => e
			if e.message == '404 Not Found'
				return "Não foi possivel extrair informacoes do Wikipedia sobre o produto"
			else
				raise e
			end
		end
	end


	# Resgata os posts do Twitter em relacao ao produto no momento
	def get_posts

		list = Array.new

		begin
			doc = Nokogiri::HTML(open("https://twitter.com/search?q="+txt(session[:product])+"%20lang%3Apt&src=typd")) 
			items = doc.css ".content"
			
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

		rescue OpenURI::HTTPError => e
			if e.message == '404 Not Found'
				return "Nenhum post foi encontrado"
			else
				raise e
			end
		end
	end

	def refresh_posts

		get_posts

		respond_to do |format|
			format.html { redirect_to params[:path] }
		end
	end


	# Obtem a URL do produto pesquisado
	def product_image

	  	suckr = ImageSuckr::GoogleSuckr.new

	  	begin
	  		suckr.get_image_url({"q" => session[:product], as_filetype: "png", safe: "active"}) do  			
	  		end
	  	rescue OpenURI::HTTPError => e
			if e.message == '404 Not Found'
				return "Nenhuma figura encontrada"
			else
				raise e
			end
		end
	end


	# Gera o arquivo PDF
	def get_pdf
		# Creates a new PDF document
	    pdf = Prawn::Document.new
	    logo = "#{Rails.root}/public/images/logo.png"
	    
	    # Draw formated text with multiple options  
	    # pdf.formatted_text([
	    #       { :text => "Bold and Italic!", :styles => [:bold, :italic] },
	    #       # Gotcha Arial is not known by default
	    #       { :text => " Colored Helvetica.", :font => "Helvetica", :color => "#FF0000" },
	    #       { :text => " GO big Runnable!", :size => 20 }
	    #     ])

	    #   

	    pdf.indent 400 do
	    	pdf.image logo, :height => 60
	    	pdf.indent 70 do
	    		pdf.draw_text "Piegas", :at => [0, pdf.bounds.top - 30]
	    	end
	    end

	    pdf.image open( product_image ), :height => 80, :width => 80, :at => [0, pdf.bounds.top + 10]

	    pdf.formatted_text([
			{ :text => session[:product], :styles => [:bold], :color => "#FF0F0F", :size => 30}
		]) 
	    pdf.move_down(10)

	    if params[:infoY].present?
	    	pdf.formatted_text([
	    		{ :text => "Informacoes do produto", :styles => [:bold], :color => "#FF0000", :size => 18 }
	    		]) 
	    	pdf.move_down(20)
	    	pdf.text get_info
	    	pdf.move_down(40)
	    end

	    if params[:neutros].present?
	    	pdf.formatted_text([
	    		{ :text => "Tweets neutros", :styles => [:bold], :color => "#FF0000", :size => 18 }
	    		]) 
	    	pdf.move_down(20)
	    	pdf.text tweets_neutral
	    	pdf.move_down(40)
	    end
	    
	    # Sends the PDF as inline document with name x.pdf
	    send_data pdf.render, :filename => "avaliacao_piegas.pdf", :type => "application/pdf", :disposition => 'inline'
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


	def tweets_neutral

		tweets = String.new

		for i in (0..30).step(4)
			tweets << session[:posts][i]
			tweets << " - " + session[:posts][i+1]
			tweets << "\n\n"
        end

        tweets
    end

end

