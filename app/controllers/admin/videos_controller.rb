class Admin::VideosController < AdminsController
  before_action :require_user

  def new
    @video = Video.new
  end

  def create
    @video = Video.new(video_params)
    if @video.save
      flash[:success] = "Sucessfully added the video '#{@video.title}'."
      redirect_to new_admin_video_path
    else
      flash[:danger] = "Something went wrong while trying to create this video."
      render :new
    end
  end

  private

  def video_params
    params.require(:video).permit(:title, :description, :category_id, :large_cover, :small_cover, :video_url)
  end
end
