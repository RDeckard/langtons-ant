class TitleScreen < RDDR::GTKObject
  ANT_IMAGE = "assets/images/ant.png".freeze

  def initialize
    @text_box = RDDR::TextBox.new(text_lines, box_alignment_v: grid.top.shift_down(grid.h/3), text_alignment: :center)

    @start_button =
      RDDR::Button.new(text: "Start", rect: { y: grid.bottom.shift_up(grid.h/4), w: grid.w/4 }, text_size: 4)
    @settings_button =
      RDDR::Button.new(text: "Settings", rect: { y: grid.bottom.shift_up(grid.h/7), w: grid.w/4 }, text_size: 4)
    @settings_button.rect.x = @start_button.rect.x = Geometry.center_inside_rect_x(@start_button.rect, grid.rect).x

    ant_space = { x: grid.left,  y: @start_button.rect.top,
                  w: grid.right, h: @text_box.rect.bottom - @start_button.rect.top }
    @ant = { path: ANT_IMAGE, w: 128, h: 128 }.sprite!
    @ant.merge!(Geometry.center_inside_rect(@ant, ant_space))
  end

  def tick
    render

    handle_inputs
  end

  def handle_inputs
    @start_button.handle_inputs { start }
    @settings_button.handle_inputs { settings }

    start if inputs.keyboard.key_down.enter
  end

  def render
    return if @render

    outputs.static_primitives.clear

    outputs.static_primitives << @text_box.primitives
    outputs.static_primitives << @start_button.primitives
    outputs.static_primitives << @settings_button.primitives
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
        x: grid.right.shift_left(5), y: grid.bottom.shift_up(45),
        text: "ENTER: Start",
        alignment_enum: 2
      }.label!,
      {
        x: grid.right.shift_left(5), y: grid.bottom.shift_up(25),
        text: "ESCAPE: Settings",
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

  def start
    outputs.static_primitives.clear

    state.current_scene = CustomizeCells.new
  end

  def settings
    outputs.static_primitives.clear

    state.current_scene = Settings.new
  end
end
