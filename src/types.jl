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
    Model

The model describing the problem to solve using GRAMPC.
"""
mutable struct Model{T}
    problem::Ptr{CGRAMPC}

    Nx::Int     # Number of state variables
    Nu::Int     # Number of control inputs
    Np::Int     # Number of problem parameters
    Ng::Int     # Number of equality constraints
    Nh::Int     # Number of inequality constraints
    NgT::Int    # Number of terminal equality constraints
    NhT::Int    # Number of terminal inequality constraints

    callbacks::ModelCallbacks

    massMatrix::Matrix{Float64}

    # User-supplied parameters that are passed to the callbacks
    param::T

    # Flag saying if the underlying GRAMPC C model has been created yet
    initialized::Bool

    function Model(; Nx=0, Nu=0, Np=0, Ng=0, Nh=0, NgT=0, NhT=0 )
        model = new{Vector{Float64}}( C_NULL,
                                      Nx, Nu, Np, Ng, Nh, NgT, NhT,
                                      ModelCallbacks(),
                                      Matrix{Float64}( undef, 0, 0 ),
                                      Vector{Float64}( undef, 0 ),
                                      false )

        finalizer( GRAMPC.clean!, model )
        return model
    end

end


"""
    is_initialized( model::Model )

Return if the underlying C structure for the GRAMPC model has been initialized.
"""
function _is_initialized( model::Model )
    return model.initialized
end


function clean!( model::Model )
    if _is_initialized( model )
        ccall( (:grampc_free, libgrampc_julia), Cvoid, (Ptr{CGRAMPC},), model )
    end
end
