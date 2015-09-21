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
    ##########
    # Ratings
    ##########

    # get all possible movie ratings
    @all_ratings = get_ratings

    # by default do not redirect
    redirect = false

    # get requested ratings
    if !params[:ratings].nil? then # rating is given in parameters
      # use rating from parameters
      @selected_ratings = params[:ratings]

      # if it is a hash, take only keys (we do not need the rest)
      if @selected_ratings.is_a?(Hash) then
        @selected_ratings = @selected_ratings.keys
      end
    elsif !session[:ratings].nil? then # rating is given in session
      # load rating from session
      @selected_ratings = session[:ratings]

      # redirect to show ratings in the address
      redirect = true
    else # no rating given
      # use default rating (show all ratings)
      @selected_ratings = @all_ratings

      # redirect to show ratings in the address
      redirect = true
    end

    # save current ratings setting to session
    session[:ratings] = @selected_ratings

    ##########
    # Sort by
    ##########

    # get the name of the column by which to order
    if  !params[:sort_by].nil? then # sort by is given in parameters
      # use sort by from parameters
      sort_by = params[:sort_by]
    elsif !session[:sort_by].nil? then # sort by is given in session
      # load sort by from session
      sort_by = session[:sort_by]

      # redirect to show ratings in the address
      redirect = true
    else # no sort by is given
      # use default sort by (sort by id)
      sort_by = 'id'

      # redirect to show ratings in the address
      redirect = true
    end

    # save current sort by setting to session
    session[:sort_by] = sort_by

    ##########################
    # Redirect, model, hilite
    ##########################

    # redirect if necessary
    if redirect then
      # save flash
      flash.keep

      # redirect to preserve REST
      redirect_to movies_path({ :sort_by => sort_by, :ratings => @selected_ratings})
    end

    # get movies with given ratings and sort them using given sort by
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
