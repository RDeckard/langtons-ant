class Ant < Model
  IMAGE = "assets/images/ant.png".freeze
  IMAGE_HEIGHT = 351
  IMAGE_WIDTH  = 251

  attr_reader :x, :y

  def initialize(x, y, cells_grid, game_params)
    @x = x
    @y = y
    @cells_grid = cells_grid
    @path       = IMAGE

    @direction  = game_params.start_direction.to_sym
    @color_rules = game_params.color_rules.chars
  end

  def primitive_marker
    :sprite
  end

  def react_to_cell!(cell)
    case @color_rules[cell]
    when "L" then turn_left!
    when "R" then turn_right!
    when "N"
    when "U" then u_turn!
    end
  end

  def turn_left!
    @direction =
      case @direction
      when :up    then :left
      when :down  then :right
      when :left  then :down
      when :right then :up
      end
  end

  def turn_right!
    @direction =
      case @direction
      when :up    then :right
      when :down  then :left
      when :left  then :up
      when :right then :down
      end
  end

  def u_turn!
    @direction =
      case @direction
      when :up    then :down
      when :down  then :up
      when :left  then :right
      when :right then :left
      end
  end

  def move_forward!
    case @direction
    when :up    then @y += 1
    when :down  then @y -= 1
    when :left  then @x -= 1
    when :right then @x += 1
    end
  end

  def draw_override(ffi_draw)
    ffi_draw.draw_sprite_3(
      @cells_grid.cell_width * @x + ant_dimensions[:xoffset],  # x
      @cells_grid.cell_height * @y + ant_dimensions[:yoffset], # y
      ant_dimensions[:width], ant_dimensions[:height],         # w, h
      @path, sprite_angle,                                     # path, sprite_angle,
      nil, nil, nil, nil,                                      # alpha, red_saturation, green_saturation, blue_saturation
      nil, nil, nil, nil,                                      # tile_x, tile_y, tile_w, tile_h,
      nil, nil,                                                # flip_horizontally, flip_vertically,
      0.5, 0.5,                                                # angle_anchor_x, angle_anchor_y,
      nil, nil, nil, nil                                       # source_x, source_y, source_w, source_h
    )
  end

  def sprite_angle
    case @direction
    when :up    then 0
    when :down  then 180
    when :left  then 90
    when :right then -90
    else        raise "Incorrect ant direction: #{@direction}"
    end
  end

  private

  def ant_dimensions
    @ant_dimensions ||=
      begin
        width_ratio  = Ant::IMAGE_WIDTH / @cells_grid.cell_width
        height_ratio = Ant::IMAGE_HEIGHT / @cells_grid.cell_height

        if width_ratio > height_ratio
          height  = Ant::IMAGE_HEIGHT / width_ratio
          yoffset = (@cells_grid.cell_height - height) / 2 + 1

          { width: @cells_grid.cell_width, height: height, xoffset: 0, yoffset: yoffset }
        else
          width   = Ant::IMAGE_WIDTH / height_ratio
          xoffset = (@cells_grid.cell_width - width) / 2 + 1

          { width: width, height: @cells_grid.cell_height, xoffset: xoffset, yoffset: 0 }
        end
      end
  end
end
