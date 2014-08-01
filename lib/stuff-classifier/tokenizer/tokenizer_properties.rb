# encoding: utf-8
require 'set'
StuffClassifier::Tokenizer::TOKENIZER_PROPERTIES = {
  "pt" => {
    :stop_word => Set.new([
     'a', 'à', 'acerca', 'agora', 'alguns', 'algum', 'algumas', 'às','ao', 'aos', 'as', 'ate', 'até', 'ateh', 
     'c', 'cima', 'com', 'como', 
     'd', 'da', 'das', 'de', 'dele', 'deles', 'depois', 'deverá', 'devera', 'direita', 'do', 'dos', 
     'e', 'e', 'é', 'eh', 'ela', 'elas', 'ele', 'eles', 'em', 'enquanto', 'entre', 'era', 'essa', 'essas', 'esse', 'esses', 'este', 'estes', 'está', 'estao', 'estão', 'eu', 
     'f', 'foi', 'foram', 'fosse',
     'h', 'há', 'havia', 'horas', 
     'i', 'inicio', 'ir', 'isso', 'isto',
     'j', 'ja', 'já', 'jah',
     'k',
     'l', 'lhe',
     'm', 'mai', 'mas', 'mais', 'maioria', 'me', 'mesmo', 'meu', 'minha', 'muito', 
     'n', 'na', 'nao', 'não', 'naum', 'nas', 'nem', 'no', 'nois', 'nós', 'nos', 'nosso', 'num', 'numa', 
     'o', 'os', 'ou', 
     'p', 'pa', 'para', 'parte', 'pela', 'pelas', 'pelo', 'pelos', 'pode', 'por', 'porque', 'povo',
     'q', 'qual', 'quando', 'que', 'quem', 
     's', 'sao', 'são', 'se', 'seja', 'sem', 'ser', 'será', 'seu', 'seus', 'só', 'soh', 'somente', 'sua', 'suas', 
     't', 'tambem', 'também', 'tem', 'têm', 'tempo', 'tenho', 'tentar', 'ter', 'tinha', 'tmb', 'to', 'todo', 'todos', 'tu',
     'u', 'último', 'ultimo', 'um', 'uma', 'uns', 'usa', 'usar',
     'v', 'ver', 'veja', 'verdade', 'verdadeiro', 'vc', 'voce', 'você'           
    ])
  }
}