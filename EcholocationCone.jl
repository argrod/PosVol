using CSV
using DataFrames
using Plots#; pyplot()
# using GLMakie

# read in the data
Dat = CSV.File("/Users/aran/Documents/GitHub/PosVol/D++.txt",delim = '\t') |> DataFrame;
rename!(Dat,[:Depth,:Pitch,:Roll,:Speed,:Heading]);
#Dat = Dat[1:(sum(ismissing.(Dat.Depth) .== false) - 1),:]

new = Dat[:,2:3]
new = new[1:16:nrow(Dat),:]
new = new[1:sum(ismissing.(Dat.Heading) .== false),:]
dat = DataFrame(Depth = Dat.Depth[1:sum(ismissing.(Dat.Heading) .== false)], Pitch = new[:,1], Roll = new[:,2], Speed = Dat.Speed[1:sum(ismissing.(Dat.Heading) .== false)], Head = Dat.Heading[sum(ismissing.(Dat.Heading) .== false)])


function maxEchD(ci)
    1500*(ci/2)
end
function sphSecVol(R,d,θ)
    (2/3)*pi*R^2*(d - d*cos(θ))
end
function ellAr(x,y)
    pi*x*y
end

d = maxEchD(0.05)
θ = 5/(180/pi)
rad = d*tan(θ)
V = sphSecVol(rad,d,θ)

ϕ = LinRange(0, 5*(180/pi), 100)
φ = LinRange(0, 5*(180/pi), 100)
x = [cospi(φ)*sinpi(ϕ) for ϕ in ϕ, φ in φ]
y = [sinpi(φ)*sinpi(ϕ) for ϕ in ϕ, φ in φ]
z = sqrt.(x.^2 + y.^2)
surface(x, y, z, shading = false)

plot(z)

tan(θ/2) = r/d


xs = LinRange(-d/2, d/2, 100)
ys = LinRange()

f(x,y) = (x)^2 + (y)^2

x = LinRange(-d,d,100)
y = x
plot(d*cos.(LinRange(0,θ,100)), d*sin.(LinRange(0,θ,100)))

plot([-d*cos(θ/2),0,d*cos(θ/2)],[-d,0,d])


d*tan(θ/2)
d*tan(-θ/2)

ϕ = LinRange(-θ/2, θ/2, 100)
ψ = LinRange(θ/2, -θ/2, 100)
x = [d*tan(ϕ) for ϕ in ϕ]
y = [d*tan(ψ) for ψ in ψ]
z = sqrt.(x.^2 + y.^2)
surface(x, y, z, shading = false)