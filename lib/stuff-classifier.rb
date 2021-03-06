# Este código foi extraido em grande parte através do GitHUB https://github.com/alexandru/stuff-classifier
# e adaptado por Pedro Grandin

module StuffClassifier

  autoload :Storage, 'stuff-classifier/storage'
  autoload :InMemoryStorage, 'stuff-classifier/storage'
  autoload :FileStorage,     'stuff-classifier/storage'
  autoload :RedisStorage, 'stuff-classifier/storage'

  autoload :Tokenizer,  'stuff-classifier/tokenizer'
  autoload :TOKENIZER_PROPERTIES, 'stuff-classifier/tokenizer/tokenizer_properties'

  autoload :Base,       'stuff-classifier/base'
  autoload :Bayes,      'stuff-classifier/bayes'

end
