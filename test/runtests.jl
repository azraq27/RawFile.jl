using RawFile
using Base.Test

fname = "testfile.raw"
for t in RawFile.rawtypekey
    for d in [rand(t,100),rand(t,75,100),rand(t,10,100)]
        saveraw(d,fname)
        dd = readraw(fname)
        catfunc = ndims(d)==1 ? vcat : hcat
        dd_batch = 0
        readraw(fname,10) do d
            if dd_batch==0
                dd_batch = d
            else
                dd_batch = catfunc(dd_batch,d)
            end
        end
        
        @assert d == dd
        @assert d == dd_batch
        
        isfile(fname) && rm(fname)
    end
end