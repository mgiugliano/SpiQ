"""
	closest_factors(N::Int) -> factors::Array{Int, 2}

Auxiliary method. Finds the pair of factors of an integer `N` that are closer between them.

### Arguments
- `N::Int` : number of which calculate the factors.

### Return
- `factors::Array{Int, 2}` : closest factor of `N`.

### Authors
- Michele Giugliano - mgiugliano@gmail.com
- Rodrigo Amaducci - amaducci.rodrigo@gmail.com
"""

function closest_factors(N::Int)
	MIN = 999;
	factors = zeros(Int, 2);

	for i in 1:round(N^0.5)+1
		if N % i == 0
			auxDiff = abs(i - (N / i));
			if auxDiff < MIN
				MIN = auxDiff;
				factors[1] = i;
				factors[2] = N / i;
			end
		end
	end
	
	return factors;
end 
