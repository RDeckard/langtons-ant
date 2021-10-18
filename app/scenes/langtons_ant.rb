class LangtonsAnt < RDDR::GTKObject
  def initialize(cells_grid, ant)
    @cells_grid = cells_grid
    @ant = ant

    @step = 0

    @steps_per_sec  = state.game_params.steps_per_sec
    @ticks_per_move = 60.div(@steps_per_sec)

    @out_of_bound_policy = state.game_params.out_of_bound_policy.to_sym
  end

  def tick
    outputs.labels << {
      x: grid.left.shift_right(5), y: grid.bottom.shift_up(25),
      text: "current step: #{@step}",
      size_enum: 2
    }.label!

    outputs.labels << {
      x: grid.right.shift_left(5), y: grid.bottom.shift_up(25),
      text: "Click/ENTER: pause & details",
      size_enum: 2,
      alignment_enum: 2
    }.label!

    @cells_updated = []

    unless @stop
      if @ticks_per_move >= 1
        move_ant if (state.tick_count % @ticks_per_move).zero?
      else
        @steps_per_sec.div(60).times do
          move_ant
          break if @stop
        end
      end
    end

    outputs[:cells_grid].clear_before_render = false
    outputs[:cells_grid].primitives << @cells_updated

    render

    pause if inputs.keyboard.key_down.enter || inputs.pointer.left_click
  end

  def move_ant
    @ant.react_to_cell!(@cells_grid.cell(@ant.x, @ant.y))
    @cells_grid.cycle_cell!(@ant.x, @ant.y)
    @cells_updated << @cells_grid.cell(@ant.x, @ant.y)
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

  def render
    outputs.primitives << grid.rect.to_hash.sprite!(path: :cells_grid)

    return if @render

    outputs.static_primitives.clear
    outputs.static_primitives << @ant
    outputs.static_primitives << grid.rect.to_hash.sprite!(path: :grid_lines)

    @render = true
  end

  def pause
    state.last_scene = self
    @render = false
    state.current_scene = Pause.new(current_step: @step)
  end
end
