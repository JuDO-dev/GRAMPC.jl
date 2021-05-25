#

using GRAMPC
using LinearAlgebra

# Gravitational constant
const GRAV = 9.81

####################################################
# Dynamics functions
####################################################
function dyn( dx::Vector{Float64}, x::Vector{Float64}, u::Vector{Float64},
              p::Vector{Float64}, t::Float64, param::Vector{Float64} )
    dx[1] = x[2];
    dx[2] = u[1];
    dx[3] = x[4];
    dx[4] = u[2];
    dx[5] = x[6];
    dx[6] = -( ( GRAV * sin( x[5] ) + cos( x[5] ) * u[1] + 2 * x[4] * x[6] ) / x[3] );
end

# Jacobian df/dx multiplied by vector vec, i.e. (df/dx)^T*vec or vec^T*(df/dx)
function dfdx_vec( res::Vector{Float64}, x::Vector{Float64}, u::Vector{Float64},
                   p::Vector{Float64}, t::Float64, vec::Vector{Float64}, param::Vector{Float64} )
  aux1 = sin( x[5] );
  aux2 = cos( x[5] );

  res[1] = 0;
  res[2] = vec[1];
  res[3] = ( GRAV * aux1 + aux2 * u[1] + 2 * x[4] * x[6] ) * vec[6] / ( x[3]^2 );
  res[4] = vec[3] - ( 2 * x[6] * vec[6] ) / x[3];
  res[5] = -( ( (GRAV * aux2 - aux1 * u[1] ) * vec[6] ) / x[3] );
  res[6] = vec[5] - ( 2 * x[4] * vec[6] ) / x[3];
end

# Jacobian df/du multiplied by vector vec, i.e. (df/du)^T*vec or vec^T*(df/du)
function dfdu_vec( res::Vector{Float64}, x::Vector{Float64}, u::Vector{Float64},
                   p::Vector{Float64}, t::Float64, vec::Vector{Float64}, param::Vector{Float64} )
  res[1] = vec[2] - ( cos( x[5] ) * vec[6] ) / x[3];
  res[2] = vec[4];
end


####################################################
# Integral cost functions
####################################################
function lfct( t::Float64, x::Vector{Float64}, u::Vector{Float64}, p::Vector{Float64}, xdes::Vector{Float64},
               udes::Vector{Float64}, param::Vector{Float64} )
    Q = diagm( param[1:6] )
    R = diagm( param[7:8] )

    xt = x - xdes
    ut = u - udes

    return xt'*Q*xt + ut'*R*ut
end

# Gradient dl/dx
function dldx( res::Vector{Float64}, t::Float64, x::Vector{Float64}, u::Vector{Float64}, p::Vector{Float64},
               xdes::Vector{Float64}, udes::Vector{Float64}, param::Vector{Float64} )
    Q = diagm( param[1:6] )

    # We need to return a column vector, so this is actually the transpose of the gradient
    res = 2*Q'*( x - xdes )
end

# Gradient dl/du
function dldu( res::Vector{Float64}, t::Float64, x::Vector{Float64}, u::Vector{Float64}, p::Vector{Float64},
               xdes::Vector{Float64}, udes::Vector{Float64}, param::Vector{Float64} )
    R = diagm( param[7:8] )

    # We need to return a column vector, so this is actually the transpose of the gradient
    res = 2*R'*( u - udes )
end


####################################################
# Inequality constraints h(t,x(t),u(t),p,uperparam) <= 0
####################################################
function hfct( res::Vector{Float64}, t::Float64, x::Vector{Float64}, u::Vector{Float64}, p::Vector{Float64},
               param::Vector{Float64} )
    pSys = param[9:11]
    xPos = x[1] + sin( x[5] ) * x[3];

    res[1] = cos( x[5] ) * x[3] - pSys[1] * xPos^2 - pSys[2];
    res[2] = x[6] - pSys[3];
    res[3] = -x[6] - pSys[3];
end

# Jacobian dh/dx multiplied by vector vec, i.e. (dh/dx)^T*vec or vec^T*(dg/dx)
function dhdx_vec( res::Vector{Float64}, t::Float64, x::Vector{Float64}, u::Vector{Float64}, p::Vector{Float64},
                   vec::Vector{Float64}, param::Vector{Float64} )
    pSys = param[9:11]
    temp = pSys[1] * ( x[1] + sin( x[5] ) * x[3] );

    res[1] = temp * vec[1];
    res[2] = 0;
    res[3] = ( sin( x[5] ) * temp + cos( x[5] ) ) * vec[1];
    res[4] = 0;
    res[5] = ( cos( x[5] ) * x[3] * temp - sin( x[5] ) * x[3] ) * vec[1];
    res[6] = 0 + vec[2] - vec[3];
end

# Jacobian dh/du multiplied by vector vec, i.e. (dh/du)^T*vec or vec^T*(dg/du)
function dhdu_vec( res::Vector{Float64}, t::Float64, x::Vector{Float64}, u::Vector{Float64}, p::Vector{Float64},
                   vec::Vector{Float64}, param::Vector{Float64} )
  res = [0];
end


####################################################
# Setup the GRAMPC problem
####################################################
craneModel = GRAMPC.Model( states = 6, inputs = 2, ineqcon = 3 )

# Add the dynamics to the problem
set_dynamics!( craneModel, dyn, dx=dfdx_vec, du=dfdu_vec )

# Setup the cost of the problem
set_lagrange_term!( craneModel, lfct, dx=dldx, du=dldu )

# Setup the constraints for the problem
set_inequality_constraints!( craneModel, hfct, dx=dhdx_vec, du=dhdu_vec )

# Starting state
x0 = [ -2.0;
        0.0;
        2.0;
        0.0;
        0.0;
        0.0 ]

# Starting input
u0 = [ 0.0;
       0.0 ]

# Constraint tolerances
constraintTol = [ 1e-4;
                  1e-3;
                  1e-3 ]

# Initialize the problem and setup the options
setup!( craneModel, Thor=2,                        # Length of the prediction horizon
                    Nhor=20,                         # Number of system integration steps
                    dt=0.002,                         # Sampling time
                    t0=0.0,                          # Initial time
                    TerminalCost=false,              # Disable the terminal cost
                    ConstraintsAbsTol=constraintTol, # Constraint tolerances
                    x0=x0,
                    u0=u0 )

# Set the limits after initializing the problem (they are considered an option and not normal constraints)
umax = [ 2.0;
         2.0 ]
umin = [ -2.0;
         -2.0 ]

set_limits!( craneModel, :input, lb=umin, ub=umax )


# Desired state/input
xdes = [ 2.0;
         0.0;
         2.0;
         0.0;
         0.0;
         0.0 ]
udes = [ 0.0;
         0.0 ]

set_setpoint!( craneModel, input=udes, state=xdes )

# Pass in the user parameters
pSys = [ 1.0,   # Q matrix diagonal
         2.0,
         2.0,
         1.0,
         1.0,
         4.0,
         0.05,  # R matrix diagonal
         0.05,
         0.2,   # Inequality constraint parameters
         1.25,
         0.3 ]

set_user_parameters!( craneModel, pSys )

estimate_penalty_min!( craneModel )

# Solve the problem
sol = solve!( craneModel )
