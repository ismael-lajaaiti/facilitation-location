using EcologicalNetworksDynamics
using Random
using Distributions
using CSV
using Tables
using LinearAlgebra
using JLD2
Random.seed!(123) # For reproducibility.

Z = 50 # Predator-prey ratio.
S = 30 # Species richness.
C = 0.1 # Trophic connectance.

n_extinction = 0
while n_extinction != 10
    n_canabilism = 10
    while n_canabilism != 0
        global fw = Foodweb(:niche; S, C)
        n_canabilism = count(Diagonal(fw.A))
    end
    global model = default_model(fw, BodyMass(; Z), ClassicResponse(; c=0.8))
    t_end = 10_000
    B0 = rand(Uniform(0.1, 1), S)
    sol = simulate(model, B0, t_end)
    global n_extinction = S - count(sol[end] .> 0)
end

save_object("data/model.jld2", model)
CSV.write("data/trophic-adjacency.csv", Tables.table(model.A), writeheader=false)
