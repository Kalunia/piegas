# Este código foi inspirado através do GitHUB https://github.com/alexandru/stuff-classifier
# e adaptado por Pedro Grandin

# encoding: utf-8

require 'set'
StuffClassifier::Tokenizer::TOKENIZER_PROPERTIES = {
  "pt" => {
    :stop_word => Set.new([
     'a', 'à', 'acerca', 'agora', 'alguns', 'algum', 'algumas', 'às','ao', 'aos', 'as', 'asim', 'assim', 'ate', 'até', 'ateh', 
     'c', 'cima', 'co', 'com', 'como', 
     'd', 'da', 'das', 'de', 'dele', 'deles', 'depois', 'deverá', 'devera', 'direita', 'do', 'dos', 
     'e', 'e', 'é', 'eh', 'ela', 'elas', 'ele', 'eles', 'em', 'enquanto', 'entre', 'era', 'essa', 'esa', 'essas', 'esas', ' esse', 'ese', 'esses', 'eses', 'este', 'estes', 'está', 'estao', 'estão', 'eu', 
     'f', 'foi', 'foram', 'fosse',
     'h', 'há', 'havia', 'horas', 'http', 'htp', 'https', 'htps',
     'i', 'inicio', 'ir', 'isso', 'isto',
     'j', 'ja', 'já', 'jah',
     'k',
     'l', 'lhe',
     'm', 'mai', 'mas', 'mais', 'maioria', 'me', 'mesmo', 'meu', 'minha', 'muito', 
     'n', 'na', 'nao', 'não', 'naum', 'nas', 'nem', 'no', 'nois', 'nós', 'nos', 'noso', 'nosso', 'num', 'numa', 
     'o', 'os', 'ou', 
     'p', 'pa', 'para', 'parte', 'pela', 'pelas', 'pelo', 'pelos', 'pode', 'por', 'porque', 'povo', 'pq',
     'q', 'qual', 'quando', 'que', 'quem', 'quero',
     's', 'sao', 'são', 'se', 'seja', 'sem', 'ser', 'será', 'seu', 'seus', 'só', 'soh', 'somente', 'sua', 'suas', 
     't', 'tambem', 'também', 'tem', 'têm', 'tempo', 'tenho', 'tentar', 'ter', 'tinha', 'tmb', 'to', 'todo', 'todos', 'tu',
     'u', 'último', 'ultimo', 'um', 'uma', 'uns', 'usa', 'usar',
     'v', 'ver', 'veja', 'verdade', 'verdadeiro', 'vc', 'voce', 'você', 'vs'           
    ])
  }
}