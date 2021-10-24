class TitleScreen < RDDR::GTKObject
  ANT_IMAGE = "assets/images/ant.png".freeze

  def initialize
    @text_box = RDDR::TextBox.new(text_lines, frame_alignment_v: grid.top.shift_down(grid.h/3), text_alignment: :center)

    @start_button =
      RDDR::Button.new(text: "Start", y: grid.bottom.shift_up(grid.h/6), w: grid.w/4, text_size: 4)
    @start_button.x = geometry.center_inside_rect_x(@start_button.frame, grid.rect).x

    ant_space = { x: grid.left,  y: @start_button.frame.top,
                  w: grid.right, h: @text_box.frame.bottom - @start_button.frame.top }
    @ant = { path: ANT_IMAGE, w: 128, h: 128 }.sprite!
    @ant.merge!(geometry.center_inside_rect(@ant, ant_space))
  end

  def tick
    render

    handler_inputs
  end

  def handler_inputs
    @start_button.handler_inputs { next_scene }

    next_scene if inputs.keyboard.key_down.enter
  end

  def render
    return if @render

    outputs.static_primitives.clear

    outputs.static_primitives << @text_box.primitives
    outputs.static_primitives << @start_button.primitives
    outputs.static_primitives << @ant

    outputs.static_primitives << [
      {
        x: grid.left.shift_right(5), y: grid.bottom.shift_up(65),
        text: "By RDeckard",
        r: 128, g: 128, b: 128
      }.label!,
      {
        x: grid.left.shift_right(5), y: grid.bottom.shift_up(45),
        text: "GitHub: https://github.com/RDeckard/langtons-ant/",
        r: 128, g: 128, b: 128
      }.label!,
      {
        x: grid.left.shift_right(5), y: grid.bottom.shift_up(25),
        text: "itch.io: https://rdeckard.itch.io/langtons-ant",
        r: 128, g: 128, b: 128
      }.label!,
      {
        x: grid.right.shift_left(5), y: grid.bottom.shift_up(25),
        text: "ENTER: Start",
        size_enum: 2,
        alignment_enum: 2
      }.label!
    ]

    @render = true
  end

  def text_lines
    [
      "LANGTON'S ANT",
      "",
      "--- Shortcuts ---",
      "Toggle fullscreen: Alt+F",
      "Reset: Alt+R",
      "Quit: Alt+Q",
    ]
  end

  def next_scene
    outputs.static_primitives.clear

    state.current_scene = Settings.new
  end
end
