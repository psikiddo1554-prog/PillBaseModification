
AddCSLuaFile()

local EntityTable = {}

function entityTable_pillarchase_recode()
    return EntityTable
end

hook.Add("OnEntityCreated", "InitializeTable_pillarchase_recode", function(ent)
    if ent:IsPlayer() or ent:IsNPC() or ent:IsNextBot() then
        table.insert(EntityTable, ent)
    end
end)

hook.Add("EntityRemoved", "Remove_pillarchase_recode", function(ent)
    table.RemoveByValue(EntityTable, ent)
end)


function Gentoi_AdvancedPillSound(SoundData, ent)
    if SERVER then
        if IsValid(ent) then
            SoundData = SoundData or {}
            SoundData.stringe = SoundData.stringe or {}
            SoundData.soundLevel = SoundData.soundLevel or 75
            SoundData.pitchPercent = SoundData.pitchPercent or 100
            SoundData.volume = SoundData.volume or 1
            SoundData.channel = SoundData.channel or CHAN_AUTO
            SoundData.soundFlags = SoundData.soundFlags or 0
            SoundData.dsp = SoundData.dsp or 0
            SoundData.filter = SoundData.filter or nil

            local chosenSound = SoundData.stringe

            if istable(SoundData.stringe) then
                local index = math.random(1, #SoundData.stringe)
                chosenSound = SoundData.stringe[index]
            end

            ent:EmitSound(
                chosenSound,
                SoundData.soundLevel,
                SoundData.pitchPercent,
                SoundData.volume,
                SoundData.channel,
                SoundData.soundFlags,
                SoundData.dsp,
                SoundData.filter
            )
        end
        return true
    end
end

function ConsideredAsEnemy_basepills(ply, ent, ent2)
    if not GetConVar("gentoipills_pvp"):GetBool() then
        if ent2:GetNWBool("gentoi_basepill_faction") then return end
        if ent2:GetNW2Bool("gentoi_basepill_faction") then return end
    end
    return true
end

if SERVER then
    util.AddNetworkString("ShakeCamera_gentoim1")
else
    net.Receive("ShakeCamera_gentoim1", function()
        local ply = LocalPlayer()
        util.ScreenShake(
            ply:GetPos(),
            15,
            15,
            0.25,
            1
        )
    end)
end

-- Set up base move --
local gentoi_slowdownfunctions = {}

function gentoi_slowdownfunctions_initialize(functions)
    gentoi_slowdownfunctions[functions.Name] = {
        ["CreateMove"] = functions.CreateMove,
        ["SetupMove"] = functions.SetupMove
    }
    return true
end

if SERVER then
    hook.Add("SetupMove", "Gentoi_DisablePlayerMovement", function(ply, mv, cmd)
        if IsValid(ply) then
            for i, v in pairs(gentoi_slowdownfunctions) do
                if v["SetupMove"] then
                    v["SetupMove"](ply, mv, cmd)
                end
            end

            local ent = ply.pk_pill_ent
            if IsValid(ent) then
                if ent.formTable.GentoiDisablePlayerMovement then
                    ent.formTable.GentoiDisablePlayerMovement(ply, ent, mv, cmd)
                end
            end
        end
    end)
else
    hook.Add("CreateMove", "Gentoi_clientsidemovement", function(cmd)
        local ply = LocalPlayer()
        if IsValid(ply) then
            for i, v in pairs(gentoi_slowdownfunctions) do
                if v["CreateMove"] then
                    v["CreateMove"](ply, cmd)
                end
            end

            local ent = ply.pk_pill_ent
            if IsValid(ent) then
                if ent.formTable.Gentoiclientsidemovement then
                    ent.formTable.Gentoiclientsidemovement(ply, ent, cmd)
                end
            end
        end
    end)
end

-- Set up base move --
local gentoi_keybindfunctions = {}

function gentoi_keybindfunctions_initialize(functions)
    gentoi_keybindfunctions[functions.Name] = {
        ["PlayerButtonDown"] = functions.PlayerButtonDown,
        ["PlayerButtonUp"] = functions.PlayerButtonUp
    }
    return true
end

-- KEYBINDs
hook.Add("PlayerButtonDown", "keybind_OM_gentoi_keybindtrigger_buttondown", function(ply, button)
    --[[
    if SERVER and button == KEY_R then


        local last = CurTime()+3
        local flung = CurTime()+0.2
        local plyvelocity = ply:GetVelocity()
        local enemyragdoll = CreateRagdolLCharacter_pills_gent({
            target = ply,
            host = ply,

            shouldremove = function(createfakeragdoll)
                if not IsValid(createfakeragdoll) then return true end
                if not IsValid(ply) then return true end

                local pos = createfakeragdoll:GetPos()

                local tr = util.TraceLine({
                    start = pos,
                    endpos = pos - Vector(0, 0, 30),
                    filter = createfakeragdoll
                })

                if (last < CurTime() and tr.Hit ) then
                    return true
                else
                    if not tr.Hit then
                        last = CurTime() + 1
                    end
                end
                return false
            end,

            shoulddocustomfunction = function(createfakeragdoll)
                if not IsValid(createfakeragdoll) then return end
                if flung <= CurTime() then return end

                for i = 0, createfakeragdoll:GetPhysicsObjectCount() - 1 do
                    local phys = createfakeragdoll:GetPhysicsObjectNum(i)

                    if IsValid(phys) then
                        phys:SetVelocity(plyvelocity)
                    end
                end
            end
        })

    end
    ]]

    for i, v in pairs(gentoi_keybindfunctions) do
        if v["PlayerButtonDown"] then
            v["PlayerButtonDown"](ply, button)
        end
    end
 
    local pillentity = ply.pk_pill_ent

    local drgbase = false
    if isfunction(ply.DrG_IsPossessing) then
        if ply:DrG_IsPossessing() then
            drgbase = true
            pillentity = ply:DrG_Possessing()
            ply = pillentity
        end
    end

    if !IsValid(pillentity) then return end
    if pillentity.formTable then else return end
    if pillentity.formTable.gentoi_basepill_buttondown then
        pillentity.formTable.gentoi_basepill_buttondown(ply, pillentity, button)
    end
    if button == KEY_SLASH then
        pillentity:SetNWBool('HoldingDownMenu_gentoi', true)
        pillentity:SetNW2Float('HoldingDownMenu_gentoi_timeframe', CurTime())
    end
end)

hook.Add("PlayerButtonUp", "keybind_OM_gentoi_keybindtrigger_buttonup", function(ply, button)
    for i, v in pairs(gentoi_keybindfunctions) do
        if v["PlayerButtonUp"] then
            v["PlayerButtonUp"](ply, button)
        end
    end
 
    local pillentity = ply.pk_pill_ent

    local drgbase = false
    if isfunction(ply.DrG_IsPossessing) then
        if ply:DrG_IsPossessing() then
            drgbase = true
            pillentity = ply:DrG_Possessing()
            ply = pillentity
        end
    end
    
    if !IsValid(pillentity) then return end
    if pillentity.formTable then else return end
    if pillentity.formTable.gentoi_basepill_buttonup then
        pillentity.formTable.gentoi_basepill_buttonup(ply, pillentity, button)
    end
    if button == KEY_SLASH then
        pillentity:SetNWBool('HoldingDownMenu_gentoi', false)
        pillentity:SetNW2Float('HoldingDownMenu_gentoi_timeframe', CurTime())
    end
end)

-- Base code


local thinkcode = function(thinktable)
    local self, ent = thinktable.self, thinktable.ent
    local ply, puppet = self:GetPillUser(), self:GetPuppet()
    if not IsValid(puppet) or not IsValid(ply) then return end
    local vel = ply:GetVelocity():Length()

    if not self.intializeangle then
        self.intializeangle = true
        local angle = ply:GetAngles()
        angle.p = 0
        if SERVER then puppet:SetAngles(angle) end
        if CLIENT then puppet:SetRenderAngles(angle) end
    end

    -- [[ Serversided settings ]]
    if SERVER then
        ply:SetNW2Bool("gentoi_faction_pvp", GetConVar("gentoipills_pvp"):GetBool())
    end

    -- [[ First person handling ]]
    if CLIENT then
        local Gentoi_FirstPerson_handle = self.formTable.Gentoi_FirstPerson_handle
        if not Gentoi_FirstPerson_handle then
            if self:GetPillUser() ~= LocalPlayer() or pk_pills.convars.cl_thirdperson:GetBool() then
                puppet:SetNoDraw(false)
            else
                puppet:SetNoDraw(true)
            end
        else Gentoi_FirstPerson_handle(ply, ent) end
    end

    -- [[ Weapon handling ]]
    if SERVER then
        if not self.formTable.hideWeapons then
            local realWep = self:GetPillUser():GetActiveWeapon()
            if IsValid(realWep) and realWep:GetModel() ~= "" then
                if realWep.pill_attachment then
                    if IsValid(self.wepmdl) then
                        self.wepmdl:Remove()
                    end

                    self.wepmdl = ents.Create("pill_attachment_wep")
                    self.wepmdl:SetParent(self:GetPuppet())
                    self.wepmdl:SetModel(realWep:GetModel())
                    self.wepmdl.attachment = realWep.pill_attachment
                    self.wepmdl:Spawn()

                    if realWep.pill_offset then
                        self.wepmdl:SetWepOffset(realWep.pill_offset)
                    end

                    if realWep.pill_angle then
                        self.wepmdl:SetWepAng(realWep.pill_angle)
                    end

                    realWep.pill_proxy = self.wepmdl
                elseif not IsValid(self.wepmdl) then
                    self.wepmdl = ents.Create("pill_attachment_wep")
                    self.wepmdl:SetParent(self:GetPuppet())
                    self.wepmdl:SetModel(realWep:GetModel())
                    self.wepmdl:Spawn()
                    realWep.pill_proxy = self.wepmdl
                elseif self.wepmdl:GetModel() ~= realWep:GetModel() then
                    self.wepmdl:SetModel(realWep:GetModel())
                end
            elseif IsValid(self.wepmdl) then
                self.wepmdl:Remove()
            end
        end
    else
        local realWep = self:GetPillUser():GetActiveWeapon()

        if IsValid(realWep) and realWep:GetModel() ~= "" and not realWep:GetNoDraw() then
            realWep:SetNoDraw(true)
        end
    end

    -- [[ inputs ]]
    if ply:KeyDown(IN_ATTACK) and self.formTable.attack and self.formTable.attack.mode == "tick" then self.formTable.attack.func(ply, self, self.formTable.attack) end
    if ply:KeyDown(IN_ATTACK2) and self.formTable.attack2 and self.formTable.attack2.mode == "tick" then self.formTable.attack2.func(ply, self, self.formTable.attack2) end

    -- [[ Pose Parameters ]]
    local Gentoi_PoseParameters_handle = self.formTable.Gentoi_PoseParameters_handle
    if not Gentoi_PoseParameters_handle then
        if self.formTable.aim then
            self.SmoothYaw = self.SmoothYaw or 0
            self.SmoothPitch = self.SmoothPitch or 0

            local yaw = math.AngleDifference(
                ply:EyeAngles().y,
                puppet:GetAngles().y
            )

            local pitch = math.AngleDifference(
                ply:EyeAngles().p,
                puppet:GetAngles().p
            )

            self.SmoothYaw = Lerp(FrameTime() * 10, self.SmoothYaw, yaw)
            self.SmoothPitch = Lerp(FrameTime() * 10, self.SmoothPitch, pitch)

            puppet:SetPoseParameter(self.formTable.aim.xPose, self.SmoothYaw)
            puppet:SetPoseParameter(self.formTable.aim.yPose, self.SmoothPitch)
        end
    else Gentoi_PoseParameters_handle(ply, ent) end

    -- [[ Anims ]]
    if SERVER then
        local anims = table.Copy(self.formTable.anims.default or {})
        table.Merge(anims, (IsValid(ply:GetActiveWeapon()) and self.formTable.anims[ply:GetActiveWeapon():GetHoldType()]) or (self.forceAnimSet and self.formTable.anims[self.forceAnimSet]) or {})
        local anim
        --local useSeqVel=true
        local overrideRate

        if (not self.anim or not anims[self.anim]) then
            self.animFreeze = nil
            self.animStart = nil
        end

        if self.anim and anims[self.anim] then
            anim = anims[self.anim]
            overrideRate = anims[self.anim .. "_rate"] or 1
            local cycle = puppet:GetCycle()

            if not self.animStart then
                if cycle == 1 or (self.animCycle and self.animCycle > cycle) or (string.lower(anim) ~= string.lower(puppet:GetSequenceName(puppet:GetSequence()))) then
                    self.anim = nil
                    self.animCycle = nil
                elseif self.animCycle then self.animCycle = cycle end
            end
        elseif ply:WaterLevel() > 2 then anim = anims["swim"] or anims["glide"] or anims["idle"]
        elseif ply:IsOnGround() then
            if ply:Crouching() then
                if vel > ply:GetCrouchedWalkSpeed() / 4 then anim = anims["crouch_walk"] or anims["crouch"] or anims["walk"] or anims["idle"]
                else anim = anims["crouch"] or anims["idle"] end
            else
                if vel > (ply:GetWalkSpeed() + ply:GetRunSpeed()) / 2 then  anim = anims["run"] or anims["walk"] or anims["idle"]
                elseif vel > ply:GetWalkSpeed() / 4 then anim = anims["walk"] or anims["idle"]
                else anim = anims["idle"] end
            end
        else anim = anims["glide"] or anims["idle"]
        end

        if anim == anims["idle"] or anim == anims["crouch"] then overrideRate = 1 end
        self:SetNW2String("Animlastplayed", anim)

        local ShouldAlternate = table.Copy(self.formTable.anims.ShouldAlternate or {})
        if type(ShouldAlternate[anim]) == "function" and ShouldAlternate[anim](self) then
            if ShouldAlternate[anim](self) ~= nil and isstring(ShouldAlternate[anim](self)) then
                anim = ShouldAlternate[anim](self)
            end
        end

        if (anim and puppet:GetSequence() ~= puppet:LookupSequence(anim)) or self.animStart or (self.formTable.autoRestartAnims and puppet:GetCycle() == 1) then
            if self.currentanim ~= puppet:GetSequence() then
                if not animFreeze then 
                    puppet:ResetSequence(puppet:LookupSequence(anim))
                    puppet:SetCycle(0)
                    self.animCycle = 0
                    self.currentanim = anim
                end
            end
        end

        self.animStart = nil
    end

    -- [[ Set Position ]]
    local animsshouldspn = self.formTable.Gentoi_SetPosition
    if not animsshouldspn then if SERVER then puppet:SetPos(ply:GetPos()) else puppet:SetRenderOrigin(ply:GetPos()) end
    else animsshouldspn(ply, ent) end

    --[[ Dynamic angles ]]
    local currentanim = self:GetNW2String("Animlastplayed")
    local animsshouldspn = table.Copy(self.formTable.anims.ShouldMoveRotate or {})
    
    if animsshouldspn[currentanim] or (type(animsshouldspn[currentanim]) == "function" and animsshouldspn[currentanim](self)) then
        local typeofitem = (type(animsshouldspn[currentanim]) == "function" and animsshouldspn[currentanim](self)) or animsshouldspn[currentanim]

        local SetAngleto
        local curAng

        local lerpspeed = 7

        local animsshouldspnLerpSpeed = table.Copy(self.formTable.anims.ShouldMoveRotate_lerpspeed or {})
        if animsshouldspnLerpSpeed[currentanim] or (type(animsshouldspnLerpSpeed[currentanim]) == "function" and animsshouldspnLerpSpeed[currentanim](self)) then
            lerpspeed = (type(animsshouldspnLerpSpeed[currentanim]) == "function" and animsshouldspnLerpSpeed[currentanim](self)) or animsshouldspnLerpSpeed[currentanim]
        end

        local lerpfactor = math.min(FrameTime() * lerpspeed, 1)

        if SERVER then curAng = puppet:GetAngles() else curAng = puppet:GetRenderAngles() or Angle(0,0,0) end
        if typeofitem == "notshftlock" then
            local vel = ply:GetVelocity()
            vel.z = 0
            if vel:Length2DSqr() > 1 then
                local targetAng = vel:Angle()
                targetAng.p = 0
                targetAng.r = 0

                SetAngleto = LerpAngle(lerpfactor, curAng, targetAng)
            end
        elseif typeofitem == "assignedagnles_instant" then SetAngleto = self:GetNW2Angle("pill_assignedangle")
        elseif typeofitem == "shiftlock" then
            local angs = ply:EyeAngles()
            angs.p = 0
            SetAngleto = LerpAngle(lerpfactor, curAng, angs)
        elseif typeofitem == "Playerangles" then
            local angs = ply:GetAngles()
            angs.p = 0
            SetAngleto = LerpAngle(lerpfactor, curAng, angs)
        elseif typeofitem == "assignedagnles" then SetAngleto = LerpAngle(lerpfactor, curAng, self:GetNW2Angle("pill_assignedangle"))
        elseif typeofitem == "notanything" then SetAngleto = curAng
        end

        if SetAngleto then
            if SERVER then puppet:SetAngles(SetAngleto) end
            if CLIENT then puppet:SetRenderAngles(SetAngleto) end
        end
    end

    -- [[ Animspeed ]]
    if SERVER then
        local rate = 1
        local animsshouldspn = table.Copy(self.formTable.anims.animrates or {})
        if animsshouldspn[currentanim] or (type(animsshouldspn[currentanim]) == "function" and animsshouldspn[currentanim](self)) then
            rate = (type(animsshouldspn[currentanim]) == "function" and animsshouldspn[currentanim](self)) or animsshouldspn[currentanim]
        end
        if rate > 12 then
            rate = 12
        end
        puppet:SetPlaybackRate(rate)
    end

    -- Think Code

    if self.formTable.gentoi_basepill_think then
        self.formTable.gentoi_basepill_think(ply, ent)
    end
end

if SERVER then
    util.AddNetworkString("clientside_thinkcodeinitialize_gentoi_base")
else
    net.Receive("clientside_thinkcodeinitialize_gentoi_base", function()
        local ply, ent = LocalPlayer(), net.ReadEntity()

        if !IsValid(ent) then return end

        ent.Think = function()
            thinkcode({ self = ent, ent = ent, })
            ent:NextThink(CurTime())
            return IsValid(ent)
        end
    end)
end

hook.Add( "PreRegisterSENT", "gentoi_basepill_initialize_overide_puppet", function( ent, class )
    if class == "pill_puppet" then
        local PuppetEntity = table.Copy(ent)
        
        PuppetEntity.Type = "anim"
        PuppetEntity.AutomaticFrameAdvance = true
        PuppetEntity.Think = function(self)
            self:NextThink(CurTime())
            return true
        end
        --[[
        PuppetEntity.SetupDataTables = function()
            PuppetEntity:NetworkVar("String", 0, "PillForm")
            PuppetEntity:NetworkVar("Entity", 1, "PillCostume")
            PuppetEntity:NetworkVar("Entity", 2, "PillUser")
        end
        ]]

        PuppetEntity.Initialize = function(self)
            self:SetRenderMode(RENDERMODE_TRANSALPHA)
        end

        PuppetEntity.Draw = function(self)
            self:DrawModel()
        end

        PuppetEntity.DrawTranslucent = function(self)
            self:Draw()
        end
        
        PuppetEntity.QueueEvent = function()
        end

        PuppetEntity.RunAI = function()
        end

        scripted_ents.Register( PuppetEntity, "pill_gentoi_pillbase_puppet" )
    end
end )

hook.Add("OnEntityCreated", "gentoi_basepill_initialize", function(ent)
    timer.Simple(0, function()
        if !IsValid(ent) then return end
        if ent:GetClass() == "pill_ent_costume" then
            if not ent then return end
            if ent.formTable then
                local PuppetEntity = ent:GetPuppet()
                local entityply = ent:GetPillUser()
                if ent.formTable.gentoi_basepill then

                    if SERVER then
                        local health = ent.formTable.Health
                        if health then
                            entityply:SetHealth(health)
                            entityply:SetMaxHealth(health)
                            entityply:GodDisable()
                        end
                    end

                    entityply:SetNW2String("gentoi_chasemusic_audio", "")

                    timer.Simple(0.1, function() if !IsValid(ent) then return end
                        ent:SetNWBool("gentoi_basepill_faction", true)
                        ent:SetNW2Bool("gentoi_basepill_faction", true)

                        entityply:SetNWBool("gentoi_basepill_faction", true)
                        entityply:SetNW2Bool("gentoi_basepill_faction", true)
                        ent:CallOnRemove("disablebasepill_gentoi"..ent:EntIndex(), function() 
                            ent:SetNWBool("gentoi_basepill_faction", false)
                            ent:SetNW2Bool("gentoi_basepill_faction", false)

                            if !IsValid(entityply) then return end
                            entityply:SetNWBool("gentoi_basepill_faction", false)
                            entityply:SetNW2Bool("gentoi_basepill_faction", false)
                        end)
                    end)

                    if SERVER then
                        PuppetEntity:Remove()
                        
                        local puppet = ents.Create("pill_gentoi_pillbase_puppet")
                        puppet:SetModel(ent.formTable.model or "models/Humans/corpse1.mdl")
                        
                        if isfunction(puppet.SetPillForm) then
                            puppet:SetPillForm(ent:GetPillForm())
                        end

                        if isfunction(puppet.SetPillCostume) then
                            puppet:SetPillCostume(ent)
                        end

                        if isfunction(puppet.SetPillUser) then
                            puppet:SetPillUser(entityply)
                        end

                        puppet:Spawn()

                        ent:DeleteOnRemove(puppet)
                        ent:SetPuppet(puppet)

                        PuppetEntity = puppet
                    end

                    local name = "MutePlayerFootsteps"..entityply:EntIndex()
                    local hitgroundname = "gmx_antifalldamage_OM".. tostring(ent:EntIndex())
                    
                    hook.Add("OnPlayerHitGround", hitgroundname, function(entityfall, inWater, onFloater, speed) if entityfall == entityply then return true end end)
                    hook.Add("PlayerFootstep", name, function(ply, pos, foot, sound, volume, filter) if ply == entityply then return true end end)
                    ent:CallOnRemove("RemoveHook_Fooststeps_gentoi"..ent:EntIndex(), function() 
                        hook.Remove("PlayerFootstep", name)
                        hook.Remove("OnPlayerHitGround", hitgroundname)
                        if !IsValid(entityply) then return end
                        entityply:SetNW2String("gentoi_chasemusic_audio", "")
                    end)

                    if ent.formTable.gentoi_basepill_event then
                        function PuppetEntity:HandleAnimEvent(event, eventTime, cycle, eventType, options)
                            ent.formTable.gentoi_basepill_event(entityply, ent, options)
                            return true
                        end
                    end

                    if ent.formTable.gentoi_basepill_onremove then
                        ent:CallOnRemove("RemoveHook_OM"..ent:EntIndex(), function() ent.formTable.gentoi_basepill_onremove(entityply,ent,PuppetEntity) end)
                    end

                    timer.Simple(0.1, function() if !IsValid(ent) then return end

                        if ent.formTable.gentoi_basepill_init then
                            ent.formTable.gentoi_basepill_init(entityply,ent,PuppetEntity)
                        end
                        ent:SetNWBool("gent_gentoibase_hudpaint_loaded", true)

                        ent.PillAnim = function(e,name, freeze)
                            local anims = table.Copy(ent.formTable.anims.default or {})
                            table.Merge(anims, (IsValid(entityply:GetActiveWeapon()) and ent.formTable.anims[entityply:GetActiveWeapon():GetHoldType()]) or (ent.forceAnimSet and ent.formTable.anims[ent.forceAnimSet]) or {})
                            if not anims[name] then return end

                            ent.anim = name
                            ent.animStart = true
                            ent.animFreeze = true
                        end

                        local self = ent

                        ent.DoKeyPress = function(_, ply, key)
                            if key == IN_ATTACK and self.formTable.attack and self.formTable.attack.mode == "trigger" then
                                self.formTable.attack.func(ply, self, self.formTable.attack)
                            end
                            if key == IN_ATTACK2 and self.formTable.attack2 and self.formTable.attack2.mode == "trigger" then
                                self.formTable.attack2.func(ply, self, self.formTable.attack2)
                            end
                            if key == IN_RELOAD and self.formTable.reload then
                                self.formTable.reload(ply, self)
                            end
                            if key == IN_DUCK then
                            end
                        end

                        local ply = self:GetPillUser()
                        if SERVER then
                            self.Think = function()
                                thinkcode({ self = self, ent = self, })
                                self:NextThink(CurTime())
                                return IsValid(self)
                            end
                            timer.Simple(0.02,function() if !IsValid(ent) then return end
                                net.Start("clientside_thinkcodeinitialize_gentoi_base")
                                    net.WriteEntity(ent)
                                net.Broadcast()
                            
                                net.Start("OM_gentoi_base_CameraCode_n")
                                net.WriteEntity(ent)
                                net.Send(ply)
                            
                            end)
                        end
                    end)
                end
            end
        end
    end)
end)

if SERVER then
    util.AddNetworkString('OM_gentoi_base_jumpscarecam')
    util.AddNetworkString("OM_gentoi_base_CameraCode_n")
else

    net.Receive('OM_gentoi_base_jumpscarecam', function()
        local ent = net.ReadEntity()
        local state = net.ReadBool()
        local startTime = CurTime()

        local hookID = "OM_gentoi_base_jumpscarecam" .. LocalPlayer():SteamID()

        if not state then
            hook.Remove('CalcView', hookID)
        else
            hook.Add('CalcView', hookID, function(ply, pos, angles, fov)
                if not IsValid(ply) or not ply:Alive() or !IsValid(ent) then
                    hook.Remove('CalcView', hookID)
                    if IsValid(ply) then
                        ply:Freeze(false)
                        ply:DrawViewModel(true)
                    end
                    return
                end

                local cam = ent:GetAttachment(ent:LookupAttachment('camera'))

                ply:Freeze(true)
                ply:DrawViewModel(false)

                local lerpFactor = math.Clamp((CurTime() - startTime) / (0.7/3), 0, 1)
                
                local targetFOV = 80 

                local orgiginlerpto = LerpVector(lerpFactor, pos, cam.Pos+Vector(0,0,5))
                local angleslerpto = LerpAngle(lerpFactor, angles, cam.Ang)
                local interpolatedFOV = Lerp(lerpFactor, fov, targetFOV)

                local view = {
                    origin = orgiginlerpto,
                    angles = angleslerpto,
                    fov = interpolatedFOV,
                    drawviewer = false
                }
                return view
            end)
        end
    end)

    net.Receive("OM_gentoi_base_CameraCode_n", function()
        local ply = LocalPlayer()
        local ent = net.ReadEntity()
    
        timer.Simple(0,function()
            if !IsValid(ent) then return end
    
            local savedCalcViewHooks = {}
    
            local calcViewHooks = hook.GetTable().CalcView or {}
            for k, v in pairs(calcViewHooks) do
                if k ~= hookID then
                    savedCalcViewHooks[k] = v
                    hook.Remove("CalcView", k)
                end
            end
    
            local name6 = "momo_calcview_".. ply:Nick()
            local name5 = "gentoi_remove_n_".. ply:Nick()
            hook.Add("EntityRemoved", name5, function(removedent)
                if removedent == ent then
                    hook.Remove('CalcView', name6)
                    hook.Remove("EntityRemoved", name5)
                    for savedID, func in pairs(savedCalcViewHooks) do
                        hook.Add("CalcView", savedID, func)
                    end
                    savedCalcViewHooks = {}
                end
            end)
            
            local lastID = nil
            local lastOrigin = nil
            local lastFOV = nil
            local transitionStart = 0
            local transitionTime = 0.25
            
            local mins = Vector(-5,-5,-5)
            local maxs = Vector(5,5,5)

            local swap = false
    
            hook.Add("CalcView", name6, function(ply, pos, ang, fov)

                local ent = pk_pills.getMappedEnt(ply)
                if isfunction(ply.DrG_IsPossessing) then
                    if ply:DrG_IsPossessing() then
                        drgbase = true
                        if ply:DrG_Possessing().formTable then
                            ent = ply:DrG_Possessing()
                        end
                    end
                end

                if !IsValid(ent) then
                    hook.Remove('CalcView', name6)
                    hook.Remove("EntityRemoved", name5)
                    for savedID, func in pairs(savedCalcViewHooks) do
                        hook.Add("CalcView", savedID, func)
                    end
                    savedCalcViewHooks = {}
                    return
                end

                if not IsValid(ent) or ply:GetViewEntity() ~= ply then return end

                local currentOMTable = ent.formTable.gentoi_basepill_camtable(ply, ent)
                if not currentOMTable then return end

                if currentOMTable.customcamfunction then return currentOMTable.customcamfunction(ply, pos, ang, fov) end
    
                if lastID ~= currentOMTable.id then
                    lastID = currentOMTable.id
                    transitionStart = CurTime()
                    lastOrigin = lastOrigin or pos
                    lastFOV = lastFOV or fov
                end
    
                if transitionTime ~= currentOMTable.transition then
                    transitionTime = currentOMTable.transition
                end

                local up = ang:Up() * currentOMTable.startoffset.z
                local right = ang:Right() * currentOMTable.startoffset.x
                local forward = ang:Forward() * currentOMTable.startoffset.y

                local currentchar = ply

                if currentOMTable.cameraentity then
                    currentchar = currentOMTable.cameraentity
                end

                local startpos = currentchar:GetPos() + up + right + forward
                
                if currentOMTable.bonecenter then
                    local boneID = currentchar:LookupBone(currentOMTable.bonecenter)
                    local bonePos, boneAng = currentchar:GetBonePosition(boneID)
                    startpos = bonePos
                end

                if currentOMTable.customoffset then startpos = currentOMTable.customoffset(ply, ent) end
                
                startpos = startpos + up + right + forward
    
                if pk_pills.convars.cl_thirdperson:GetBool() then
                    local dist = currentOMTable.dist
                    local offset = ang:Forward() * -dist
    
                    local tr = util.TraceHull({
                        start = startpos,
                        endpos = startpos + offset,
                        filter = ent.camTraceFilter,
                        mins = mins,
                        maxs = maxs,
                        mask = MASK_VISIBLE
                    })
    
                    local targetOrigin = tr.HitPos
                    local targetFOV = currentOMTable.fov
    
                    local t = math.Clamp((CurTime() - transitionStart) / transitionTime, 0, 1)
    
                    local smoothOrigin = LerpVector(t, lastOrigin, targetOrigin)
                    local smoothFOV = Lerp(t, lastFOV, targetFOV)
    
                    lastOrigin = smoothOrigin
                    lastFOV = smoothFOV
    
                    return {
                        origin = smoothOrigin,
                        angles = ang,
                        fov = smoothFOV,
                        drawviewer = true
                    }
                else
                    return {
                        origin = pos + Vector(0,0,60),
                        angles = ang,
                        fov = smoothFOV,
                        drawviewer = true
                    }
                end
            end)
        end)
    end)

    local old = "Normal"

    surface.CreateFont("OM_SlashKey", {
        font = "Roboto",
        size = 32,
        weight = 700,
        antialias = true
    })

    surface.CreateFont("CreditsText_Large_Gent", {
        font = "Arial",
        size = 70,
        weight = 700,
        antialias = true,
    })

    hook.Add("HUDPaint", "gent_gentoibase_hudpaint", function()
        local ply = LocalPlayer()
        if !IsValid(ply) then return end

        local drgbase = false
        local pillentity = ply.pk_pill_ent
        if isfunction(ply.DrG_IsPossessing) then
            if ply:DrG_IsPossessing() then
                drgbase = true
                pillentity = ply:DrG_Possessing()
            end
        end

        if not IsValid(pillentity) then return end
        if not pillentity.GetPuppet then return end
        if not IsValid(pillentity:GetPuppet()) then return end
        if pillentity.formTable then else return end
        if not pillentity.formTable.gentoi_basepill then return end

        if not pillentity:GetNWBool("gent_gentoibase_hudpaint_loaded") then return end
        if not pillentity.gentoi_hud_pillloadin then 
            pillentity.gentoi_hud_pillloadin = true
            return
        end

        local curtime = CurTime()

        local screenW, screenH = ScrW(), ScrH()
        local iconize = ScreenScale(60)
        local biggericoon = ScreenScale(100)

        local rx, ry = screenW/2 + screenW/6, screenH - ScreenScale(40)

        local yaxis = screenH - biggericoon/2

        local shouldset = false
        local CanOpenInstructions = pillentity.formTable.gentoi_basepill_uifunction_shouldopen and pillentity.formTable.gentoi_basepill_uifunction_shouldopen(ply, pillentity)

        if not CanOpenInstructions then 
            shouldset = true
        end

        pillentity.HoldingDownMenu_gentoi_lerp = pillentity.HoldingDownMenu_gentoi_lerp or (CanOpenInstructions and 0 or 1)
        pillentity.HoldingDownMenu_gentoi_lerp_bg = pillentity.HoldingDownMenu_gentoi_lerp_bg or 0
        pillentity.HoldingDownMenu_gentoi_lerp_char = pillentity.HoldingDownMenu_gentoi_lerp_char or 0
        pillentity.HoldingDownMenu_gentoi_lerp_text = pillentity.HoldingDownMenu_gentoi_lerp_text or 0
        pillentity.HoldingDownMenu_gentoi_lerp_bio = pillentity.HoldingDownMenu_gentoi_lerp_bio or 0
        pillentity.HoldingDownMenu_gentoi_lerp_ability = pillentity.HoldingDownMenu_gentoi_lerp_ability or 0

        pillentity.LoadIn_gentoi_lerp = pillentity.LoadIn_gentoi_lerp or 0
        if pillentity.HoldingDownMenu_gentoi_lerp <= 0.05 then
            pillentity.LoadIn_gentoi_lerp = Lerp(FrameTime()*10, pillentity.LoadIn_gentoi_lerp, 1)
        end

        ry = Lerp(pillentity.HoldingDownMenu_gentoi_lerp, ry, screenH + biggericoon/1.5)
        yaxis = Lerp(pillentity.HoldingDownMenu_gentoi_lerp, yaxis, screenH + biggericoon/1.5)

        if pillentity.formTable.gentoi_basepill_uifunction_instructions and CanOpenInstructions then
            if pillentity:GetNWBool("HoldingDownMenu_gentoi") then
                shouldset = true
                if curtime-pillentity:GetNW2Float('HoldingDownMenu_gentoi_timeframe') > 0.45 then
                    pillentity.HoldingDownMenu_gentoi_lerp_bg = Lerp( FrameTime() * 13, pillentity.HoldingDownMenu_gentoi_lerp_bg, 1)
                    pillentity.HoldingDownMenu_gentoi_lerp_ability = Lerp( FrameTime() * 13, pillentity.HoldingDownMenu_gentoi_lerp_ability, 1)

                    pillentity.HoldingDownMenu_gentoi_lerp_char = Lerp( FrameTime() * 7, pillentity.HoldingDownMenu_gentoi_lerp_char, 1)
                    pillentity.HoldingDownMenu_gentoi_lerp_text = Lerp( FrameTime() * 7, pillentity.HoldingDownMenu_gentoi_lerp_text, 1)
                    pillentity.HoldingDownMenu_gentoi_lerp_bio = Lerp( FrameTime() * 7, pillentity.HoldingDownMenu_gentoi_lerp_bio, 1)

                    if not pillentity.PlayRatSound_1 then
                        pillentity.PlayRatSound_1 = true
                        sound.PlayFile("sound/gentoi/witheredbon/HELPHUDOPEN.wav", "noplay", function(station, err)
                            if IsValid(station) then
                                station:SetVolume(0.3)
                                station:Play()
                            end
                        end)
                    end
                end
            else
                pillentity.HoldingDownMenu_gentoi_lerp_bg = Lerp( FrameTime() * 5, pillentity.HoldingDownMenu_gentoi_lerp_bg, 0)
                pillentity.HoldingDownMenu_gentoi_lerp_char = Lerp( FrameTime() * 5, pillentity.HoldingDownMenu_gentoi_lerp_char, 0)
                pillentity.HoldingDownMenu_gentoi_lerp_text = Lerp( FrameTime() * 5, pillentity.HoldingDownMenu_gentoi_lerp_text, 0)
                pillentity.HoldingDownMenu_gentoi_lerp_bio = Lerp( FrameTime() * 5, pillentity.HoldingDownMenu_gentoi_lerp_bio, 0)
                pillentity.HoldingDownMenu_gentoi_lerp_ability = Lerp( FrameTime() * 5, pillentity.HoldingDownMenu_gentoi_lerp_ability, 0)
                if pillentity.PlayRatSound_1 then
                    pillentity.PlayRatSound_1 = false
                    sound.PlayFile("sound/gentoi/witheredbon/HELPHUDEXIT.wav", "noplay", function(station, err)
                        if IsValid(station) then
                            station:SetVolume(0.3)
                            station:Play()
                        end
                    end)
                end
                if curtime-pillentity:GetNW2Float('HoldingDownMenu_gentoi_timeframe') > 0.45 then
                    --pillentity.HoldingDownMenu_gentoi_lerp = Lerp( FrameTime() * 5, pillentity.HoldingDownMenu_gentoi_lerp, 0)
                else
                    shouldset = true
                end
            end


            local w = ScreenScale(20)
            local h = ScreenScale(40)
            local inset = ScreenScale(10)

            local offset = Lerp(pillentity.HoldingDownMenu_gentoi_lerp, 0, ScreenScale(25))

            local x = 0
            local y = ScreenScale(25)

            draw.NoTexture()

            surface.SetDrawColor(25, 25, 25, 220)
            surface.DrawPoly({
                {x = x- offset,     y = y},
                {x = x + w- offset, y = y + inset},
                {x = x + w- offset, y = y + h - inset},
                {x = x- offset,     y = y + h},
            })

            surface.SetDrawColor(255, 0, 0)

            surface.DrawLine(x - offset,     y,             x + w - offset, y + inset)
            surface.DrawLine(x + w - offset, y + inset,     x + w - offset, y + h - inset)
            surface.DrawLine(x + w - offset, y + h - inset, x - offset,     y + h)

            draw.SimpleText(
                "/",
                "OM_SlashKey",
                x + w * 0.55- offset,
                y + h * 0.5,
                color_white,
                TEXT_ALIGN_CENTER,
                TEXT_ALIGN_CENTER
            )

            local preservedmats = pillentity.formTable.gentoi_basepill_uifunction_instructions(ply,pillentity)
            local currentaadd = Lerp(pillentity.HoldingDownMenu_gentoi_lerp, 0, screenW*0.1)

            surface.SetDrawColor(255,255,255,math.Round(255 * pillentity.HoldingDownMenu_gentoi_lerp_bg))
            surface.SetMaterial(preservedmats["BG"])
            surface.DrawTexturedRect(-screenW*0.1+currentaadd,0,screenW,screenH)


            local currentaadd = Lerp(pillentity.HoldingDownMenu_gentoi_lerp_char, 0, screenW*0.1)

            surface.SetDrawColor(255,255,255,math.Round(255 * pillentity.HoldingDownMenu_gentoi_lerp_char))
            surface.SetMaterial(preservedmats["ICONUI"])
            surface.DrawTexturedRect(-screenW*0.1+currentaadd,0,screenW,screenH)


            local currentaadd = Lerp(pillentity.HoldingDownMenu_gentoi_lerp_text, 0, screenH*0.1)

            surface.SetDrawColor(255,255,255,math.Round(255 * pillentity.HoldingDownMenu_gentoi_lerp_text))
            surface.SetMaterial(preservedmats["TEXTUI"])
            surface.DrawTexturedRect(0,screenH*0.1-currentaadd,screenW,screenH)


            local currentaadd = Lerp(pillentity.HoldingDownMenu_gentoi_lerp_bio, 0, screenW*0.1)

            surface.SetDrawColor(255,255,255,math.Round(255 * pillentity.HoldingDownMenu_gentoi_lerp_bio))
            surface.SetMaterial(preservedmats["ABILITYTEXTUI"])
            surface.DrawTexturedRect(screenW*0.1-currentaadd,0,screenW,screenH)


            local currentaadd = Lerp(pillentity.HoldingDownMenu_gentoi_lerp_ability, 0, screenW*0.025)

            surface.SetDrawColor(255,255,255,math.Round(255 * pillentity.HoldingDownMenu_gentoi_lerp_ability))
            surface.SetMaterial(preservedmats["ABILITYICONUI"])
            surface.DrawTexturedRect(-screenW*0.025+currentaadd,0,screenW,screenH)
        end

        if pillentity.formTable.gentoi_basepill_uifunction_charactericon then
            local preservedmats = pillentity.formTable.gentoi_basepill_uifunction_charactericon(ply,pillentity)
            surface.SetDrawColor(255,255,255,255)
            surface.SetMaterial(preservedmats)
            surface.DrawTexturedRectRotated((0 + biggericoon/2)*pillentity.LoadIn_gentoi_lerp, yaxis,biggericoon*pillentity.LoadIn_gentoi_lerp,biggericoon,0)
        end

        if shouldset then
            pillentity.HoldingDownMenu_gentoi_lerp = Lerp( FrameTime() * 5, pillentity.HoldingDownMenu_gentoi_lerp, 1)
        else
            pillentity.HoldingDownMenu_gentoi_lerp = Lerp( FrameTime() * 5, pillentity.HoldingDownMenu_gentoi_lerp, 0)
        end

        if pillentity.formTable.gentoi_basepill_ui_abilityicons then
            local screenW, screenH = ScrW(), ScrH()
            local iconize = ScreenScale(50)
            local biggericoon = ScreenScale(100)

            local reali = 0
            for i, v in ipairs(pillentity.formTable.gentoi_basepill_ui_abilityicons) do

                local shouldAppear = true
                if v.shouldappear and not v:shouldappear(false, ply, pillentity) then -- make it so that if this becomes true or false randomly, the other icons move to their place. Also make it fade instead of snappy
                    continue
                end

                reali = reali + 1

                local icons = v:icons(ply, pillentity) or ""
                local cooldown = v:cooldown(ply, pillentity) or 1
                local maxcd = v:maximumcooldown(ply, pillentity) or 1
                local keybind = v:keybind(ply, pillentity) or "E"
                local CustomFont = v.CustomFont and v:CustomFont(ply, pillentity) or "CreditsText_Large_Gent"

                local rx, ry = screenW/2 + screenW/6, yaxis + biggericoon*0.175
                -- pillentity:GetNWFloat("Gentoi_Dog_LaserEyes_duration") > CurTime()
                -- pillentity:GetNWFloat("Gentoi_Dog_BloodhoundRush_duration") > CurTime()

                ry = Lerp(pillentity.HoldingDownMenu_gentoi_lerp, ry, screenH + biggericoon/1.5)

                local frac = 0

                if cooldown then
                    frac = math.Clamp( (cooldown-CurTime()) / maxcd, 0, 1 )
                end

                surface.SetDrawColor(255,255,255,255)
                surface.SetMaterial(icons)
                surface.DrawTexturedRectRotated( (0 + biggericoon/2 + iconize * (1.5+(reali-1)*1.08))*pillentity.LoadIn_gentoi_lerp , ry, iconize*pillentity.LoadIn_gentoi_lerp, iconize, 0)

                if cooldown then
                    local h  = Lerp(frac, 0, iconize)
                    local y2 = Lerp(frac, ry + iconize/2, ry - iconize/2)
                    local uv = Lerp(frac, 1, 0)

                    surface.SetDrawColor(25,25,25,255)
                    surface.DrawTexturedRectUV((0 + biggericoon/2 + iconize * (1+(reali-1)*1.08))*pillentity.LoadIn_gentoi_lerp,y2,iconize*pillentity.LoadIn_gentoi_lerp,h,0,uv,1,1)
                end

                draw.SimpleTextOutlined(keybind,CustomFont,(0 + biggericoon/2 + iconize * (1+(reali-1)*1.08))*pillentity.LoadIn_gentoi_lerp,ry -iconize /2+ ScreenScale(2),Color(255,255,255,255*pillentity.LoadIn_gentoi_lerp),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER,6,Color(0,0,0,255*pillentity.LoadIn_gentoi_lerp))
                

                if v.CustomDraw then 

                    v.CustomDraw(ply, pillentity, (0 + biggericoon/2 + iconize * (1.5+(reali-1)*1.08))*pillentity.LoadIn_gentoi_lerp, ry) end

            end
        end

        if pillentity.formTable.gentoi_basepill_uifunction_drawfunction then
            pillentity.formTable.gentoi_basepill_uifunction_drawfunction(ply,pillentity)
        end



        local health = math.Clamp(ply:Health(), 0, ply:GetMaxHealth())
        local healthfrac = math.Clamp(health / ply:GetMaxHealth(), 0, 1)

        pillentity.gentoi_health_lerp = pillentity.gentoi_health_lerp or health
        pillentity.gentoi_health_lerp = Lerp(FrameTime() * 12, pillentity.gentoi_health_lerp, health)

        local healthfrac = math.Clamp(pillentity.gentoi_health_lerp / ply:GetMaxHealth(), 0, 1)

        pillentity.gentoi_health_damagelerp = pillentity.gentoi_health_damagelerp or healthfrac
        pillentity.gentoi_health_damagelerp = Lerp(FrameTime() * 4, pillentity.gentoi_health_damagelerp, healthfrac)

        local healthW = ScreenScale(90)
        local healthH = ScreenScale(9)
        local healthX = screenW - healthW - ScreenScale(15)
        local healthY = screenH - ScreenScale(22)

        healthY = Lerp(pillentity.HoldingDownMenu_gentoi_lerp, healthY, screenH + biggericoon/3)

        local healthPercent = math.Round(healthfrac * 100)

        draw.RoundedBox(6, healthX - 3, healthY - 3, healthW + 6, healthH + 6, Color(0, 0, 0, 220))
        draw.RoundedBox(5, healthX, healthY, healthW, healthH, Color(15, 15, 20, 250))

        local innerX = healthX + 2
        local innerY = healthY + 2
        local innerW = healthW - 4
        local innerH = healthH - 4

        draw.RoundedBox(4, innerX, innerY, innerW, innerH, Color(35, 25, 30, 255))

        if pillentity.gentoi_health_damagelerp > healthfrac then
            draw.RoundedBox(
                4,
                innerX,
                innerY,
                innerW * pillentity.gentoi_health_damagelerp,
                innerH,
                Color(255, 175, 55, 255)
            )
        end

        if healthfrac > 0 then
            local healthFillW = innerW * healthfrac

            draw.RoundedBox(
                4,
                innerX,
                innerY,
                healthFillW,
                innerH,
                Color(190, 25, 40, 255)
            )
        end

        surface.SetDrawColor(255, 255, 255, 45)
        surface.DrawOutlinedRect(healthX - 1, healthY - 1, healthW + 2, healthH + 2, 1)

        draw.SimpleText(
            health .. " / " .. ply:GetMaxHealth() .. "  |  " .. healthPercent .. "%",
            "DermaDefaultBold",
            healthX + healthW / 2,
            healthY + healthH / 2,
            Color(255, 255, 255, 255),
            TEXT_ALIGN_CENTER,
            TEXT_ALIGN_CENTER
        )

    end)



    local CinemaBar = {}
    CinemaBar.Alpha = 0
    CinemaBar.TargetAlpha = 0
    CinemaBar.Height = 0
    CinemaBar.TargetHeight = 0

    hook.Add("HUDPaint", "CinemaBar_HUD_gentoi", function()
        local scrW, scrH = ScrW(), ScrH()

        CinemaBar.Alpha = Lerp(FrameTime() * 5, CinemaBar.Alpha, CinemaBar.TargetAlpha)
        CinemaBar.Height = Lerp(FrameTime() * 5, CinemaBar.Height, CinemaBar.TargetHeight)

        if CinemaBar.Alpha <= 0.01 and CinemaBar.TargetAlpha == 0 then
            return
        end

        surface.SetDrawColor(0, 0, 0, CinemaBar.Alpha)
        surface.DrawRect(0, 0, scrW, CinemaBar.Height)
        surface.DrawRect(0, scrH-CinemaBar.Height, scrW, CinemaBar.Height*2)
    end)

    function CinemaBarEnable_gentoi(height)
        CinemaBar.TargetAlpha = 255
        CinemaBar.TargetHeight = height or 100
    end

    function CinemaBarDisable_gentoi()
        CinemaBar.TargetAlpha = 0
        CinemaBar.TargetHeight = 0
    end
end


local function callcamerafunction(puppet, bool, target)
    net.Start('OM_gentoi_base_jumpscarecam')
    net.WriteEntity(puppet)
    net.WriteBool(bool)
    net.Send(target)
end

--[[EXAMPLE
gentoi_jumpscarehandling_cam({
    ["ply"] = ply
    ["ent"] = ent
    ["target"] = target
    ["OnStartFunction"] = OnStartFunction
    ["OnRemoveFunction"] = OnRemoveFunction
    ["OnEndFunction"] = OnEndFunction
    ["Toggle"] = Toggle
})
]]

function gentoi_targetcamerahandling_cam(tableregister)
    local ply = tableregister.ply
    local ent = tableregister.ent
    local target = tableregister.target
    local OnStartFunction = tableregister.OnStartFunction
    local OnRemoveFunction = tableregister.OnRemoveFunction
    local OnEndFunction = tableregister.OnEndFunction
    local Toggle = tableregister.Toggle

    local puppet = ent:GetPuppet()
    local nameremove = "GentoiOnRemove_function"..ent:EntIndex()
    if SERVER then
        if Toggle then
            if target:IsPlayer() then
                callcamerafunction(puppet, true, target)
            else
                target:NextThink(1e9+CurTime())
            end
            
            target:AddFlags(FL_NOTARGET)

            ent:CallOnRemove(nameremove, function()
                if !IsValid(target) then return end

                target:RemoveFlags(FL_NOTARGET)

                if target:IsPlayer() then
                    callcamerafunction(puppet, false, target)
                else
                    target:NextThink(CurTime())
                end

                if OnRemoveFunction then OnRemoveFunction() end
            end)

            ent.JuumpscareStart = CurTime()

            if OnStartFunction then OnStartFunction() end
        else
            target:RemoveFlags(FL_NOTARGET)
            ent:RemoveCallOnRemove(nameremove)
            if target:IsPlayer() then callcamerafunction(puppet, false, target)
            else target:NextThink(CurTime()) end
            if OnEndFunction then OnEndFunction() end
        end
    end
end

if CLIENT then

    local ChaseSound = nil
    local CurrentSoundPath = nil

    local TriggerDist, ChaseDist, StopDist, FadeSpeed = 700, 700, 700, 3
    local currentVolume, targetVolume = 0, 0

    local ChaseMusicRadiusMultiplier = 1.5

    hook.Add("Think", "gentoi_chasemusic_handle", function()
        local ply = LocalPlayer()
        if !IsValid(ply) then return end

        local maxVol = math.Clamp(GetConVar("gentoipills_chasemusicvolume"):GetInt() / 100, 0, 1)
        local musicrn = GetConVar("gentoipills_chasemusic"):GetBool() == false
        if musicrn then maxVol = 0 end

        if ChaseSound and !ChaseSound:IsPlaying() then
            ChaseSound:Play()
        end

        if !ply:Alive() then
            targetVolume = 0
            currentVolume = Lerp(FrameTime() * FadeSpeed, currentVolume, targetVolume)

            if ChaseSound then
                ChaseSound:ChangeVolume(currentVolume * maxVol, 0)

                if currentVolume <= 0.01 then
                    ChaseSound:FadeOut(0.5)
                    ChaseSound = nil
                    CurrentSoundPath = nil
                end
            end

            return
        end

        if ((ply:GetNW2Bool("gentoi_basepill_faction") and ply:GetNW2String("gentoi_chasemusic_audio") ~= "") or ((IsValid(ply:GetNW2Entity("DrGBasePossessing")) and ply:GetNW2Entity("DrGBasePossessing"):GetNW2Bool("gentoi_basepill_faction")) and ply:GetNW2Entity("DrGBasePossessing"):GetNW2String("gentoi_chasemusic_audio") ~= "" )) then

            local nearestDist = math.huge
            local currentenemy = nil

            local plyPos = ply:GetPos()
            local chaseRadius = ChaseDist * ChaseMusicRadiusMultiplier

            for _, ent in ipairs(ents.FindInSphere(plyPos, chaseRadius)) do
                if ent == ply then continue end

                if (ent:IsPlayer() or ent:IsNPC() or ent:IsNextBot()) and ent:Health() > 0.1 then
                    if ent:GetNW2Bool("gentoi_basepill_faction") then if ent:GetNW2Bool("gentoi_faction_pvp") then else continue end end
                    local dist = plyPos:DistToSqr(ent:GetPos())

                    if dist < nearestDist then
                        nearestDist = dist
                        currentenemy = ent
                    end
                end
            end

            local dist = math.sqrt(nearestDist)

            if IsValid(currentenemy) then
                local tr = util.TraceLine({
                    start = ply:EyePos(),
                    endpos = currentenemy:WorldSpaceCenter(),
                    mask = MASK_ALL,
                    filter = function(ent)
                        if ent == ply or ent == currentenemy then return false end
                        if ent:IsPlayer() then return false end
                        if ent:IsNPC() then return false end
                        if ent:IsNextBot() then return false end
                        return true
                    end
                })

                local effectiveRadius = ChaseDist * ChaseMusicRadiusMultiplier

                if tr.Hit then
                    effectiveRadius = effectiveRadius * 0.6
                end

                targetVolume = dist <= effectiveRadius and 1 or 0
            else
                targetVolume = 0
            end

            currentVolume = Lerp(FrameTime() * FadeSpeed, currentVolume, targetVolume)

            if currentVolume > 0.01 and IsValid(currentenemy) then

                local tr = util.TraceLine({
                    start = ply:EyePos(),
                    endpos = currentenemy:WorldSpaceCenter(),
                    mask = MASK_ALL,
                    filter = function(ent)
                        if ent == ply or ent == currentenemy then return false end
                        if ent:IsPlayer() then return false end
                        if ent:IsNPC() then return false end
                        if ent:IsNextBot() then return false end
                        return true
                    end
                })

                local effectiveRadius = ChaseDist * ChaseMusicRadiusMultiplier

                if tr.Hit then
                    effectiveRadius = effectiveRadius * 0.9
                end

                if dist <= effectiveRadius then
                    local soundPath = ply:GetNW2String("gentoi_chasemusic_audio")

                    if (ply.Gentoi_Chasemusic_shouldplay_killer and ply.Gentoi_Chasemusic_shouldplay_killer(ply, currentenemy)) then
                        soundPath = nil
                        CurrentSoundPath = ""
                    end
                    if (soundPath ~= "" and soundPath ~= CurrentSoundPath) then
                        if ChaseSound then
                            ChaseSound:FadeOut(0.4)
                            ChaseSound = nil
                        end

                        if soundPath then
                            ChaseSound = CreateSound(ply, soundPath)
                        end

                        if ChaseSound then
                            ChaseSound:Play()
                            CurrentSoundPath = soundPath
                        end
                    end
                end

                if ChaseSound then
                    ChaseSound:ChangeVolume(currentVolume * maxVol, 0)

                    if !ChaseSound:IsPlaying() then
                        ChaseSound:Play()
                    end
                end

            else
                if ChaseSound then
                    ChaseSound:FadeOut(0.6)
                    ChaseSound = nil
                    CurrentSoundPath = nil
                end
            end

            return
        end

        local nearestDist = math.huge
        local currentenemy = nil

        local plyPos = ply:GetPos()

        for _, ent in ipairs(ents.FindInSphere(plyPos, StopDist * ChaseMusicRadiusMultiplier)) do
            if ent:GetNW2Bool("gentoi_basepill_faction") then
                if (ent:IsPlayer() or ent:IsNPC() or ent:IsNextBot()) and ent:Health() > 0.1 then

                    local soundPath = ent:GetNW2String("gentoi_chasemusic_audio")
                    if soundPath == "" then continue end
            
                    if (ent.Gentoi_Chasemusic_shouldplay and ent.Gentoi_Chasemusic_shouldplay(ply, ent)) then
                        --soundPath = nil
                        continue
                    end

                    local dist = plyPos:DistToSqr(ent:GetPos())

                    if dist < nearestDist then
                        nearestDist = dist
                        currentenemy = ent
                    end
                end
            end
        end

        local dist = math.sqrt(nearestDist)
        local currentRadius = IsValid(currentenemy) and ChaseMusicRadiusMultiplier or 1

        targetVolume = (!IsValid(currentenemy) or dist > TriggerDist * currentRadius) and 0 or 1

        currentVolume = Lerp(FrameTime() * FadeSpeed, currentVolume, targetVolume)

        if currentVolume > 0.01 and IsValid(currentenemy) then
            if !IsValid(currentenemy) then return end
            local dist = math.sqrt(nearestDist)

            local tr = util.TraceLine({
                start = ply:EyePos(),
                endpos = currentenemy:WorldSpaceCenter(),
                mask = MASK_ALL,
                filter = function(ent)
                    if ent == ply or ent == currentenemy then return false end
                    if ent:IsPlayer() then return false end
                    if ent:IsNPC() then return false end
                    if ent:IsNextBot() then return false end
                    return true
                end
            })

            local chaseRadius = ChaseDist

            if tr.Hit then
                chaseRadius = ChaseDist * 0.9
            end

            if dist <= chaseRadius then
                soundPath = currentenemy:GetNW2String("gentoi_chasemusic_audio")
            end
            
            if (currentenemy.Gentoi_Chasemusic_shouldplay and currentenemy.Gentoi_Chasemusic_shouldplay(ply, currentenemy)) then
                soundPath = nil
            end

            if soundPath ~= CurrentSoundPath then
                if ChaseSound then
                    ChaseSound:FadeOut(0.5)
                    ChaseSound = nil
                end

                CurrentSoundPath = soundPath

                if (soundPath and soundPath ~= "")  then
                    if soundPath then
                        ChaseSound = CreateSound(ply, soundPath)
                    end

                    if ChaseSound then
                        ChaseSound:Play()
                    else
                        CurrentSoundPath = nil
                    end
                end
            end

            if ChaseSound then
                ChaseSound:ChangeVolume(currentVolume * maxVol, 0)

                if !ChaseSound:IsPlaying() then
                    ChaseSound:Play()
                end
            end
        else
            if ChaseSound then
                ChaseSound:FadeOut(1)
                ChaseSound = nil
                CurrentSoundPath = nil
            end
        end

    end)

end


-- new damage code
function Gentoi_dynamic_attacking(DamageData)
    local InitialData = {}
    if DamageData.ply ~= nil then InitialData.ply = DamageData.ply else return end
    if DamageData.target ~= nil then InitialData.target = DamageData.target else return end
    if DamageData.DamageNumb ~= nil then
        InitialData.DamageNumb = DamageData.DamageNumb
    else
        InitialData.DamageNumb = 0
    end
    if DamageData.flingremoveal ~= nil then
        InitialData.flingremoveal = DamageData.flingremoveal
    else
        InitialData.flingremoveal = false
    end
    if DamageData.ShouldBlood ~= nil then
        InitialData.ShouldBlood = DamageData.ShouldBlood
    else
        InitialData.ShouldBlood = false
    end
    if DamageData.ShouldBloodEffect ~= nil then
        InitialData.ShouldBloodEffect = DamageData.ShouldBloodEffect
    else
        InitialData.ShouldBloodEffect = false
    end
    if DamageData.damagesound ~= nil then
        InitialData.damagesound = DamageData.damagesound
    else
        InitialData.damagesound = false
    end
    if DamageData.CustomDamageSound ~= nil then
        InitialData.CustomDamageSound = DamageData.CustomDamageSound
    end
    if DamageData.damagetype ~= nil then
        InitialData.damagetype = DamageData.damagetype
    else
        InitialData.damagetype = false
    end
    if SERVER then
        if InitialData.damagesound then
        end
        if InitialData.ShouldBlood then
        end

        if InitialData.ShouldBloodEffect then
        end

        local dmg = DamageInfo()
        dmg:SetDamage(InitialData.DamageNumb)
        dmg:SetAttacker(InitialData.ply)
        dmg:SetInflictor(InitialData.ply)
        dmg:SetDamageType(InitialData.damagetype)
        dmg:SetDamagePosition(InitialData.target:GetPos())

        if InitialData.flingremoveal then
            dmg:SetDamageForce(vector_origin)
        end

        InitialData.target:TakeDamageInfo(dmg)
    end
end

local gentoi_attackfunctions = {}

function gentoi_attackfunctions_initialize(functions)
    gentoi_attackfunctions[functions.Name] = {
        ["Function"] = functions.Function,
    }
    return true
end


hook.Add("EntityTakeDamage", "gentoi_damagehook_pills", function(entityfall, dmg)
    local attacker = dmg:GetAttacker()

    for i, v in pairs(gentoi_attackfunctions) do
        if v["Function"] then
            v["Function"](entityfall, dmg)
        end
    end

    if IsValid(entityfall) then
        if entityfall.Gentoi_DamageCustomFunction then
            entityfall:Gentoi_DamageCustomFunction({entityfall, dmg},{entityfall, dmg})
        end
    end
    if IsValid(attacker) then
        if attacker.Gentoi_AttacterCustomFunction then
            attacker:Gentoi_AttacterCustomFunction({entityfall, dmg},{entityfall, dmg})
        end
    end
end)

if SERVER then
    util.AddNetworkString("OM_gentoi_impact_frames")

    function ImpactFrames_gentoi_pills(target)
        if target:IsPlayer() then else return end
        net.Start('OM_gentoi_impact_frames')
        net.Send(target)
    end
else

    local isinimpact = false

    hook.Add("PostDrawTranslucentRenderables", "OM_gentoi_impact_frames_pillmodel", function()
        if isinimpact then else return end
        local ply = LocalPlayer()

        local pillentity = ply.pk_pill_ent

        if IsValid(pillentity) and pillentity.GetPuppet and IsValid(pillentity:GetPuppet()) then
            local ent = pillentity:GetPuppet()
            render.ClearStencil()

            render.SetStencilEnable(true)

            render.SetStencilWriteMask(255)
            render.SetStencilTestMask(255)

            render.SetStencilReferenceValue(1)

            render.SetStencilCompareFunction(STENCIL_ALWAYS)
            render.SetStencilPassOperation(STENCIL_REPLACE)

            cam.IgnoreZ(false)
            render.SetBlend(ent:GetColor().a / 255)
                ent:DrawModel()
            render.SetBlend(1)
            cam.IgnoreZ(false)

            render.SetStencilCompareFunction(STENCIL_EQUAL)
            render.SetStencilPassOperation(STENCIL_KEEP)
            render.SetStencilFailOperation(STENCIL_KEEP)
            render.SetStencilZFailOperation(STENCIL_KEEP)

            local alpha = ent:GetColor().a / 255
            
            DrawColorModify({
                ["$pp_colour_addr"]       = 0,
                ["$pp_colour_addg"]       = 0,
                ["$pp_colour_addb"]       = 0,
                ["$pp_colour_brightness"] = 0.47,
                ["$pp_colour_contrast"]   = 1,
                ["$pp_colour_colour"]     = 1,
                ["$pp_colour_mulr"]       = 0,
                ["$pp_colour_mulg"]       = 0,
                ["$pp_colour_mulb"]       = 0
            })

            render.SetStencilEnable(false)
        end
    end)

    local id = 0
    net.Receive('OM_gentoi_impact_frames', function()
        local ply = LocalPlayer()
        if ply:GetInfoNum("gentoipills_antiepilepsy", 0) ~= 0 then return end
        local ply = LocalPlayer()

        local frame = 1
        local frameTime = 0.05
        local nextFrame = CurTime()
        local hookID = "OM_gentoi_base_impactframes_" .. ply:SteamID() .. "_".. CurTime().. "".. id
        id = id + 1

        hook.Add("RenderScreenspaceEffects", hookID, function()
            if frame >= 4 then hook.Remove("RenderScreenspaceEffects", hookID)
                isinimpact = false
                return end
            isinimpact = true

            if CurTime() >= nextFrame then
                nextFrame = CurTime() + frameTime
                frame = frame + 1
            end

            local currentFrame = frame

            local tab = { -- frame 1
                ["$pp_colour_addr"] = 0,
                ["$pp_colour_addg"] = 0,
                ["$pp_colour_addb"] = 0,
                ["$pp_colour_brightness"] = -0.48,
                ["$pp_colour_contrast"] = 9,
                ["$pp_colour_colour"] = 0.8,
                ["$pp_colour_mulr"] = 0,
                ["$pp_colour_mulg"] = 0,
                ["$pp_colour_mulb"] = 0
            }

            if currentFrame == 2 then
                tab = {
                    ["$pp_colour_addr"] = 1,
                    ["$pp_colour_addg"] = 1,
                    ["$pp_colour_addb"] = 1,
                    ["$pp_colour_brightness"] = -1.4,
                    ["$pp_colour_contrast"] = 20,
                    ["$pp_colour_colour"] = 0,
                    ["$pp_colour_mulr"] = 0,
                    ["$pp_colour_mulg"] = 0,
                    ["$pp_colour_mulb"] = 0
                }
            end

            if currentFrame == 3 then
                tab = {
                    ["$pp_colour_addr"] = 0,
                    ["$pp_colour_addg"] = 0,
                    ["$pp_colour_addb"] = 0,
                    ["$pp_colour_brightness"] = -0.5,
                    ["$pp_colour_contrast"] = -15,
                    ["$pp_colour_colour"] = 0,
                    ["$pp_colour_mulr"] = 0,
                    ["$pp_colour_mulg"] = 0,
                    ["$pp_colour_mulb"] = 0
                }
            end

            DrawColorModify(tab)
        end)
    end)
end


gentoi_slowdownfunctions_initialize({
    ["Name"] = "Gentoi_ragdollbugfix",
    ["CreateMove"] = function(ply,cmd)
        local rag = ply:GetNWEntity("ragdollchar_om_gent")
        if IsValid(rag) then
            if rag:GetNW2Bool("ragdollchar_om_gent_canpressbuttons") then return end
            if rag:GetNWBool("ragdollchar_om_gent_canpressbuttons") then return end
            cmd:ClearButtons()
        end
    end,
})

if SERVER then

    local function createfakeragdoll(jumpscare_entity)
        if !IsValid(jumpscare_entity) then return end
        --[[
        if jumpscare_entity.Think then
            jumpscare_entity:Think()
        end
        ]]

        if SERVER then
            local ragdoll = ents.Create("prop_ragdoll")
            if jumpscare_entity.pk_pill_ent and IsValid(jumpscare_entity.pk_pill_ent) then
                ragdoll:SetModel(jumpscare_entity.pk_pill_ent:GetPuppet():GetModel())
            else
                local model = jumpscare_entity:GetModel()

                if model and util.IsValidModel(model) then
                    ragdoll:SetModel(model)
                else
                    ragdoll:SetModel("models/error.mdl")
                end
            end
            ragdoll:SetPos(jumpscare_entity:GetPos())
            ragdoll:SetAngles(jumpscare_entity:GetAngles())
            ragdoll:SetSkin(jumpscare_entity:GetSkin() or 0)
            ragdoll:Spawn()

            ragdoll:SetNWEntity("prop_ragdoll_gentoi_replacement_owner", jumpscare_entity)

            local physCount = ragdoll:GetPhysicsObjectCount()
            if physCount <= 0 then
                ragdoll:Remove()

                ragdoll = ents.Create("prop_physics")
                ragdoll:SetModel("models/hunter/blocks/cube025x025x025.mdl")--ragdoll:SetModel("models/props_c17/oildrum001.mdl")
                ragdoll:SetPos(jumpscare_entity:GetPos())
                ragdoll:SetAngles(jumpscare_entity:GetAngles())
                ragdoll:SetSkin(jumpscare_entity:GetSkin() or 0)
                ragdoll:Spawn()
                ragdoll:SetRenderMode(RENDERMODE_TRANSALPHA)
                ragdoll:SetColor(Color(255, 255, 255, 0))
                ragdoll:ManipulateBoneScale(0,Vector(0,0,0))

                local ball = ents.Create("prop_dynamic")
                if jumpscare_entity.pk_pill_ent and IsValid(jumpscare_entity.pk_pill_ent) then
                    ball:SetModel(jumpscare_entity.pk_pill_ent:GetPuppet():GetModel())
                else
                    local model = jumpscare_entity:GetModel()

                    if model and util.IsValidModel(model) then
                        ball:SetModel(model)
                    else
                        ball:SetModel("models/error.mdl")
                    end
                end
                ball:SetPos(jumpscare_entity:GetPos())
                ball:SetAngles(jumpscare_entity:GetAngles())
                ball:SetSkin(jumpscare_entity:GetSkin() or 0)
                ball:SetParent(ragdoll)
                ball:SetModelScale(jumpscare_entity:GetModelScale())
                ball:Spawn()
                ball:SetCollisionGroup(COLLISION_GROUP_WORLD)

                local seqName = jumpscare_entity:GetSequenceName(jumpscare_entity:GetSequence())
                local seqID = jumpscare_entity:LookupSequence(seqName)
                ball:SetSequence(seqID)
                ball:SetPlaybackRate(0)
                ball:SetCycle(jumpscare_entity:GetCycle())

                ragdoll:DeleteOnRemove(ball)

                ragdoll:SetNW2Entity("fakemodel_om", ball)
            end

            local hookname = "DisableSpecificRagdollDamage"..ragdoll:EntIndex()
            hook.Add("EntityTakeDamage", hookname, function(target, dmginfo)
                if !IsValid(dmginfo:GetAttacker()) then return end
                        
                if dmginfo:GetAttacker() == ragdoll or dmginfo:GetInflictor() == ragdoll then
                    dmginfo:SetDamage(0)
                end
            end)

            ragdoll:CallOnRemove(hookname, function()
                hook.Remove("hookname",hookname)
            end)

            if jumpscare_entity.GetBodyGroups then
                if jumpscare_entity.pk_pill_ent and IsValid(jumpscare_entity.pk_pill_ent) then
                    local jumpscare_entity = jumpscare_entity.pk_pill_ent:GetPuppet()
                    for _, bg in ipairs(jumpscare_entity:GetBodyGroups()) do
                        ragdoll:SetBodygroup(bg.id, jumpscare_entity:GetBodygroup(bg.id))
                    end
                end
            end

            if jumpscare_entity.GetPlayerColor and ragdoll.SetPlayerColor then
                ragdoll:SetPlayerColor(jumpscare_entity:GetPlayerColor())
            end

            if jumpscare_entity.GetColor then
                ragdoll:SetColor(jumpscare_entity:GetColor())
            end

            if jumpscare_entity.GetMaterial then
                ragdoll:SetMaterial(jumpscare_entity:GetMaterial())
            end

            if ragdoll.GetNumSubMaterials and ragdoll.SetSubMaterial and jumpscare_entity.GetSubMaterial then
                for i = 0, ragdoll:GetNumSubMaterials() - 1 do
                    local sub = jumpscare_entity:GetSubMaterial(i)
                    if sub then
                        ragdoll:SetSubMaterial(i, sub)
                    end
                end
            end

            jumpscare_entity:SetNotSolid(true)
            jumpscare_entity:SetCollisionGroup(COLLISION_GROUP_WORLD)
            ragdoll.OMRagdoll = true

            ragdoll:SetCollisionGroup(COLLISION_GROUP_WORLD)
            return ragdoll
        end
    end
                                                --[[
                                                ]]
    function CreateRagdolLCharacter_pills_gent(tableofitemz)
        local shoulddocustomfunction = tableofitemz.shoulddocustomfunction
        local shouldremove = tableofitemz.shouldremove
        local ent2 = tableofitemz.target
        local ent = tableofitemz.host
        local firstperson = tableofitemz.firstperson
        local shouldntdraw = tableofitemz.shouldntdraw
        local canpressbuttons = tableofitemz.canpressbuttons

        if not ent2 or !IsValid(ent2) then return end
        if not ent or !IsValid(ent) then return end
        if not shouldremove then shouldremove = function() return true end end
        if not shoulddocustomfunction then shoulddocustomfunction = function() return false end end

        if ent2:GetNW2Float("ragdolltype_grab") > CurTime() and ent:GetNW2Float("ragdolltype_bypass") < CurTime() then
            return
        end

        if IsValid(ent2:GetNWEntity("OM_ragdollentity_gent")) then
            ent2:GetNWEntity("OM_ragdollentity_gent"):Remove()
            --return
        end

        local createfakeragdoll = createfakeragdoll(ent2)
        if IsValid(createfakeragdoll) then
            ent2:SetNWEntity("OM_ragdollentity_gent", createfakeragdoll)
            if ent2.pk_pill_ent then
                ent2.pk_pill_ent:SetNWEntity("OM_ragdollentity_gent", createfakeragdoll)
                if ent2.pk_pill_ent:GetPuppet() then
                    ent2.pk_pill_ent:GetPuppet():SetNWEntity("OM_ragdollentity_gent", createfakeragdoll)
                end
            end
            ent2:SetNWEntity("ragdollchar_om_gent", createfakeragdoll)
        end

        if firstperson then createfakeragdoll:SetNW2Bool("createfakeragdoll_firstperson", true) end
        if shouldntdraw then createfakeragdoll:SetNW2Bool("createfakeragdoll_shouldntdraw", true) end
        if canpressbuttons then createfakeragdoll:SetNW2Bool("ragdollchar_om_gent_canpressbuttons", true) end
        if canpressbuttons then createfakeragdoll:SetNWBool("ragdollchar_om_gent_canpressbuttons", true) end

        local currrentpos = ent2:GetPos()
        local name = "ragdoll_nosey" .. ent2:EntIndex() .. " " .. ent:EntIndex()
        local dead = false
        hook.Add("Think", name, function()
            if shouldremove(createfakeragdoll) then
                if IsValid(createfakeragdoll) then
                    createfakeragdoll:Remove()
                end
                if IsValid(ent2) then
                    local mins, maxs = ent2:OBBMins(), ent2:OBBMaxs()
                    local safePos

                    local function IsSafe(pos)
                        local tr = util.TraceHull({
                            start = pos,
                            endpos = pos,
                            mins = mins,
                            maxs = maxs,
                            filter = ent2,
                            mask = MASK_SOLID
                        })

                        return not tr.Hit
                    end

                    if IsSafe(currrentpos) then
                        safePos = currrentpos
                    else
                        local radiusStep = 16
                        local maxRadius = 96

                        for radius = radiusStep, maxRadius, radiusStep do
                            for ang = 0, 360 - 45, 45 do
                                local dir = Angle(0, ang, 0):Forward()

                                for z = 0, 48, 16 do
                                    local pos = currrentpos + dir * radius + Vector(0, 0, z)

                                    if IsSafe(pos) then
                                        safePos = pos
                                        break
                                    end
                                end

                                if safePos then break end
                            end

                            if safePos then break end
                        end
                    end

                    ent2:SetPos(safePos or currrentpos)
                    ent2:SetNotSolid(false)
                    ent2:SetCollisionGroup(COLLISION_GROUP_NONE)
                end

                if ent2.pk_pill_ent and IsValid(ent2.pk_pill_ent) and ent2.pk_pill_ent.GetPuppet then
                    local puppet = ent2.pk_pill_ent:GetPuppet()
                    if IsValid(puppet) then
                        puppet:SetRenderMode(RENDERMODE_TRANSALPHA)
                        puppet:SetColor(Color(255, 255, 255, 255))
                    end
                end

                hook.Remove("Think", name)
                return
            end
            if IsValid(createfakeragdoll) then
                ent2:SetNWEntity("OM_ragdollentity_gent", createfakeragdoll)
                ent2:SetNWEntity("ragdollchar_om_gent", createfakeragdoll)
            end
            shoulddocustomfunction(createfakeragdoll)
                
            local phys = createfakeragdoll:GetPhysicsObject()
            local vel = phys:GetVelocity()

            if ent2.loco then
                if ent2.loco.SetVelocity then
                    ent2.loco:SetVelocity(vel)
                end
                if ent2.loco.SetDesiredSpeed then
                    ent2.loco:SetDesiredSpeed(vel:Length())
                end
            end

            ent2:SetVelocity(vel * FrameTime())
                        
            local desiredPos = createfakeragdoll:GetPos()
            local mins, maxs = ent2:OBBMins(), ent2:OBBMaxs()

            local tr = util.TraceHull({
                start  = ent2:GetPos(),
                endpos = desiredPos,
                mins   = mins,
                maxs   = maxs,
                filter = function(ent)
                    if ent == ent2 then return false end
                    if ent == createfakeragdoll then return false end
                    return true
                end,
                mask = MASK_SOLID
            })

            if tr.Hit then
                local safePos = tr.HitPos + tr.HitNormal * 1
                ent2:SetPos(safePos + Vector(0,0,30))
            else
                ent2:SetPos(desiredPos + Vector(0,0,30))
            end

            if IsValid(ent2) then
                ent2:SetVelocity(Vector(0,0,0))
                ent2:SetLocalVelocity(Vector(0,0,0))
            end

            if ent2.loco then
                ent2.loco:SetVelocity(vector_origin)
                ent2.loco:SetDesiredSpeed(0)
            end
            if ent2.pk_pill_ent and IsValid(ent2.pk_pill_ent) and ent2.pk_pill_ent.GetPuppet then
                local puppet = ent2.pk_pill_ent:GetPuppet()
                if IsValid(puppet) then
                    puppet:SetRenderMode(RENDERMODE_TRANSALPHA)
                    puppet:SetColor(Color(255, 255, 255, 0))
                    puppet:SetNWEntity("OM_ragdollentity_gent", createfakeragdoll)
                    puppet:SetNWEntity("ragdollchar_om_gent", createfakeragdoll)
                end
            end

            local tr = util.TraceHull({
                start = createfakeragdoll:GetPos(),
                endpos = createfakeragdoll:GetPos(),
                mins = Vector(-1, -1, -1),
                maxs = Vector(1, 1, 1),
                mask = MASK_NPCWORLDSTATIC,
                filter = createfakeragdoll
            })

            if not tr.Hit then
                currrentpos = createfakeragdoll:GetPos()
            end

            if ent2:Health() <= 0.1 then
                dead = true
                createfakeragdoll:Remove()
            end


            if ent2.GetActiveWeapon then
                local wep = ent2:GetActiveWeapon()
                if IsValid(wep) then
                    wep:SetNWFloat("om_invisiblemodel", CurTime()+0.15)
                end
            end
        end)
        return createfakeragdoll
    end

else
    hook.Add("PostDrawTranslucentRenderables", "om_invisiblemodel_ragdoll_gent", function()
        for _, ent in ipairs(ents.FindByClass("prop_ragdoll")) do
            if not IsValid(ent) then continue end
            if IsValid(ent:GetNWEntity("prop_ragdoll_gentoi_replacement_owner")) then
                local ownership = ent:GetNWEntity("prop_ragdoll_gentoi_replacement_owner")
                ownership.RenderOverride = function()
                    if !IsValid(ent) and IsValid(ownership) then
                        ownership.RenderOverride = nil
                    end
                end
            end
        end
    end)

    local factor = 0

    local lastposition, lastangles

    hook.Add("CalcView", "RagdollHeadView_OM_pillsbase", function(ply, pos, angles, fov)
        local rag = ply:GetNWEntity("ragdollchar_om_gent")

        if IsValid(rag) then
        
            if rag:GetNW2Bool("createfakeragdoll_shouldntdraw") then return end
            if rag:GetNW2Bool("createfakeragdoll_firstperson") then
                factor = math.Round(Lerp(FrameTime() * 8, factor, 0), 2)
            else
                factor = math.Round(Lerp(FrameTime() * 8, factor, 1), 2)
                local startpos = rag:GetPos()
                local offset = angles:Forward() * -170

                local tr = util.TraceHull({
                    start = startpos,
                    endpos = startpos + offset,
                    filter = {rag, ply},
                    mins = Vector(-5, -5, -5),
                    maxs = Vector(5, 5, 5),
                    mask = MASK_VISIBLE
                })

                lastposition = tr.HitPos
                lastangles = angles
            end
        else
            factor = math.Round(Lerp(FrameTime() * 8, factor, 0), 2)
            if factor <= 0.1 then 
                lastposition = pos
                lastangles = angles
            end
        end

        if factor <= 0.1 then return end

        return {
            origin = LerpVector(factor,pos,lastposition + lastangles:Forward() * 2),
            angles = LerpAngle(factor,angles,lastangles or angles),
            fov = fov,
            drawviewer = true
        }
    end)
end

if CLIENT then
    hook.Add("PreDrawOutlines_nick_base", "Gentoi_eddy_outlineforpills", function()
        local ply = LocalPlayer()
        if !IsValid(ply) then return end

        local drgbase = false
        local pillentity = ply.pk_pill_ent
        if isfunction(ply.DrG_IsPossessing) then
            if ply:DrG_IsPossessing() then
                drgbase = true
                pillentity = ply:DrG_Possessing()
            end
        end

        if not IsValid(pillentity) then return end
        if not pillentity.GetPuppet then return end
        if not IsValid(pillentity:GetPuppet()) then return end
        if pillentity.formTable then else return end
        if not pillentity.formTable.gentoi_basepill then return end

        if pillentity.formTable.nick_base_halo_add then
            pillentity.formTable.nick_base_halo_add(ply, pillentity)
        end

        --local dictionary = entityTable_pillarchase_recode()
        --nick_base_halo.Add( dictionary, Color(255,255,255,255), 1, true )
    end)
end


function gent_lookatpillfunction_type1(ply, ent)
    local returnentity = {}
    if SERVER then
        for k, v in ipairs(entityTable_pillarchase_recode()) do
            if IsValid(v) then
                local visible = pilluser:Visible(v) 
                if ply ~= v then
                    if v:GetClass() == "pill_puppet" then continue end
                    if v:Health() > 0 then else continue end
                    if visible then
                        local formula = (v:EyeAngles():Forward():Dot(pilluser:EyePos() - v:EyePos()) / (pilluser:EyePos() - v:EyePos()):Length() >= 0.5)
                        if formula then
                            table.insert(returnentity,v)
                        end
                    end
                end
            end
        end
    end
    return returnentity
end