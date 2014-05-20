class ProjectController < ApplicationController

require 'classifierclass'
require 'twitterreader'

helper_method :classify_spam
layout false


	def search

		@product = params[:search]
		@posts = TwitterReader.reader(@product)

	end

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
	

	def classify_spam (text)
		ClassifierClass.classify_tweet(text)
	end

	# Prevent CSRF attacks by raising an exception.
	# For APIs, you may want to use :null_session instead.
	protect_from_forgery with: :exception

end

