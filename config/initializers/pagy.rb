# config/initializers/pagy.rb
require 'pagy/extras/bootstrap'
require 'pagy/extras/overflow'

Pagy::DEFAULT[:items] = 20 # Nombre d'éléments par page (ajustez selon vos besoins)
