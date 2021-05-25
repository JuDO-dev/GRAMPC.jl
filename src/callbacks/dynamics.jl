export set_dynamics!

function set_dynamics!( model::Model, sysf::Function; mm::MassMatrix=I, dx::CallbackArg=:autodiff, du::CallbackArg=:autodiff, dp::CallbackArg=:autodiff )
    # Create/store the mass matrix in the model
    if isa( mm, UniformScaling )
        model.massMatrix = convert( Matrix{Float64}, mm(model.Nx) )
    else
        model.massMatrix = mm
    end

    model.callbacks.ffct_cb = sysf

    if isa( dx, Function )
        model.callbacks.dfdx_vec_cb = dx
    elseif dx == :autodiff

    else
        throw( ArgumentError( "Unknown option $(String(dx)) for dx" ) )
    end

    if isa( du, Function )
        model.callbacks.dfdu_vec_cb = du
    elseif du == :autodiff

    else
        throw( ArgumentError( "Unknown option $(String(du)) for du" ) )
    end

    if isa( dp, Function )
        model.callbacks.dfdp_vec_cb = dp
    elseif dp == :autodiff

    else
        throw( ArgumentError( "Unknown option $(String(dp)) for dp" ) )
    end
end
