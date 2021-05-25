const realOptions = [ :IntegratorRelTol, :IntegratorAbsTol, :IntegratorMinStepSize, :LineSearchMax, :LineSearchMin,
                      :LineSearchInit, :LineSearchAdaptAbsTol, :LineSearchAdaptFactor, :LineSearchIntervalTol,
                      :LineSearchIntervalFactor, :OptimParamLineSearchFactor, :OptimTimeLineSearchFactor,
                      :TScale, :TOffset, :JScale, :MultiplierMax, :MultiplierDampingFactor, :PenaltyMax,
                      :PenaltyMin, :PenaltyIncreaseFactor, :PenaltyDecreaseFactor, :PenaltyIncreaseThreshold,
                      :AugLagUpdateGradientRelTol, :ConvergenceGradientRelTol ]

const intOptions = [ :MaxGradIter, :MaxMultIter, :Nhor, :IntegratorMaxSteps ]

const stringOptions = [ :TimeDiscretization, :IntegratorCost, :Integrator, :LineSearchType, :ConstraintsHandling ]

const boolOptions = [ :ShiftControl, :ScaleProblem, :LineSearchExpAutoFallback, :OptimControl,
                      :OptimParam, :OptimTime, :IntegralCost, :TerminalCost, :EqualityConstraints,
                      :InequalityConstraints, :TerminalEqualityConstraints, :TerminalInequalityConstraints,
                      :ConvergenceCheck ]

const realVectorOptions = [ :xScale, :xOffset, :uScale, :uOffset, :pScale, :pOffset, :cScale, :ConstraintsAbsTol ]

const intVectorOptions = [ :FlagsRodas ]

const vectorParameters = [ :x0, :xdes, :u0, :udes, :umax, :umin, :p0, :pmax, :pmin ]

const scalarParameters = [ :Thor, :Tmax, :Tmin, :dt, :t0 ]

"""
    _set_settings!( model::GRAMPC.Model; settings... )

Internal helper function to pass all settings (options and parameters) to the underlying C solver.
"""
function _set_settings!( model::GRAMPC.Model; settings... )
    isempty( settings ) && return

    # We need an initialized model to set the options
    _is_initialized( model ) || error( "Model must be initialized before options can be set" )

    for (key, value) in settings
        keyString = String( key )

        if( key in intOptions )
            ccall( (:grampc_setopt_int, libgrampc_julia), Cvoid, (Ptr{CGRAMPC}, Cstring, typeInt), model.problem, keyString, value )

        elseif( key in realOptions )
            ccall( (:grampc_setopt_real, libgrampc_julia), Cvoid, (Ptr{CGRAMPC}, Cstring, typeRNum), model.problem, keyString, value )

        elseif( key in stringOptions )
            # Look-up the string to use to set the setting
            optDict = optionSymbolStringDict[key]
            valString = optDict[value]
            ccall( (:grampc_setopt_string, libgrampc_julia), Cvoid, (Ptr{CGRAMPC}, Cstring, Cstring), model.problem, keyString, valString )

        elseif( key in boolOptions )
            # Boolean options are handled by passing in a string of either "on" or "off"
            boolString = value ? "on" : "off"
            ccall( (:grampc_setopt_string, libgrampc_julia), Cvoid, (Ptr{CGRAMPC}, Cstring, Cstring), model.problem, keyString, boolString )

        elseif( key in realVectorOptions )
            ccall( (:grampc_setopt_real_vector, libgrampc_julia), Cvoid, (Ptr{CGRAMPC}, Cstring, Ptr{typeRNum}), model.problem, keyString, value )

        elseif( key in intVectorOptions )
            ccall( (:grampc_setopt_int_vector, libgrampc_julia), Cvoid, (Ptr{CGRAMPC}, Cstring, Ptr{typeInt}), model.problem, keyString, value )

        elseif( key in vectorParameters )
            ccall( (:grampc_setparam_real_vector, libgrampc_julia), Cvoid, (Ptr{CGRAMPC}, Cstring, Ptr{typeRNum}), model.problem, keyString, value )

        elseif( key in scalarParameters )
            ccall( (:grampc_setparam_real, libgrampc_julia), Cvoid, (Ptr{CGRAMPC}, Cstring, typeRNum), model.problem, keyString, value )

        else
            error( "Unknown setting $keyString" )

        end
    end
end


function _get_setting( model::GRAMPC.Model, setting::Symbol )
    _is_initialized( model ) || error( "Model not initialized" )

    problem = unsafe_load( model.problem )

    options = unsafe_load( problem.opt )
    params  = unsafe_load( problem.param )

    if( setting in intOptions )
        return getproperty( options, setting )

    elseif( setting in realOptions )
        return getproperty( options, setting )

    elseif( setting in stringOptions )
        # Look-up the string to use to set the setting
        optDict = optionSymbolSymbolDict[setting]
        return optDict[getproperty( options, setting )]

    elseif( setting in boolOptions )
        return boolMap[getproperty( options, setting )]

    elseif( setting in realVectorOptions )
        a = unsafe_wrap( Array, getproperty( options, setting ), _get_setting_vector_length( model, setting ) )
        return a

    elseif( setting in intVectorOptions )
        a = unsafe_wrap( Array, getproperty( options, setting ), _get_setting_vector_length( model, setting ) )
        return a

    elseif( setting in vectorParameters )
        a = unsafe_wrap( Array, getproperty( params, setting ), _get_setting_vector_length( model, setting ) )
        return a

    elseif( setting in scalarParameters )
        return getproperty( params, setting )

    else
        error( "Unknown setting $(String(setting))" )

    end

end


function _get_setting_vector_length( model::GRAMPC.Model, setting::Symbol )
    if setting == :FlagsRodas
        return 8

    elseif setting == :x0 || setting == :xdes || setting == :xScale || setting == :xOffset
        return model.Nx

    elseif setting == :u0 || setting == :udes || setting == :umax || setting == :umin || setting == :uScale || setting == :uOffset
        return model.Nu

    elseif setting == :p0 || setting == :pmax || setting == :pmin || setting == :pScale || setting == :pOffset

        return model.Np
    elseif setting == :cScale || setting == :ConstraintsAbsTol
        problem = unsafe_load( model.problem )
        params  = unsafe_load( problem.param )

        return params.Nc
    end
end
