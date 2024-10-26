using EcologicalNetworksDynamics
using Random
using DataFrames
using Distributions
using CairoMakie
using CSV
using JLD2
using LinearAlgebra
include("utils.jl")
set_theme!(theme_minimal())
Random.seed!(123) # For reproducibility.

Z = 50 # Predator-prey ratio.
S = 30 # Species richness.
C = 0.1 # Trophic connectance.
t_max = 1 #10_000
intensity = 1 # Facilitation intensity.
n_rep = 10 # Number of replicates per number of facilitation interactions.
model = load_object("data/model.jld2")
fw = Foodweb(Array(model.A))
max_L = count(possible_facilitation_interactions(model))

# for L_facilitation in 1:max_L
l_fac_values = 0:10:200
df_vec = Any[undef for _ in eachindex(l_fac_values)]
Threads.@threads for i in eachindex(l_fac_values)
    l_facilitation = l_fac_values[i]
    df_tmp = DataFrame(; l_facilitation=Float64[], persistence=Float64[], replicate=Int64[])
    for replicate in 1:n_rep
        @info replicate
        A = get_facilitation_matrix(model, l_facilitation)
        model_fac = default_model(fw, BodyMass(; Z), ClassicResponse(; c=0.8), FacilitationLayer(; A, intensity))
        B0 = rand(Uniform(0.1, 1), S)
        sol = simulate(model_fac, B0, t_max)
        persistence = get_persistence(sol)
        push!(df_tmp, (l_facilitation, persistence, replicate))
    end
    df_vec[i] = df_tmp
end
df = reduce(vcat, df_vec)

se(x) = std(x) / sqrt(length(x))
data = combine(groupby(df, :l_facilitation), :persistence => mean, :persistence => se)

fig = Figure();
ax = Axis(fig[1, 1], xlabel="Number of facilitation links", ylabel="Species persistence")
scatter!(data.l_facilitation, data.persistence_mean)

script_name = split(@__FILE__, "/")[end][begin:end-3]
save("figures/$script_name.png", fig)
CSV.write("data/$script_name.csv", df)
