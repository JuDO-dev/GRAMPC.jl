using GRAMPC
using GRAMPC_jll
using Test

####################################################################
# Introduce an error and see if it is reported by the library
####################################################################
@test_throws ErrorException ccall( (:printError, libgrampc_julia), Cvoid, (Cstring,), "Test error" )
@test_throws ErrorException ccall( (:printErrorAddString, libgrampc_julia), Cvoid, (Cstring, Cstring), "Error", "Message" )


####################################################################
# Test warning reporting
####################################################################
warnCString = Vector{UInt8}(undef, 1024)

# Ensure our clear function works
GRAMPC._clear_warning()
@test ccall( (:grampcjl_get_last_warning, libgrampc_julia), Cint, (Ptr{UInt8},), warnCString ) == 0


# Introduce a warning and see if it is reported by the library (these are only done by polling)
ccall( (:printWarningAddString, libgrampc_julia), Cvoid, (Cstring, Cstring), "Warning", "Message" )
@test ccall( (:grampcjl_get_last_warning, libgrampc_julia), Cint, (Ptr{UInt8},), warnCString ) == 1
@test unsafe_string( pointer( warnCString ) ) == "Warning: Message"

# Make sure the warning was cleared after we read it
@test ccall( (:grampcjl_get_last_warning, libgrampc_julia), Cint, (Ptr{UInt8},), warnCString ) == 0


# Test the warning macro
ccall( (:printWarningAddString, libgrampc_julia), Cvoid, (Cstring, Cstring), "Warning", "Message" )
@test_logs (:warn, "Warning: Message") GRAMPC.@check_warning

# Make sure the warning was cleared after we read it
@test ccall( (:grampcjl_get_last_warning, libgrampc_julia), Cint, (Ptr{UInt8},), warnCString ) == 0
