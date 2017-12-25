using RawFile
using Base.Test

sizes = [(100,),(75,100),(10,20,50)]
fname = "testfile.raw"
for t in RawFile.rawtypekey
    for s in sizes
        d = rand(t,s)
        saveraw(d,fname)
        dd = readraw(fname)
        dd_batch = t[]
        readraw(fname,10) do d
            append!(dd_batch,d[:])
        end
        dd_batch = reshape(dd_batch,s)
        
        @assert d == dd
        @assert d == dd_batch
        @assert s == rawsize(fname)
        
        saveraw(fname) do f
           for i=0:Int(s[end]/10)-1
                write(f,view(d,[Colon() for j=1:ndims(d)-1]...,i*10+1:i*10+10))
            end
        end
        
        dd = readraw(fname)
        info(size(d))
        info(size(dd))
        info(d[70:80])
        info(dd[70:80])
        @assert d == dd
        
        isfile(fname) && rm(fname)
    end
end
