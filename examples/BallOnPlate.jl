#

using GRAMPC

####################################################
# Dynamics functions
####################################################
function dyn( dx::Vector{Float64}, x::Vector{Float64}, u::Vector{Float64},
              p::Vector{Float64}, t::Float64, param::Vector{Float64} )
    dx[1] = -0.04*u[1] + x[2]
    dx[2] = -7.01*u[1]
end

# Jacobian df/dx multiplied by vector vec, i.e. (df/dx)^T*vec or vec^T*(df/dx)
function dfdx_vec( res::Vector{Float64}, x::Vector{Float64}, u::Vector{Float64},
                   p::Vector{Float64}, t::Float64, vec::Vector{Float64}, param::Vector{Float64} )
    res[1] = 0;
    res[2] = vec[1];
end

# Jacobian df/du multiplied by vector vec, i.e. (df/du)^T*vec or vec^T*(df/du)
function dfdu_vec( res::Vector{Float64}, x::Vector{Float64}, u::Vector{Float64},
                   p::Vector{Float64}, t::Float64, vec::Vector{Float64}, param::Vector{Float64} )
    res[1] = -0.04*vec[1] - 7.01*vec[2];
end


####################################################
# Integral cost functions
####################################################
function lfct( t::Float64, x::Vector{Float64}, u::Vector{Float64}, p::Vector{Float64}, xdes::Vector{Float64},
               udes::Vector{Float64}, param::Vector{Float64} )
    cost = (   param[1] * ( x[1] - xdes[1] )^2
             + param[2] * ( x[2] - xdes[2] )^2
             + param[3] * ( u[1] - udes[1] )^2 ) / 2;

    return cost
end

# Gradient dl/dx
function dldx( res::Vector{Float64}, t::Float64, x::Vector{Float64}, u::Vector{Float64}, p::Vector{Float64},
               xdes::Vector{Float64}, udes::Vector{Float64}, param::Vector{Float64} )
    res[1] = param[1] * ( x[1] - xdes[1] );
    res[2] = param[2] * ( x[2] - xdes[2] );
end

# Gradient dl/du
function dldu( res::Vector{Float64}, t::Float64, x::Vector{Float64}, u::Vector{Float64}, p::Vector{Float64},
               xdes::Vector{Float64}, udes::Vector{Float64}, param::Vector{Float64} )
    res[1] = param[3] * (u[1] - udes[1]);
end


####################################################
# Terminal cost functions
####################################################
function Vfct( T::Float64, x::Vector{Float64}, p::Vector{Float64},xdes::Vector{Float64},
               param::Vector{Float64} )
    cost = (   param[4] * ( x[1] - xdes[1] )^2
             + param[5] * ( x[2] - xdes[2] )^2 ) / 2;

    return cost
end

# Gradient dV/dx
function dVdx( res::Vector{Float64}, T::Float64, x::Vector{Float64}, p::Vector{Float64}, xdes::Vector{Float64},
               param::Vector{Float64} )
    res[1] = param[4] * ( x[1] - xdes[1] );
    res[2] = param[5] * ( x[2] - xdes[2] );
end


####################################################
# Inequality constraints h(t,x(t),u(t),p,uperparam) <= 0
####################################################
function hfct( res::Vector{Float64}, t::Float64, x::Vector{Float64}, u::Vector{Float64}, p::Vector{Float64},
               param::Vector{Float64} )
    res[1] =  param[6] - x[1];
    res[2] = -param[7] + x[1];
    res[3] =  param[8] - x[2];
    res[4] = -param[9] + x[2];
end

# Jacobian dh/dx multiplied by vector vec, i.e. (dh/dx)^T*vec or vec^T*(dg/dx)
function dhdx_vec( res::Vector{Float64}, t::Float64, x::Vector{Float64}, u::Vector{Float64}, p::Vector{Float64},
                   vec::Vector{Float64}, param::Vector{Float64} )
    res[1] = -vec[1] + vec[2];
    res[2] = -vec[3] + vec[4];
end

# Jacobian dh/du multiplied by vector vec, i.e. (dh/du)^T*vec or vec^T*(dg/du)
function dhdu_vec( res::Vector{Float64}, t::Float64, x::Vector{Float64}, u::Vector{Float64}, p::Vector{Float64},
                   vec::Vector{Float64}, param::Vector{Float64} )
    res[1] = 0;
end


####################################################
# Setup the GRAMPC problem
####################################################
BPmodel = GRAMPC.Model( states = 2, inputs = 1, ineqcon = 4 )

# Add the dynamics to the problem
set_dynamics!( BPmodel, dyn, dx=dfdx_vec, du=dfdu_vec )

# Setup the cost of the problem
set_lagrange_term!( BPmodel, lfct, dx=dldx, du=dldu )
set_mayer_term!( BPmodel, Vfct, dx=dVdx )

# Setup the constraints for the problem
set_inequality_constraints!( BPmodel, hfct, dx=dhdx_vec, du=dhdu_vec )

# Starting state
x0 = [ 0.1;
       0.01 ]

# Starting input
u0 = [ 0.0 ]

# Constraint tolerances
constraintTol = [ 1e-3;
                  1e-3;
                  1e-3;
                  1e-3 ]

# Initialize the problem and setup the options
setup!( BPmodel, Thor=0.3,                        # Length of the prediction horizon
                 Nhor=10,                         # Number of system integration steps
                 dt=0.01,                         # Sampling time
                 t0=0.0,                          # Initial time
                 MaxMultIter=3,                   # Maximum number of augmented lagrangian iterations
                 AugLagUpdateGradientRelTol=1,    # Augmented langrangian gradient tolerance
                 ConstraintsAbsTol=constraintTol, # Constraint tolerances
                 x0=x0,
                 u0=u0 )

# Set the limits after initializing the problem (they are considered an option and not normal constraints)
umax = [  0.0524 ]
umin = [ -0.0524 ]

set_limits!( BPmodel, :input, lb=umin, ub=umax )


# Desired state/input
xdes = [ -0.2;
          0.0 ]
udes = [  0.0 ]

set_setpoint!( BPmodel, input=udes, state=xdes )

# Pass in the user parameters
pCost = [ 100; 10; 180; 100; 10; -0.2; 0.2; -0.1; 0.1 ]
set_user_parameters!( BPmodel, pCost )

estimate_penalty_min!( BPmodel )

# Solve the problem
sol = solve!( BPmodel )
