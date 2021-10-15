class Pause < GTKObject
  def initialize(current_step:)
    @current_step = current_step
    @text_box = TextBox.new(text_lines, box_alignment: :right, box_alignment_v: :top, text_alignment: :right)
  end

  def tick
    outputs.labels << {
      x: grid.right.shift_left(5), y: grid.bottom.shift_up(25),
      text: "current step: #{@current_step}",
      size_enum: 2,
      alignment_enum: 2
    }.label!

    render

    return_to_game     if inputs.keyboard.key_down.enter || inputs.mouse.click
    return_to_settings if inputs.keyboard.key_down.escape
  end

  def text_lines
    [
      "PAUSE",
      "",
      "--- Shortcuts ---",
      "Pause: Click or ENTER",
      "Change settings: ESCAPE",
      "",
      "Toggle fullscreen: Alt+F",
      "Reset: Alt+R",
      "Quit: Alt+Q",
      "",
      "--- Configuration ---",
      "Grid width: #{state.game_params.screen_size}",
      "Number of colors: #{state.game_params.number_of_colors}",
      "Color rules: #{state.game_params.color_rules}",
      "Start direction: #{state.game_params.start_direction}",
      "Steps per second: #{state.game_params.steps_per_sec}",
      "Out of bound policy: #{state.game_params.out_of_bound_policy}",
      "Color set: #{state.game_params.color_set}"
    ]
  end

  def render
    outputs.primitives << grid.rect.to_hash.sprite!(path: :cells_grid)

    return if @render

    outputs.static_primitives << @text_box.primitives

    @render = true
  end

  def return_to_game
    state.current_scene = state.last_scene
  end

  def return_to_settings
    state.current_scene = Settings.new
  end
end
