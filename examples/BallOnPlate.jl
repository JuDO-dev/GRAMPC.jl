#

using GRAMPC

BPmodel = GRAMPC.Model( Nx = 2, Nu = 1, Nh = 4 )

# Dynamics functions
function dyn( dx::Vector{Float64}, x::Vector{Float64}, u::Vector{Float64},
              p::Vector{Float64}, t::Float64, param::Vector{Float64} )
    dx[0] = -0.04*u[0] + x[1]
    dx[1] = -7.01*u[0]
end

# Jacobian df/dx multiplied by vector vec, i.e. (df/dx)^T*vec or vec^T*(df/dx)
function dfdx_vec( res::Vector{Float64}, x::Vector{Float64}, u::Vector{Float64},
                   p::Vector{Float64}, t::Float64, vec::Vector{Float64}, param::Vector{Float64} )
    res[0] = 0;
    res[1] = vec[0];
end

# Jacobian df/du multiplied by vector vec, i.e. (df/du)^T*vec or vec^T*(df/du)
function dfdu_vec( res::Vector{Float64}, x::Vector{Float64}, u::Vector{Float64},
                   p::Vector{Float64}, t::Float64, vec::Vector{Float64}, param::Vector{Float64} )
    res[0] = -0.04*vec[0] - 7.01*vec[1];
end

set_dynamics!( 2, dyn, dfdx=dfdx_vec, dfdu=dfdu_vec )


# Integral cost
function lfct( typeRNum *out, ctypeRNum t, ctypeRNum *x, ctypeRNum *u, ctypeRNum *p, ctypeRNum *xdes, ctypeRNum *udes, typeUSERPARAM *userparam )
{
    ctypeRNum* param = (ctypeRNum*)userparam;

    out[0] = (param[0] * POW2(x[0] - xdes[0])
            + param[1] * POW2(x[1] - xdes[1])
            + param[2] * POW2(u[0] - udes[0])) / 2;
end

# Gradient dl/dx
void dldx(typeRNum *out, ctypeRNum t, ctypeRNum *x, ctypeRNum *u, ctypeRNum *p, ctypeRNum *xdes, ctypeRNum *udes, typeUSERPARAM *userparam)
{
    ctypeRNum* param = (ctypeRNum*)userparam;

    out[0] = param[0] * (x[0] - xdes[0]);
    out[1] = param[1] * (x[1] - xdes[1]);
}

# Gradient dl/du
void dldu(typeRNum *out, ctypeRNum t, ctypeRNum *x, ctypeRNum *u, ctypeRNum *p, ctypeRNum *xdes, ctypeRNum *udes, typeUSERPARAM *userparam)
{
    ctypeRNum* param = (ctypeRNum*)userparam;

    out[0] = param[2] * (u[0] - udes[0]);
}


## Terminal cost
void Vfct(typeRNum *out, ctypeRNum T, ctypeRNum *x, ctypeRNum *p, ctypeRNum *xdes, typeUSERPARAM *userparam)
{
    ctypeRNum* param = (ctypeRNum*)userparam;

    out[0] = (param[3] * POW2(x[0] - xdes[0])
            + param[4] * POW2(x[1] - xdes[1])) / 2;
}
/** Gradient dV/dx **/
void dVdx(typeRNum *out, ctypeRNum T, ctypeRNum *x, ctypeRNum *p, ctypeRNum *xdes, typeUSERPARAM *userparam)
{
    ctypeRNum* param = (ctypeRNum*)userparam;

    out[0] = param[3] * (x[0] - xdes[0]);
    out[1] = param[4] * (x[1] - xdes[1]);
}

# Inequality constraints
/** Inequality constraints h(t,x(t),u(t),p,uperparam) <= 0
    ------------------------------------------------------ **/
void hfct(typeRNum *out, ctypeRNum t, ctypeRNum *x, ctypeRNum *u, ctypeRNum *p, typeUSERPARAM *userparam)
{
    ctypeRNum* param = (ctypeRNum*)userparam;

    out[0] =  param[5] - x[0];
    out[1] = -param[6] + x[0];
    out[2] =  param[7] - x[1];
    out[3] = -param[8] + x[1];
}
/** Jacobian dh/dx multiplied by vector vec, i.e. (dh/dx)^T*vec or vec^T*(dg/dx) **/
void dhdx_vec(typeRNum *out, ctypeRNum t, ctypeRNum *x, ctypeRNum *u, ctypeRNum *p, ctypeRNum *vec, typeUSERPARAM *userparam)
{
    out[0] = -vec[0] + vec[1];
    out[1] = -vec[2] + vec[3];
}
/** Jacobian dh/du multiplied by vector vec, i.e. (dh/du)^T*vec or vec^T*(dg/du) **/
void dhdu_vec(typeRNum *out, ctypeRNum t, ctypeRNum *x, ctypeRNum *u, ctypeRNum *p, ctypeRNum *vec, typeUSERPARAM *userparam)
{
    out[0] = 0;
}
