class Image < ActiveRecord::Base
  belongs_to :project
  def url
    File.join(project.dir, path)
  end
  def thumb_url
    File.join(project.thumbs_dir, path)
  end
end
