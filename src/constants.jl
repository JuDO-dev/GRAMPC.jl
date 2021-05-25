# These types are defined in grampc_macro.h, and are used as aliases
# here to allow for easier copy-pasting of the GRAMPC C structures into
# the Julia code.
const typeRNum      = Cdouble
const ctypeRNum     = Cdouble  # This is const in C, but Julia doesn't care about that
const typeInt       = Cint
const ctypeInt      = Cint     # This is const in C, but Julia doesn't care about that
const typeLInt      = Cint
const typeLogical   = Clong
const typeBoolean   = Cint
const typeChar      = Cchar
const typeUSERPARAM = Cvoid

# These status codes are in grampc_mess.h
@bitflag GRAMPCStatus::UInt32 begin
    NONE                            =    0
    GRADIENT_CONVERGED              =    1
    CONSTRAINTS_CONVERGED           =    2
    USED_LINESEARCH_MIN             =    4
    USED_LINESEARCH_MAX             =    8
    USED_LINESEARCH_INIT            =   16
    MULTIPLIER_UPDATED              =   32
    REACHED_MULTIPLIER_MAX          =   64
    REACHED_PENALTY_MAX             =  128
    INFEASIBLE                      =  256
    INTEGRATOR_INPUT_NOT_CONSISTENT =  512
    INTEGRATOR_REACHED_MAXSTEPS     = 1024
    INTEGRATOR_STEPS_TOO_SMALL      = 2048
    INTEGRATOR_MATRIX_IS_SINGULAR   = 4096
    INTEGRATOR_USED_H_MIN           = 8192
end

@enum PenaltyEstimationStatus begin
    SATURATED_PENALTY         = 0
    USED_ACTIVE_CONSTRAINTS   = 1
    USED_CONSTRAINT_TOLERANCE = 2
end

# These values come from the grampc_macro.h file

# Boolean map for the fields that are binary options
const boolMap = Dict{Int, Bool}(
    0 => false,
    1 => true )

# The time discretizations for the "TimeDiscretization" setting field
const timeDiscretization = Dict{Int, Symbol}(
    0 => :uniform,
    1 => :nonuniform )

const timeDiscretizationStrings = Dict{Symbol, String}(
    :uniform => "uniform",
    :nonuniform => "nonuniform" )



# The integrator options for the "Integrator" field
const dynamicsIntegrators = Dict{Int, Symbol}(
    0 => :euler,
    1 => :modeuler,
    2 => :heun,
    3 => :rodas,
    4 => :rk45 )

const dynamicsIntegratorsStrings = Dict{Symbol, String}(
    :euler => "euler",
    :modeuler => "modeuler",
    :heun => "heun",
    :rodas => "rodas",
    :rk45 => "ruku45" )



# The integrator options for the "IntegratorCost" field
const costIntegrators = Dict{Int, Symbol}(
    0 => :trapezoidal,
    1 => :simpson )

const costIntegratorsStrings = Dict{Symbol, String}(
    :trapezoidal => "trapezoidal",
    :simpson => "simpson" )



# The line searches available for the "LineSearchType" field
const lineSearchType = Dict{Int, Symbol}(
    0 => :adaptive,
    1 => :explicit_1,
    2 => :explicit_2 )

const lineSearchTypeStrings = Dict{Symbol, String}(
    :adaptive => "adaptive",
    :explicit_1 => "explicit1",
    :explicit_2 => "explicit2" )



# The method for handling the constraints for the "ConstraintsHandling" field
const constraintHandlingMethod = Dict{Int, Symbol}(
    0 => :external_penalty,
    1 => :augmented_lagrangian )

const constraintHandlingMethodStrings = Dict{Symbol, String}(
    :external_penalty => "extpen",
    :augmented_lagrangian => "auglag" )


# This dictionary maps the field to its setting strings
const optionSymbolStringDict = Dict{Symbol, Dict}(
    :TimeDiscretization => timeDiscretizationStrings,
    :IntegratorCost => costIntegratorsStrings,
    :Integrator => dynamicsIntegratorsStrings,
    :LineSearchType => lineSearchTypeStrings,
    :ConstraintsHandling => constraintHandlingMethodStrings )

const optionSymbolSymbolDict = Dict{Symbol, Dict}(
    :TimeDiscretization => timeDiscretization,
    :IntegratorCost => costIntegrators,
    :Integrator => dynamicsIntegrators,
    :LineSearchType => lineSearchType,
    :ConstraintsHandling => constraintHandlingMethod )
