class Admin::VideosController < ApplicationController
  before_action :require_user
  before_action :require_admin

  def new
    @video = Video.new
  end

  def create
    @video = Video.create(video_params)
    if @video.save
      flash[:success] = "Sucessfully added the video '#{@video.title}'."
      redirect_to new_admin_video_path
    else
      flash[:danger] = "Something went wrong while trying to create this video."
      render :new
    end
  end

  def require_admin
    if !current_user.admin?
      flash[:danger] = "You are not authorized to do that."
      redirect_to home_path
    end
  end

  private

  def video_params
    params.require(:video).permit(:title, :description, :category_id, :large_cover, :small_cover)
  end
end
