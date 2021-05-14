# For more information about how the error handling in the Julia wrapper is implemented,
# see the Internals section of the docs.

"""
    @check_warning

Check if the GRAMPC solver has triggered a warning and propagate it to the user as a
warning log message with the location information as the current line of code.
"""
macro check_warning()
    quote
        _check_warning( $(String(__source__.file)), $(__source__.line) )
    end
end


function _check_warning( file, line )
    # This buffer size matches the buffer in the code
    warnCString = Vector{UInt8}(undef, 1024)

    if( ccall( (:grampcjl_get_last_warning, libgrampc_julia), Cint, (Ptr{UInt8},), warnCString ) == 1 )
        # Convert the string
        warnString = unsafe_string( pointer( warnCString ) )

        @warn warnString _line=line _file=file
    end
end


"""
    _clear_warning()

Clears the current warning stored in the buffer inside the library.
"""
function _clear_warning()
    ccall( (:grampcjl_clear_last_warning, libgrampc_julia), Cvoid, () )
end
