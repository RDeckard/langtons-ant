class Tool
  include Serializable

  private

  def gtk
    $gtk
  end

  def state
    gtk.args.state
  end

  def inputs
    gtk.args.inputs
  end

  def grid
    gtk.args.grid
  end
end
