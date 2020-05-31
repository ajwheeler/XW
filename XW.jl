#A puzzle is a Matrix of Squares, toegerther with vectors of views into each word, `down` and `across`
const Square = Union{Char, Nothing}
struct Puzzle #TODO make immutable
    grid::Matrix{Square}
    across::Vector{SubArray{Square}}
    down::Vector{SubArray{Square}}
end

#construct a puzzle from a grid of squares, i.e. calculate across and down
function Puzzle(grid::Matrix{Square})
    function collect_down(grid)
        down = []
        for i in 1:size(grid, 2)
            blocks = vcat(0, findall(grid[:, i] .== nothing), size(grid, 1)+1)
            for ii in 1:length(blocks)-1
                if blocks[ii]+1 <= blocks[ii+1]-1
                    push!(down, view(grid,blocks[ii]+1 : blocks[ii+1]-1, i))
                end end
        end
        down
    end
    
    Puzzle(grid, collect_down(PermutedDimsArray(grid, (2, 1))), collect_down(grid))
end

#pretty-print grid
function Base.show(io::IO, ::MIME"text/plain", grid::Matrix{Square})
    for row in eachrow(puz.grid)
        println((l->"$l ").(replace(row, nothing=>'■', ' '=>'_'))...)
    end
end

#pretty print grid and clues
function Base.show(io::IO, ::MIME"text/plain", puz::Puzzle)
    show(stdout, "text/plain", puz.grid)
    function printwords(acrossordown)
        for (i, word) in enumerate(acrossordown)
            println("$i. ", (l->"$l ").(replace(word, ' '=>'_'))...)
        end
    end
    println()
    println("ACROSS:")
    printwords(puz.across)
    println()
    println("DOWN:")
    printwords(puz.down)
end

function Base.show(io::IO, puz::Puzzle)
    println("Puzzle ($(size(puz.grid, 2))x$(size(puz.grid, 1)))")
end

function fillable_with(word, lexicon, mask)
    #mask = ones(Bool, size(right_length))    
    for (i, c) in enumerate(word)
        if c != ' '
            mask[mask] .&= (w->w[i] == c).(lexicon[mask])
        end
    end
    mask
end
fillable_with(word, lexicon) = fillable_with(word, lexicon, length.(lexicon) .== length(word))

function set(puz::Puzzle, lexicon::Vector{Vector{Char}}; verbose=false)
	words = [puz.across; puz.down] #vector of all words
	possibilities = [fillable_with(w, lexicon) for w in words]
                
	verbose && display(puz.grid)
			
	function set_inner(possibilities)
		if verbose
			print("\u1b[$(size(grid, 1))F")
			display(puz.grid)
		end

	    ! any([' ' in w for w in words]) && return true

		nchoices = sum.(possibilities)
        any(nchoices .== 0) && return false
        nchoices[nchoices .== 1] .= typemax(Int)

        i = argmin(nchoices) #set the word with the fewest possible answers
        orig = copy(words[i])
        for choice in lexicon[possibilities[i]]
        	words[i] .= choice
            #TODO only recalculate for words that have been changed
            possibilities = [fillable_with(w, lexicon) for w in words] 
            set_inner(possibilities) && return true
		end
        words[i] .= orig
        return false
	end

    set_inner(possibilities)
end
