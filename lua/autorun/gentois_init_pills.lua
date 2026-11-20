if !pcall(require,"pk_pills") then
    if SERVER then
        hook.Add("PlayerInitialSpawn","pk_pill_extfail_cl",function(ply)
            if game.SinglePlayer() || ply:IsListenServerHost() then
                ply:SendLua('notification.AddLegacy("One or more pill extensions failed to load. Did you forget to install Parakeet\'s Pill Pack?",NOTIFY_ERROR,30)')
            end
        end)
        hook.Add("Initialize","pk_pill_extfail_sv",function(ply)
            print("[ALERT] One or more pill extensions failed to load. Did you forget to install Enhanced Parakeet's Pill Base?")
        end)
    end
    return
end

AddCSLuaFile()

local function CountIncludeFolder(path)
    local files, folders = file.Find(path .. "/*", "LUA")
    --local returnamount = 0

    for _, fileName in ipairs(files) do
        if string.EndsWith(fileName, ".lua") then
            --returnamount = returnamount + 1
        end
    end

    --return returnamount
end

local function IncludeFolder(path)
    local files, folders = file.Find(path .. "/*", "LUA")
    --local returnamount = 0

    for _, fileName in ipairs(files) do
        if string.EndsWith(fileName, ".lua") then
            AddCSLuaFile(path .. "/" .. fileName)
            include(path .. "/" .. fileName)
            --returnamount = returnamount + 1
        end
    end

    --return returnamount

    --[[
    for _, folderName in ipairs(folders) do
        IncludeFolder(path .. "/" .. folderName)
    end
    ]]
end

AddCSLuaFile("autorun/gentois_functions_pills.lua")
include("autorun/gentois_functions_pills.lua")

--if CountIncludeFolder("autorun/include/Gentoi_KillerPills") >= 1 then 
    pk_pills.packStart("Gentoi Monster Pills", "noodlesPillz_gentoi_monsters", "icons/gentoiimage.png")
    --Gentoi_KillerPills_monstercount = IncludeFolder("autorun/include/Gentoi_KillerPills")
    IncludeFolder("autorun/include/Gentoi_KillerPills")
--end

--if CountIncludeFolder("autorun/include/Eddygar_KillerPills") >= 1 then 
    pk_pills.packStart("Eddygar Monster Pills", "noodlesPillz_eddygar_monsters", "icons/eddygaricon.png")
    --Eddygar_KillerPills_monstercount = IncludeFolder("autorun/include/Eddygar_KillerPills")
    IncludeFolder("autorun/include/Eddygar_KillerPills")
--end

--if CountIncludeFolder("autorun/include/Custom_KillerPills") >= 1 then 
--end

IncludeFolder("autorun/gentoipill_basecode")

require("nick_base_halo")
--