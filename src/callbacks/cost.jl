export set_lagrange_term!, set_mayer_term!

function set_lagrange_term!( model::Model, lagrange::Union{Nothing,Function}; dx::CallbackArg=:autodiff, du::CallbackArg=:autodiff, dp::CallbackArg=:autodiff )
    # Allow the lagrange term to be disabled
    if isa( lagrange, Nothing )
        model.integralCost = false

        model.callbacks.lfct_cb = nothing
        model.callbacks.dldx_cb = nothing
        model.callbacks.dldu_cb = nothing
        model.callbacks.dldp_cb = nothing

        return
    else
        model.integralCost = true
        model.callbacks.lfct_cb = lagrange
    end

    if isa( dx, Function )
        model.callbacks.dldx_cb = dx
    elseif dx == :autodiff
        # TODO
    else
        throw( ArgumentError( "Unknown option $(String(dx)) for dx" ) )
    end

    if isa( du, Function )
        model.callbacks.dldu_cb = du
    elseif du == :autodiff
        # TODO
    else
        throw( ArgumentError( "Unknown option $(String(du)) for du" ) )
    end

    if isa( dp, Function )
        model.callbacks.dldp_cb = dp
    elseif dp == :autodiff
        # TODO
    else
        throw( ArgumentError( "Unknown option $(String(dp)) for dp" ) )
    end
end


function set_mayer_term!( model::Model, mayer::Union{Nothing,Function}; dx::CallbackArg=:autodiff, dp::CallbackArg=:autodiff, dT::CallbackArg=:autodiff )
    # Allow the mayer term to be disabled
    if isa( mayer, Nothing )
        model.terminalCost = false

        model.callbacks.Vfct_cb = nothing
        model.callbacks.dVdx_cb = nothing
        model.callbacks.dVdp_cb = nothing
        model.callbacks.dVdT_cb = nothing

        return
    else
        model.terminalCost = true
        model.callbacks.Vfct_cb = mayer
    end

    if isa( dx, Function )
        model.callbacks.dVdx_cb = dx
    elseif dx == :autodiff
        # TODO
    else
        throw( ArgumentError( "Unknown option $(String(dx)) for dx" ) )
    end

    if isa( dp, Function )
        model.callbacks.dVdp_cb = dp
    elseif dp == :autodiff
        # TODO
    else
        throw( ArgumentError( "Unknown option $(String(dp)) for dp" ) )
    end

    if isa( dT, Function )
        model.callbacks.dVdT_cb = dT
    elseif dT == :autodiff
        # TODO
    else
        throw( ArgumentError( "Unknown option $(String(dT)) for dT" ) )
    end
end
