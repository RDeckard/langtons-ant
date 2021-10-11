class Bchmk < Scene
  def initialize
    grid_width  = state.game_params.screen_size
    grid_height = grid_width * 9/16
    @cells_grid = CellsGrid.new(grid_width, grid_height, state.game_params)
  end

  def tick
    if state.tick_count == 0
      outputs.static_primitives << @cells_grid.cells
      outputs.static_primitives << @cells_grid.lines
    end
  end
end
