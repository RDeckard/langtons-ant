class Settings < RDDR::GTKObject
  def initialize
    @menu = RDDR::Menu.new(prompts: prompts)
  end

  def tick
    next_scene if @menu.call == :done

    return if @menu.updated_labels.empty?

    outputs.static_primitives.clear
    outputs.static_primitives << @menu.updated_labels
    outputs.static_primitives << [
      {
        x: grid.left.shift_right(5), y: grid.top.shift_down(25),
        text: "",
        size_enum: 2
      }.label!,
      {
        x: grid.left.shift_right(5), y: grid.bottom.shift_up(25),
        text: "Right click/ESCAPE: Previous/exit",
        size_enum: 2
      }.label!,
      {
        x: grid.right.shift_left(5), y: grid.bottom.shift_up(25),
        text: "Click/ENTER: Next",
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
      RDDR::Prompt.new(
        title:         "Grid width:",
        description:   "What is the size of the grid?" +
                       "\n\nPossible values: the height will be computed with a 16/9 ratio, and both must be integers.",
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

                               [true, "Grid height: #{screen_height} (#{ok ? "OK" : "KO"})"]
                             else
                               [false, "Integer only (for both)!"]
                             end
                           end
      ),
      RDDR::Prompt.new(
        title:         "Color rules:",
        description:   "Rules of movement of the ant?" +
                       "\n(The number of colors will match with the number of rules.)" +
                       "\n\nPossible values: from 2 to 16 rules," +
                       %(\n"R" for Right, "L" for Left, "U" for u-turn, "N" for "keep going".) +
                       %(\nE.g.: "RLR" means "Turn Right on the 1st color, Left on the 2nd and Right on the 3rd".),
        default_value: state.game_params.color_rules.to_s,
        validation:    lambda do |input|
                         input = input.upcase
                         return unless input.delete("LRNU").size.zero? && input.size >= 2 && input.size <= 16

                         state.game_params.color_rules      = input
                         state.game_params.number_of_colors = input.size
                         true
                       end,
        continuous_action: lambda do |input|
                             if input.size < 2
                               [true, "Too few rules (< 2)"]
                             elsif input.size > 16
                               [false, "Too many rules (> 16)"]
                             elsif !["R", "L", "N", "U", nil].include?(input[-1]&.upcase)
                               [false, %("#{input[-1]}" isn't a valid rule, please choose "R", "L", "N" or "U".)]
                             else
                               classic = input.size == 2 && input.chars.sort.join == "LR"
                               [true, "#{input.size} colors#{" (classic mode)" if classic }"]
                             end
                           end
      ),
      RDDR::Prompt.new(
        title:         "Start direction:",
        description:   %(Which direction does the Ant face at first?) +
                       %(\n\nPossible values: "up", "down", "left" or "right"),
        default_value: state.game_params.start_direction.to_s,
        validation:    lambda do |input|
                         input = input.downcase
                         return unless %w[up down left right].include?(input)

                         state.game_params.start_direction = input
                         true
                       end
      ),
      RDDR::Prompt.new(
        title:         "Steps per second:",
        description:   "How many steps per second should the ant execute?" +
                       "\n\nPossible values: from 1 to 60, or multiple of 60 for high speed." +
                       "\n(Very high values like 6000 or 12000 are perfectly acceptable.)",
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
      RDDR::Prompt.new(
        title:         "Out of bound policy:",
        description:   "What the ant should do when it get out of the screen?" +
                       %(\n\nPossible values: "backward", "warp" (on the other side) or "stop"),
        default_value: state.game_params.out_of_bound_policy.to_s,
        validation:    lambda do |input|
                         input = input.downcase
                         return unless %w[backward warp stop].include?(input)

                         state.game_params.out_of_bound_policy = input
                         true
                       end
      ),
      RDDR::Prompt.new(
        title:         "Color set:",
        description:   "Which color set will be used?" +
                       "\n\nPossible values: classic, c64 (Commodore 64 color palette) or random." +
                       %(\n("random" will also scramble the colors order, except white and black.)),
        default_value: state.game_params.color_set.to_s,
        validation:    lambda do |input|
                         input = input.downcase
                         return unless %w[random classic c64].include?(input)

                         state.game_params.color_set = input
                         true
                       end
      ),
      RDDR::Prompt.new(
        title:         "Grid visibility:",
        description:   "Should the grid be visible?" +
                       "\n\nPossible values: enable, disable",
        default_value: state.game_params.grid_visibility.to_s,
        validation:    lambda do |input|
                         input = input.downcase
                         return unless %w[enable disable].include?(input)

                         state.game_params.grid_visibility = input
                         true
                       end
      )
    ]
  end
end
