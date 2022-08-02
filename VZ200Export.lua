-- VZ200 sprite data export by Jason "WauloK" Oakley
-- https://www.BlueBilby.com/
-- Based on Gameboy export code from
-- https://github.com/boombuler/aseprite-gbexport/blob/master/GameboyExport.lua
-- May also work for other Motorola 6847 based graphics chip computers
-- https://en.wikipedia.org/wiki/Motorola_6847
-- Place this file in the Aesprite scripts directory
-- Usually on Windows: %APPDATA%\Aseprite\scripts

local sprite = app.activeSprite
local choice = ""

-- Check constrains
if sprite == nil then
  app.alert("No Sprite...")
  return
end
if sprite.colorMode ~= ColorMode.INDEXED then
  app.alert("Sprite needs to be indexed")
  return
end

if (sprite.width % 4) ~= 0 then
  app.alert("Sprite width needs to be a multiple of 4")
  return
end

-- Get and convert pixel data in Hex Assembly format
local function getTileData(img, x, y)
    local res = ""
    local dbformat = ""
    if choice.trs80CoCoFormat then
        dbformat = "FCB"
    else
        dbformat = "DB"
    end
    for  cy = 0, sprite.height-1 do
        local val = 0
        -- VZ200 has 2 bits per pixel and 4 pixels per byte
        for cx = 0, sprite.width-1, 4 do
            value = 0
            for xbyte = 0, 3 do
                px = img:getPixel(cx+x+xbyte, cy+y)
                -- Index 0 is transparent and not used for VZ200
                px = px - 1
                value = value << 2 | px
            end
            res = res .. string.format("$%02x", value)  
            if cx+4 < sprite.width-1 then
                res = res .. ", "
            else
                if cy < sprite.height-1 then
                    res = res .. "\n"..dbformat.." "
                end
            end
        end
    end
    return dbformat .. " " .. res .. "\n"
end

-- Get and convert pixel data in TRSE Decimal Array format
local function getTileDataTRSE(img, x, y)
    local res = ""

    for  cy = 0, sprite.height-1 do
        local val = 0
        -- VZ200 has 2 bits per pixel and 4 pixels per byte
        for cx = 0, sprite.width-1, 4 do
            value = 0
            for xbyte = 0, 3 do
                px = img:getPixel(cx+x+xbyte, cy+y)
                -- Index 0 is transparent and not used for VZ200
                px = px - 1
                value = value << 2 | px
            end
            res = res .. string.format("%03d", value)
            if cy < sprite.height then
                res = res .. ", "
            end
        end
    end
    return res
end

-- Get and convert pixel data in binary format
local function getTileDataBinary(img, x, y)
    local res = ""

    for  cy = 0, sprite.height-1 do
        local val = 0
        -- VZ200 has 2 bits per pixel and 4 pixels per byte
        for cx = 0, sprite.width-1, 4 do
            value = 0
            for xbyte = 0, 3 do
                px = img:getPixel(cx+x+xbyte, cy+y)
                -- Index 0 is transparent and not used for VZ200
                px = px - 1
                value = value << 2 | px
            end
            res = res .. (string.char(value))
        end
    end
    return res
end

local spriteLookup = {}
local lastLookupId = 0

-- Export frame data in Assembly Hex format - used in single or all sprite output
local function exportFrame(useLookup, frm)
    if frm == nil then
        frm = 1
    end

    local img = Image(sprite.spec)
    img:drawSprite(sprite, frm)

    local result = {}

    for x = 0, sprite.width-1, sprite.width do
        local column = {}
        local data = ""
        for y = 0, sprite.height-1, sprite.height do

            -- Gather decimal values
            if choice.trseDecArrayFormat then
                data = getTileDataTRSE(img, x, y)
                if frm == #sprite.frames or choice.onlyCurrentFrame then
                    data = string.sub(data,1,-3)
                end
            elseif choice.binaryFileFormat then
                data = getTileDataBinary(img, x, y)
            else
                data = getTileData(img, x, y)
            end
            local id = 0
            if useLookup then
                id = spriteLookup[data]
                if id == nil then
                    id = lastLookupId + 1
                    lastLookupId = id

                    spriteLookup[data] = id
                else
                    data = nil
                end 
            else
                id = lastLookupId + 1
                lastLookupId = id
            end
            table.insert(column, id)
            if data ~= nil then
                io.write(data)
            end
        end
        table.insert(result, column)
    end
    return result
end

local dlg = Dialog()
dlg:label{ id="info",
           text="Outputs data in MC6847 2-bits-per-pixel format"}
dlg:file{ id="exportFile",
          label="File",
          title="VZ200-Assembler Export",
          open=false,
          save=true,
          filetypes={"asm", "bin", "inc", "z80", "txt" }}

dlg:newrow()           
dlg:radio{ id="VZ200AssemblyFormat",
           text="Output VZ200 Assembly Hex data",
           selected=true} 
dlg:newrow()           
dlg:radio{ id="trseDecArrayFormat",
           text="Output TRSE Array data in Decimal",
           selected=false}         
dlg:newrow()           
dlg:radio{ id="trs80CoCoFormat",
           text="Output Assembly to TRS80 Coco opcode",
           selected=false}
dlg:newrow()           
dlg:radio{ id="binaryFileFormat",
           text="Output to a binary file",
           selected=false}

dlg:check{ id="onlyCurrentFrame",
           text="Export only current frame",
           selected=false }
dlg:newrow()           
dlg:check{ id="removeDuplicates",
           text="Remove duplicate tiles",
           selected=false}
dlg:button{ id="ok", text="OK" }
dlg:button{ id="cancel", text="Cancel" }
dlg:show()
choice = dlg.data

if choice.ok then
    -- Open a Binary file or Text file
    if choice.binaryFileFormat then
        f = io.open(choice.exportFile, "wb")
    else
        f = io.open(choice.exportFile, "w")
    end

    io.output(f)

    local mapData = {}

    -- Output TRSE array prefix
    if choice.trseDecArrayFormat then
        io.write("spriteData: array[] of byte =(")
    end

    -- Output just the one frame?
    if choice.onlyCurrentFrame then
        table.insert(mapData, exportFrame(choice.removeDuplicates, app.activeFrame))
    else
        for i = 1,#sprite.frames do
            if not choice.trseDecArrayFormat and not choice.binaryFileFormat then
                io.write(string.format(";Frame %d\n", i))
            end
            table.insert(mapData, exportFrame(choice.removeDuplicates, i))
        end
    end

    -- Output TRSE array suffix
    if choice.trseDecArrayFormat then
        io.write(");")
    end

    -- Write data out
    io.flush()

    -- Close file
    io.close(f)
end
