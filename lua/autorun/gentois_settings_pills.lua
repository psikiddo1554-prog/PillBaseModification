
AddCSLuaFile()

if SERVER then
    local function CreateAConvVarConstant(VarName, DefaultSetting, Text,min,max)
        CreateConVar(VarName, DefaultSetting, FCVAR_ARCHIVE, Text, min, max)     
    end
    CreateAConvVarConstant("gentoipills_pvp", 0, "", 0, 1) 
else
    CreateClientConVar("gentoipills_basefov", 80, true, true, "")

    CreateClientConVar("gentoipills_chasemusic", 1, true, true, "")
    CreateClientConVar("gentoipills_chasemusicvolume", 100, true, true, "")

    CreateClientConVar("gentoipills_antiepilepsy", 0, true, true, "")
    CreateClientConVar("gentoipills_limitedfovmultiplyer", 100, true, true, "")
    hook.Add("PopulateToolMenu", "Gentoi_pill_basepills_populate", function()   

        spawnmenu.AddToolMenuOption("Pill Base Settings", "Base Pills", "Gentoi_pills_basepills", "Restrictions", "", "", function(panel)

            panel:Help("------------ BASE PILLS ------------")
            panel:Help("")

            panel:Help("------------ PVP ------------")
            panel:Help("")
            panel:CheckBox("PVP","gentoipills_pvp")
            panel:Help("Enabling this will allow pills under this base to start attacking each other.")
            panel:Help("")
        end)       

        spawnmenu.AddToolMenuOption("Pill Base Settings", "Base Pills", "Gentoi_pills_Preferences", "Preferences", "", "", function(panel)

            panel:Help("------------ Preferences ------------")
            panel:Help("")

            panel:Help("------------ MISC ------------")
            panel:Help("")
            panel:NumSlider("Base Fov","gentoipills_basefov",75,135)
            panel:Help("")

            panel:Help("------------ Chase music ------------")
            panel:Help("")
            panel:CheckBox("Chase music","gentoipills_chasemusic")
            panel:NumSlider("Volume","gentoipills_chasemusicvolume",1,200)
            panel:Help("")

            panel:Help("------------ IMPORTANT ------------")
            panel:CheckBox("epilepsy","gentoipills_antiepilepsy")
            panel:Help("Enabling this will replace flashing lights or complex patterns with something more simple.")
            panel:NumSlider("fov change multiplyer","gentoipills_limitedfovmultiplyer",0,100)
            panel:Help("There are some abilities that will change your fov. The lower the value is, the weaker the fov change is.")
            panel:Help("")
        end) 
    end)
end