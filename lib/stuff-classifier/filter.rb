# encoding: utf-8

require 'set'

StuffClassifier::Filter = {
    :trash_word => Set.new([
	 'olá', 'oi', 'oie', 'tchau', 'adeus', 'xau', 'chau',
	 'comer', 'comendo', 'comi', 
     'caramba',
     'eita',
     'ish',
     'ne', 'né', 'neh',
     'vish', 'pqp', 
     'lol', 'LOL', 'Lol',
     'menino', 'menina', 'homem', 'mulher',
     'amanha', 'amanhã', 'ontem',
     'manhã', 'tarde', 'noite',
     'um', 'dois', 'tres', 'três', 'quatro', 'cinco', 'seis', 'sete', 'oito', 'nove', 'dez'
    ])
}