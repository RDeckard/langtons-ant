class CustomizeCells < RDDR::GTKObject
  def initialize
    screen_size = state.game_params.screen_size
    grid_height = screen_size * 9/16
    @cells_grid = CellsGrid.new(screen_size, grid_height, state.game_params)

    @ant = Ant.new(
      @cells_grid.width.div(2), @cells_grid.height.div(2),
      @cells_grid,
      state.game_params
    )

    outputs[:cells_grid].clear
    outputs[:cells_grid].background_color = [255, 255, 255, 255]

    outputs[:grid_lines].clear
    outputs[:grid_lines].background_color = [0, 0, 0, 0]
    outputs[:grid_lines].static_primitives << @cells_grid.lines if state.game_params.grid_visibility == "enable"
  end

  def tick
    handler_inputs

    render

    next_scene if inputs.keyboard.key_down.enter || inputs.pointer.right_click
  end

  def handler_inputs
    cell_x = (inputs.mouse.x / @cells_grid.cell_width).to_i
    cell_y = (inputs.mouse.y / @cells_grid.cell_height).to_i

    if inputs.pointer.left_click
      @start_cell_x     = cell_x
      @start_cell_y     = cell_y
      @start_cell_value = @cells_grid.cell(cell_x, cell_y).value
    end

    if cell_x == @start_cell_x && cell_y == @start_cell_y
      if inputs.mouse.up
        cell_updated = true
        @cells_grid.cycle_cell!(cell_x, cell_y)
      end
    elsif inputs.mouse.button_left
      cell_updated = true
      @cells_grid.set_cell_value!(cell_x, cell_y, @start_cell_value) unless cell_x == @last_cell_set_x &&
                                                                            cell_y == @last_cell_set_y

      @last_cell_set_x = cell_x
      @last_cell_set_y = cell_y
    end

    outputs[:cells_grid].clear_before_render = false
    outputs[:cells_grid].primitives << @cells_grid.cell(cell_x, cell_y) if cell_updated
  end

  def render
    outputs.primitives << grid.rect.to_hash.sprite!(path: :cells_grid)

    return if @render

    outputs.static_primitives.clear
    outputs.static_primitives << @ant
    outputs.static_primitives << grid.rect.to_hash.sprite!(path: :grid_lines)

    outputs.static_primitives << [
      {
        x: grid.left.shift_right(5), y: grid.bottom.shift_up(45),
        text: "Click to add color cells",
        size_enum: 2
      }.label!,
      {
        x: grid.left.shift_right(5), y: grid.bottom.shift_up(25),
        text: "Click and drag from a colored cell to draw",
        size_enum: 2
      }.label!,
      {
        x: grid.right.shift_left(5), y: grid.bottom.shift_up(25),
        text: "Right click/ENTER: Start",
        size_enum: 2,
        alignment_enum: 2
      }.label!
    ]

    @render = true
  end

  def next_scene
    state.current_scene = LangtonsAnt.new(@cells_grid, @ant)
  end
end
