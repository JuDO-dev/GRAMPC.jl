
export setup!, solve!, estimate_penalty_min!

"""
    setup!( model::GRAMPC.Model; settings... )

Initialize the GRAMPC problem so it is ready to solve.

Settings for the solver can be specified by passing in keyword argument pairs.
"""
function setup!( model::GRAMPC.Model; settings... )
    _is_initialized( model ) && error( "Model already initialized" )

    # The GRAMPC library takes a double pointer to create the problem, so we must create a temp
    # reference to handle this
    problem = Ref{Ptr{CGRAMPC}}()
    ccall( (:grampcjl_init, libgrampc_julia), Cvoid, (Ptr{Ptr{CGRAMPC}}, Ref{Cgrampcjl_callbacks}, Ref{Model}), problem, model.Ccallbacks, model )
    model.problem = problem[]

    # Enable/disable solver parts based on specified callbacks
    _set_settings!( model, OptimControl=model.optimizeu,
                           OptimParam=model.optimizep,
                           OptimTime=model.optimizeT,
                           IntegralCost=model.integralCost,
                           TerminalCost=model.terminalCost,
                           EqualityConstraints=model.eqCon,
                           InequalityConstraints=model.ineqCon,
                           TerminalEqualityConstraints=model.termEqCon,
                           TerminalInequalityConstraints=model.termIneqCon )

    # The user can provide options here as kwargs, so pass them to the solver
    _set_settings!( model; settings...)
end


function solve!( model::Model )
    _is_initialized( model ) || error( "Model not initialized" )

    ccall( (:grampc_run, libgrampc_julia), Cvoid, (Ptr{CGRAMPC},), model.problem )

    return Solution( model )
end



function estimate_penalty_min!( model::GRAMPC.Model; runonce=true )
    _is_initialized( model ) || error( "Model not initialized" )

    run = runonce ? 1 : 0

    ret = ccall( (:grampc_estim_penmin, libgrampc_julia), Cint, (Ptr{CGRAMPC}, Cint), model.problem, run )

    return PenaltyEstimationStatus( ret )
end
