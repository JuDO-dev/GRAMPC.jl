# Get the dimensions of the problem
function ocp_dim_wrapper( Nx::Ptr{typeInt}, Nu::Ptr{typeInt}, Np::Ptr{typeInt}, Ng::Ptr{typeInt},
                          Nh::Ptr{typeInt}, NgT::Ptr{typeInt}, NhT::Ptr{typeInt}, userparam::Ptr{typeUSERPARAM} )

    # Extract the GRAMPC problem
    model = unsafe_pointer_to_objref( userparam )::GRAMPC.Model

    # Return the problem dimension to the C code
    unsafe_store!( Nx,  model.Nx )
    unsafe_store!( Nu,  model.Nu )
    unsafe_store!( Np,  model.Np )
    unsafe_store!( Ng,  model.Ng )
    unsafe_store!( Nh,  model.Nh )
    unsafe_store!( NgT, model.NgT )
    unsafe_store!( NhT, model.NhT )
end


#########################################################################################
# System dynamics
#########################################################################################

# System function f(t,x,u,p,userparam)
function ffct_wrapper( out_ptr::Ptr{typeRNum}, t_in::ctypeRNum, x_ptr::Ptr{ctypeRNum}, u_ptr::Ptr{ctypeRNum}, p_ptr::Ptr{ctypeRNum},
                       userparam::Ptr{typeUSERPARAM} )

    # Extract the GRAMPC problem
    model = unsafe_pointer_to_objref( userparam )::GRAMPC.Model

    # Don't do anything if no callback is defined
    isa( model.callbacks.ffct_cb, Nothing ) && return

    t = unsafe_load( t_in )
    x = unsafe_wrap( Array, x_ptr, Int( model.Nx ) )
    u = unsafe_wrap( Array, u_ptr, Int( model.Nu ) )
    p = unsafe_wrap( Array, p_ptr, Int( model.Np ) )

    dx = unsafe_wrap( Array, out_ptr, Int( model.Nx ) )

    # Call the callback
    model.callbacks.ffct_cb( dx, x, u, p, t, model.param )
end


# Jacobian df/dx multiplied by vector vec, i.e. (df/dx)^T*vec or vec^T*(df/dx)
function dfdx_vec_wrapper( out_ptr::Ptr{typeRNum}, t_in::ctypeRNum, x_ptr::Ptr{ctypeRNum}, vec_ptr::Ptr{ctypeRNum}, u_ptr::Ptr{ctypeRNum},
                           p_ptr::Ptr{ctypeRNum}, userparam::Ptr{typeUSERPARAM} )

    # Extract the GRAMPC problem
    model = unsafe_pointer_to_objref( userparam )::GRAMPC.Model

    # Don't do anything if no callback is defined
    isa( model.callbacks.dfdx_vec_cb, Nothing ) && return

    t   = Float64( t_in )
    x   = unsafe_wrap( Array, x_ptr, Int( model.Nx ) )
    u   = unsafe_wrap( Array, u_ptr, Int( model.Nu ) )
    p   = unsafe_wrap( Array, p_ptr, Int( model.Np ) )
    vec = unsafe_wrap( Array, p_ptr, Int( model.Nx ) )
    res = unsafe_wrap( Array, out_ptr, Int( model.Nx ) )

    # Call the callback
    model.callbacks.dfdx_vec_cb( res, x, u, p, t, vec, model.param )
end


# Jacobian df/du multiplied by vector vec, i.e. (df/du)^T*vec or vec^T*(df/du)
function dfdu_vec_wrapper( out_ptr::Ptr{typeRNum}, t_in::ctypeRNum, x_ptr::Ptr{ctypeRNum}, vec_ptr::Ptr{ctypeRNum}, u_ptr::Ptr{ctypeRNum},
                           p_ptr::Ptr{ctypeRNum}, userparam::Ptr{typeUSERPARAM} )

    # Extract the GRAMPC problem
    model = unsafe_pointer_to_objref( userparam )::GRAMPC.Model

    # Don't do anything if no callback is defined
    isa( model.callbacks.dfdu_vec_cb, Nothing ) && return

    t   = Float64( t_in )
    x   = unsafe_wrap( Array, x_ptr, Int( model.Nx ) )
    u   = unsafe_wrap( Array, u_ptr, Int( model.Nu ) )
    p   = unsafe_wrap( Array, p_ptr, Int( model.Np ) )
    vec = unsafe_wrap( Array, p_ptr, Int( model.Nx ) )
    res = unsafe_wrap( Array, out_ptr, Int( model.Nu ) )

    # Call the callback
    model.callbacks.dfdu_vec_cb( res, x, u, p, t, vec, model.param )
end


# Jacobian df/dp multiplied by vector vec, i.e. (df/dp)^T*vec or vec^T*(df/dp)
function dfdp_vec_wrapper( out_ptr::Ptr{typeRNum}, t_in::ctypeRNum, x_ptr::Ptr{ctypeRNum}, vec_ptr::Ptr{ctypeRNum}, u_ptr::Ptr{ctypeRNum},
                           p_ptr::Ptr{ctypeRNum}, userparam::Ptr{typeUSERPARAM} )

    # Extract the GRAMPC problem
    model = unsafe_pointer_to_objref( userparam )::GRAMPC.Model

    # Don't do anything if no callback is defined
    isa( model.callbacks.dfdp_vec_cb, Nothing ) && return

    t   = Float64( t_in )
    x   = unsafe_wrap( Array, x_ptr, Int( model.Nx ) )
    u   = unsafe_wrap( Array, u_ptr, Int( model.Nu ) )
    p   = unsafe_wrap( Array, p_ptr, Int( model.Np ) )
    vec = unsafe_wrap( Array, p_ptr, Int( model.Nx ) )
    res = unsafe_wrap( Array, out_ptr, Int( model.Np ) )

    # Call the callback
    model.callbacks.dfdp_vec_cb( res, x, u, p, t, vec, model.param )
end


#########################################################################################
# Integral cost term
#########################################################################################

# Integral cost l(t,x(t),u(t),p,xdes,udes,userparam)
function lfct_wrapper( out_ptr::Ptr{typeRNum}, t_in::ctypeRNum, x_ptr::Ptr{ctypeRNum}, u_ptr::Ptr{ctypeRNum}, p_ptr::Ptr{ctypeRNum},
                       xdes_ptr::Ptr{ctypeRNum}, udes::Ptr{ctypeRNum}, userparam::Ptr{typeUSERPARAM} )
end


# Gradient dl/dx
function dldx_wrapper( out_ptr::Ptr{typeRNum}, t_in::ctypeRNum, x_ptr::Ptr{ctypeRNum}, u_ptr::Ptr{ctypeRNum}, p_ptr::Ptr{ctypeRNum},
                       xdes_ptr::Ptr{ctypeRNum}, udes::Ptr{ctypeRNum}, userparam::Ptr{typeUSERPARAM} )
end


# Gradient dl/du
function dldu_wrapper( out_ptr::Ptr{typeRNum}, t_in::ctypeRNum, x_ptr::Ptr{ctypeRNum}, u_ptr::Ptr{ctypeRNum}, p_ptr::Ptr{ctypeRNum},
                       xdes_ptr::Ptr{ctypeRNum}, udes::Ptr{ctypeRNum}, userparam::Ptr{typeUSERPARAM} )
end


# Gradient dl/dp
function dldp_wrapper( out_ptr::Ptr{typeRNum}, t_in::ctypeRNum, x_ptr::Ptr{ctypeRNum}, u_ptr::Ptr{ctypeRNum}, p_ptr::Ptr{ctypeRNum},
                       xdes_ptr::Ptr{ctypeRNum}, udes::Ptr{ctypeRNum}, userparam::Ptr{typeUSERPARAM} )
end


#########################################################################################
# Terminal cost term
#########################################################################################

# Terminal cost V(T,x(T),p,xdes,userparam)
function Vfct_wrapper( out_ptr::Ptr{typeRNum}, T_in::ctypeRNum, x_ptr::Ptr{ctypeRNum}, p_ptr::Ptr{ctypeRNum}, xdes_ptr::Ptr{ctypeRNum},
                       userparam::Ptr{typeUSERPARAM} )
end


# Gradient dV/dx
function dVdx_wrapper( out_ptr::Ptr{typeRNum}, T_in::ctypeRNum, x_ptr::Ptr{ctypeRNum}, p_ptr::Ptr{ctypeRNum}, xdes_ptr::Ptr{ctypeRNum},
                       userparam::Ptr{typeUSERPARAM} )
end


# Gradient dV/dp
function dVdp_wrapper( out_ptr::Ptr{typeRNum}, T_in::ctypeRNum, x_ptr::Ptr{ctypeRNum}, p_ptr::Ptr{ctypeRNum}, xdes_ptr::Ptr{ctypeRNum},
                       userparam::Ptr{typeUSERPARAM} )
end


# Gradient dV/dT
function dVdT_wrapper( out_ptr::Ptr{typeRNum}, T_in::ctypeRNum, x_ptr::Ptr{ctypeRNum}, p_ptr::Ptr{ctypeRNum}, xdes_ptr::Ptr{ctypeRNum},
                       userparam::Ptr{typeUSERPARAM} )
end


#########################################################################################
# Equality constraints
#########################################################################################

# Equality constraints g(t,x(t),u(t),p,userparam) = 0
function gfct_wrapper( out_ptr::Ptr{typeRNum}, t_in::ctypeRNum, x_ptr::Ptr{ctypeRNum}, u_ptr::Ptr{ctypeRNum}, p_ptr::Ptr{ctypeRNum},
                       userparam::Ptr{typeUSERPARAM} )
end


# Jacobian dg/dx multiplied by vector vec, i.e. (dg/dx)^T*vec or vec^T*(dg/dx)
function dgdx_vec_wrapper( out_ptr::Ptr{typeRNum}, t_in::ctypeRNum, x_ptr::Ptr{ctypeRNum}, u_ptr::Ptr{ctypeRNum}, p_ptr::Ptr{ctypeRNum},
                           vec_ptr::Ptr{ctypeRNum}, userparam::Ptr{typeUSERPARAM} )
end


# Jacobian dg/du multiplied by vector vec, i.e. (dg/du)^T*vec or vec^T*(dg/du)
function dgdu_vec_wrapper( out_ptr::Ptr{typeRNum}, t_in::ctypeRNum, x_ptr::Ptr{ctypeRNum}, u_ptr::Ptr{ctypeRNum}, p_ptr::Ptr{ctypeRNum},
                           vec_ptr::Ptr{ctypeRNum}, userparam::Ptr{typeUSERPARAM} )
end


# Jacobian dg/dp multiplied by vector vec, i.e. (dg/dp)^T*vec or vec^T*(dg/dp)
function dgdp_vec_wrapper( out_ptr::Ptr{typeRNum}, t_in::ctypeRNum, x_ptr::Ptr{ctypeRNum}, u_ptr::Ptr{ctypeRNum}, p_ptr::Ptr{ctypeRNum},
                           vec_ptr::Ptr{ctypeRNum}, userparam::Ptr{typeUSERPARAM} )
end


#########################################################################################
# Inequality constraints
#########################################################################################

# Inequality constraints h(t,x(t),u(t),p,userparam) <= 0
function hfct_wrapper( out_ptr::Ptr{typeRNum}, t_in::ctypeRNum, x_ptr::Ptr{ctypeRNum}, u_ptr::Ptr{ctypeRNum}, p_ptr::Ptr{ctypeRNum},
                       userparam::Ptr{typeUSERPARAM} )
end


# Jacobian dh/dx multiplied by vector vec, i.e. (dh/dx)^T*vec or vec^T*(dg/dx)
function dhdx_vec_wrapper( out_ptr::Ptr{typeRNum}, t_in::ctypeRNum, x_ptr::Ptr{ctypeRNum}, u_ptr::Ptr{ctypeRNum}, p_ptr::Ptr{ctypeRNum},
                           vec_ptr::Ptr{ctypeRNum}, userparam::Ptr{typeUSERPARAM} )
end


# Jacobian dh/du multiplied by vector vec, i.e. (dh/du)^T*vec or vec^T*(dg/du)
function dhdu_vec_wrapper( out_ptr::Ptr{typeRNum}, t_in::ctypeRNum, x_ptr::Ptr{ctypeRNum}, u_ptr::Ptr{ctypeRNum}, p_ptr::Ptr{ctypeRNum},
                           vec_ptr::Ptr{ctypeRNum}, userparam::Ptr{typeUSERPARAM} )
end


# Jacobian dh/dp multiplied by vector vec, i.e. (dh/dp)^T*vec or vec^T*(dg/dp)
function dhdp_vec_wrapper( out_ptr::Ptr{typeRNum}, t_in::ctypeRNum, x_ptr::Ptr{ctypeRNum}, u_ptr::Ptr{ctypeRNum}, p_ptr::Ptr{ctypeRNum},
                           vec_ptr::Ptr{ctypeRNum}, userparam::Ptr{typeUSERPARAM} )
end


#########################################################################################
# Terminal equality constraints
#########################################################################################

# Terminal equality constraints gT(T,x(T),p,userparam) = 0
function gTfct_wrapper( out_ptr::Ptr{typeRNum}, T_in::ctypeRNum, x_ptr::Ptr{ctypeRNum}, p_ptr::Ptr{ctypeRNum}, userparam::Ptr{typeUSERPARAM} )
end


# Jacobian dgT/dx multiplied by vector vec, i.e. (dgT/dx)^T*vec or vec^T*(dgT/dx)
function dgTdx_vec_wrapper( out_ptr::Ptr{typeRNum}, T_in::ctypeRNum, x_ptr::Ptr{ctypeRNum}, p_ptr::Ptr{ctypeRNum}, vec_ptr::Ptr{ctypeRNum},
                            userparam::Ptr{typeUSERPARAM} )
end


# Jacobian dgT/dp multiplied by vector vec, i.e. (dgT/dp)^T*vec or vec^T*(dgT/dp)
function dgTdp_vec_wrapper( out_ptr::Ptr{typeRNum}, T_in::ctypeRNum, x_ptr::Ptr{ctypeRNum}, p_ptr::Ptr{ctypeRNum}, vec_ptr::Ptr{ctypeRNum},
                            userparam::Ptr{typeUSERPARAM} )
end


# Jacobian dgT/dT multiplied by vector vec, i.e. (dgT/dT)^T*vec or vec^T*(dgT/dT)
function dgTdT_vec_wrapper( out_ptr::Ptr{typeRNum}, T_in::ctypeRNum, x_ptr::Ptr{ctypeRNum}, p_ptr::Ptr{ctypeRNum}, vec_ptr::Ptr{ctypeRNum},
                            userparam::Ptr{typeUSERPARAM} )
end


#########################################################################################
# Terminal inequality constraints
#########################################################################################

# Terminal inequality constraints hT(T,x(T),p,userparam) <= 0
function hTfct_wrapper( out_ptr::Ptr{typeRNum}, T_in::ctypeRNum, x_ptr::Ptr{ctypeRNum}, p_ptr::Ptr{ctypeRNum}, userparam::Ptr{typeUSERPARAM} )
end


# Jacobian dhT/dx multiplied by vector vec, i.e. (dhT/dx)^T*vec or vec^T*(dhT/dx)
function dhTdx_vec_wrapper( out_ptr::Ptr{typeRNum}, T_in::ctypeRNum, x_ptr::Ptr{ctypeRNum}, p_ptr::Ptr{ctypeRNum}, vec_ptr::Ptr{ctypeRNum},
                            userparam::Ptr{typeUSERPARAM} )
end


# Jacobian dhT/dp multiplied by vector vec, i.e. (dhT/dp)^T*vec or vec^T*(dhT/dp)
function dhTdp_vec_wrapper( out_ptr::Ptr{typeRNum}, T_in::ctypeRNum, x_ptr::Ptr{ctypeRNum}, p_ptr::Ptr{ctypeRNum}, vec_ptr::Ptr{ctypeRNum},
                            userparam::Ptr{typeUSERPARAM} )
end


# Jacobian dhT/dT multiplied by vector vec, i.e. (dhT/dT)^T*vec or vec^T*(dhT/dT)
function dhTdT_vec_wrapper( out_ptr::Ptr{typeRNum}, T_in::ctypeRNum, x_ptr::Ptr{ctypeRNum}, p_ptr::Ptr{ctypeRNum}, vec_ptr::Ptr{ctypeRNum},
                            userparam::Ptr{typeUSERPARAM} )
end


#########################################################################################
# Functions required for semi-implicit systems
# M*dx/dt(t) = f(t0+t,x(t),u(t),p) using the solver RODAS,
#########################################################################################

# Jacobian df/dx in vector form (column-wise)
function dfdx_wrapper( out_ptr::Ptr{typeRNum}, t_in::ctypeRNum, x_ptr::Ptr{ctypeRNum}, u_ptr::Ptr{ctypeRNum}, p_ptr::Ptr{ctypeRNum},
                       userparam::Ptr{typeUSERPARAM} )
end


# Transpose of the Jacobian df/dx in vector form (column-wise)
function dfdxtrans_wrapper( out_ptr::Ptr{typeRNum}, t_in::ctypeRNum, x_ptr::Ptr{ctypeRNum}, u_ptr::Ptr{ctypeRNum}, p_ptr::Ptr{ctypeRNum},
                            userparam::Ptr{typeUSERPARAM} )
end


# Jacobian df/dt
function dfdt_wrapper( out_ptr::Ptr{typeRNum}, t_in::ctypeRNum, x_ptr::Ptr{ctypeRNum}, u_ptr::Ptr{ctypeRNum}, p_ptr::Ptr{ctypeRNum},
                       userparam::Ptr{typeUSERPARAM} )
end


# Jacobian d(dH/dx)/dt
function dHdxdt_wrapper( out_ptr::Ptr{typeRNum}, t_in::ctypeRNum, x_ptr::Ptr{ctypeRNum}, u_ptr::Ptr{ctypeRNum}, vec_ptr::Ptr{ctypeRNum},
                         p_ptr::Ptr{ctypeRNum}, userparam::Ptr{typeUSERPARAM} )
end


# Mass matrix in vector form (column-wise, either banded or full matrix)
function Mfct_wrapper( out_ptr::Ptr{typeRNum}, userparam::Ptr{typeUSERPARAM} )
    # Extract the GRAMPC problem
    model = unsafe_pointer_to_objref( userparam )::GRAMPC.Model

    numElem = model.Nx * model.Nx

    # Return the columns of the mass matrix concatenated into a single vector
    out = unsafe_wrap( Array, out_ptr, Int( numElem ) )
    out = reshape( model.massMatrix, (:) )
end


# Transposed mass matrix in vector form (column-wise, either banded or full matrix)
function Mtrans_wrapper( out_ptr::Ptr{typeRNum}, userparam::Ptr{typeUSERPARAM} )
    # Extract the GRAMPC problem
    model = unsafe_pointer_to_objref( userparam )::GRAMPC.Model

    numElem = model.Nx * model.Nx

    # Transpose the mass matrix then concatenate the columnd into a single vector and return them
    out = unsafe_wrap( Array, out_ptr, Int( numElem ) )
    out = collect( reshape( model.massMatrix', (:) ) )
end



# Julia wrapper for the problem function structure
struct Cjulia_funcs_wrapper
    ocp_dim::Ptr{Cvoid}

    ffct::Ptr{Cvoid}
    dfdx_vec_ptr::Ptr{Cvoid}
    dfdu_vec_ptr::Ptr{Cvoid}
    dfdp_vec_ptr::Ptr{Cvoid}

    lfct::Ptr{Cvoid}
    dldx_ptr::Ptr{Cvoid}
    dldu_ptr::Ptr{Cvoid}
    dldp_ptr::Ptr{Cvoid}

    Vfct::Ptr{Cvoid}
    dVdx_ptr::Ptr{Cvoid}
    dVdp_ptr::Ptr{Cvoid}
    dVdT::Ptr{Cvoid}

    gfct::Ptr{Cvoid}
    dgdx_vec_ptr::Ptr{Cvoid}
    dgdu_vec_ptr::Ptr{Cvoid}
    dgdp_vec_ptr::Ptr{Cvoid}

    hfct::Ptr{Cvoid}
    dhdx_vec_ptr::Ptr{Cvoid}
    dhdu_vec_ptr::Ptr{Cvoid}
    dhdp_vec_ptr::Ptr{Cvoid}

    gTfct::Ptr{Cvoid}
    dgTdx_vec_ptr::Ptr{Cvoid}
    dgTdp_vec_ptr::Ptr{Cvoid}
    dgTdT_vec_ptr::Ptr{Cvoid}

    hTfct::Ptr{Cvoid}
    dhTdx_vec_ptr::Ptr{Cvoid}
    dhTdp_vec_ptr::Ptr{Cvoid}
    dhTdT_vec_ptr::Ptr{Cvoid}

    dfdx_ptr::Ptr{Cvoid}
    dfdxtrans::Ptr{Cvoid}
    dfdt::Ptr{Cvoid}
    dHdxdt::Ptr{Cvoid}
    Mfct::Ptr{Cvoid}
    Mtrans::Ptr{Cvoid}

    function Cjulia_funcs_wrapper()
        return new( @cfunction( ocp_dim_wrapper, Cvoid,
                                ( Ptr{typeInt}, Ptr{typeInt}, Ptr{typeInt}, Ptr{typeInt}, Ptr{typeInt}, Ptr{typeInt}, Ptr{typeInt}, Ptr{typeUSERPARAM} ) ),
                    @cfunction( ffct_wrapper, Cvoid,
                                ( Ptr{typeRNum}, ctypeRNum, Ptr{ctypeRNum}, Ptr{ctypeRNum}, Ptr{ctypeRNum}, Ptr{typeUSERPARAM}) ),
                    @cfunction( dfdx_vec_wrapper, Cvoid,
                                ( Ptr{typeRNum}, ctypeRNum, Ptr{ctypeRNum}, Ptr{ctypeRNum}, Ptr{ctypeRNum}, Ptr{ctypeRNum}, Ptr{typeUSERPARAM} ) ),
                    @cfunction( dfdu_vec_wrapper, Cvoid,
                                ( Ptr{typeRNum}, ctypeRNum, Ptr{ctypeRNum}, Ptr{ctypeRNum}, Ptr{ctypeRNum}, Ptr{ctypeRNum}, Ptr{typeUSERPARAM} ) ),
                    @cfunction( dfdp_vec_wrapper, Cvoid,
                                ( Ptr{typeRNum}, ctypeRNum, Ptr{ctypeRNum}, Ptr{ctypeRNum}, Ptr{ctypeRNum}, Ptr{ctypeRNum}, Ptr{typeUSERPARAM} ) ),
                    @cfunction( lfct_wrapper, Cvoid,
                                ( Ptr{typeRNum}, ctypeRNum, Ptr{ctypeRNum}, Ptr{ctypeRNum}, Ptr{ctypeRNum}, Ptr{ctypeRNum}, Ptr{ctypeRNum}, Ptr{typeUSERPARAM} ) ),
                    @cfunction( dldx_wrapper, Cvoid,
                                ( Ptr{typeRNum}, ctypeRNum, Ptr{ctypeRNum}, Ptr{ctypeRNum}, Ptr{ctypeRNum}, Ptr{ctypeRNum}, Ptr{ctypeRNum}, Ptr{typeUSERPARAM} ) ),
                    @cfunction( dldu_wrapper, Cvoid,
                                ( Ptr{typeRNum}, ctypeRNum, Ptr{ctypeRNum}, Ptr{ctypeRNum}, Ptr{ctypeRNum}, Ptr{ctypeRNum}, Ptr{ctypeRNum}, Ptr{typeUSERPARAM} ) ),
                    @cfunction( dldp_wrapper, Cvoid,
                                ( Ptr{typeRNum}, ctypeRNum, Ptr{ctypeRNum}, Ptr{ctypeRNum}, Ptr{ctypeRNum}, Ptr{ctypeRNum}, Ptr{ctypeRNum}, Ptr{typeUSERPARAM} ) ),
                    @cfunction( Vfct_wrapper, Cvoid,
                                ( Ptr{typeRNum}, ctypeRNum, Ptr{ctypeRNum}, Ptr{ctypeRNum}, Ptr{ctypeRNum}, Ptr{typeUSERPARAM} ) ),
                    @cfunction( dVdx_wrapper, Cvoid,
                                ( Ptr{typeRNum}, ctypeRNum, Ptr{ctypeRNum}, Ptr{ctypeRNum}, Ptr{ctypeRNum}, Ptr{typeUSERPARAM} ) ),
                    @cfunction( dVdp_wrapper, Cvoid,
                                ( Ptr{typeRNum}, ctypeRNum, Ptr{ctypeRNum}, Ptr{ctypeRNum}, Ptr{ctypeRNum}, Ptr{typeUSERPARAM} ) ),
                    @cfunction( dVdT_wrapper, Cvoid,
                                ( Ptr{typeRNum}, ctypeRNum, Ptr{ctypeRNum}, Ptr{ctypeRNum}, Ptr{ctypeRNum}, Ptr{typeUSERPARAM} ) ),
                    @cfunction( gfct_wrapper, Cvoid,
                                ( Ptr{typeRNum}, ctypeRNum, Ptr{ctypeRNum}, Ptr{ctypeRNum}, Ptr{ctypeRNum}, Ptr{typeUSERPARAM} ) ),
                    @cfunction( dgdx_vec_wrapper, Cvoid,
                                ( Ptr{typeRNum}, ctypeRNum, Ptr{ctypeRNum}, Ptr{ctypeRNum}, Ptr{ctypeRNum}, Ptr{ctypeRNum}, Ptr{typeUSERPARAM} ) ),
                    @cfunction( dgdu_vec_wrapper, Cvoid,
                                ( Ptr{typeRNum}, ctypeRNum, Ptr{ctypeRNum}, Ptr{ctypeRNum}, Ptr{ctypeRNum}, Ptr{ctypeRNum}, Ptr{typeUSERPARAM} ) ),
                    @cfunction( dgdp_vec_wrapper, Cvoid,
                                ( Ptr{typeRNum}, ctypeRNum, Ptr{ctypeRNum}, Ptr{ctypeRNum}, Ptr{ctypeRNum}, Ptr{ctypeRNum}, Ptr{typeUSERPARAM} ) ),
                    @cfunction( hfct_wrapper, Cvoid,
                                ( Ptr{typeRNum}, ctypeRNum, Ptr{ctypeRNum}, Ptr{ctypeRNum}, Ptr{ctypeRNum}, Ptr{typeUSERPARAM} ) ),
                    @cfunction( dhdx_vec_wrapper, Cvoid,
                                ( Ptr{typeRNum}, ctypeRNum, Ptr{ctypeRNum}, Ptr{ctypeRNum}, Ptr{ctypeRNum}, Ptr{ctypeRNum}, Ptr{typeUSERPARAM} ) ),
                    @cfunction( dhdu_vec_wrapper, Cvoid,
                                ( Ptr{typeRNum}, ctypeRNum, Ptr{ctypeRNum}, Ptr{ctypeRNum}, Ptr{ctypeRNum}, Ptr{ctypeRNum}, Ptr{typeUSERPARAM} ) ),
                    @cfunction( dhdp_vec_wrapper, Cvoid,
                                ( Ptr{typeRNum}, ctypeRNum, Ptr{ctypeRNum}, Ptr{ctypeRNum}, Ptr{ctypeRNum}, Ptr{ctypeRNum}, Ptr{typeUSERPARAM} ) ),
                    @cfunction( gTfct_wrapper, Cvoid,
                                ( Ptr{typeRNum}, ctypeRNum, Ptr{ctypeRNum}, Ptr{ctypeRNum}, Ptr{typeUSERPARAM} ) ),
                    @cfunction( dgTdx_vec_wrapper, Cvoid,
                                ( Ptr{typeRNum}, ctypeRNum, Ptr{ctypeRNum}, Ptr{ctypeRNum}, Ptr{ctypeRNum}, Ptr{typeUSERPARAM} ) ),
                    @cfunction( dgTdp_vec_wrapper, Cvoid,
                                ( Ptr{typeRNum}, ctypeRNum, Ptr{ctypeRNum}, Ptr{ctypeRNum}, Ptr{ctypeRNum}, Ptr{typeUSERPARAM} ) ),
                    @cfunction( dgTdT_vec_wrapper, Cvoid,
                                ( Ptr{typeRNum}, ctypeRNum, Ptr{ctypeRNum}, Ptr{ctypeRNum}, Ptr{ctypeRNum}, Ptr{typeUSERPARAM} ) ),
                    @cfunction( hTfct_wrapper, Cvoid,
                                ( Ptr{typeRNum}, ctypeRNum, Ptr{ctypeRNum}, Ptr{ctypeRNum}, Ptr{typeUSERPARAM} ) ),
                    @cfunction( dhTdx_vec_wrapper, Cvoid,
                                ( Ptr{typeRNum}, ctypeRNum, Ptr{ctypeRNum}, Ptr{ctypeRNum}, Ptr{ctypeRNum}, Ptr{typeUSERPARAM} ) ),
                    @cfunction( dhTdp_vec_wrapper, Cvoid,
                                ( Ptr{typeRNum}, ctypeRNum, Ptr{ctypeRNum}, Ptr{ctypeRNum}, Ptr{ctypeRNum}, Ptr{typeUSERPARAM} ) ),
                    @cfunction( dhTdT_vec_wrapper, Cvoid,
                                ( Ptr{typeRNum}, ctypeRNum, Ptr{ctypeRNum}, Ptr{ctypeRNum}, Ptr{ctypeRNum}, Ptr{typeUSERPARAM} ) ),
                    @cfunction( dfdx_wrapper, Cvoid,
                                ( Ptr{typeRNum}, ctypeRNum, Ptr{ctypeRNum}, Ptr{ctypeRNum}, Ptr{ctypeRNum}, Ptr{typeUSERPARAM} ) ),
                    @cfunction( dfdxtrans_wrapper, Cvoid,
                                ( Ptr{typeRNum}, ctypeRNum, Ptr{ctypeRNum}, Ptr{ctypeRNum}, Ptr{ctypeRNum}, Ptr{typeUSERPARAM} ) ),
                    @cfunction( dfdt_wrapper, Cvoid,
                                ( Ptr{typeRNum}, ctypeRNum, Ptr{ctypeRNum}, Ptr{ctypeRNum}, Ptr{ctypeRNum}, Ptr{typeUSERPARAM} ) ),
                    @cfunction( dHdxdt_wrapper, Cvoid,
                                ( Ptr{typeRNum}, ctypeRNum, Ptr{ctypeRNum}, Ptr{ctypeRNum}, Ptr{ctypeRNum}, Ptr{ctypeRNum}, Ptr{typeUSERPARAM} ) ),
                    @cfunction( Mfct_wrapper, Cvoid,
                                ( Ptr{typeRNum}, Ptr{typeUSERPARAM} ) ),
                    @cfunction( Mtrans_wrapper, Cvoid,
                                ( Ptr{typeRNum}, Ptr{typeUSERPARAM} ) )
                  )
    end
end
