module AcademiesHelper
  def display_academy_image(academy)
    if academy.image.attached?
      cl_image_path(academy.image.key, quality: :auto)
    else
      asset_path('home.jpg')
    end
  end
end
