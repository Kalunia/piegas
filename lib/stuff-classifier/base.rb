# encoding: utf-8

class StuffClassifier::Base
  extend StuffClassifier::Storage::ActAsStorable
  attr_reader :name
  attr_reader :word_list
  attr_reader :category_list
  attr_reader :training_count

  attr_accessor :tokenizer
  attr_accessor :language
  
  attr_accessor :thresholds
  attr_accessor :min_prob


  storable :version,:word_list,:category_list,:training_count,:thresholds,:min_prob
    
  # opts :
  # language
  # stemming : true | false
  # weight
  # assumed_prob
  # storage
  # purge_state ?

  def initialize(name, opts={})
    @version = StuffClassifier::VERSION
    
    @name = name

    # This values are nil or are loaded from storage
    @word_list = {}
    @category_list = {}
    @training_count=0

    # storage
    purge_state = opts[:purge_state]
    @storage = opts[:storage] || StuffClassifier::Base.storage
    unless purge_state
      @storage.load_state(self)
    else
      @storage.purge_state(self)
    end

    # This value can be set during initialization or overrided after load_state
    @thresholds = opts[:thresholds] || {}
    @min_prob = opts[:min_prob] || 0.0
    

    @ignore_words = nil
    @tokenizer = StuffClassifier::Tokenizer.new(opts)
    
  end

  def incr_word(word, category)
    @word_list[word] ||= {}

    @word_list[word][:categories] ||= {}
    @word_list[word][:categories][category] ||= 0
    @word_list[word][:categories][category] += 1

    @word_list[word][:_total_word] ||= 0
    @word_list[word][:_total_word] += 1

  
    # words count by categroy
    @category_list[category] ||= {}
    @category_list[category][:_total_word] ||= 0
    @category_list[category][:_total_word] += 1

  end

  def incr_cat(category)
    @category_list[category] ||= {}
    @category_list[category][:_count] ||= 0
    @category_list[category][:_count] += 1

    @training_count ||= 0
    @training_count += 1 

  end

  # return number of times the word appears in a category
  def word_count(word, category)
    return 0.0 unless @word_list[word] && @word_list[word][:categories] && @word_list[word][:categories][category]
    @word_list[word][:categories][category].to_f
  end

  # return the number of times the word appears in all categories
  def total_word_count(word)
    return 0.0 unless @word_list[word] && @word_list[word][:_total_word]
    @word_list[word][:_total_word].to_f
  end

  # return the number of words in a categories
  def total_word_count_in_cat(cat)
    return 0.0 unless @category_list[cat] && @category_list[cat][:_total_word]
    @category_list[cat][:_total_word].to_f
  end

  # return the number of training item 
  def total_cat_count
    @training_count
  end
  
  # return the number of training document for a category
  def cat_count(category)
    @category_list[category][:_count] ? @category_list[category][:_count].to_f : 0.0
  end

  # return the number of time categories in wich a word appear
  def categories_with_word_count(word)
    return 0 unless @word_list[word] && @word_list[word][:categories]
    @word_list[word][:categories].length 
  end  

  # return the number of categories
  def total_categories
    categories.length
  end

  # return categories list
  def categories
    @category_list.keys
  end

  # train the classifier
  def train(category, text)
    @tokenizer.each_word(text) {|w| incr_word(w, category) }
    incr_cat(category)
  end

  def train_file(file)
    File.open("public/"+file, "r").each_line do |line|
      tokens = line.split(" ")
      word = tokens[0]
      value = tokens[1]

      if value == "-4"
        category = "negative4"
      elsif value == "-3"
        category = "negative3"
      elsif value == "-2"
        category = "negative2"
      elsif value == "-1"
        category = "negative1"
      elsif value == "1"
        category = "positive1"
      elsif value == "2"
        category = "positive2"
      elsif value == "3"
        category = "positive3"
      elsif value == "4"
        category = "positive4"
      else
        category = "neutro"
      end

      #puts category + " - " + word
      train(category, word)
    end
  end

  def train_negative()
    File.open("public/tweets-negatives.txt", "r").each_line do |line|
      train("negative", line)
    end
  end

  def train_positive()
    File.open("public/tweets-positives.txt", "r").each_line do |line|
      train("positive", line)
    end
  end

  # classify a text
  def classify(text, default=nil)
    # Find the category with the highest probability
    max_prob = @min_prob
    prob1 = @min_prob
    prob2 = @min_prob
    best = nil
    margin = 0.05
    diff_prob = 0

    scores = cat_scores(text)
    scores.each do |score|
      cat, prob = score
       # puts prob
       # puts ">"
       # puts max_prob
       # puts ""

      # if prob > max_prob
      #   max_prob = prob
      #   best = cat
      #    puts cat
      # end


      # ---------------------------------------------------


      # if cat == "positive"
      #   max_prob += prob
      # elsif cat == "negative"
      #   max_prob -= prob
      # end

      # puts "max_prob:" + max_prob

      # margin_prob = margin * max_prob
      # n_prob = Math.sqrt(margin_prob ** 2)

      # puts "n_prob:" + n_prob

      # if max_prob > 0
      #   best = "positive"
      # elsif max_prob < 0
      #   best = "negative"
      # elsif max_prob == 0
      #   best = "neutro"
      # end

      # ----------------------------------------------------

      if cat == "positive"
        prob1 += prob
      elsif cat == "negative"
        prob2 += prob
      end

      puts "prob1:" + prob1.to_s
      puts "prob2:" + prob2.to_s

      margin_prob1 = margin * prob1
      margin_prob2 = margin * prob2
      diff_prob = Math.sqrt((prob1 - prob2) ** 2)

      puts "margin1:" + margin_prob1.to_s
      puts "margin2:" + margin_prob2.to_s
      puts "diff_prob:" + diff_prob.to_s

      if prob1 > prob2
        best = "positive"
      end
      if prob1 < prob2
        best = "negative"
      end
      
      if prob1 == prob2 or (diff_prob < margin_prob1 and diff_prob < margin_prob2)
        best = "neutro"
      end
       # puts ""
    end

    # Return the default category in case the threshold condition was
    # not met. For example, if the threshold for :spam is 1.2
    #
    #    :spam => 0.73, :ham => 0.40  (OK)
    #    :spam => 0.80, :ham => 0.70  (Fail, :ham is too close)

    return default unless best
    #return best

    threshold = @thresholds[best] || 1.0

    # puts threshold
    # puts "TT"

    # scores.each do |score|
    #   cat, prob = score
    #   next if cat == best
    #   return default if prob * threshold > max_prob
    # end

    return best    
  end

  def save_state
    @storage.save_state(self)
  end

  class << self
    attr_writer :storage

    def storage
      @storage = StuffClassifier::InMemoryStorage.new unless defined? @storage
      @storage
    end

    def open(name)
      inst = self.new(name)
      if block_given?
        yield inst
        inst.save_state
      else
        inst
      end
    end
  end
end
