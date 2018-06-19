# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :boids,
  frame_duration: 100, #duration between two frames in ms
  number_boids: 10,
  max_grid_size: 10000 #max x,y grid size of the boids world

config :logger,
  level: :debug
