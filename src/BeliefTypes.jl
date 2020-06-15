
# """
#     CliqStatus
# Clique status message enumerated type with status.
#
# DevNotes
# - Temporary convert to Symbol to support #459 consolidation effort
# - Long term enum looks like a good idea (see #744)
# """
# @enum CliqStatus NULL INITIALIZED UPSOLVED MARGINALIZED DOWNSOLVED UPRECYCLED ERROR_STATUS
const CliqStatus = Symbol
## Currently same name by used as Symbol, e.g. :NULL, ...
## Older status names
# :null; :upsolved; :downsolved; :marginalized; :uprecycled,
## FIXME, consolidate at end of #459 work

"""
    $TYPEDEF

INTERMEDIATE DATA STRUCTURE DURING REFACTORING.

Representation of the belief of a single variable.

Notes:
- we want to send the joint, this is just to resolve consolidation #459 first.
- Long term objective is single joint definition, likely called `LikelihoodMessage`.
"""
struct TreeBelief{T <: InferenceVariable}
  val::Array{Float64,2}
  bw::Array{Float64,2}
  inferdim::Float64
  softtype::T
  # TODO -- DEPRECATE
  manifolds::Tuple{Vararg{Symbol}}# TODO #459
end
TreeBelief(p::BallTreeDensity,
           inferdim::Real=0.0,
           softtype::T=ContinuousScalar(),
           manifolds=getManifolds(softtype)) where {T <: InferenceVariable} = TreeBelief{T}(getPoints(p), getBW(p), inferdim, softtype, manifolds)

TreeBelief(val::Array{Float64,2},
           bw::Array{Float64,2},
           inferdim::Real=0.0,
           softtype::T=ContinuousScalar(),
           manifolds=getManifolds(softtype)) where {T <: InferenceVariable} = TreeBelief{T}(val, bw, inferdim, softtype, manifolds)

function TreeBelief(vnd::VariableNodeData)
  TreeBelief( vnd.val, vnd.bw, vnd.inferdim, getSofttype(vnd), getManifolds(vnd) )
end

TreeBelief(vari::DFGVariable, solveKey=:default) = TreeBelief(getSolverData(vari, solveKey))

getManifolds(treeb::TreeBelief) = getManifolds(treeb.softtype)


"""
  $(TYPEDEF)
Belief message for message passing on the tree.  This should be considered an incomplete joint probility.

Notes:
- belief -> Dictionary of [`TreeBelief`](@ref)
- variableOrder -> Ordered variable id list of the seperators in cliqueLikelihood
- cliqueLikelihood -> marginal distribution (<: `SamplableBelief`) over clique seperators.
- Older names include: productFactor, Fnew, MsgPrior, LikelihoodMessage

DevNotes:
- Used by both nonparametric and parametric.
- Objective for parametric case: `MvNormal(μ=[:x0;:x2;:l5], Σ=[+ * *; * + *; * * +])`.
- Part of the consolidation effort, see #459.
- Better conditioning for joint structure in the works using deconvolution, see #579, #635.
  - TODO confirm why <: Singleton.

  $(TYPEDFIELDS)
"""
mutable struct LikelihoodMessage <: Singleton
  status::CliqStatus
  belief::Dict{Symbol, TreeBelief}
  variableOrder::Vector{Symbol}
  cliqueLikelihood::Union{Nothing,SamplableBelief}
end


LikelihoodMessage(;status::CliqStatus=:NULL,
                   beliefDict::Dict=Dict{Symbol, TreeBelief}(),
                   variableOrder=Symbol[],
                   cliqueLikelihood=nothing ) =
        LikelihoodMessage(status, beliefDict, variableOrder, cliqueLikelihood)
#


# FIXME, better standardize intermediate types
# used during nonparametric CK preparation, when information from multiple siblings must be shared together
const IntermediateSiblingMessages = Vector{Tuple{BallTreeDensity,Float64}}
const IntermediateMultiSiblingMessages = Dict{Symbol, IntermediateSiblingMessages}

const TempUpMsgPlotting = Dict{Symbol,Vector{Tuple{Symbol, Int, BallTreeDensity, Float64}}}


"""
$(TYPEDEF)
"""
mutable struct PotProd
    Xi::Symbol # Int
    prev::Array{Float64,2}
    product::Array{Float64,2}
    potentials::Array{BallTreeDensity,1}
    potentialfac::Vector{Symbol}
end
"""
$(TYPEDEF)
"""
mutable struct CliqGibbsMC
    prods::Array{PotProd,1}
    lbls::Vector{Symbol}
    CliqGibbsMC() = new()
    CliqGibbsMC(a,b) = new(a,b)
end
"""
$(TYPEDEF)
"""
mutable struct DebugCliqMCMC
  mcmc::Union{Nothing, Array{CliqGibbsMC,1}}
  outmsg::LikelihoodMessage
  outmsglbls::Dict{Symbol, Symbol} # Int
  priorprods::Vector{CliqGibbsMC}
  DebugCliqMCMC() = new()
  DebugCliqMCMC(a,b,c,d) = new(a,b,c,d)
end

"""
$(TYPEDEF)
"""
mutable struct UpReturnBPType
  upMsgs::LikelihoodMessage
  dbgUp::DebugCliqMCMC
  IDvals::Dict{Symbol, TreeBelief}
  keepupmsgs::LikelihoodMessage # Dict{Symbol, BallTreeDensity} # TODO Why separate upMsgs?
  totalsolve::Bool
  UpReturnBPType() = new()
  UpReturnBPType(x1,x2,x3,x4,x5) = new(x1,x2,x3,x4,x5)
end

"""
$(TYPEDEF)

TODO refactor msgs into only a single variable
"""
mutable struct DownReturnBPType
  dwnMsg::LikelihoodMessage
  dbgDwn::DebugCliqMCMC
  IDvals::Dict{Symbol,TreeBelief}
  keepdwnmsgs::LikelihoodMessage
end


"""
$(TYPEDEF)
"""
mutable struct MsgPassType
  fg::GraphsDFG
  cliq::TreeClique
  vid::Symbol # Int
  msgs::Array{LikelihoodMessage,1}
  N::Int
end





#
