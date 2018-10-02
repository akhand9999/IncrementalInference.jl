using IncrementalInference
using Test


@testset "test solve by saving and loading basic jld..." begin


global fgt = emptyFactorGraph()

addNode!(fgt, :x1, ContinuousScalar)
addFactor!(fgt, [:x1], Prior(Normal()))

addNode!(fgt, :x2, ContinuousScalar)
addFactor!(fgt, [:x1;:x2], LinearConditional(Normal(10,1)))

savejld(fgt)
# savejld(fgt, file=joinpath(Pkg.dir("IncrementalInference"),"test","testdata","compatibility_test_fg.jld"))
global fgl, = loadjld()

global fct = getData(fgt, :x1x2f1, nt=:fct).fnc.cpt[1].factormetadata
global fcl = getData(fgl, :x1x2f1, nt=:fct).fnc.cpt[1].factormetadata

@test fct.solvefor == fcl.solvefor
@test length(fct.variableuserdata) == length(fcl.variableuserdata)

batchSolve!(fgt)
batchSolve!(fgl)

# test again after solve
@test fct.solvefor == fcl.solvefor
@test length(fct.variableuserdata) == length(fcl.variableuserdata)

# save load and repeat tests
savejld(fgt)
global fgl, = loadjld()

Base.rm("tempfg.jld2")

global fct = getData(fgt, :x1x2f1, nt=:fct).fnc.cpt[1].factormetadata
global fcl = getData(fgl, :x1x2f1, nt=:fct).fnc.cpt[1].factormetadata

# @test fct.solvefor == fcl.solvefor # defaults to :null during load
@test length(fct.variableuserdata) == length(fcl.variableuserdata)


end



@testset "test backwards compatibility of loadjld from previous versions of IIF (from an existing test data file)..." begin


global filename = joinpath(dirname(pathof(IncrementalInference)), "..", "test","testdata","compatibility_test_fg.jld2")
global fgprev, = loadjld(file=filename )

global fc = getData(getVert(fgprev, :x1x2f1, nt=:fnc))
@test length(fc.fnc.cpt[1].factormetadata.variableuserdata) == 2
@test fc.fnc.cpt[1].factormetadata.solvefor == :null

batchSolve!(fgprev)


end








#