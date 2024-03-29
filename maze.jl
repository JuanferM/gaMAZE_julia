# ----------------------------------------------------------------------------------------------------
# Xavier Gandibleux - Metaheuristiques - Algorithmes genetiques - Probleme du robot dans un labyrinthe
# Modifié par Juanfer MERCIER - Novembre 2022

using Printf

include("movements.jl")

# -------------------------------------------------------------------------------------------------
# Contruit un labyrinthe de 10x10 pour un affichage style 1970
function construireLabyrinthe()
    carte = Matrix{Char}(undef,21,21)
    for i=1:21
        for j=1:21
            carte[i,j] = ' '
        end
    end

    for i=1:2:21
        for j=1:2:21
            carte[i,j] = '.'
        end
    end

    for j=2:2:20
        carte[1,j] = '-'
        carte[21,j] = '-'
    end

    for i=2:2:20
        carte[i,1] = '|'
        carte[i,21] = '|'
    end

    carte[2,1] = '>'
    carte[20,21] = ' '
    return carte
end

# -------------------------------------------------------------------------------------------------
# Affichage alphanumerique du labyrinthe
function afficheLabyrinthe(carte)
    @printf("\n")
    for i=1:21
        @printf("    ")
        for j=1:21
            @printf("%c",carte[i,j])
        end
        @printf("\n")
    end
    @printf("\n")
end

# -------------------------------------------------------------------------------------------------
# Affichage alphanumerique du labyrinthe
function afficheIndividu(indIn, carteIn)
    ind = indIn[1]
    fitness = indIn[2]
    carte = copy(carteIn)

    i=1; iplot = 2
    j=1; jplot = 2
    carte[iplot,jplot] = repr(0)[1]
    for longueur=2:fitness
            if    (ind[i,j] == 1) # Nord
                i-=1
            elseif (ind[i,j] == 2) # Est
                j+=1
            elseif (ind[i,j] == 3) # Sud
                i+=1
            elseif (ind[i,j] == 4) # Ouest
                j-=1
            end
            carte[2*i,2*j] = repr((longueur-1)%10)[1]
    end

    @printf("\n")
    for i=1:21
        @printf("    ")
        for j=1:21
            @printf("%c",carte[i,j])
        end
        @printf("\n")
    end
    @printf("\n")
end

# -------------------------------------------------------------------------------------------------
# Ajoute quelques obstacles au labyrinthe
function contrainteSoftLabyrinthe(carte)
    for i=1:10
        j=rand(1:10)
        pattern=rand([1,2,4,8])
        if    (pattern == 1)
            carte[2*i,2*j-1] = '|'
        elseif (pattern == 2)
            carte[2*i+1,2*j] = '-'
        elseif (pattern == 4)
            carte[2*i,2*j+1] = '|'
        elseif (pattern == 8)
            carte[2*i-1,2*j] = '-'
        end
    end
    carte[2,1] = '>'
    carte[20,21] = ' '
end

# -------------------------------------------------------------------------------------------------
# Creation d'une population d'individus
function creerPopulation(n,popSize,carte)
    NbRealisable = 0
    realisable = false
    maxFitness = 0
    population = 0
    ind=Array{Int}(undef, 10,10)

    pop=Vector(undef, popSize)

    for individu =1:popSize
    #while realisable ==false
        ind=rand(1:4,n,n)
        ind[1,1]=rand([1,2,3]) # interdit de sortir
        ind[10,10]=2 # force a sortir
        #individu +=1

        visite=Matrix{Bool}(undef,10,11)
        visite=fill(false,10,11)
        i=1; j=1; fitness=0; avance = true
        visite[i,j]=true
        while avance && j!=11
            if ind[i,j] ==1 && carte[2*i-1,2*j] ==' ' && visite[i-1,j]==false
                i-=1 ; fitness +=1; visite[i,j]=true #; println("Nord")
            elseif ind[i,j] ==2 && carte[2*i,2*j+1] ==' ' && visite[i,j+1]==false
                j+=1 ; fitness +=1; visite[i,j]=true #; println("Est")
            elseif ind[i,j] ==3 && carte[2*i+1,2*j] ==' ' && visite[i+1,j]==false
                i+=1 ; fitness +=1; visite[i,j]=true #; println("Sud")
            elseif ind[i,j] ==4 && carte[2*i,2*j-1] ==' ' && visite[i,j-1]==false
                j-=1 ; fitness +=1; visite[i,j]=true #; println("Ouest")
            else avance = false #; print(individu," "); println("fitness = ", fitness, "   i = ",i, " j = ",j);
                maxFitness = max(fitness, maxFitness)
            end
        end # while
        if j==11 println("REALISABLE")
            print(individu," "); println("fitness = ", fitness, "   i = ",i, " j = ",j);
            NbRealisable +=1
            realisable = true
        end
        pop[individu] = (ind , fitness , realisable)
    end # for individu
    println("Nbre Realisable = ", NbRealisable, " maxFitness = ", maxFitness)
    return pop
end

# -------------------------------------------------------------------------------------------------
# Evaluation d'un individu
function evaluerIndividu(n,carte,ind)
    visite = fill(false,10,11)
    i=1; j=1; fitness = 0; avance = true; realisable = false
    visite[i,j]=true
    while (avance) && (!realisable)
            if    (ind[i,j] == 1) && (carte[2*i-1,2*j] ==' ') && (visite[i-1,j] == false)  # Nord
                i-=1 ; fitness +=1; visite[i,j]=true
            elseif (ind[i,j] == 2) && (carte[2*i,2*j+1] ==' ') && (visite[i,j+1] == false)  # Est
                j+=1 ; fitness +=1; visite[i,j]=true
            elseif (ind[i,j] == 3) && (carte[2*i+1,2*j] ==' ') && (visite[i+1,j] == false)  # Sud
                i+=1 ; fitness +=1; visite[i,j]=true
            elseif (ind[i,j] == 4) && (carte[2*i,2*j-1] ==' ') && (visite[i,j-1] == false) # Ouest
                j-=1 ; fitness +=1; visite[i,j]=true
            else
                avance = false
            end
        realisable = j==11
    end
    return fitness , realisable
end

# -------------------------------------------------------------------------------------------------
# Selection d'un parent dans la population
function selectionParent(pop)
    n = length(pop)
    probs = Vector{Float64}(undef, n)
    previous_probs = Vector{Float64}(undef, n)

    sum_fitness = 0
    for i=1:n
        probs[i] = pop[i][2]
        previous_probs[i] = sum_fitness + probs[i]
        sum_fitness = sum_fitness + probs[i]
    end

    i, r, ind = 1, rand(), 0
    while i <= n && ind == 0
        if r < previous_probs[i]/sum_fitness
            ind = i
        end
        i = i+1
    end

    if(ind == 0) ind = rand(1:n) end
    p1 = copy(pop[ind][1])
    return p1
 end

# -------------------------------------------------------------------------------------------------
# crossover entre deux individus
function crossover(p1,p2)
    pc = rand(0.6:0.1:0.9)

    if rand() <= pc
        n, m = size(p1)
        mask = rand([false, true], n, m)

        e1 = zeros(Int64, n, m)
        e2 = zeros(Int64, n, m)

        for i=1:n
            for j=1:m
                if mask[i,j]
                    e1[i,j] = p1[i,j]
                    e2[i,j] = p2[i,j]
                else
                    e1[i,j] = p2[i,j]
                    e2[i,j] = p1[i,j]
                end
            end
        end

        return e1,e2
    end

    return p1,p2
end

# -------------------------------------------------------------------------------------------------
# mutation d'un individu
function mutation( carte , individu )
    pm = rand(0.6:0.1:0.9)
    n, m = size(individu)

    if rand() <= pm
        # mutations avec flip et shift
        i1 = shift(flips(individu))
        # mutations aléatoire
        i2 = copy(individu)
        mask = rand([true, false],n,n)
        for i=1:n
            for j=1:n
                if i != 1 && j != 1 && i != 10 && j != 10 && !mask[i,j]
                    i2[i,j] = rand(1:4)
                end
            end
        end

        f1, r1 = evaluerIndividu(n, carte, individu)
        f2, r2 = evaluerIndividu(n, carte, i1)
        f3, r3 = evaluerIndividu(n, carte, i2)

        if f1 > f2
            if(f1 > f3) return copy(individu) else return i2 end
        else
            if(f2 > f3) return i1 else return i2 end
        end
    end

    return copy(individu)
end

# -------------------------------------------------------------------------------------------------
# Selectionne un individu survivant entre deux individus
function survivantEnfant( carte, e , em )
    n, m = size(e)
    f1, r1 = evaluerIndividu(n, carte, e)
    f2, r2 = evaluerIndividu(n, carte, em)

    if (r1 && r2) || (!r1 && !r2)
        return (f1 > f2) ? e : em
    elseif r1 && !r2
        return e
    end

    return em
end

# -------------------------------------------------------------------------------------------------
# Recupere la nouvelle generation comme population de base
function changeGeneration(newGen, popSize)
    pop = Vector(undef, popSize)
    NbRealisable = 0
    maxFitness = 0
    minFitness = 100

    for i=1:popSize
        pop[i] = pop!(newGen)
        ind, fitness, realisable = pop[i]
        if realisable
            NbRealisable +=1
            minFitness = min(fitness,minFitness)
        end
        maxFitness = max(fitness,maxFitness)
    end
    println("Nbre Realisable = ", NbRealisable, " minFitnessRealisable = ", minFitness, " maxFitness = ", maxFitness)
    return pop
end

# -------------------------------------------------------------------------------------------------
# Identifie deux individus elites membres de la population
function IdentifieMeilleur( pop , popSize )
    iElite1=0
    existe = false

    # Premier meilleurs
    minFitness=100
    for i=1:popSize
        ind, fitness, realisable = pop[i]
        if (realisable) && (fitness < minFitness)
            iElite1 = i
            minFitness = fitness
            existe = true
        end
    end
    if existe
        @printf(" Longueur de meilleure solution trouvee : %3d\n",minFitness)
    # else
    #    println(" Pas de solution realisable trouvee !")
    end
    return iElite1
end

# -------------------------------------------------------------------------------------------------
# Rock and Roll
function main()
    # partie "creation du labyrinthe"
    numGen = 40
    if length(ARGS) == 1
        numGen = parse(Int64, ARGS[1])
    end

    n = 10
    carte = Matrix{Char}( undef, 21, 21 )
    carte = construireLabyrinthe()
    afficheLabyrinthe( carte )
    contrainteSoftLabyrinthe( carte )
    afficheLabyrinthe( carte )

    # partie "algorithme genetique"
    popSize = 100 # multiple de 2
    pop = creerPopulation( n , popSize , carte )
    alltimebest = []

    for generation=1:numGen
        newGen = []
        @printf("[%5d]  ",generation)

        # reproduction entre individus
        for reproduction=1:Int(popSize / 2)
            p1 = selectionParent( pop )
            p2 = selectionParent( pop )
            e1, e2 = crossover( p1, p2 )
            e1 = survivantEnfant( carte, e1 , mutation( carte, e1 ) )
            e2 = survivantEnfant( carte, e2 , mutation( carte, e2 ) )
            fitness, realisable = evaluerIndividu( n, carte, e1)
            push!( newGen, (e1, fitness, realisable) )
            fitness, realisable = evaluerIndividu( n, carte, e2)
            push!( newGen, (e2, fitness, realisable) )
        end # reproduction

        iBest = IdentifieMeilleur( pop , popSize )
        if iBest !=0
            push!( alltimebest, pop[iBest] )
        end

        pop = changeGeneration( newGen, popSize )

        if numGen > 40 && generation%(numGen//4) == 0
            println("New generation!")
            pop = creerPopulation( n, popSize, carte )
        end
    end # generation
    iBest = IdentifieMeilleur( alltimebest , length(alltimebest) )
    if iBest !=0
        afficheIndividu( alltimebest[iBest], carte )
    else
      println("Pas de solution réalisable trouvée!")
    end
end

main()
