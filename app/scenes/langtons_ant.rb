class LangtonsAnt < Scene
  def initialize(cells_grid)
    @cells_grid = cells_grid

    puts_stats

    @step = 0

    @steps_per_sec  = state.game_params.steps_per_sec
    @ticks_per_move = 60.div(@steps_per_sec)

    @ant = Ant.new(
      @cells_grid.width.div(2), @cells_grid.height.div(2),
      @cells_grid,
      state.game_params
    )

    @out_of_bound_policy = state.game_params.out_of_bound_policy.to_sym
  end

  def tick
    pause if inputs.keyboard.key_down.enter || inputs.mouse.click

    outputs.static_debug.clear
    outputs.static_debug << [
      {
        x: grid.left.shift_right(5), y: grid.top.shift_down(5),
        text: "current FPS: #{gtk.current_framerate.round}",
        size_enum: 2,
        r: 255, g: 0, b: 0
      }.label!,
      {
        x: grid.left.shift_right(5), y: grid.top.shift_down(25),
        text: "current step: #{@step}",
        size_enum: 2,
        r: 255, g: 0, b: 0
      }.label!,
      gtk.framerate_diagnostics_primitives
    ]

    return if @stop

    if @ticks_per_move >= 1
      if (state.tick_count % @ticks_per_move).zero?
        move_ant
        render_sprites
      end
    else
      @steps_per_sec.div(60).times do
        move_ant
        if @stop
          render_sprites
          puts_stats
          break
        end
      end
      render_sprites
    end
  end

  def move_ant
    @ant.react_to_cell!(@cells_grid.cell(@ant.x, @ant.y))
    @cells_grid.cycle_cell!(@ant.x, @ant.y)
    @ant.move_forward!

    if @ant.x.between?(0, @cells_grid.width - 1) && @ant.y.between?(0, @cells_grid.height - 1)
      @step += 1
    else
      case @out_of_bound_policy
      when :backward
        @ant.u_turn!
        @ant.move_forward!
      when :warp
        @ant.x = @cells_grid.width - 1 if @ant.x < 0
        @ant.x = 0 if @ant.x >= @cells_grid.width
        @ant.y = @cells_grid.height - 1 if @ant.y < 0
        @ant.y = 0 if @ant.y >= @cells_grid.height
      when :stop
        @ant.u_turn!
        @ant.move_forward!
        @ant.u_turn!
        @stop = true
      end
    end
  end

  def render_sprites
    outputs.static_sprites.clear
    outputs.static_sprites << @cells_grid.cells
    outputs.static_sprites << @ant
  end

  def pause
    state.last_scene = self
    state.current_scene = Pause.new
  end

  def puts_stats
    puts "Screen size: #{state.game_params.screen_size}",
         "Number of colors: #{state.game_params.number_of_colors}",
         "Color rules: #{state.game_params.color_rules}",
         "Start direction: #{state.game_params.start_direction}",
         "Step per second: #{state.game_params.steps_per_sec}",
         "Out of bound policy: #{state.game_params.out_of_bound_policy}",
         "Color palette: #{state.game_params.color_palette}"
   end
end
