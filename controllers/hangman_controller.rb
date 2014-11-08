class HangmanController < ApplicationController

	helpers Sinatra::HangmanglerHelper

	get '/game' do
		@current_game = current_user.hangmen.where(complete: false).first
		if @current_game != nil
			hangman_word = @current_game.word.word
			@game_state = @current_game.game_state
			@incorrect_guesses = @current_game.incorrect_guesses
		end
		erb :'hangman/index'
	end


  post '/game' do
  	hangman_word = Word.limit(1).order("RANDOM()")[0] ## Doesn't work well with large data, ##refactor##
  	## better than Word.all.sample though.
  	@game_state = create_game_state(hangman_word.word)
  	if current_user.hangmen.where(complete: false).first.nil?
  	  new_game = Hangman.create(word: hangman_word, user: current_user, game_state: @game_state, complete: false)
  	end
  end
  

  patch '/game' do

  	guess = params["guess"]
  	@current_game = current_user.hangmen.where(complete: false).first

  	if @current_game != nil
  	  hangman_word = @current_game.word.word
  	  game_state = @current_game.game_state
  	  incorrect_guesses = @current_game.incorrect_guesses
  	  @incorrect_guesses = update_incorrect_guesses(incorrect_guesses, guess, hangman_word)
  	  @game_state = update_game_state(params["guess"], hangman_word, game_state)

  	  params[:data] ||= {}
  	  params[:data][:user_id] = current_user.id
  	  params[:data][:game_state] = @game_state
  	  params[:data][:incorrect_guesses] = @incorrect_guesses
  	  params[:data][:complete] = true if @incorrect_guesses.length == 6

  	  updated_hangman = Hangman.update(@current_game.id, params[:data])
    end
    erb :'hangman/index'
  end



end























