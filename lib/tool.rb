class Tool
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

  def grid
    @grid ||= gtk.args.grid
  end
end
