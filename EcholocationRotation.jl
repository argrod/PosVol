# using Makie
# using CairoMakie
# using GLMakie
using CSV
using DataFrames
# using WebIO
# using MeshIO
using Plots
using LinearAlgebra
using StaticArrays
using PlotlyJS
using Statistics
using Rotations

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

rotMat(dat.Head[1],dat.Pitch[1],dat.Roll[1])

Dat = CSV.File("D++.txt",delim = '\t') |> DataFrame;
rename!(Dat,[:Depth,:Pitch,:Roll,:Speed,:Heading]);
new = Dat[:,2:3]
new = new[1:16:nrow(Dat),:]
new = new[1:sum(ismissing.(Dat.Heading) .== false),:]
dat = DataFrame(Depth = Dat.Depth[1:sum(ismissing.(Dat.Heading) .== false)], Pitch = new[:,1], Roll = new[:,2], Speed = Dat.Speed[1:sum(ismissing.(Dat.Heading) .== false)], Head = Dat.Heading[sum(ismissing.(Dat.Heading) .== false)])


RotZYX(dat.Head[1]*(pi/180),dat.Pitch[1]*(pi/180),dat.Roll[1]*(pi/180))
tst = rotMat(dat.Head[1],dat.Pitch[1],dat.Roll[1])

Plots.scatter(accumulate(+,sum.(rotMat.(dat.Head,dat.Pitch,dat.Roll)[:,3])),accumulate(+,sum.(rotMat.(dat.Head,dat.Pitch,dat.Roll)[:,1])),dat.Depth)

rotMat.(dat.Head,dat.Pitch,dat.Roll)[:][:,3]


length()


# in vector space, the whale moves in [spd,0,0] as you assume no up or down movement
# so you rotate that point [spd,0,0] by the rotational matrix produced by the yaw, pitch, and roll
   

Plots.scatter(accumulate(+,[sum(x[:,3]) for x in rotMat.(dat.Head,dat.Pitch,dat.Roll)]),accumulate(+,[sum(x[:,1]) for x in rotMat.(dat.Head,dat.Pitch,dat.Roll)]),dat.Depth.*-1,markersize=1)


tst=(x->sum(x[:,3]),rotMat.(dat.Head,dat.Pitch,dat.Roll));


sum(tst[:,1] * 1)
# initialise travel from point [0,0,0]
plotlyjs()
Plots.scatter([0],[0],[0],markersize=1)

Plots.scatter(1:nrow(dat),dat.Depth.*-1,zeros(nrow(dat)),markersize=1)


# first point denotes the orientation of the animal
Plots.scatter!(yawRot(dat.Head[1])*[0,0,1]*dat.Speed[1],pitchRot(dat.Pitch[1])*dat.Speed[1],rollRot(dat.Roll[1])*dat.Speed[1])

dat.Depth[1]


bleurgh = @layout [a ; b]

Plots.plot(dat.Pitch)

Plots.plot(accumulate(+, dat.Speed.*dat.Pitch))

Plots.plot(accumulate(+, sin.(dat.Pitch)))

Plots.plot(dat.Pitch)
Plots.plot!(dat.Depth)

plotlyjs()
Plots.plot(accumulate(+,dat.Speed.*sin.(dat.Pitch)),accumulate(+, dat.Speed.*cos.(dat.Roll)),accumulate(+, dat.Speed.*cos.(dat.Head)))

Plots.plot(accumulate(+,dat.Speed.*sin.(dat.Pitch)))

Plots.plot(dat.Depth,yflip=true)

plotlyjs()
Plots.plot(dat.Depth,yflip=true)
pk,tr = PeakTrough(identity.(dat.Depth));
Plots.scatter!(tr,dat.Depth[tr])
Plots.plot!(dat.Pitch,mirror=true,ylims=(minimum(dat.Pitch),maximum(dat.Pitch)))


Plots.scatter([1,1,1], [0,0,0], [0,0,0])
Plots.plot([0,0],[0,1],[0,0])


Plots.plot([0,0],[0,0],[0,1],arrow=2)