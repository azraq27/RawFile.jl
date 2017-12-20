using RawFile
using Base.Test

sizes = [(100,),(75,100),(10,20,50)]
fname = "testfile.raw"
for t in RawFile.rawtypekey
    for s in sizes
        d = rand(t,s)
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
        @assert s == rawsize(fname)
        
        isfile(fname) && rm(fname)
    end
end