
@testset "Extinction" begin
# Standard usage    
spec = mock_spectrum()
extincted = extinct(spec, 0.3)
extinct!(spec, 0.3)
@test extincted.flux ≈ spec.flux

# Bad law
@test_throws AssertionError extinct(spec, 0.3, law=:penguin)

end
