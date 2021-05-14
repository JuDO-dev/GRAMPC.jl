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
const lineSearchTypes = Dict{Int, Symbol}(
    0 => :adaptive,
    1 => :explicit_1,
    2 => :explicit_2 )

const lineSearchTypesStrings = Dict{Symbol, String}(
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
const settingStrings = Dict{Symbol, Dict}(
    :TimeDiscretization => timeDiscretizationStrings,
    :IntegratorCost => costIntegratorsStrings,
    :Integrator => dynamicsIntegratorsStrings,
    :LineSearchType => lineSearchTypesStrings,
    :ConstraintsHandling => constraintHandlingMethodStrings )
