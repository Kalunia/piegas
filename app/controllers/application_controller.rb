class ApplicationController < ActionController::Base
	
# Prevent CSRF attacks by raising an exception.
# For APIs, you may want to use :null_session instead.
protect_from_forgery with: :exception

require 'rubygems'
require 'set'

attr_accessor :posts
attr_accessor :product

helper_method :filter

	

	def txt (str)
		str.sub(" ", "_")
	end

	def filter (str)
		str.sub("%", " ")
		str.sub("|", " ")
		str.sub("@", " ")
		str.sub("'", " ")
		str.sub("\n", " ")
	end

	def wiki (str)
		str.split.map(&:capitalize).join('_')
	end

	#Filtra o tweet com palavras inutilizadas 
	def filter_tweet(text)
		
		trash_set = Set.new([
	     '=)', '=P', '=p', '=*', '=D', '=]', '=[', '=(', ':)', ':(', ':]', ':[', ':P', ':p', ':*', 'T.T', '^^',
	     '.com', '.br',
	     'ish',
	     ' vish',
	     'lol', 'LOL', 'Lol'
	    ])
		
	    #Remove palavras inutilizaveis
	    trash_set.each do |trash_word|
	      text.gsub! trash_word, ''
	    end

	    #Remove Links
	    text = text.gsub /http:\/\/.*/, ''

	    #Remove risadas "kkkkkkkkk"
	    text = text.gsub /k.k*/, ''

	    #Remove risadas "sauhsauhsua", "hahaha", "hehehe" 
	    text = text.gsub(/\b[hsuae]+\b/, '')

	    #Remove risadas "rsrsrs"
	    text = text.gsub(/\b[rs]+\b/, '')

	    #Remove hashtags
	    text = text.gsub /(?:\s|^)(?:#(?!(?:\d+|\w+?_|_\w+?)(?:\s|$)))(\w+)(?=\s|$)/i, ''

	    #Remove @usuario
	    text = text.gsub /(?:\s|^)(?:@(?!(?:\d+|\w+?_|_\w+?)(?:\s|$)))(\w+)(?=\s|$)/i, ''
	   
	    #Remove caracteres repetidos
	    text = text.squeeze

	    return text
  	end

	private

	# def after_sign_in_path_for(resource_or_scope)
 #    	request.referrer
 #  	end

  	

end
