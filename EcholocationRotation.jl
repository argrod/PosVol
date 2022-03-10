# using Makie
# using CairoMakie
# using GLMakie
using DataFrames, LinearAlgebra, StaticArrays, Plots, Statistics, Rotations, CSV

# windowed function
movF(fs,x,window) = [fs(x[Int(maximum([1,round((g-window)/2)])):Int(minimum([length(x),round((g+window)/2)]))]) for g in 1:length(x)]
# peakstroughs
function PeakTrough(x::Vector{Float64})
    Peaks = zeros(Int64,0)
    Troughs = zeros(Int64,0)
    for b = 2:length(x)-1
        if x[b-1] > x[b] && x[b+1] >= x[b]
            append!(Troughs, b)
        elseif x[b-1] <= x[b] && x[b+1] < x[b]
            append!(Peaks,b)
        end
    end
    return Peaks, Troughs
end
# calculate echolocation distance
function echDist(ICI::Number,pT::Number=0)
    dist = (343*ICI) - pT;
    if dist < pT
    throw(ArgumentError("Processing time exceeds half the ICI"))
    end
    return dist
end
# rotations
function yawRot(γ::Number,deg::Bool=true)
    if deg == true
        γ = γ*(pi/180)
    end
    return([[cos(γ), sin(γ), 0] [-sin(γ), cos(γ), 0] [0,0,1]])
end
function pitchRot(ρ::Number,deg::Bool=false)
    if deg == true
        ρ = ρ*(pi/180)
    end
    return([[cos(ρ),0,sin(ρ)] [0,1,0] [-sin(ρ),0,cos(ρ)]])
end
function rollRot(r::Number,deg::Bool=false)
    if deg == true
        r = r*(pi/180)
    end
    return([[1,0,0] [0,cos(r),sin(r)] [0,-sin(r),cos(r)]])
end
function rotMat(γ::Number,ρ::Number,r::Number,deg::Bool=true)
    # apply rotations as yaw then pitch then roll
    return yawRot(γ,deg)*pitchRot(ρ,deg)*rollRot(r,deg)
end

Dat = CSV.File("D++.txt",delim = '\t') |> DataFrame;
rename!(Dat,[:Depth,:Pitch,:Roll,:Speed,:Heading]);


Dat[1,:]

dat = DataFrame(Depth = Dat.Depth[1:findlast(Dat.Speed.!== missing)], Pitch = Dat.Pitch[1:16:(findlast(Dat.Speed.!== missing)*16)],
    Roll = Dat.Roll[1:16:(findlast(Dat.Speed.!== missing)*16)],Speed = Dat.Speed[1:findlast(Dat.Speed.!== missing)], Head = Dat.Heading[1:findlast(Dat.Speed.!== missing)])
# if any(ismissing.(dat.Depth))
#     for x = findall(ismissing.(dat.Depth))
#         findlast(dat.Depth[1:x])
#     end
# elseif any(ismissing.(dat.Speed))
#     for x = findall(ismissing.(dat.Speed))
#         dat.Speed[x] = sum(skipmissing(dat.Speed[(findlast(ismissing.(dat.Speed[1:x]) .== 0)):(findfirst(ismissing.(Dat.Speed[x:end]) .== 0)+x-1)]))/((findfirst(ismissing.(Dat.Speed[x:end]) .== 0)+x-1)-(findlast(ismissing.(dat.Speed[1:x])) - 1))
#     end
# end
# new = Dat[:,2:3]
# new = new[1:16:nrow(Dat),:]
# new = new[1:sum(ismissing.(Dat.Heading) .== false),:]
# dat = DataFrame(Depth = Dat.Depth[1:sum(ismissing.(Dat.Heading) .== false)], Pitch = new[:,1], Roll = new[:,2], Speed = Dat.Speed[1:sum(ismissing.(Dat.Heading) .== false)], Head = Dat.Heading[sum(ismissing.(Dat.Heading) .== false)])
# # 16 hz for pitch and Roll
# nrow(Dat)/16

angSide(x,θ) = x*cos(θ)

plotlyjs()
Plots.plot(1:1000,1:1000)
Plots.plot!(1:1000,angSide.(1:1000,Ref(-.5)))
Plots.plot!(1:1000,(1:1000).+(1:1000).-angSide.(1:1000,Ref(-.5)))

datLim = dat[ismissing.(dat.Head) .== 0,:]
# horizontal speed
σ = identity.(datLim.Speed.*cosd.(abs.(datLim.Pitch)));

Plots.plot(σ.*sind.(datLim.Head),σ.*cosd.(datLim.Head),.-datLim.Depth)
Plots.scatter!(-datLim.Depth[1],σ[1]*sind(datLim.Head[1]),σ[1]*cosd(datLim.Head[1]))

anim = @animate for g = 1:length(σ)
    Plots.scatter([σ[g]*sind(datLim.Head[g])],[σ[g]*cosd(datLim.Head[g])],[-datLim.Depth[g]],markersize=3,color="red",xlims=(minimum(σ.*sind.(datLim.Head)),maximum(σ.*sind.(datLim.Head))),
    ylims=(minimum(σ.*cosd.(datLim.Head)),maximum(σ.*cosd.(datLim.Head))),zlims=(minimum(-datLim.Depth),0))
    if g > 1
        Plots.plot!(σ[1:g].*sind.(datLim.Head[1:g]),σ[1:g].*cosd.(datLim.Head[1:g]),.-datLim.Depth[1:g],color="blue")
    end
end
gif(anim, "E:/My Drive/PhD/Figures/Visuals/whale_anim.gif", fps = 15)
# given some radius θ and a straight line x, calculate the corresponding boundaries of a cone


datLim[1,:]


Plots.plot([0,-datLim.Depth[1]],[0,σ[1]*sind(datLim.Head[1])],[0,σ[1]*cosd(datLim.Head[1])])


echDist(.5)

function maxEchD(ci)
    1500*(ci/2)
end
function ConVol(b,d)
    (b*d)/3
end
function ellAr(x,y)
    pi*x*y
end
di = maxEchD(0.05)
θ = 5*(180/pi)
rad = di*tan(θ)
V = ConVol(pi*rad^2,di)
# convert echolocation signal into volumes

anim = @animate for g = 1:length(σ)
    Plots.scatter([σ[g]*sind(datLim.Head[g])],[σ[g]*cosd(datLim.Head[g])],[-datLim.Depth[g]],markersize=3,color="red",xlims=(minimum(σ.*sind.(datLim.Head)),maximum(σ.*sind.(datLim.Head))),
    ylims=(minimum(σ.*cosd.(datLim.Head)),maximum(σ.*cosd.(datLim.Head))),zlims=(minimum(-datLim.Depth),0))
    if g > 1
        Plots.plot!(σ[1:g].*sind.(datLim.Head[1:g]),σ[1:g].*cosd.(datLim.Head[1:g]),.-datLim.Depth[1:g],color="blue")
    end
end

g=1
Plots.scatter([σ[g]*sind(datLim.Head[g])],[σ[g]*cosd(datLim.Head[g])],[-datLim.Depth[g]],markersize=3,color="red")


n = 100
u = range(0,stop=2*π,length=n);
v = range(0,stop=π,length=n);

x = cos.(u) * sin.(v)';
y = sin.(u) * sin.(v)';
z = ones(n) * cos.(v)';
# The rstride and cstride arguments default to 10

plotlyjs()
b = 50:100
Plots.plot(x[:,b],y[:,b],z[:,1:50],st=:scatter,markersize=1,
    xlims=[-1,1],ylims=[-1,1],zlims=[-1,1],
    xaxis="x",yaxis="y",zaxis="z")
Plots.plot!(x[:,b],y[:,b],z[:,1:50],st=:surf,
    xlims=[-1,1],ylims=[-1,1],zlims=[-1,1],
    xaxis="x",yaxis="y",zaxis="z")

x = cos.(range(0,.3, length=100)) * sin.(range(0,.3,length=100))';
y = sin.(range(0,.3, length=100)) * sin.(range(0,.3,length=100))';
z = ones(100)

Plots.plot(x,y,z,st=:surf,
xaxis="x",yaxis="y",zaxis="z")

# determine the furthest angular distance reached for radius R and angle θ
function furthConeDist(R,θ)
    R*acos(θ)
end

scatter([0,furthConeDist(150,5)],)

b=15*(pi/180)
Plots.scatter([1:100].*sin(b*(pi/180)),[1:100].*cos(b*(pi/180)))
Plots.scatter!([0],[100])
Plots.scatter!(-[1:100].*sin(b*(pi/180)),[1:100].*cos(b*(pi/180)))

u = range(-100,100,length=100)
v = range(0,100,length=100)
Plots.plot(u.*sin(b),v.*cos(b))


Plots.scatter(cos.(range(-b,b,length=100))*sin.(range(-b,b,length=100))',
sin.(range(pi/2,pi/2-b,length=100))*sin.(range(0,pi/2-b,length=100))')


[-100:100].*sin(b*(pi/180)),

Plots.plot([-100:100].*sin(b*(pi/180)),
cos.(range(-b,b,length=201)*(pi/180)).*range(-100,100,length=201),
xlims=[-100,100])
Plots.plot!([-100:100].*sin(b*(pi/180)),100*cos.(range(-b,b,length=201)*(pi/180)))

Plots.scatter([-100:100].*sin(b*(pi/180)),[1:100])

u = range(0,stop=2*π,length=n);
v = range(0,stop=π,length=n);

x = cos.(u) * sin.(v)';
y = sin.(u) * sin.(v)';
z = ones(n) * cos.(v)';

Plots.plot!([-100:100].*sin(b*(pi/180)),100*cos.(range(-15,15,length=201)*(pi/180)))


Plots.plot(x,y,z,st=:surf,
    xlims=[-1,1],ylims=[-1,1],zlims=[-1,1],
    xaxis="x",yaxis="y",zaxis="z")


size(x)


x = range(0,stop=50,length=n);

echDist(.5)
function conex(d,θ,len)
    r = d*cos(θ)
    u = range(0,stop=d,length=len)
    return ((d.-u)./d).*r.*cos(θ), ((d.-u)./d).*r.*sin(θ), u
end
x,y,z = conex(echDist(.5),5,1000)

n = 100
u = range(-π, π; length = n)
v = range(0, π; length = n)
x = cos.(u) * sin.(v)'
y = sin.(u) * sin.(v)'
z = ones(n) * cos.(v)'
plotly()
surface(x, y, z)

Plots.plot(conex(echDist(.5),5,1000))

t=range(0,30*π,length=10000)
x=t.*cos.(t)
y=t.*sin.(t)
Plots.plot(x,y,t,st=:surface)

Plots.plot(x[10:50,:],y[10:50,:])

Plots.plot(y)
Plots.plot(x[:,1])
Plots.plot(z[:,1])


Plots.plot(sin.(range(0,100,length=1000)))

coneVals(r,t) = r*cos(t)sin(pi/4),r*sin(t)sin(pi/4),r*cos(pi/4)

surface(coneVals.(range(0,stop=.5,length=1000),range(0,stop=2*π,length=1000)))

Plots.plot(coneVals.(range(0,stop=.5,length=1000),range(0,stop=2*π,length=1000)))


y = ((h-u)/h)*r*sin(θ)



gcf()

Plots.plot(dat.Depth,yflip=true)

ismissing(Dat.Speed[86671]) + Dat.Heading[86671] !== missing


plot(Dat.Heading .!== missing .+ ismissing.(Dat.Speed),reuse=false)

Plots.plot(Dat.Heading .!== missing .+ ismissing.(Dat.Speed) .+ ismissing.(Dat.D))



plotlyjs()
Plots.plot(dat.Depth,yflip=true)
pk,tr = PeakTrough(identity.(dat.Depth));
Plots.scatter!(tr,dat.Depth[tr])
Plots.plot!(dat.Pitch,mirror=true,ylims=(minimum(dat.Pitch),maximum(dat.Pitch)))

dat.Speed.*sind.(dat.Head)


Plots.plot(datLim.Depth,σ.*sind.(datLim.Head),σ.*cosd.(datLim.Head))


cosd(360-dat.Head[1])

Plots.scatter()

Plots.plot(dat.Speed.*cosd.(abs.(dat.Pitch)))

Plots.scatter([1,1,1], [0,0,0], [0,0,0])
Plots.plot([0,0],[0,1],[0,0])


Plots.plot([0,0],[0,0],[0,1],arrow=2)