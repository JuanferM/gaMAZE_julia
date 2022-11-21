function shiftfirstline(ligne, n)
    k = rand(2:n)
    v = ligne[k]

    for i=k:n-1
        ligne[i] = ligne[i+1]
    end

    ligne[n] = v
    return ligne
end

function shiftlastline(ligne, n)
    k = rand(1:n-1)
    v = ligne[k]

    for i=k:n-2
        ligne[i] = ligne[i+1]
    end

    ligne[n-1] = v
    return ligne
end

function shiftline(ligne, n)
    k = rand(1:n)
    v = ligne[k]

    for i=k:n-1
        ligne[i] = ligne[i+1]
    end

    ligne[n] = v
    return ligne
end

function shift(individu)
    ind = copy(individu)
    m,n = size(ind)

    for i=1:rand(5:m*n)
        k = rand(1:m)
        if k==1
            ind[1,:] = shiftfirstline(ind[1,:], n)
        elseif k==m
            ind[m,:] = shiftlastline(ind[m,:], n)
        else
            ind[k,:] = shiftline(ind[k,:], n)
        end
    end

    return ind
end

function flips(individu)
    ind = copy(individu)
    n, m = size(ind)
    max_sz = unsafe_trunc(Int64, (n*m)/2)
    sz = rand(1:max_sz)
    couples_idx = Array{Int64}(undef, sz, 2)

    for i=1:sz
        couples_idx[i,1] = rand(1:n)
        couples_idx[i,2] = rand(1:m)
    end

    for i=1:sz
        elt = couples_idx[i,:]
        if elt[1] == 1 && elt[2] == 1
            ind[elt[1],elt[2]] = rand([1,2,3])
        elseif elt[1] == n && elt[2] == m
            ind[elt[1],elt[2]] = rand(1:4)
        end
    end

    return ind
end
