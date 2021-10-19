require "lib/rddr-libs/require.rb"

require "app/require.rb"

def tick(args)
  set_defaults if args.state.tick_count.zero?

  @tick ||= RDDR::Tick.new(TitleScreen)

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
  $gtk.args.state.game_params.grid_visibility     = "disable"
end
