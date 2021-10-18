class CellsGrid < RDDR::GTKObject
  WHITE_AND_BLACK = [
    { r: 255, g: 255, b: 255 }.freeze,
    { r: 0,   g: 0,   b: 0 }.freeze,
  ].freeze

  DEFAULT_CELL_COLOR_INDEX = 0

  attr_reader :width, :height, :cells, :cell_width, :cell_height, :colors

  def initialize(width, height, game_params)
    @width  = width
    @height = height

    @number_of_colors = game_params.number_of_colors

    color_set = game_params.color_set.to_sym
    @colors =
      WHITE_AND_BLACK.dup.concat(
        if color_set == :random
          RDDR::Colors::SETS.values.sample.values[2..-1].shuffle!
        else
          RDDR::Colors::SETS[color_set].values
        end
      )

    @cells =
      Array.new(@width) do |x_grid|
        Array.new(@height) do |y_grid|
          Cell.new(
            x_grid, y_grid, cell_width, cell_height,
            DEFAULT_CELL_COLOR_INDEX, @colors[DEFAULT_CELL_COLOR_INDEX].dup
          )
        end
      end
  end

  def cell(x, y)
    @cells[x][y]
  end

  def cell_width
    @cell_width ||= grid.w / width
  end

  def cell_height
    @cell_height ||= grid.h / height
  end

  def cycle_cell!(x, y)
    current_cell = cell(x, y)

    current_cell.value += 1
    current_cell.value =  0 if current_cell.value == @number_of_colors
    current_cell.color = @colors[current_cell.value]
  end

  def set_cell_value!(x, y, value)
    if value.between?(0, @number_of_colors - 1)
      current_cell = cell(x, y)

      current_cell.value = value
      current_cell.color = @colors[value]
    end
  end

  def lines
    return @lines if @lines

    @lines = []

    # vertical lines
    @lines <<
      Array.new(width) do |cell_x|
        x = cell_width * cell_x

        {
          x:  x,
          y:  grid.bottom,
          x2: x,
          y2: grid.top
        }.line!
      end

    # horizontal lines
    @lines <<
      Array.new(height) do |cell_y|
        y = cell_height * cell_y

        {
          x:  grid.left,
          y:  y,
          x2: grid.right,
          y2: y
        }.line!
      end

    @lines
  end

  class Cell < RDDR::GTKObject
    include RDDR::Spriteable

    attr_reader :x_grid, :y_grid
    attr_accessor :value, :color

    def initialize(x_grid, y_grid, w, h, value, color)
      @x_grid = x_grid
      @y_grid = y_grid
      @w = w
      @h = h

      @x =  @x_grid * @w
      @y =  @y_grid * @h

      @value = value
      @color = color
    end

    def static_draw_parameters
      @static_draw_parameters ||= { x: @x, y: @y, w: @w, h: @h }
    end

    def draw_parameters
      static_draw_parameters.merge(@color)
    end
  end
end
