
-- Positions must be a table (or metatable) where table.x and table.y are accessible.

require( "vector" )

Luafinding = {}

-- To-do: maybe some form of different distance checks for diagonals?
-- There's something wrong happening in this function, because sometimes close to walls there are huge blobs in the final path.
local function distance( start, finish )
    local x = math.abs( start.x - finish.x )
    local y = math.abs( start.y - finish.y )
    return x * x + y * y
end

local function findLowest( set, scores )
    local min, lowest = math.huge, nil

    for node, _ in pairs( set ) do
        local score = scores[node]
        if score < min then
            min, lowest = score, node
        end
    end

    return lowest
end

local function positionIsOpen( pos, check )
    if type( check ) == "table" then
        return check[pos.x] and check[pos.x][pos.y]
    elseif type( check ) == "function" then
        return check( pos.x, pos.y ) or true
    end

    return true
end

local adjacentPositions = {
    Vector(  0, -1 ),
    Vector( -1,  0 ),
    Vector(  0,  1 ),
    Vector(  1,  0 ),
    Vector( -1, -1 ),
    Vector(  1, -1 ),
    Vector( -1,  1 ),
    Vector(  1,  1 )
}

local function fetchOpenAdjacentNodes( pos, positionOpenCheck )
    local result = {}

    for _, adjacent in ipairs( adjacentPositions ) do
        local adjacentPos = pos + adjacent
        if positionIsOpen( adjacentPos, positionOpenCheck ) then
            table.insert( result, adjacentPos )
        end
    end

    return result
end

-- positionOpenCheck can be a function or a table.
-- If it's a function it must have a return value of true or false depending on whether or not the position is open.
-- If it's a table it should simply be a table of values such as "pos[x][y] = true".
function Luafinding.FindPath( start, finish, positionOpenCheck )
    if not positionIsOpen( finish, positionOpenCheck ) then return end
    local open, closed, gScore, hScore, fScore, reconstructionKeys, reconstruction = {}, {}, {}, {}, {}, {}, {}

    open[start] = true
    gScore[start] = 0
    hScore[start] = distance( start, finish )
    fScore[start] = hScore[start]

    while next( open ) do
        local current = findLowest( open, fScore )
        open[current] = nil
        if not closed[tostring(current)] then
            if current == finish then return reconstruction end

            closed[tostring(current)] = true

            for _, adjacent in ipairs( fetchOpenAdjacentNodes( current, positionOpenCheck ) ) do
                local added_gScore = gScore[current] + distance( current, adjacent )

                if not gScore[adjacent] or added_gScore < gScore[adjacent] then
                    if not reconstructionKeys[current] then
                        reconstructionKeys[current] = true
                        table.insert( reconstruction, current )
                    end
                    gScore[adjacent] = added_gScore
                    if not hScore[adjacent] then
                        hScore[adjacent] = distance( adjacent, finish )
                    end
                    fScore[adjacent] = added_gScore + hScore[adjacent]

                    open[adjacent] = true
                end
            end
        end
    end
end