require "lib/serializable.rb"
require "lib/spriteable.rb"
require "lib/gtk_object.rb"
require "lib/tools/prompt.rb"
require "lib/tools/menu.rb"
require "lib/tools/text_box.rb"
require "app/scenes/benchmark.rb"
require "app/scenes/title_screen.rb"
require "app/scenes/conf_menu.rb"
require "app/models/cells_grid.rb"
require "app/scenes/customize_cells.rb"
require "app/models/ant.rb"
require "app/scenes/langtons_ant.rb"
require "app/scenes/pause.rb"

def tick(args)
  set_defaults if args.state.tick_count.zero?

  args.state.current_scene ||= TitleScreen.new
  # args.state.current_scene ||= Bchmk.new

  debug

  args.state.current_scene.tick

  handle_quit_and_reset
rescue => e
  # HOTFIX DragonRuby: raise exception correctly when using blocks/procs/lambdas
  puts "+-" * 50
  puts e
  puts e.backtrace.join("\n")
  puts "+-" * 50
  raise e
end

def set_defaults
  $gtk.args.state.game_params.screen_size         = 128
  $gtk.args.state.game_params.number_of_colors    = 2
  $gtk.args.state.game_params.color_rules         = "RL"
  $gtk.args.state.game_params.start_direction     = "up"
  $gtk.args.state.game_params.steps_per_sec       = 600
  $gtk.args.state.game_params.out_of_bound_policy = "stop"
  $gtk.args.state.game_params.color_palette       = "random"
end

def handle_quit_and_reset
  if $gtk.args.inputs.keyboard.key_held.alt && $gtk.args.inputs.keyboard.key_down.f
    $gtk.args.state.window_fullscreen = !$gtk.args.state.window_fullscreen
    $gtk.set_window_fullscreen($gtk.args.state.window_fullscreen)
  end

  if $gtk.args.inputs.keyboard.key_held.alt && $gtk.args.inputs.keyboard.key_down.q
    $gtk.request_quit unless $gtk.platform?(:html)
    $gtk.reset
  end

  $gtk.reset if $gtk.args.inputs.keyboard.key_held.alt && $gtk.args.inputs.keyboard.key_down.r
end

def debug
  if @last_tick_time
    now = Time.now.to_f
    tps = 1/(now - @last_tick_time)

    $gtk.args.outputs.debug << {
      x: $gtk.args.grid.left.shift_right(5), y: $gtk.args.grid.top.shift_down(5),
      text: "TPS: #{tps.to_i}",
      size_enum: 2,
      r: 255, g: 0, b: 0
    }.label!

    # if @last_print_time.nil? || now - @last_print_time >= 1
    #   h = {}
    #   puts "------"
    #   puts "SCENE: #{$gtk.args.state.current_scene.class.name}"
    #   puts "TPS: #{tps}"
    #   puts "PRIMITIVES: #{$gtk.args.outputs.static_primitives.flatten.size}"
    #   puts ObjectSpace.count_objects(h)
    #   puts "------"
    #   @last_print_time = Time.now.to_f
    # end
  end
  @last_tick_time = Time.now.to_f
end
