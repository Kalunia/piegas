class ProjectController < ApplicationController

# Prevent CSRF attacks by raising an exception.
# For APIs, you may want to use :null_session instead.
protect_from_forgery with: :exception

require 'classifierclass'
require 'stuff-classifier'
require 'open-uri'
require 'base64'
require 'twitter'
require 'date'

helper_method :get_info
helper_method :get_posts
helper_method :product_image
helper_method :classify_spam
helper_method :list_spams
helper_method :add_spam
helper_method :get_spams_detected
helper_method :get_spams_tweets
helper_method :get_pdf

respond_to :html


	# Resgata os posts do Twitter em relacao ao produto no momento
	def get_info

		text = String.new
		product = URI.encode(session[:product].split.map(&:capitalize).join('_'))

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

			if text.include? "referir-se a" or text.include? "remete-se a" 
				return "Muitas informações encontradas no Wikipedia - favor especificar..."
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


	################################################################ TWEETS

	# Resgata os posts do Twitter em relacao ao produto no momento
	def get_posts

		txt = ""
		sentiment = ""
		session[:positives] = 0
		session[:negatives] = 0
		session[:neutros] = 0

		@tokenizer = StuffClassifier::Tokenizer.new
		@sentClassifier = StuffClassifier::Bayes.open("Positive vs Negative")

		list = Array.new
		tag_words = ""

		begin

			client = Twitter::REST::Client.new do |config|
				config.consumer_key        = "MOe3DYlVMw1qYpRNPZdf8nSTG"
				config.consumer_secret     = "PwmHyTvtiBQBJlQ95ghnyfBHfGhBaxIO67D6n0RSzlX3DUDwUx"
				config.access_token        = "93068866-EVLLzkGGoqDyK6jn4nXqvH4eanl4btTwg6RoouN7G"
				config.access_token_secret = "fizJverUWl7d4tfYQj41GS03KQsCY4T68KZCNGWXmsCDA"
			end

			client.search(session[:product]+' -rt', :lang => "pt", :result_type => "recent", :exclude => "links").take(100).collect do |tweet|
				
				txt = filter_tweet("#{tweet.text}", session[:product])

				if !list.include?(txt)

					sentiment = @sentClassifier.classify(txt)
					tag_words += @tokenizer.each_word_tag_cloud(txt)
					d = DateTime.parse("#{tweet.created_at}")

					list << "#{tweet.user.screen_name}"
					list << "#{tweet.text}"
					list << d.strftime('%H:%M %p - %d/%m/%y')
					list << "#{tweet.user.profile_image_url}"
					list << sentiment

					#puts sentiment
					if sentiment.include?('positive')
						session[:positives] += 1
					elsif  sentiment.include?('negative')
						session[:negatives] += 1
					elsif sentiment.include?('neutro')
						session[:neutros] += 1
					end
				end
			end

			#puts tag_words
			tag_words_list = tag_words.split.inject(Hash.new(0)) { |h,v| h[v] += 1; h }
			tag_words_list_sorted = tag_words_list.sort_by{|k,v| v}.reverse
			session[:tag_cloud_words] = tag_words_list_sorted

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


	##################################################################### PDF
	def create_barchart_png

		data = params[:data_uri]
		
		image_data = Base64.decode64(data['data:image/png;base64,'.length .. -1])

		File.open("#{Rails.root}/public/images/barchart.png", 'wb') do |f|
		  f.write image_data
		end

		render :json => {:success => true}
	end


	def create_piechart_png

		data = params[:data_uri]
		
		image_data = Base64.decode64(data['data:image/png;base64,'.length .. -1])

		File.open("#{Rails.root}/public/images/piechart.png", 'wb') do |f|
		  f.write image_data
		end

		render :json => {:success => true}
	end

	# Organiza os Tweets neutros
	def tweets_neutral

		tweets = String.new

		for i in (0..session[:posts].length-1).step(5)
			if session[:posts][i+4].include?('neutro')
				tweets << session[:posts][i]
				tweets << " - " + session[:posts][i+1]
				tweets << "\n\n"
			end
        end

        tweets
    end

    # Organiza os Tweets positivos
    def tweets_positive

		tweets = String.new

		for i in (0..session[:posts].length-1).step(5)
			if session[:posts][i+4].include?('positive')
				tweets << session[:posts][i]
				tweets << " - " + session[:posts][i+1]
				tweets << "\n\n"
			end
        end

        tweets
    end

    # Organiza os Tweets negativos
    def tweets_negative

		tweets = String.new

		for i in (0..session[:posts].length-1).step(5)
			if session[:posts][i+4].include?('negative')
				tweets << session[:posts][i]
				tweets << " - " + session[:posts][i+1]
				tweets << "\n\n"
			end
        end

        tweets
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

	   	if product_image.present?
	    	pdf.image open( product_image ), :height => 80, :width => 80, :at => [0, pdf.bounds.top + 10]
	    end

	    pdf.formatted_text([
			{ :text => session[:product], :styles => [:bold], :color => "#FF0F0F", :size => 30}
		]) 
	    pdf.move_down(10)

	    if params[:info] == "infoY"
	    	pdf.formatted_text([
	    		{ :text => "Informacoes da pesquisa", :styles => [:bold], :color => "#FF0000", :size => 18 }
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
				pdf.image "#{Rails.root}/public/images//piechart.png", :height => 300
			end
	    	pdf.move_down(40)
	    end

	    if params[:barras].present?
	    	pdf.indent 50 do
	    		pdf.image "#{Rails.root}/public/images/barchart.png", :height => 300
	    	end
	    	pdf.move_down(40)
	    end

	    if params[:positivos].present?
	    	pdf.formatted_text([
	    		{ :text => "Tweets positivos", :styles => [:bold], :color => "#FF0000", :size => 18 }
	    		]) 
	    	pdf.move_down(20)
	    	pdf.text tweets_positive
	    	pdf.move_down(40)
	    end

	    if params[:negativos].present?
	    	pdf.formatted_text([
	    		{ :text => "Tweets negativos", :styles => [:bold], :color => "#FF0000", :size => 18 }
	    		]) 
	    	pdf.move_down(20)
	    	pdf.text tweets_negative
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

	
	##################################################################### SPAMS

	# Classifica o post em "Spam" ou "Nao Spam"
	def classify_spam

		@spams_detected = 0
		@tweets = Array.new
		@tweets_spams = Array.new

		for i in (0..session[:posts].length-1).step(5)

			if session[:spam_on] == 1
	           if ClassifierClass.classify_tweet(session[:posts][i+1]) != 'Spam'

	                @tweets << session[:posts][i]
					@tweets << session[:posts][i+1]
					@tweets << session[:posts][i+2]
					@tweets << session[:posts][i+3]
					@tweets << session[:posts][i+4]

	           else
	              	@spams_detected += 1
	              	@tweets_spams << session[:posts][i]
				    @tweets_spams << session[:posts][i+1]
					@tweets_spams << session[:posts][i+2]
					@tweets_spams << session[:posts][i+3]
					@tweets_spams << session[:posts][i+4]
	           end
	        else
          
          		@tweets << session[:posts][i]
				@tweets << session[:posts][i+1]
				@tweets << session[:posts][i+2]
				@tweets << session[:posts][i+3]
				@tweets << session[:posts][i+4]
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

end

