

export PackedUniform


mutable struct PackedUniform <: PackedSamplableBelief
  a::Float64
  b::Float64
  PackedSamplableTypeJSON::String
end

function convert(::Union{Type{<:PackedSamplableBelief},Type{<:PackedUniform}},
                  obj::Distributions.Uniform)
  #
  packed = PackedUniform(obj.a, obj.b, 
                        "IncrementalInference.PackedUniform")
  #
  return JSON2.write(packed)
end


convert(::Type{<:SamplableBelief}, obj::PackedUniform) = return Uniform(obj.a, obj.b)



# TODO stop-gap string storage of Distrubtion types, should be upgraded to more efficient storage
function normalfromstring(str::AbstractString)
  meanstr = match(r"μ=[+-]?([0-9]*[.])?[0-9]+", str).match
  mean = split(meanstr, '=')[2]
  sigmastr = match(r"σ=[+-]?([0-9]*[.])?[0-9]+", str).match
  sigma = split(sigmastr, '=')[2]
  Normal{Float64}(parse(Float64,mean), parse(Float64,sigma))
end

function mvnormalfromstring(str::AbstractString)
  means = split(split(split(str, 'μ')[2],']')[1],'[')[end]
  mean = Float64[]
  for ms in split(means, ',')
    push!(mean, parse(Float64, ms))
  end
  sigs = split(split(split(str, 'Σ')[2],']')[1],'[')[end]
  sig = Float64[]
  for ms in split(sigs, ';')
    for m in split(ms, ' ')
      length(m) > 0 ? push!(sig, parse(Float64, m)) : nothing
    end
  end
  len = length(mean)
  sigm = reshape(sig, len,len)
  MvNormal(mean, sigm)
end

function categoricalfromstring(str::AbstractString)
  # pstr = match(r"p=\[", str).match
  psubs = split(str, '=')[end]
  psubs = split(psubs, '[')[end]
  psubsub = split(psubs, ']')[1]
  pw = split(psubsub, ',')
  p = parse.(Float64, pw)
  return Categorical(p ./ sum(p))
end


# NOTE SEE EXAMPLE IN src/Flux/FluxModelsSerialization.jl
function _extractDistributionJson(jsonstr::AbstractString, checkJson::AbstractVector{<:AbstractString})
  # Assume first word after split is the type
  mjs = findfirst(r"([a-zA-Z0-9._]+)\w", checkJson[2])
  maybemodule = split(checkJson[2][mjs], '.')
  # get dedicated Module or revert to Main
  packmodule = 1 < length(maybemodule) ? getfield(Main, Symbol(maybemodule[1])) : Main
  packtype = getfield(packmodule, Symbol(maybemodule[end]))
  packed = JSON2.read(jsonstr, packtype)
  # call the dedicated converter for this packed type using dispatch
  convert(SamplableBelief, packed)
end


# NOTE part of new effort to overhaul the SamplableBelief serialization approach
# maybe it all becomes a JSON struct sort of thing in the long run.
StringThemSamplableBeliefs = Union{Normal, MvNormal, Categorical, DiscreteNonParametric, BallTreeDensity, AliasingScalarSampler}
convert(::Type{<:PackedSamplableBelief}, obj::StringThemSamplableBeliefs) = string(obj)


function convert(::Type{<:SamplableBelief}, str::Union{<:PackedSamplableBelief,<:AbstractString})
  # TODO improve use of multidispatch and packing of Distribution types
  # extractdistribution(str::AS) where {AS <: AbstractString}
  # TODO improve use of multidispatch and packing of Distribution types
  # TODO use startswith
  checkJson = split(str, r"PackedSamplableTypeJSON")
  if str == ""
    return nothing
  elseif length(checkJson) == 2
    # TODO this is the new direction for serializing (pack/unpack) of <:Samplable objects
    # NOTE uses intermediate consolidation keyword search pattern `SamplableTypeJSON`
    return _extractDistributionJson(str, checkJson)
  elseif startswith(str, "DiagNormal")
    # Diags are internally squared, so only option here is to sqrt on input.
    return mvnormalfromstring(str)
  elseif occursin(r"FullNormal", str)
    return mvnormalfromstring(str)
  elseif (occursin(r"Normal", str) )# && !occursin(r"FullNormal", str))
    return normalfromstring(str)
  elseif occursin(r"Categorical", str)
    return categoricalfromstring(str)
  elseif occursin(r"DiscreteNonParametric", str)
    return categoricalfromstring(str)
  elseif occursin(r"KDE:", str)
    return convert(BallTreeDensity, str)
  elseif occursin(r"AliasingScalarSampler", str)
    return convert(AliasingScalarSampler, str)
  else
    error("Don't know how to extract distribution from str=$(str)")
  end
end


function convert(::Type{<:PackedSamplableBelief}, obj::SamplableBelief)
  # FIXME must use string, because unpacking templated e.g. PackedType{T} has problems, see DFG #668
  string(obj)
end



#