include("/home/trung/_qhe-julia/FQH_state_v2.jl")
include("/home/trung/_qhe-julia/HilbertSpace.jl")
include("/home/trung/_qhe-julia/Misc.jl")
using .FQH_states
using .HilbertSpaceGenerator
using .MiscRoutine

using ArgMacros

function main()
	@inlinearguments begin
		@argumentrequired String inputfile "--input" "-i"
		@argumentdefault String "" appendconfig "--append" "-a"
		@argumentoptional String outputfile "--output" "-o"
		@argumentrequired String monomialfile "--monomial" "-m"
		@argumentflag overwrite "--overwrite"
		@argumentflag normalize "--normalize"
		@argumentdefault String "binary" outputformat "--output-format"
		@argumentflag full "--full"
	end

	# Validate inpurt parameters
	if outputfile==nothing
		outputfile = "$(inputfile)_append$(appendconfig)_out"
	end

	if !isdir(outputfile)
		mkdir(outputfile)
	elseif !overwrite
		println("Output directory $(outputfile) already exists.")
		println("Use a different output name (recommended), or overwrite the directory with the tag --overwrite.")
		return
	else
		rm(outputfile,recursive=true)
		mkdir(outputfile)
	end

	outputformat = lowercase(outputformat)
	@assert(outputformat in ["decimal","binary"], "The output format must be either 'decimal' or 'binary'.")

	if isfile(inputfile)
		if normalize
			appendzeros = BitVector(zeros(length(appendconfig)))
			normstate = sphere_normalize(append_basis(readwf(inputfile),appendzeros))
			#printwf(normstate;fname="teststate")
			e_positions = findall(==('1'),collect(appendconfig))
			mainstate = add_electron(normstate,e_positions)
		else
			mainstate = append_basis(readwf(inputfile),appendconfig)
		end
		No = length(mainstate.basis[1])
		Ne = count(mainstate.basis[1])
	else
		println("Input file not found. Terminating.")
		return
	end

	println("The system has $Ne electrons and $No orbitals.")

	# Save initial state
	printwf(mainstate;fname="$(outputfile)/basis_0")

	#squeezed_basis = squeezedhilbertspace(maximum(mainstate.basis)) # All monomials squeezed from root of main state
	squeezed_state = readwf(monomialfile)

	if full # Collate the main state and squeezed basis into a single basis
		mainstate,squeezed_state = collate_vector(mainstate,squeezed_state)
	end

	squeezed_basis = squeezed_state.basis
	println("$(length(squeezed_basis)) monomial(s) squeezed from $(bit2string(maximum(mainstate.basis)))")
	i = 1 # Index of saved file
	for b in squeezed_basis
		if iszero(monomial_coefficient(mainstate,b))
			if full
				monomial_coefs = [bb == b ? 1.0 : 0.0 for bb in squeezed_basis]
				monomial_state = FQH_state(squeezed_basis,monomial_coefs)
				if outputformat == "decimal"
					printwf(monomial_state;fname="$(outputfile)/basis_$i",format=:DEC)
				elseif otuptuformat == "binary"
					printwf(monomial_state;fname="$(outputfile)/basis_$i",format=:BIN)
				end
			else
				monomial_state = FQH_state([b],[1.0])
				if outputformat == "decimal"
					printwf(monomial_state;fname="$(outputfile)/basis_$i",format=:DEC)
				elseif otuptuformat == "binary"
					printwf(monomial_state;fname="$(outputfile)/basis_$i",format=:BIN)
				end
			end
			i += 1
		end
	end
	println("Total $i state(s).")
	println("---------------------------------")

end

@time main()