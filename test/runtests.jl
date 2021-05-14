using GRAMPC
using Test
using SafeTestsets

@testset "GRAMPC.jl" begin
    @testset "C Interface" begin
        @safetestset "Error handling" begin include( "cinterface/test_error_handling.jl" ) end
    end
end
