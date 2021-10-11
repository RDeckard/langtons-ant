class ConfMenu < Scene
  def initialize
    @menu = Menu.new(prompts: prompts)
  end

  def tick
    next_scene if @menu.call == :done

    return if @menu.updated_labels.empty?

    outputs.static_primitives.clear
    outputs.static_primitives << @menu.updated_labels
    outputs.static_primitives << [
      {
        x: grid.left.shift_right(5), y: grid.bottom.shift_up(25),
        text: "ESCAPE: Previous",
        size_enum: 2
      }.label!,
      {
        x: grid.right.shift_left(5), y: grid.bottom.shift_up(25),
        text: "ENTER: Next",
        size_enum: 2,
        alignment_enum: 2
      }.label!
    ]
  end

  def next_scene
    outputs.static_primitives.clear

    state.current_scene = CustomizeCells.new
  end

  def prompts
    @prompts ||= [
      Prompt.new(
        title:         "Screen width:",
        description:   "In pixels, the height will be computed with a 16/9 ratio.",
        default_value: state.game_params.screen_size.to_s,
        validation:    lambda do |input|
                         input = Integer(input) rescue nil
                         return unless input && ((input * 9/16) % 1).zero?

                         state.game_params.screen_size = input
                         true
                       end,
        continuous_action: lambda do |input|
                             input = Integer(input) rescue nil

                             if input
                               screen_height = input * 9/16
                               ok            = (screen_height % 1).zero?
                               screen_height = screen_height.to_i if ok

                               [true, "Screen height: #{screen_height} (#{ok ? "OK" : "KO"})"]
                             else
                               [false, "Integer only (for both)!"]
                             end
                           end
      ),
      Prompt.new(
        title:         "Nb of colors:",
        description:   "from 2 to 16",
        default_value: state.game_params.number_of_colors.to_s,
        validation:    lambda do |input|
                         input = Integer(input) rescue nil
                         return unless input && input >= 2 && input <= 16

                         state.game_params.number_of_colors = input
                         true
                       end,
        continuous_action: lambda do |input|
                             input = Integer(input) rescue nil

                             input ? true : [false, "Numbers only!"]
                           end
      ),
      Prompt.new(
        title:         "Color rules:",
        description:   %(R for Right, L for Left, U for U turn, N for "keep going".) +
                       %(\nE.g.: "RLR" means "Turn Right on the 1st color, Left on the 2nd, etc.),
        default_value: state.game_params.color_rules.to_s,
        validation:    lambda do |input|
                         input = input.upcase
                         return unless input.delete("LRNU").size.zero? && input.size == state.game_params.number_of_colors

                         state.game_params.color_rules = input
                         true
                       end,
        continuous_action: lambda do |input|
                             number_of_colors = state.game_params.number_of_colors

                             if input.size > number_of_colors
                               [false, "Too many rules (> #{number_of_colors})"]
                             elsif !["R", "L", "N", "U", nil].include?(input[-1]&.upcase)
                               [false, %("#{input[-1]}" isn't a valid rule, please choose "R", "L", "N" or "U".)]
                             else
                               [true, "#{input.size}/#{number_of_colors}"]
                             end
                           end
      ),
      Prompt.new(
        title:         "Start direction:",
        description:   "up, down, left or right",
        default_value: state.game_params.start_direction.to_s,
        validation:    lambda do |input|
                         input = input.downcase
                         return unless %w[up down left right].include?(input)

                         state.game_params.start_direction = input
                         true
                       end
      ),
      Prompt.new(
        title:         "Step per second:",
        description:   "from 1 to 60, or multiple of 60 for high speed.",
        default_value: state.game_params.steps_per_sec.to_s,
        validation:    lambda do |input|
                         input = Integer(input) rescue nil
                         return unless input && (input.between?(1, 60) || (input % 60).zero?)

                         state.game_params.steps_per_sec = input
                         true
                       end,
        continuous_action: lambda do |input|
                             input = Integer(input) rescue nil

                             input ? true : [false, "Numbers only!"]
                           end
      ),
      Prompt.new(
        title:         "Out of bound policy:",
        description:   "What the ant should do when it get out of the screen?" +
                       %(\n"backward", "warp" (on the other side) or "stop"),
        default_value: state.game_params.out_of_bound_policy.to_s,
        validation:    lambda do |input|
                         input = input.downcase
                         return unless %w[backward warp stop].include?(input)

                         state.game_params.out_of_bound_policy = input
                         true
                       end
      ),
      Prompt.new(
        title:         "Color palette:",
        description:   "random, classic or c64 (Commodore 64 color palette)." +
                       %(\n"random" will also scramble the colors order (except white and black)),
        default_value: state.game_params.color_palette.to_s,
        validation:    lambda do |input|
                         input = input.downcase
                         return unless %w[random classic c64].include?(input)

                         state.game_params.color_palette = input
                         true
                       end
      )
    ]
  end
end
