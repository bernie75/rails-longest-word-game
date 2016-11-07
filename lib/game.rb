require 'open-uri'
require 'json'

def generate_grid(grid_size)
  # TODO: generate random grid of letters
  grid = []
  grid << ("A".."Z").to_a.sample until grid.size == grid_size
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
