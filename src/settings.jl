export set_options!, set_parameters!, get_option, get_parameter,
       set_limits!, set_setpoint!, set_user_parameters!

"""
    set_options!( model::GRAMPC.Model; options... )

Set solver options in the specified GRAMPC model. The options are specified as keyword arguments,
where the keyword is the option name and the value is the desired value.
"""
set_options!( model::GRAMPC.Model; options... ) = _set_settings!( model; options... )


"""
    set_parameters!( model::GRAMPC.Model; params... )

Set solver parameters in the specified GRAMPC model. The parameters are specified as keyword arguments,
where the keyword is the parameter name and the value is the desired value.
"""
set_parameters!( model::GRAMPC.Model; params... ) = _set_settings!( model; params... )


"""
    get_option( model::GRAMPC.Model, option::Symbol )

Get the current value of the solver option `option` in the GRAMPC model `model`.
"""
get_option( model::GRAMPC.Model, option::Symbol ) = _get_setting( model, option )


"""
    get_parameter( model::GRAMPC.Model, param::Symbol )

Get the current value of the parameter `param` in GRAMPC model `model`.
"""
get_parameter( model::GRAMPC.Model, param::Symbol ) = _get_setting( model, param )


"""
    set_user_parameters!( model::GRAMPC.Model{T}, userparam::T ) where T

Set the user-defined parameters that are passed into every function callback.
"""
set_user_parameters!( model::GRAMPC.Model{T}, userparam::T ) where T = ( model.param= userparam )


"""
    set_limits!( model::GRAMPC.Model, type::Symbol; lb=nothing, ub=nothing )

Set the upper and lower bounds for the inputs and parameters. The valid values for `type` are
`:input` or `:u` for input bounds and `:parameters` or `:p` for parameter bounds. If a bound is
set to `nothing`, it will default to ``∞/-∞`` for the upper/lower bounds respectively.
"""
function set_limits!( model::GRAMPC.Model, type::Symbol; lb=nothing, ub=nothing )
    settingsKey = ""
    len = 0

    if type == :input || type == :u
        settingsKey = "u"
        len = model.Nu
    elseif type == :parameters || type == :p
        settingsKey = "p"
        len = model.Np
    else
        error( "Unknown type $(type)")
    end

    # If a bound isn't specified, it is infinite
    isa( lb, Nothing ) || ( lb = fill( -Inf, len ) )
    isa( ub, Nothing ) || ( ub = fill(  Inf, len ) )

    d = Dict( Symbol( "$(settingsKey)min" ) => lb,
              Symbol( "$(settingsKey)max" ) => ub )

    set_parameters!( model; d... )
end


"""
    set_setpoint!( model::GRAMPC.Model; input=nothing, state=nothing )

Set the desired setpoint for the states and inputs. If it is set to `nothing`, then
no change is made to the setpoint in the problem.
"""
function set_setpoint!( model::GRAMPC.Model; input=nothing, state=nothing )
    d = Dict()

    # If a setpoint isn't specified, it isn't set
    isa( state, Nothing ) || ( d[:xdes] = state )
    isa( input, Nothing ) || ( d[:udes] = input )

    set_parameters!( model; d... )
end
