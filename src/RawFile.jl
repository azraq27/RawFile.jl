module RawFile

export saveraw,readraw

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

function readraw(func::Function,fname::String,batch::Int)
    open(fname) do f
        h = readheader(f)
        batch_step = reduce(*,h.sizes[1:end-1])
        total_length = batch_step*h.sizes[end]
        batch_size = copy(h.sizes)
        i = 0
        while i<total_length
            this_len = Int(min(batch,(total_length-i)/batch_step))
            batch_size[end] = this_len
            d = read(f,h.typet,Tuple(batch_size))
            func(d)
            i += batch_step*this_len
        end
        endtok = String(read(f,length(endtoken)))
        endtok != endtoken && error("Invalid end of RawFile")
    end
end


end