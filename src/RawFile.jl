module RawFile

export saveraw,readraw
export RawFile,RawFileIter,start,done,next

token = "RAWF"
version = 1
endtoken = "FIN"

rawtypekey = Type[
    Float64,
    Float32,
    Float16,
    Int64  ,
    Int32  ,
    Int16  ,
    Int8   ,
    UInt8
]

type RawHeader
    version::Int8
    typenum::Int8
    typet::Type
    sizes::Array{Int64,1}
end

import Base.write

function write(f::IO,x::RawHeader)
    write(f,token)
    write(f,x.version)
    write(f,x.typenum)
    write(f,Int8(length(x.sizes)))
    write(f,x.sizes)
end

function readheader(f::IO)
    tok = String(read(f,length(token)))
    tok != token && error("Invalid token in RawFile")
    ver = read(f,Int8)
    typenum = read(f,Int8)
    typet = rawtypekey[typenum]
    nd = read(f,Int8)
    sizes = read(f,Int64,nd)
    RawHeader(ver,typenum,typet,sizes)
end

function saveraw{T<:Real,V}(a::AbstractArray{T,V},fname::String)
    typenum = Int8(findfirst(rawtypekey,typeof(a[1])))
    header = RawHeader(version,typenum,typeof(a[1]),collect(size(a)))
    open(fname,"w") do f
        write(f,header)
        write(f,a)
        write(f,endtoken)
    end
end

function readraw(fname::String)
    open(fname) do f
        h = readheader(f)
        d = read(f,h.typet,Tuple(h.sizes))
        endtok = String(read(f,length(endtoken)))
        endtok != endtoken && error("Invalid end of RawFile")
        return d
    end
end

type RawFileIter
    fname::String
    num_batch::Int
end

type RawFileState
    i::Int
    total_length::Int
    num_batch::Int
    batch_step::Int
    batch_size::Array{Int,1}
    f::IO
    typet::Type
end

import Base.start,Base.next,Base.done

function start(r::RawFileIter)
    f = open(r.fname)
    h = readheader(f)
    batch_step = reduce(*,h.sizes[1:end-1])
    total_length = batch_step*h.sizes[end]
    batch_size = copy(h.sizes)
    i = 0
    return RawFileState(i,total_length,r.num_batch,batch_step,batch_size,f,h.typet)
end

function done(r::RawFileIter,state)
    if state.i < state.total_length
        return false
    else
        endtok = String(read(state.f,length(endtoken)))
        endtok != endtoken && error("Invalid end of RawFile")
        return true
    end
end

function next(r::RawFileIter,state)
    this_len = Int(min(state.num_batch,(state.total_length-state.i)/state.batch_step))
    state.batch_size[end] = this_len
    d = read(state.f,state.typet,Tuple(state.batch_size))
    state.i += state.batch_step*this_len
    return (d,state)
end

function readraw(func::Function,fname::String,batch::Int)
    for d in RawFileIter(fname,batch)
        func(d)
    end
end

end