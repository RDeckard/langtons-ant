class Model
  include Serializable

  private

  def grid
    $gtk.args.grid
  end
end
