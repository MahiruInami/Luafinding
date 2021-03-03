
require( "vector" )
require( "luafinding" )
local map = {}
local mapSize = 100
local numberOfTests = 1000
local mapDensity = 0.65

local seed = os.time()
math.randomseed( seed )
print( string.format( "Running with seed %d", seed ) )

print( string.format( "Building a map of %dx%d...", mapSize, mapSize ) )
for x = 1, mapSize do
    map[x] = {}
    for y = 1, mapSize do
        map[x][y] = math.random()
    end
end

print( string.format( "Precalculating %d random start/goal positions...", numberOfTests * 2 ) )
local testPoints = {}
for i = 1, numberOfTests * 2 do
    table.insert( testPoints, Vector( math.random( 1, mapSize ), math.random( 1, mapSize ) ) )
end

print( string.format( "Finding %d paths...", numberOfTests ) )
local function positionIsOpenFunc( x, y )
    if not map[x] or not map[x][y] then return false end
    return map[x][y] > mapDensity
end
local testStart = os.clock()
for testNumber = 1, numberOfTests do
    Luafinding.FindPath( table.remove( testPoints ), table.remove( testPoints ), map, positionIsOpenFunc )
end
local testEnd = os.clock()
local totalSec = testEnd - testStart
local pathSec = totalSec / numberOfTests

print( "Done in " .. totalSec .. " seconds.\nAverage of " .. pathSec .. " per path." )