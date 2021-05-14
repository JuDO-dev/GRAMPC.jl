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


"""
    set_options!( model::GRAMPC.Model; kwargs... )

Set solver options in the specified GRAMPC model. The options are specified as keyword arguments,
where the keyword is the option name and the value is the desired setting's value.
"""
function set_options!( model::GRAMPC.Model; kwargs... )

    if isempty(kwargs)
        return
    end

    # We need an initialized model to set the options
    if !_is_initialized( model )
        error( "Model must be initialized before options can be set" )
    end

    for (key, value) in kwargs
        keyString = String( key )

        if( key in intOptions )
            ccall( (:grampc_setopt_int, libgrampc_julia), Cvoid, (Ptr{CGRAMPC}, Cstring, typeInt), model.problem, keyString, value )

        elseif( key in realOptions )
            ccall( (:grampc_setopt_real, libgrampc_julia), Cvoid, (Ptr{CGRAMPC}, Cstring, typeRNum), model.problem, keyString, value )

        elseif( key in stringOptions )
            # Look-up the string to use to set the setting
            optDict = settingStrings[key]
            valString = optDict[value]
            ccall( (:grampc_setopt_string, libgrampc_julia), Cvoid, (Ptr{CGRAMPC}, Cstring, Cstring), model.problem, keyString, valString )

        elseif( key in boolOptions )
            # Boolean options are handled by passing in a string of either "on" or "off"
            boolString = value ? "on" : "off"
            ccall( (:grampc_setopt_string, libgrampc_julia), Cvoid, (Ptr{CGRAMPC}, Cstring, Cstring), model.problem, keyString, boolString )

        else
            error( "Unknown setting $keyString" )

        end
    end

end
