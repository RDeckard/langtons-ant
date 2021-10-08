class CellsGrid < Model
  WHITE_AND_BLACK = [
      { r: 255, g: 255, b: 255 },
      { r: 0,   g: 0,   b: 0 },
    ].freeze

  COLORS = {
    classic: [
      { r: 255, g: 0,   b: 0 },
      { r: 0,   g: 255, b: 0 },
      { r: 0,   g: 0,   b: 255 },
      { r: 255, g: 255, b: 0 },
      { r: 0,   g: 255, b: 255 },
      { r: 255, g: 0,   b: 255 },
      { r: 192, g: 192, b: 192 },
      { r: 128, g: 128, b: 128 },
      { r: 128, g: 0,   b: 0 },
      { r: 128, g: 128, b: 0 },
      { r: 0,   g: 128, b: 0 },
      { r: 128, g: 0,   b: 128 },
      { r: 0,   g: 128, b: 128 },
      { r: 0,   g: 0,   b: 128 }
    ].freeze,
    c64: [
      { r: 136, g: 0,   b: 0 },
      { r: 170, g: 255, b: 238 },
      { r: 204, g: 68,  b: 204 },
      { r: 0,   g: 204, b: 85 },
      { r: 0,   g: 0,   b: 170 },
      { r: 238, g: 238, b: 119 },
      { r: 221, g: 136, b: 85 },
      { r: 102, g: 68,  b: 0 },
      { r: 255, g: 119, b: 119 },
      { r: 51,  g: 51,  b: 51 },
      { r: 119, g: 119, b: 119 },
      { r: 170, g: 255, b: 102 },
      { r: 0,   g: 136, b: 255 },
      { r: 187, g: 187, b: 187 }
    ].freeze
  }.freeze

  attr_reader :width, :height, :cell_width, :cell_height, :colors

  def initialize(width, height, game_params)
    @width  = width
    @height = height

    @number_of_colors = game_params.number_of_colors

    @cells = Array.new(@width) { Array.new(@height) { 0 } }

    color_palette = game_params.color_palette.to_sym
    @colors =
      WHITE_AND_BLACK.dup.concat(
        if color_palette == :random
          colors = COLORS.values.sample.shuffle
        else
          COLORS[color_palette].dup
        end
      )
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
    @cells[x][y] += 1
    @cells[x][y] =  0 if @cells[x][y] == @number_of_colors
  end

  def set_cell!(x, y, value)
    @cells[x][y] = value if value.between?(0, @number_of_colors - 1)
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
          y2: grid.top,
        }
      end

    # horizontal lines
    @lines <<
      Array.new(height) do |cell_y|
        y = cell_height * cell_y

        {
          x:  grid.left,
          y:  y,
          x2: grid.right,
          y2: y,
        }
      end

    @lines
  end

  def cells
    map_cells do |x, y, cell|
      next if cell.zero?

      {
        x: cell_width * x, y: cell_height * y,
        w: cell_width,     h: cell_height,
        path: :pixel
      }.merge!(@colors[cell])
    end.tap(&:compact!)
  end

  private

  def map_cells
    @cells.map_2d { |x, y, cell| yield x, y, cell }
  end
end
