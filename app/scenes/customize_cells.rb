class CustomizeCells < Scene
  def initialize
    grid_width  = state.game_params.screen_size
    grid_height = grid_width * 9/16
    @cells_grid = CellsGrid.new(grid_width, grid_height, state.game_params)
  end

  def tick
    next_scene if inputs.keyboard.key_down.enter

    render_gridlines

    render_cells if handler_inputs
  end

  def handler_inputs
    cells_grid_updated = false

    cell_x = (inputs.mouse.x / @cells_grid.cell_width).to_i
    cell_y = (inputs.mouse.y / @cells_grid.cell_height).to_i

    if inputs.mouse.click
      @start_cell_x     = cell_x
      @start_cell_y     = cell_y
      @start_cell_value = @cells_grid.cell(cell_x, cell_y)
    end

    if cell_x == @start_cell_x && cell_y == @start_cell_y
      if inputs.mouse.up
        @cells_grid.cycle_cell!(cell_x, cell_y)
        cells_grid_updated = true
      end
    elsif inputs.mouse.button_left
      unless cell_x == @last_cell_set_x && cell_y == @last_cell_set_y
        @cells_grid.set_cell!(cell_x, cell_y, @start_cell_value)
        cells_grid_updated = true
      end

      @last_cell_set_x = cell_x
      @last_cell_set_y = cell_y
    end

    cells_grid_updated
  end

  def render_cells
    outputs.static_sprites.clear
    outputs.static_sprites << @cells_grid.cells
  end

  def render_gridlines
    return if @render_gridlines

    outputs.static_lines << @cells_grid.lines

    @render_gridlines = true
  end

  def next_scene
    state.current_scene = LangtonsAnt.new(@cells_grid)
  end
end
