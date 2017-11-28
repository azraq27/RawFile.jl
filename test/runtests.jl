using RawFile
using Base.Test

fname = "testfile.raw"
for t in RawFile.rawtypekey
    for d in [rand(t,100),rand(t,75,100),rand(t,10,30,60)]
        saveraw(d,fname)
        dd = readraw(fname)
        @assert d == dd
        isfile(fname) && rm(fname)
    end
end