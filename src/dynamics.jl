
export set_dynamics!

function set_dynamics!( model::Model, sysf::Function; mm::MassMatrix=I, dfdx::CallbackArg=:autodiff, dfdu::CallbackArg=:autodiff, dfdp::CallbackArg=:autodiff )

    model.Nx = Nx

    # Create/store the mass matrix in the model
    if isa( mm, UniformScaling )
        model.massMatrix = convert( Matrix{Float64}, mm(Nx) )
    else
        model.massMatrix = mm
    end

    model.callbacks.ffct_cb = sysf

    if isa( dfdx, Function )
        model.callbacks.dfdx_cb = dfdx
    elseif dfdx == :autodiff

    else
        throw( ArgumentError( "Unknown option $(String(dfdx)) for dfdx" ) )
    end

end
