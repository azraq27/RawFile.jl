module RawFile

export saveraw,readraw

token = "RAWF001"
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


function saveraw{T,V}(a::AbstractArray{T,V},fname::String)
    open(fname,"w") do f
        write(f,token)
        write(f,Int8(findfirst(rawtypekey,typeof(a[1]))))
        write(f,Int8(V))
        write(f,collect(size(a)))
        write(f,a)
        write(f,endtoken)
    end
end

function readraw(fname::String)
    open(fname) do f
        tok = String(read(f,length(token)))
        tok != token && error("Invalid token in raw file")
        typenum = read(f,Int8)
        typet = rawtypekey[typenum]
        nd = read(f,Int8)
        siz = read(f,Int64,nd)
        d = read(f,typet,Tuple(siz))
        endtok = String(read(f,length(endtoken)))
        endtok != endtoken && error("Invalid end of file")
        return d
    end
end


end