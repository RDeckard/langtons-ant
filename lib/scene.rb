class Scene
  include Serializable

  private

  def gtk
    @gtk ||= $gtk
  end

  def state
    @state ||= gtk.args.state
  end

  def inputs
    @inputs ||= gtk.args.inputs
  end

  def outputs
    @outputs ||= gtk.args.outputs
  end

  def grid
    @grid ||= gtk.args.grid
  end
end
