include("XW.jl")

grid = [nothing ' ' ' ' ' ' nothing
        ' ' ' ' ' ' ' ' ' '
        'T' 'R' 'O' 'U' 'T'
        ' ' ' ' ' ' ' ' ' '
        nothing ' ' ' ' ' ' nothing]

lexicon = Vector{Char}.(uppercase.(readlines("/usr/share/dict/words")))
lexicon = collect(Set(lexicon))
println(length(lexicon), " words in the lexicon");

puz = Puzzle(grid)
set(puz, lexicon; verbose=true)
