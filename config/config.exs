# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :boids,
  # duration between two frames in ms
  frame_duration: 1000,
  number_boids: 1000,
  # max x,y grid size of the boids world
  max_grid_size: 1000,
  max_velocity: 20

config :logger,
  level: :info
