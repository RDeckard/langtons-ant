class Model
  include Serializable

  private

  def grid
    @grid ||= $gtk.args.grid
  end
end
