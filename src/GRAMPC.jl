module GRAMPC

using BitFlags
using GRAMPC_jll
using LinearAlgebra

const CallbackArg = Union{Symbol, Function}
const Callback    = Union{Function, Nothing}
const MassMatrix  = Union{Array{Float64}, UniformScaling}

# Define the library error handling
include( "cinterface/errorHandling.jl" )

# Constants used in this package
include( "constants.jl" )

# Must come before the ctypes because this defines the wrapper struct
include( "cinterface/wrapperFunctions.jl" )

# Most types used in this package
include( "cinterface/ctypes.jl" )
include( "types.jl" )

# Low-level problem translation for the C wrapper
include( "cinterface/options.jl" )
include( "cinterface/interface.jl" )

# High-level Julia part of the interface
include( "callbacks/dynamics.jl" )
include( "callbacks/cost.jl" )
include( "callbacks/constraints.jl" )
include( "settings.jl" )

end
