extends Node

@warning_ignore_start("unused_signal")

signal spawn_particle(sprite: Texture2D, position: Vector2i)
signal level_complete
signal level_goal(text: String)
signal broken_tile(position: Vector2i)
signal bite_death(healing: int)
