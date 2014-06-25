class ProjectController < ApplicationController

# Prevent CSRF attacks by raising an exception.
# For APIs, you may want to use :null_session instead.
protect_from_forgery with: :exception

require 'classifierclass'
require 'twitterreader'
require 'open-uri'
require 'classifierclass'
require 'base64'

helper_method :get_info
helper_method :get_posts
helper_method :product_image
helper_method :classify_spam
helper_method :list_spams
helper_method :add_spam
helper_method :get_spams_detected
helper_method :get_spams_tweets
helper_method :get_pdf

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
			elsif e.message == '403 Forbidden'
				return "Figura proibida"
			else
				raise e
			end
		end
	end


	##################################################################### PDF
	def create_barchart_png

		data = params[:data_uri]
		
		image_data = Base64.decode64(data['data:image/png;base64,'.length .. -1])

		File.open("#{Rails.root}/tmp/barchart.png", 'wb') do |f|
		  f.write image_data
		end

		render :json => {:success => true}
	end


	def create_piechart_png

		data = params[:data_uri]
		
		image_data = Base64.decode64(data['data:image/png;base64,'.length .. -1])

		File.open("#{Rails.root}/tmp/piechart.png", 'wb') do |f|
		  f.write image_data
		end

		render :json => {:success => true}
	end


	# Gera o arquivo PDF
	def get_pdf
		# Creates a new PDF document
	    pdf = Prawn::Document.new
	    logo = "#{Rails.root}/public/images/piegas_logo.png"
	    
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

	    if params[:info] == "infoY"
	    	pdf.formatted_text([
	    		{ :text => "Informacoes do produto", :styles => [:bold], :color => "#FF0000", :size => 18 }
	    		]) 
	    	pdf.move_down(20)
	    	pdf.text get_info
	    	pdf.move_down(40)
	    end

	    if params[:pizza].present?
	    	
	    	# Load the html to convert to PDF
		    #html = File.read("#{Rails.root}/app/views/project/charts.html.erb")
		    # Create a new kit and define page size to be US letter

		    # kit = PDFKit.new(html, :page_size => 'Letter')
		    # kit.stylesheets << "#{Rails.root}/app/assets/javascripts/charts.js"
		    # send_data(kit.to_pdf, :filename => 'report.pdf', :type => 'application/pdf', :disposition => 'inline')
		    # Render the html
		    #render :text => html

		    #kit = IMGKit.new(File.new("#{Rails.root}/app/views/project/charts.html.erb"))

		    #file = kit.to_file("#{Rails.root}/public/images/logo.png") 
		    #pdf.image kit.to_png

	  #   	html = render_to_string(:controller => 'project', :action => "charts")
			# kit = PDFKit.new(html)
			#send_data(kit.to_pdf, :filename => 'report.pdf', :type => 'application/pdf', :disposition => 'inline'

			pdf.indent 50 do
				pdf.image "#{Rails.root}/tmp/piechart.png", :height => 300
			end
	    	pdf.move_down(40)
	    end

	    if params[:barras].present?
	    	pdf.indent 50 do
	    		pdf.image "#{Rails.root}/tmp/barchart.png", :height => 300
	    	end
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
		@tweets_spams = Array.new

		for i in (0..70).step(4)

          if ClassifierClass.classify_tweet(session[:posts][i+1]) != 'Spam'

                @tweets << session[:posts][i]
				@tweets << session[:posts][i+1]
				@tweets << session[:posts][i+2]
				@tweets << session[:posts][i+3]

          else
             	@spams_detected += 1
             	@tweets_spams << session[:posts][i]
				@tweets_spams << session[:posts][i+1]
				@tweets_spams << session[:posts][i+2]
				@tweets_spams << session[:posts][i+3]
          end
          
        end

        @tweets
	end

	def get_spams_detected
		@spams_detected
	end

	def get_spams_tweets
		@tweets_spams
	end


	# Adiciona post à lista de Spams
	def add_spam

		#ClassifierClass.add_spam (filter(params[:post]))

		sql = "INSERT INTO spams (user, query, post) VALUES ('"+current_user.email+"','"+session[:product]+"','"+filter(params[:post])+"');"
		records_array = ActiveRecord::Base.connection.execute(sql)

		#render :json => {:success => true}
	end

	# Adiciona post à lista de Favoritos
	def add_favorited

		#ClassifierClass.add_not_spam (filter(params[:post]))

		sql = "INSERT INTO favoriteds (user, query, post) VALUES ('"+current_user.email+"','"+session[:product]+"','"+filter(params[:post])+"');"
		records_array = ActiveRecord::Base.connection.execute(sql)

		#render :json => {:success => true}
	end




	def tweets_neutral

		tweets = String.new

		for i in (0..70).step(4)
			tweets << session[:posts][i]
			tweets << " - " + session[:posts][i+1]
			tweets << "\n\n"
        end

        tweets
    end
end

