.PHONY: all setup figures clean # High-level actions.

all: setup figures # Build everything.

setup:
	julia --project=. -e 'import Pkg; Pkg.instantiate()'
	mkdir -p figures data

figures: data/model.jld2 \
	  	 data/trophic-adjacency.csv \
		 data/persistence-vs-nb-facilitation.csv \
		 figures/persistence-vs-nb-facilitation.png

data/model.jld2 data/trophic-adjacency.csv: src/create-food-web.jl
	julia --project=. src/create-food-web.jl

figures/%.png data/%.csv: data/model.jld2 src/plot-%.jl
	julia --project=. --threads 5 src/plot-$*.jl

clean:
	rm -rf figures
	rm -rf data
