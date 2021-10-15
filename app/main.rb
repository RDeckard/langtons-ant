require "lib/rddr-libs/gtk_object.rb"
require "lib/rddr-libs/tick.rb"
require "lib/rddr-libs/spriteable.rb"
require "lib/rddr-libs/tools/prompt.rb"
require "lib/rddr-libs/tools/menu.rb"
require "lib/rddr-libs/tools/text_box.rb"
require "app/models/cells_grid.rb"
require "app/models/ant.rb"
require "app/scenes/title_screen.rb"
require "app/scenes/settings.rb"
require "app/scenes/customize_cells.rb"
require "app/scenes/langtons_ant.rb"
require "app/scenes/pause.rb"

def tick(args)
  set_defaults if args.state.tick_count.zero?

  @tick ||= Tick.new(TitleScreen)

  @tick.call
end

def set_defaults
  $gtk.args.state.game_params.screen_size         = 128
  $gtk.args.state.game_params.number_of_colors    = 2
  $gtk.args.state.game_params.color_rules         = "RL"
  $gtk.args.state.game_params.start_direction     = "up"
  $gtk.args.state.game_params.steps_per_sec       = 600
  $gtk.args.state.game_params.out_of_bound_policy = "stop"
  $gtk.args.state.game_params.color_set           = "random"
end
