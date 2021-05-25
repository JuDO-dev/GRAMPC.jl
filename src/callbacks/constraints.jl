export set_inequality_constraints!, set_terminal_inequality_constraints!, set_equality_constraints!, set_terminal_equality_constraints!

function set_inequality_constraints!( model::Model, func::Union{Nothing,Function}; dx::CallbackArg=:autodiff, du::CallbackArg=:autodiff, dp::CallbackArg=:autodiff )
    # Allow the inequality constraints to be disabled
    if isa( func, Nothing )
        model.ineqCon = false

        model.callbacks.hfct_cb     = nothing
        model.callbacks.dhdx_vec_cb = nothing
        model.callbacks.dhdu_vec_cb = nothing
        model.callbacks.dhdp_vec_cb = nothing

        return
    else
        model.ineqCon = true
        model.callbacks.hfct_cb = func
    end

    if isa( dx, Function )
        model.callbacks.dhdx_vec_cb = dx
    elseif dx == :autodiff
        # TODO
    else
        throw( ArgumentError( "Unknown option $(String(dx)) for dx" ) )
    end

    if isa( du, Function )
        model.callbacks.dhdu_vec_cb = du
    elseif du == :autodiff
        # TODO
    else
        throw( ArgumentError( "Unknown option $(String(du)) for du" ) )
    end

    if isa( dp, Function )
        model.callbacks.dhdp_vec_cb = dp
    elseif dp == :autodiff
        # TODO
    else
        throw( ArgumentError( "Unknown option $(String(dp)) for dp" ) )
    end
end


function set_terminal_inequality_constraints!( model::Model, func::Function; dx::CallbackArg=:autodiff, dp::CallbackArg=:autodiff, dT::CallbackArg=:autodiff )
    # Allow the terminal inequality constraints to be disabled
    if isa( func, Nothing )
        model.termIneqCon = false

        model.callbacks.hTfct_cb     = nothing
        model.callbacks.dhTdp_vec_cb = nothing
        model.callbacks.dhTdp_vec_cb = nothing
        model.callbacks.dhTdT_vec_cb = nothing

        return
    else
        model.termIneqCon = true
        model.callbacks.hTfct_cb = func
    end

    if isa( dx, Function )
        model.callbacks.dhTdx_vec_cb = dx
    elseif dx == :autodiff
        # TODO
    else
        throw( ArgumentError( "Unknown option $(String(dx)) for dx" ) )
    end

    if isa( dp, Function )
        model.callbacks.dhTdp_vec_cb = dp
    elseif dp == :autodiff
        # TODO
    else
        throw( ArgumentError( "Unknown option $(String(dp)) for dp" ) )
    end

    if isa( dT, Function )
        model.callbacks.dhTdT_vec_cb = dT
    elseif dT == :autodiff
        # TODO
    else
        throw( ArgumentError( "Unknown option $(String(dT)) for dT" ) )
    end
end


function set_equality_constraints!( model::Model, func::Function; dx::CallbackArg=:autodiff, du::CallbackArg=:autodiff, dp::CallbackArg=:autodiff )
    # Allow the equality constraints to be disabled
    if isa( func, Nothing )
        model.eqCon = false

        model.callbacks.gfct_cb     = nothing
        model.callbacks.dgdx_vec_cb = nothing
        model.callbacks.dgdu_vec_cb = nothing
        model.callbacks.dgdp_vec_cb = nothing

        return
    else
        model.eqCon = true
        model.callbacks.gfct_cb = func
    end

    if isa( dx, Function )
        model.callbacks.dgdx_vec_cb = dx
    elseif dx == :autodiff
        # TODO
    else
        throw( ArgumentError( "Unknown option $(String(dx)) for dx" ) )
    end

    if isa( du, Function )
        model.callbacks.dgdu_vec_cb = du
    elseif du == :autodiff
        # TODO
    else
        throw( ArgumentError( "Unknown option $(String(du)) for du" ) )
    end

    if isa( dp, Function )
        model.callbacks.dgdp_vec_cb = dp
    elseif dp == :autodiff
        # TODO
    else
        throw( ArgumentError( "Unknown option $(String(dp)) for dp" ) )
    end
end


function set_terminal_equality_constraints!( model::Model, func::Function; dx::CallbackArg=:autodiff, dp::CallbackArg=:autodiff, dT::CallbackArg=:autodiff )
    # Allow the equality constraints to be disabled
    if isa( func, Nothing )
        model.termEqCon = false

        model.callbacks.gTfct_cb     = nothing
        model.callbacks.dgTdx_vec_cb = nothing
        model.callbacks.dgTdp_vec_cb = nothing
        model.callbacks.dgTdT_vec_cb = nothing

        return
    else
        model.termEqCon = true
        model.callbacks.gTfct_cb = func
    end

    if isa( dx, Function )
        model.callbacks.dgTdx_vec_cb = dx
    elseif dx == :autodiff
        # TODO
    else
        throw( ArgumentError( "Unknown option $(String(dx)) for dx" ) )
    end

    if isa( dp, Function )
        model.callbacks.dgTdp_vec_cb = dp
    elseif dp == :autodiff
        # TODO
    else
        throw( ArgumentError( "Unknown option $(String(dp)) for dp" ) )
    end

    if isa( dT, Function )
        model.callbacks.dgTdT_vec_cb = dT
    elseif dT == :autodiff
        # TODO
    else
        throw( ArgumentError( "Unknown option $(String(dT)) for dT" ) )
    end
end
