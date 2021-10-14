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

    return_game if inputs.keyboard.key_down.enter || inputs.mouse.click
  end

  def text_lines
    [
      "PAUSE",
      "--- Shortcuts ---",
      "Toggle fullscreen: Alt+F",
      "Pause: Click or ENTER",
      "Reset: Alt+R",
      "Quit: Alt+Q",
      "--- Configuration ---",
      "Screen size: #{state.game_params.screen_size}",
      "Number of colors: #{state.game_params.number_of_colors}",
      "Color rules: #{state.game_params.color_rules}",
      "Start direction: #{state.game_params.start_direction}",
      "Step per second: #{state.game_params.steps_per_sec}",
      "Out of bound policy: #{state.game_params.out_of_bound_policy}",
      "Color palette: #{state.game_params.color_palette}"
    ]
  end

  def render
    outputs.primitives << grid.rect.to_hash.sprite!(path: :cells_grid)

    return if @render

    outputs.static_primitives << @text_box.primitives

    @render = true
  end

  def return_game
    state.current_scene = state.last_scene
  end
end
