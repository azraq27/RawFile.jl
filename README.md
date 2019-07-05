# RawFile

A simple, fast file format for storing numeric arrays. I built this package because I was frustrated with the speed and complexity of other formats.

The basic format (`raw`) saves bit arrays as flat files with a minimal header. Arrays can be read back and will be formatted into the correct `Type` and `size`.

## Saving arrays:

Save an Array to a file:

    saveraw{T<:Number,V}(a::AbstractArray{T,V},fname::String)
    
Append a Number or Array to an existing file. If appending an Array, appends along last dimension. This function requires that the two Arrays have the same sie (except the last dimension) and `Type`.

    appendraw{T<:Number,V}(a::AbstractArray{T,V},fname::String)
    appendraw(a::T,fname::String) where {T<:Number} = appendraw([a],fname)

## Reading arrays:

Read an Array from a file:

    readraw(fname::String)

## Meta data:

Just read the Array size from the header and return a `Tuple`
 
    rawsize(fname::String)

## Partial read/write

These functions were made if you are handling large files and want to be able to write them progressively without keeping all of the data in memory at one time.

### Progressive saving

To save an Array progressively, each piece needs to have the same dimensions (except for the last, where they will be concatenated)

    saveraw(func::Function,fname::String)

```julia-repl
julia> saveraw("test.raw") do f
           for i=1:10
               write(f,rand(100,10,5))
           end
       end
julia> rawsize("test.raw")
(100, 10, 50)
```

### Progressive reading

The `RawFileIter` Type is an interator that can be used to read through a file returning chunks of data (based on the parameter `num_batch`), instead of the entire file at once. The iteration is also encapsulated into the `readraw` function for convenience.

    RawFileIter(fname::String,num_batch::Int)
    readraw(func::Function,fname::String,batch::Int)

```julia-repl
julia> for d in RawFileIter("test.raw",20)
                  @info(size(d))
              end
[ Info: (100, 10, 20)
[ Info: (100, 10, 20)
[ Info: (100, 10, 10)
```

```julia-repl
julia> readraw("test.raw",20) do c
           @info(size(c))
       end
[ Info: (100, 10, 20)
[ Info: (100, 10, 20)
[ Info: (100, 10, 10)
```

[![Build Status](https://travis-ci.org/azraq27/RawFile.jl.svg?branch=master)](https://travis-ci.org/azraq27/RawFile.jl)

[![Coverage Status](https://coveralls.io/repos/azraq27/RawFile.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/azraq27/RawFile.jl?branch=master)

[![codecov.io](http://codecov.io/github/azraq27/RawFile.jl/coverage.svg?branch=master)](http://codecov.io/github/azraq27/RawFile.jl?branch=master)
