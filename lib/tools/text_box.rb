class TextBox < Tool
  def initialize(text_lines, text_size: 0, text_alignment: :left, offset: 5)
    @text_lines     = text_lines
    @text_size      = text_size
    @text_alignment = text_alignment
    @offset         = offset
  end

  def primitives
    return @primitives if @primitives

    @primitives = []

    box_w, line_h = @text_lines.map { |text| gtk.calcstringbox(text, @text_size) }.max_by(&:first)
    box_w += @offset*2
    line_h += @offset
    box_h = @offset + @text_lines.size*line_h

    @primitives << {
      x: grid.right.shift_left(@offset + box_w),
      y: grid.top.shift_down(@offset + box_h),
      w: box_w, h: box_h,
      a: 128
    }.solid!

    @primitives << @text_lines.map.with_index do |text, index|
      {
        x: grid.right.shift_left(@offset*2),
        y: grid.top.shift_down(@offset*2 + line_h*index),
        text: text,
        size_enum: @text_size,
        alignment_enum: %i[left center right].index(@text_alignment),
        r: 255, g: 255, b: 255
      }.label!
    end

    @primitives
  end
end
