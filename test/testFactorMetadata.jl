using IncrementalInference
using Test

##

@testset "test default userdata::FactorMetadata..." begin

##

fgt = initfg()

addVariable!(fgt, :x1, ContinuousScalar)
addFactor!(fgt, [:x1], Prior(Normal()))

addVariable!(fgt, :x2, ContinuousScalar)
addFactor!(fgt, [:x1;:x2], LinearRelative(Normal(10,1)))

fc = DFG.getSolverData(getFactor(fgt, :x1x2f1))

@test length(IIF._getCCW(fc).cpt[1].factormetadata.fullvariables) == 2
@test IIF._getCCW(fc).cpt[1].factormetadata.solvefor == :x2

##

end








#
