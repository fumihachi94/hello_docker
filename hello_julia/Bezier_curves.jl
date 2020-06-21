using PyPlot
using LinearAlgebra

function bernstein(n, i, t)
    return binomial(n, i) * t^i * (1-t)^(n-i)
end

function bezier_curve(n, t, p)
    x = [dot([bernstein(n, i, t) for i = 0:n], p[:,1]) dot([bernstein(n, i, t) for i = 0:n], p[:,2])];
    return x
end

# Create control points at random
N = 4;
L = 10;
p = rand(N, 2) * L;
p = p[sortperm(p[:,1]), :]

# Calculate
nt  = 100
x   = Array{Float64,2}(undef, nt+1, 2)
for k = 1:nt+1
    x[k,:] = bezier_curve(N - 1, (k-1)/100, p)
end

# Draw
plot(p[:,1], p[:,2], marker="o")
plot(x[:,1], x[:,2])
title("Bezier curve")
xlabel("X")
ylabel("Y")
grid("on")

print("test")

show()
