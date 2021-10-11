class Scene
  include Serializable

  private

  def gtk
    $gtk
  end

  def state
    $gtk.args.state
  end

  def inputs
    $gtk.args.inputs
  end

  def outputs
    $gtk.args.outputs
  end

  def grid
    $gtk.args.grid
  end
end
