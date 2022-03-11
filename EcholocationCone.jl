using CSV
using DataFrames
using Plots;
# using GLMakie

# read in the data
Dat = CSV.File("D++.txt",delim = '\t') |> DataFrame;
rename!(Dat,[:Depth,:Pitch,:Roll,:Speed,:Heading]);
#Dat = Dat[1:(sum(ismissing.(Dat.Depth) .== false) - 1),:]

new = Dat[:,2:3]
new = new[1:16:nrow(Dat),:]
new = new[1:sum(ismissing.(Dat.Heading) .== false),:]
dat = DataFrame(Depth = Dat.Depth[1:sum(ismissing.(Dat.Heading) .== false)], Pitch = new[:,1], Roll = new[:,2], Speed = Dat.Speed[1:sum(ismissing.(Dat.Heading) .== false)], Head = Dat.Heading[sum(ismissing.(Dat.Heading) .== false)])


function maxEchD(ci)
    1500*(ci/2)
end
function echDist(ICI::Number,pT::Number=0)
    dist = (343*ICI) - pT;
    if dist < pT
    throw(ArgumentError("Processing time exceeds half the ICI"))
    end
    return dist
end
function sphSecVol(d,θ)
    (2/3)*pi*d^2*(d - d*cos(θ/2))
end
function ellAr(x,y)
    pi*x*y
end
function coneCoords(x,y,z,pitch,head,θ=15)
    
end 

d = maxEchD(0.05)
θ = 5/(180/pi)
V = sphSecVol(d,θ)

ϕ = LinRange(0, 5*(180/pi), 100)
φ = LinRange(0, 5*(180/pi), 100)
x = [cospi(φ)*sinpi(ϕ) for ϕ in ϕ, φ in φ]
y = [sinpi(φ)*sinpi(ϕ) for ϕ in ϕ, φ in φ]
z = sqrt.(x.^2 + y.^2)
surface(x, y, z, shading = false)

plot(x,y,z,st=:surface,c=cgrad([:black,:grey]))

function xcoord(ρ,θ,ϕ,inDegs=true)
    return inDegs == true ? ρ*cos(θ*(π/180))*cos(ϕ*(π/180)) : ρ*cos(θ)*cos(ϕ)
end
function ycoord(ρ,θ,ϕ,inDegs=true)
    return inDegs == true ? ρ*sin(θ*(π/180))*sin(ϕ*(π/180)) : ρ*sin(θ)*sin(ϕ)
end
function zcoord(ρ,ϕ,inDegs=true)
    return inDegs == true ? ρ*cos(ϕ*(π/180)) : ρ*cos(ϕ)
end

# set θ as 0 : 2π
# ϕ determined as angle cone makes with z axis
# rotating a cone so there is one axis of symmetry (only need rotation about the z and y axes)
θ = LinRange(0,2*π, 100)
ϕ = LinRange(0, 15*(180/pi), 100)
surface(xcoord.(3,θ,ϕ,false),ycoord.(3,θ,ϕ,false),
    zcoord.(3,ϕ,false))

xcoord(3,1.5,.15,false)


n = 100
u = range(-π, π; length = n)
v = range(0, 15*(π/180); length = n)
x = cos.(u) * sin.(v)'
y = sin.(u) * sin.(v)'
z = ones(n) * cos.(v)'

Plots.surface(5.*x,5.*y,5.*z)

n = 200
θ = range(-π, π; length = n)
φ = [(0:2n-2)*2/(2n-1);2]
x = [cospi(φ)*sinpi(θ) for θ in θ, φ in φ]
y = [sinpi(φ)*sinpi(θ) for θ in θ, φ in φ]
z = @. sqrt(x^2 + y^2)
surface(x, y, z, xlims=(-2,2),ylims=(-2,2),zlims=(-2,2))


n = 200
θ = LinRange(0, 0.5, 100)
φ = LinRange(0, 2, 100)
x = [cospi(φ)*sinpi(θ) for θ in θ, φ in φ]
y = [sinpi(φ)*sinpi(θ) for θ in θ, φ in φ]
z = sqrt.(x.^2 + y.^2)
surface(x, y, z, shading = false)

plot(x.+1,y,z,seriestype=:scatter)

x[1,:]
y[1,:]
z[1,:]
z[2,:]

datLim = dat[ismissing.(dat.Head) .== 0,:]
# horizontal speed
σ = identity.(datLim.Speed.*cosd.(abs.(datLim.Pitch)));
Plots.plot!(σ.*sind.(datLim.Head),σ.*cosd.(datLim.Head),.-datLim.Depth,color="blue")

Plots.plot([σ[499]*sind(datLim.Head[499]),σ[500]*sind(datLim.Head[500])],
    [σ[499]*cosd(datLim.Head[499]),σ[500]*cosd(datLim.Head[500])],
    [-datLim.Depth[499],-datLim.Depth[500]],color="blue")
Plots.plot!([σ[500]*sind(datLim.Head[500])],[σ[500]*cosd(datLim.Head[500])],[-datLim.Depth[500]],color="blue",seriestype=:scatter,markersize =3)
θ = LinRange(σ[499]*sind(datLim.Head[499]), σ[500]*sind(datLim.Head[500]), 100)
φ = LinRange(σ[499]*cosd(datLim.Head[499]), σ[500]*cosd(datLim.Head[500]), 100)
x = [cospi(φ)*sinpi(θ) for θ in θ, φ in φ]
y = [sinpi(φ)*sinpi(θ) for θ in θ, φ in φ]
z = sqrt.(x.^2 + y.^2)
surface(x,y,z,xlims=(minimum(x),maximum(x)),ylims=(minimum(y),maximum(y)),zlims=(minimum(z),maximum(z)))

# calculate the x and y positions of whale (z axis as depth)
datLim.y = cumsum(σ.*cosd.(datLim.Head))
datLim.x = cumsum(σ.*sind.(datLim.Head))

plot([datLim.x],[datLim.y],[.-datLim.Depth],xlabel="X",ylabel="Y",zlabel="Depth")

anim = @animate for g = 1:nrow(datLim)
    Plots.scatter([datLim.x[g]],[datLim.y[g]],[-datLim.Depth[g]],markersize=3,color="red",xlims=(minimum(datLim.x),maximum(datLim.x)),
    ylims=(minimum(datLim.y),maximum(datLim.y)),zlims=(minimum(-datLim.Depth),0))
    if g > 1
        Plots.plot!(datLim.x[1:g],datLim.y[1:g],.-datLim.Depth[1:g],color="blue")
    end
end

g = 1100
Plots.scatter([datLim.x[g]],[datLim.y[g]],[-datLim.Depth[g]],markersize=3,color="red",xlims=(minimum(datLim.x),maximum(datLim.x)),
    ylims=(minimum(datLim.y),maximum(datLim.y)),zlims=(minimum(-datLim.Depth),0))
plot!(
    [datLim.x[g],echDist(1)*sind(datLim.Head[g])],
    [datLim.y[g],echDist(1)*cosd(datLim.Head[g])],
    [-datLim.Depth[g],echDist(1)*cosd(datLim.Pitch[g])],
    arrow=true,linewidth=2
)


Plots.plot([σ.*sind.(datLim.Head)],[σ.*cosd.(datLim.Head)],[.-datLim.Depth],
    color="blue",xlabel="X",ylabel="Y",zlabel="Depth")


g = 500
Plots.scatter([σ[g]*sind(datLim.Head[g])],[σ[g]*cosd(datLim.Head[g])],[-datLim.Depth[g]],markersize=3,color="red",xlims=(minimum(σ.*sind.(datLim.Head)),maximum(σ.*sind.(datLim.Head))),
    ylims=(minimum(σ.*cosd.(datLim.Head)),maximum(σ.*cosd.(datLim.Head))),zlims=(minimum(-datLim.Depth),0),xlabel="X",ylabel="Y",zlabel="Depth")

Plots.plot([0],[0],[0],seriestype=:scatter,xlims=(-5,5),
    ylims=(-5,5),zlims=(-5,5))

Plots.plot!([5],[5],[5],seriestype=:scatter)

    Plots.plot!([xcoord.(5,0:360,5)],[ycoord.(5,0:360,5)],[repeat([zcoord(5,5)],360)],
    seriestype=:scatter)

repeat([0],360)

Plots.scatter([σ[500]*sind(datLim.Head[500])],[σ[500]*cosd.(datLim.Head[500])],[-datLim.Depth[500]])
Plots.scatter!([σ[500]*sind(datLim.Head[500])+echDist(1)*sind(datLim.Head[500]+15)],
    [σ[500]*cosd(datLim.Head[500])+echDist(1)*cosd(datLim.Head[500]+15)])


    [σ[500]*sind(datLim.Head[500]).+echDist(1).*sind.(datLim.Head[500] .+ [-15,15])]
    [σ[500]*cosd(datLim.Head[500]).+echDist(1).*cosd.(datLim.Head[500] .+ [-15,15])]
    [-datLim.Depth[500].+echDist(1).*[cosd(datLim.Pitch[500])]]

newPitch = x .+ r.*[cosd(pitch+15)])

Plots.plot(σ.*sind.(datLim.Head),σ.*cosd.(datLim.Head),.-datLim.Depth,color="blue")

Plots.pyplot()

plotlyjs()
Plots.plot([0],[0],[0],seriestype=:scatter,xlims=(-5,5),
    ylims=(-5,5),zlims=(-5,5))
Plots.plot!([3*cosd(15)],[3*cosd(15)],[3*cosd(15)],seriestype=:scatter)
Plots.plot!([3*sind(15)],[3*sind(15)],[3*sind(15)],seriestype=:scatter)

scatter([5*cosd.([15/2,-15/2])],[5*sind.([15/2,-15/2])],[5*cosd.([15/2,-15/2])])

plot([0],[0],seriestype=:scatter,xlims=(-5,5),ylims=(-5,5))
Plots.plot!([3*cosd(15)],[3*cosd(15)],seriestype=:scatter)
Plots.plot!([3*cosd(10)],[3*cosd(10)],seriestype=:scatter)

Plots.plot!([3*sind(-15)],[3*sind(-15)],seriestype=:scatter)



Plots.plot([0],[0],seriestype=:scatter,xlims=(-5,5),ylims=(-5,5))


xs = LinRange(-d/2, d/2, 100)
ys = LinRange()

f(x,y) = (x)^2 + (y)^2

datLim = dat[ismissing.(dat.Head) .== 0,:]
# horizontal speed
σ = identity.(datLim.Speed.*cosd.(abs.(datLim.Pitch)));


Plots.scatter([σ.*sind.(datLim.Head)],[-datLim.Depth],[σ.*cosd.(datLim.Head)],markersize=3,color="red",xlims=(minimum(σ.*sind.(datLim.Head)),maximum(σ.*sind.(datLim.Head))),
zlims=(minimum(σ.*cosd.(datLim.Head)),maximum(σ.*cosd.(datLim.Head))),ylims=(minimum(-datLim.Depth),0))

Plots.pyplot()
Plots.scatter([σ.*sind.(datLim.Head)],-datLim.Depth,[σ.*cosd.(datLim.Head)])


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

n = 100
u = LinRange(0,2*π,n);
v = LinRange(0,π,n);

x = [cos(u) * sin(v) for u in u, v in v]
# y = sin(u) * sin(v)';
y = [sin(u) * sin(v) for u in u, v in v]
z = sqrt.(x.^2 + y.^2);

# The rstride and cstride arguments default to 10
plot(x,y,z, st = :surface,camera = (-50,30))

function rotY(θ)
    [[cos(θ), 0, -sin(θ)] [0, 1, 0] [sin(θ), 0, cos(θ)]]
end

function rotX(θ)
    [[1,0,0] [0,cos(θ),-sin(θ)] [0,sin(θ),cos(θ)]]
end

function rotZ(θ)
    [[cos(θ),-sin(θ),0] [sin(θ),cos(θ),0] [0,0,1]]
end

[0,0,1].*rotY(50).*rotX(50).*rotZ(50)

rotX(50).*rotY(50)