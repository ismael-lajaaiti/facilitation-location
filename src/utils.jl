"""
Draw randomly where facilitation interactions occur. 
Rows correspond to facilitators, and columns to receivors.
The number of facilitation interactions is either determined by connectance or
number of links.
Facilitation interactions are always directed toward a basal species, that is,
a species whose trophic level is equal to one.
The occurence of facilitation interactions can be constrained by the difference in trophic
level between the facilitator and the basal species.
C is the connectance of facilitation interaction.
"""
function get_facilitation_matrix(model, L; ΔTL=nothing)
    S = model.richness
    A_possible = possible_facilitation_interactions(model; ΔTL)
    possible_indices = []
    for i in 1:S, j in 1:S
        if A_possible[i, j] == 1
            push!(possible_indices, (i, j))
        end
    end
    realised_indices = sample(possible_indices, L; replace=false)
    A_realised = zeros(Bool, S, S)
    for (i, j) in realised_indices
        A_realised[i, j] = 1
    end
    A_realised
end

function possible_facilitation_interactions(model; ΔTL=nothing)
    S = model.richness
    prod_idx = model.producers_indices
    tl = model.trophic_levels
    m = zeros(Bool, S, S)
    for facilitator in 1:S, receivor in prod_idx
        δtl = tl[facilitator] - 1
        tl_condition = isnothing(ΔTL) ? true : ΔTL - 1 < δtl <= ΔTL
        if facilitator != receivor && tl_condition
            m[facilitator, receivor] = 1
        end
    end
    m
end

function get_persistence(sol; threshold=1e-6)
    count(sol[end] .> threshold) / length(sol[end])
end

function get_script_name()
    script_name = split(@__FILE__, "/")[end]
    script_name = split(script_name, ".")[begin] # Remove extension '.jl'.
end
