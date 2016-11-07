require "game"

class GamesController < ApplicationController
  def game #calcule la grille
    @grid= generate_grid(20).join("")
    @start = Time.now
  end
  def score #recupere l'attempt#calculer le score
    @attempt = params[:attempt]
    @grid = params[:grid]
    @result = run_game(@attempt, @grid.split(" "), Time.parse(params[:start]), Time.now) #le mettre dans une variable d'instance
  end
private
  def generate_grid(grid_size)
  # TODO: generate random grid of letters
  grid = []
  grid << ("A".."V").to_a.sample until grid.size == grid_size
  grid
end

def run_game(attempt, grid, start_time, end_time)
  # TODO: runs the game and return detailed hash of result
  h = {
    score: 0,
    time: end_time - start_time,
    translation: nil,
    message: ""
  }
  tmp_grid = grid.dup
  response = open("http://api.wordreference.com/0.8/80143/json/enfr/#{attempt.downcase}")
  data_h = JSON.parse(response.read)
  if data_h.key?("Error")
    h[:message] = "not an english word"
    return h
  end
  attempt.upcase!.split("").each do |letter|
    if !tmp_grid.include?(letter)
      h[:message] = "not in the grid"
      return h
    else
      tmp_grid.delete_at(tmp_grid.find_index(letter))
    end
  end
  h[:score] += (attempt.size.to_f / grid.size) * 10 + ((1.0 / h[:time]) * 500)
  h[:message] = "well done"
  h[:translation] = data_h["term0"]["PrincipalTranslations"]["0"]["FirstTranslation"]["term"]
  h
end

end
