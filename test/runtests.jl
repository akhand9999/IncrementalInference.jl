# addprocs(3)
using Test
# using Compat
# using IncrementalInference

include("testApproxConv.jl")

include("testHasPriors913.jl")

include("testInitVariableOrder.jl")

include("testExpXstroke.jl")

include("testBasicRecycling.jl")

include("TestModuleFunctions.jl")

include("testStateMachine.jl")

include("testCompareVariablesFactors.jl")

include("typeReturnMemRef.jl")

include("basicGraphsOperations.jl")

include("testMixturePrior.jl")

include("testPartialFactors.jl")

include("testBayesTreeiSAM2Example.jl")

include("testSpecialSampler.jl")

include("testSaveLoadDFG.jl")

include("testJunctionTreeConstruction.jl")

#FIXME fails on MetaBayesTree
include("testTreeSaveLoad.jl")

include("saveconvertertypes.jl")

include("testgraphpackingconverters.jl")

include("testNLsolve.jl")

# Randomized roots no longer supported, see PR #1075
# include("testNumericRootGenericRandomized.jl")

include("testCommonConvWrapper.jl")

include("testBasicForwardConvolve.jl")

include("testFactorMetadata.jl")

include("testBasicCSM.jl")

include("testCliqueFactors.jl")

include("testCcolamdOrdering.jl")

include("testBasicGraphs.jl")

include("testDefaultDeconv.jl")

include("testJointEnforcement.jl")

include("testlocalconstraintexamples.jl")

include("testBasicTreeInit.jl")

include("testSolveOrphanedFG.jl")

include("testSolveSetPPE.jl")

include("testEuclidDistance.jl")

include("priorusetest.jl")

include("testVariousNSolveSize.jl")

include("testExplicitMultihypo.jl")

include("TestCSMMultihypo.jl")

include("testMultihypoFMD.jl")

include("testMultiHypo2Door.jl")

include("testMultimodal1D.jl")

include("testMultihypoAndChain.jl")

include("testMultithreaded.jl")

include("testpartialconstraint.jl")

include("testnullhypothesis.jl")

include("testmultihypothesisapi.jl")

include("fourdoortest.jl")

include("testSphere1.jl")

include("testMixtureLinearConditional.jl")

include("testFluxModelsDistribution.jl")

include("testDERelative.jl")

include("testAnalysisTools.jl")

include("testBasicParametric.jl")

# dont run test on ARM, as per issue #527
if Base.Sys.ARCH in [:x86_64;]
  include("testTexTreeIllustration.jl")
end

include("testMultiprocess.jl")

include("testDeadReckoningTether.jl")

include("testCSMMonitor.jl")

include("testSkipUpDown.jl")

include("testTreeFunctions.jl")


#
