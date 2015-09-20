class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    # get all possible movie ratings
    @all_ratings = get_ratings

    # get selected ratings
    ratings = params[:ratings]

    # if no rating is selected, display all ratings, else display only those ratings selected
    if (ratings.nil?) then
      @selected_ratings = @all_ratings
    else
      @selected_ratings = ratings.keys
    end


    # get the name of the column by which to order
    sort_by = params[:sort_by]

    # if no column is given, do default ordering, else order by that column
    if sort_by.nil? then
      # default ordering
      sort_by = "id"
    end

    # order by selected column
    @movies = Movie.where(:rating => @selected_ratings).order("movies.#{sort_by} ASC")

    # hilite particular column
    instance_variable_set('@css_' + sort_by, 'hilite')

  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

  private
  def get_ratings
    # unique ratings from the Movie model
    Movie.uniq.pluck(:rating)
  end
end
