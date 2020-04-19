class TagsController < ApplicationController

  def index
    @tags = Tag.all
    render :json => @tags.to_json(:only => [:value])
  end

end
