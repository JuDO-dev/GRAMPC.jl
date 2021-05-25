"""
    ModelCallbacks

The function callbacks for the dynamics and constraints.
"""
mutable struct ModelCallbacks

    ffct_cb::Callback
    dfdx_vec_cb::Callback
    dfdu_vec_cb::Callback
    dfdp_vec_cb::Callback

    lfct_cb::Callback
    dldx_cb::Callback
    dldu_cb::Callback
    dldp_cb::Callback

    Vfct_cb::Callback
    dVdx_cb::Callback
    dVdp_cb::Callback
    dVdT_cb::Callback

    gfct_cb::Callback
    dgdx_vec_cb::Callback
    dgdu_vec_cb::Callback
    dgdp_vec_cb::Callback

    hfct_cb::Callback
    dhdx_vec_cb::Callback
    dhdu_vec_cb::Callback
    dhdp_vec_cb::Callback

    gTfct_cb::Callback
    dgTdx_vec_cb::Callback
    dgTdp_vec_cb::Callback
    dgTdT_vec_cb::Callback

    hTfct_cb::Callback
    dhTdx_vec_cb::Callback
    dhTdp_vec_cb::Callback
    dhTdT_vec_cb::Callback

    dfdx_cb::Callback
    dfdxtrans_cb::Callback
    dfdt_cb::Callback
    dHdxdt_cb::Callback

    function ModelCallbacks()
        return new( nothing, nothing, nothing, nothing, nothing, nothing, nothing, nothing, nothing, nothing, nothing, nothing,
                    nothing, nothing, nothing, nothing, nothing, nothing, nothing, nothing, nothing, nothing, nothing, nothing,
                    nothing, nothing, nothing, nothing, nothing, nothing, nothing, nothing )
    end
end


"""
    Model( model::Model; states=0, inputs=0, parameters=0, eqcon=0, ineqcon=0, terminal_eqcon=0, terminal_ineqcon=0 )

The model describing the problem to solve using GRAMPC. The arguments set the dimensions of the created model.

* `states` is the number of states the dynamics have
* `inputs` is the number of inputs the dynamics have
* `parameters` is the number of parameters in the problem
* `eqcon` is the number of equality constraints in the problem
* `ineqcon` is the number of inequality constraints in the problem
* `terminal_eqcon` is the number of terminal equality constraints in the problem
* `terminal_ineqcon` is the number of terminal inequality constraints in the problem
"""
mutable struct Model{T}
    # C pointer to the underlying GRAMPC solver problem
    problem::Ptr{CGRAMPC}
    Ccallbacks::Cgrampcjl_callbacks

    # Problem size
    Nx::Int     # Number of state variables
    Nu::Int     # Number of control inputs
    Np::Int     # Number of problem parameters
    Ng::Int     # Number of equality constraints
    Nh::Int     # Number of inequality constraints
    NgT::Int    # Number of terminal equality constraints
    NhT::Int    # Number of terminal inequality constraints

    # Which optimization parts are enabled
    optimizeu::Bool
    optimizep::Bool
    optimizeT::Bool
    eqCon::Bool
    ineqCon::Bool
    termEqCon::Bool
    termIneqCon::Bool
    integralCost::Bool
    terminalCost::Bool


    # Dynamics information, cost and constraints
    callbacks::ModelCallbacks
    massMatrix::Matrix{Float64}

    # User-supplied parameters that are passed to the callbacks
    param::T


    function Model(; states=0, inputs=0, parameters=0, eqcon=0, ineqcon=0, terminal_eqcon=0, terminal_ineqcon=0 )
        model = new{Vector{Float64}}( C_NULL, Cgrampcjl_callbacks(),
                                      states, inputs, parameters, eqcon, ineqcon, terminal_eqcon, terminal_ineqcon,
                                      true, false, false, false, false, false, false, false, false,
                                      ModelCallbacks(),
                                      Matrix{Float64}( undef, 0, 0 ),
                                      Vector{Float64}( undef, 0 ) )

        finalizer( GRAMPC.clean!, model )
        return model
    end

end


"""
    is_initialized( model::Model )

Return if the underlying C structure for the GRAMPC model has been initialized.
"""
function _is_initialized( model::Model )
    return model.problem != C_NULL
end


function clean!( model::Model )
    if _is_initialized( model )
        ccall( (:grampcjl_free, libgrampc_julia), Cvoid, (Ptr{CGRAMPC},), model.problem )
    end
end


# Julia wrapper for typeGRAMPCsol, which contains the (public) solution data
struct Solution
    x::Vector{Float64}
    u::Vector{Float64}
    p::Vector{Float64}

    T::Float64
    J::Vector{Float64} # A 2-element array
    constraint_norm::Float64
    penalty_norm::Float64

    grad_iter::Vector{Int32}

    status::GRAMPCStatus

    function Solution( model::Model )
        _is_initialized( model ) || return

        x = Float64[]
        u = Float64[]
        p = Float64[]
        J = Float64[]
        iter = Int32[]

        problem = unsafe_load( model.problem )
        csol    = unsafe_load( problem.sol )

        # The C array will be unallocated if there are no uses of that variable
        ( model.Nx > 0 ) && ( x = unsafe_wrap( Array, csol.xnext, model.Nx ) )
        ( model.Nu > 0 ) && ( u = unsafe_wrap( Array, csol.unext, model.Nu ) )
        ( model.Np > 0 ) && ( p = unsafe_wrap( Array, csol.pnext, model.Np ) )

        J = unsafe_wrap( Array, csol.J , 2 )

        # Number of gradient iterations every
        numIter = _get_setting( model, :MaxMultIter )
        iter = unsafe_wrap( Array, csol.iter, numIter )

        return new( x, u, p, csol.Tnext, J, csol.cfct, csol.pen, iter, GRAMPCStatus( csol.status ) )
    end
end
