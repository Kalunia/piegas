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
require "net/http"

helper_method :get_info
helper_method :get_posts
helper_method :product_image
helper_method :classify_spam
helper_method :list_spams
helper_method :add_spam
helper_method :get_spams_detected
helper_method :get_spams_tweets
helper_method :get_pdf
helper_method :count_rows_spams
helper_method :count_rows_favoriteds
helper_method :select_favoriteds

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

		product = URI.encode(session[:product].split.map(&:capitalize).join('_'))
	  	suckr = ImageSuckr::GoogleSuckr.new

		  	begin
		  		suckr.get_image_url({"q" => product, as_filetype: "png", safe: "active"}) do
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

		num_tweets = 50
		txt = ""
		filtered = "" 
		sentiment = ""
		session[:positives] = 0
		session[:negatives] = 0
		session[:neutros] = 0
		session[:spams] = 0

		@tokenizer = StuffClassifier::Tokenizer.new
		@sentClassifier = StuffClassifier::Bayes.open("Positive vs Negative")
		if user_signed_in? and current_user.anti_spam == 1
			ClassifierClass.initialize_classifier(select_spams, select_favoriteds)
		end

		list = Array.new
		list_text = Array.new
		tag_words = ""

		begin

			client = Twitter::REST::Client.new do |config|
				config.consumer_key        = "MOe3DYlVMw1qYpRNPZdf8nSTG"
				config.consumer_secret     = "PwmHyTvtiBQBJlQ95ghnyfBHfGhBaxIO67D6n0RSzlX3DUDwUx"
				config.access_token        = "93068866-EVLLzkGGoqDyK6jn4nXqvH4eanl4btTwg6RoouN7G"
				config.access_token_secret = "fizJverUWl7d4tfYQj41GS03KQsCY4T68KZCNGWXmsCDA"
			end

			client.search(session[:product]+' -rt', :lang => "pt", :result_type => "recent", :exclude => "links").take(num_tweets).collect do |tweet|
				
				#puts "#{tweet.text}"

				txt = filter_tweet("#{tweet.text}", session[:product])
				filtered = filter("#{tweet.text}")

				if !list_text.include?(txt) and !"#{tweet.user.screen_name}".match(/#{session[:product]}/i)

					sentiment = @sentClassifier.classify(txt)
					tag_words += @tokenizer.each_word_tag_cloud(filter_text_for_tag_word("#{tweet.text}"))
					d = DateTime.parse("#{tweet.created_at}")

					list << "#{tweet.user.screen_name}"
					list << filtered
					list << d.strftime('%H:%M %p - %d/%m/%y')
					list << "#{tweet.user.profile_image_url}"

					list_text << txt

					#puts sentiment
					if user_signed_in? and current_user.anti_spam == 1 and ClassifierClass.classify_tweet(filter("#{tweet.text}")) == 'Spam' and count_rows_spams.to_i >= 5 and count_rows_favoriteds.to_i >= 5
						session[:spams] += 1
						list << 'spam'
					elsif user_signed_in? and current_user.anti_spam == 1 and select_spams.include?(filtered)
						session[:spams] += 1
						list << 'spam'
					else
						list << sentiment

						if sentiment.include?('positive')
							session[:positives] += 1
						elsif  sentiment.include?('negative')
							session[:negatives] += 1
						elsif sentiment.include?('neutro')
							session[:neutros] += 1
						end
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

		session[:barchart_url] = ""
		session[:barchart_url] = params[:barchart]

		render :json => {:success => true}
	end

	def create_piechart_png

		session[:piechart_url] = ""
		session[:piechart_url] = params[:piechart]

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
	    query_image = product_image

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

	    url = URI.parse(query_image)
		req = Net::HTTP.new(url.host, url.port)
		res = req.request_head(url.path)

	   	if res.code == '200'
	    	pdf.image open( query_image ), :height => 80, :width => 80, :at => [0, pdf.bounds.top + 10]
	    end

	    pdf.formatted_text([
			{ :text => session[:product].capitalize, :styles => [:bold], :color => "#FF0F0F", :size => 30}
		]) 
	    pdf.move_down(30)

    	pdf.formatted_text([
    		{ :text => "Resultados gerais da pesquisa", :styles => [:bold], :color => "#FF0000", :size => 18 }
    		]) 
    	pdf.move_down(20)
    	pdf.formatted_text([
    		{ :text => "Positivos: "+session[:positives].to_s, :size => 14 }
    		])
    	pdf.formatted_text([
    		{ :text => "Negativos: "+session[:negatives].to_s, :size => 14 }
    		])
    	pdf.formatted_text([
    		{ :text => "Neutros: "+session[:neutros].to_s, :size => 14 }
    		])
    	pdf.move_down(40)

	    if params[:info] == "infoY"
	    	pdf.formatted_text([
	    		{ :text => "Informacoes da pesquisa", :styles => [:bold], :color => "#FF0000", :size => 18 }
	    		]) 
	    	pdf.move_down(20)
	    	pdf.text get_info
	    	pdf.move_down(40)
	    end

	    if params[:cloud].present?
	    	pdf.formatted_text([
				{ :text => "Tag Cloud", :styles => [:bold], :color => "#FF0000", :size => 18 }
			])
	    	pdf.indent 50 do 
				pdf.move_down(20)

	    		if session[:tag_cloud_words]		
	    			if session[:tag_cloud_words][0]
						pdf.text session[:tag_cloud_words][0][0], :size => 20, :align => :center
					end
					if session[:tag_cloud_words][1] and session[:tag_cloud_words][2]
						pdf.text session[:tag_cloud_words][1][0]+" "+
							 session[:tag_cloud_words][2][0], :size => 18, :align => :center
					end
					if session[:tag_cloud_words][3] and session[:tag_cloud_words][5]
						pdf.text session[:tag_cloud_words][3][0]+" "+
							 session[:tag_cloud_words][4][0]+" "+
							 session[:tag_cloud_words][5][0], :size => 16, :align => :center
					end
					if session[:tag_cloud_words][6] and session[:tag_cloud_words][9]
						pdf.text session[:tag_cloud_words][6][0]+" "+
							 session[:tag_cloud_words][7][0]+" "+
							 session[:tag_cloud_words][8][0]+" "+
							 session[:tag_cloud_words][9][0], :size => 14, :align => :center
					end
					if session[:tag_cloud_words][10] and session[:tag_cloud_words][14]
						pdf.text session[:tag_cloud_words][10][0]+" "+
							 session[:tag_cloud_words][11][0]+" "+
							 session[:tag_cloud_words][12][0]+" "+
							 session[:tag_cloud_words][13][0]+" "+
							 session[:tag_cloud_words][14][0], :size => 12, :align => :center
					end
					if session[:tag_cloud_words][15] and session[:tag_cloud_words][20]
						pdf.text session[:tag_cloud_words][15][0]+" "+
							 session[:tag_cloud_words][16][0]+" "+
							 session[:tag_cloud_words][17][0]+" "+
							 session[:tag_cloud_words][18][0]+" "+
							 session[:tag_cloud_words][19][0]+" "+
							 session[:tag_cloud_words][20][0], :size => 10, :align => :center
					end
				elsif
					pdf.text 'Palavras insuficientes para construir o Tag Cloud.'
				end
			end
	    	pdf.move_down(40)
	   	end

	    if params[:pizza].present?
	    	pdf.formatted_text([
				{ :text => "Gráfico de Seção", :styles => [:bold], :color => "#FF0000", :size => 18 }
				]) 
			pdf.move_down(20)
			pdf.indent 140 do
				pdf.image open(session[:piechart_url]), :height => 200, :align => :center
			end
	    	pdf.move_down(40)
	    end

	    if params[:barras].present?
	    	pdf.formatted_text([
				{ :text => "Gráfico de Barras", :styles => [:bold], :color => "#FF0000", :size => 18 }
				]) 
			pdf.move_down(20)
	    	pdf.indent 140 do
	    		pdf.image open(session[:barchart_url]), :height => 200, :align => :center
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

		#@spams_detected = 0
		@tweets = Array.new
		@tweets_spams = Array.new

		for i in (0..session[:posts].length-1).step(5)

	  			if !session[:posts][i+4].include?('spam')
	                @tweets << session[:posts][i]
					@tweets << session[:posts][i+1]
					@tweets << session[:posts][i+2]
					@tweets << session[:posts][i+3]
					@tweets << session[:posts][i+4]

	            else
	              	@tweets_spams << session[:posts][i]
				    @tweets_spams << session[:posts][i+1]
					@tweets_spams << session[:posts][i+2]
					@tweets_spams << session[:posts][i+3]
					@tweets_spams << session[:posts][i+4]
				end
        end

        @tweets
	end

	def get_spams_tweets
		@tweets_spams
	end


	# Adiciona post à lista de Spams
	def add_spam

		index = params[:post].to_i
		classify_spam

		sql = "INSERT INTO spams (user, query, post) VALUES ('"+current_user.email+"','"+session[:product]+"','"+@tweets[index]+"');"
		records_array = ActiveRecord::Base.connection.execute(sql)

		for i in (0..session[:posts].length-1).step(5)
			if session[:posts][i+1] = @tweets[index]
				if session[:posts][i+4].include?('positive')
					session[:positives] -= 1
				elsif  session[:posts][i+4].include?('negative')
					session[:negatives] -= 1
				elsif session[:posts][i+4].include?('neutro')
					session[:neutros] -= 1
				end
				session[:posts][i+4] = 'spam'
				break
			end
		end

		session[:spams] += 1

		return render :json => {:success => true}
	end

	# Adiciona post à lista de Favoritos
	def add_favorited

		index = params[:post].to_i
		classify_spam

		sql = "INSERT INTO favoriteds (user, query, post) VALUES ('"+current_user.email+"','"+session[:product]+"','"+@tweets[index]+"');"
		records_array = ActiveRecord::Base.connection.execute(sql)

		return render :json => {:success => true}
	end

	def select_spams

		spam = Array.new 
  		sql = "SELECT post FROM spams WHERE user = '"+current_user.email+"';"
		spam_results = ActiveRecord::Base.connection.select_all(sql)

		spam_results.each do |row|
		 	spam << row["post"]
		end

		return spam
	end


	def select_favoriteds

		not_spam = Array.new 
  		sql = "SELECT post FROM favoriteds WHERE user = '"+current_user.email+"';"
		favorited_results = ActiveRecord::Base.connection.select_all(sql)

		favorited_results.each do |row|
		 	not_spam << row["post"]
		end

		return not_spam
	end

	def delete_spams

		sql = "DELETE FROM spams WHERE user = '"+current_user.email+"';"
		records_array = ActiveRecord::Base.connection.execute(sql)

		return render :json => {:success => true}
	end

	def delete_favoriteds

		sql = "DELETE FROM favoriteds WHERE user = '"+current_user.email+"';"
		records_array = ActiveRecord::Base.connection.execute(sql)

		return render :json => {:success => true}
	end

	def count_rows_spams

		sql = "SELECT COUNT(*) FROM spams WHERE user = '"+current_user.email+"';"

		return Spam.count_by_sql(sql)
	end

	def count_rows_favoriteds

		sql = "SELECT COUNT(*) FROM favoriteds WHERE user = '"+current_user.email+"';"

		return Favorited.count_by_sql(sql)
	end

end

