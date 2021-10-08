require "lib/serializable.rb"
require "lib/scene.rb"
require "lib/model.rb"
require "lib/tool.rb"
require "lib/tools/prompt.rb"
require "lib/tools/menu.rb"
require "lib/tools/text_box.rb"
require "app/scenes/conf_menu.rb"
require "app/models/cells_grid.rb"
require "app/scenes/customize_cells.rb"
require "app/models/ant.rb"
require "app/scenes/langtons_ant.rb"
require "app/scenes/pause.rb"

# Default game_params
$gtk.args.state.game_params.screen_size         = 128
$gtk.args.state.game_params.number_of_colors    = 2
$gtk.args.state.game_params.color_rules         = "RL"
$gtk.args.state.game_params.start_direction     = "up"
$gtk.args.state.game_params.steps_per_sec       = 600
$gtk.args.state.game_params.out_of_bound_policy = "stop"
$gtk.args.state.game_params.color_palette       = "random"

def tick(args)
  args.state.current_scene ||= ConfMenu.new

  args.outputs.debug << args.gtk.framerate_diagnostics_primitives

  args.state.current_scene.tick

  if args.inputs.keyboard.key_held.alt && args.inputs.keyboard.key_down.f
    args.state.window_fullscreen = !args.state.window_fullscreen
    args.gtk.set_window_fullscreen(args.state.window_fullscreen)
  end

  if args.inputs.keyboard.key_held.alt && args.inputs.keyboard.key_down.q
    args.gtk.request_quit unless args.gtk.platform?(:html)
    args.gtk.reset
  end

  args.gtk.reset if args.inputs.keyboard.key_held.alt && args.inputs.keyboard.key_down.r
rescue => e
  # HOTFIX DragonRuby: raise exception correctly when using blocks/procs/lambdas
  puts "+-" * 50
  puts e
  puts e.backtrace.join("\n")
  puts "+-" * 50
  raise e
end
