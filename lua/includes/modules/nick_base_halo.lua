
module( "nick_base_halo", package.seeall )


AddCSLuaFile()

if CLIENT then 
    local outlineMatSettings = {
        ["$translucent"] = 1,
        ["$vertexalpha"] = 1,
        ["$vertexcolor"] = 1
    }
    local outlineMat = CreateMaterial("OutlineMat", "UnlitGeneric", outlineMatSettings)


    local List = {}

    function Add( entities, color, size, ignorez )

        local t = {
            Ents = entities,
            Color = color,
            size = size or 2,
            ignorez = ignorez or false
        }

        table.insert( List, t )

    end

    local copyMat = Material("pp/copy")
    local storeTexture = render.GetScreenEffectTexture(0)
    local drawTexture = render.GetScreenEffectTexture(1)

    local function DrawEntity_effect(ent, playerIndex, ply)

        local rag = ent:GetNWEntity("OM_ragdollentity")
        local ball = ent:GetNW2Entity("GlowingBallThingy_OM")

        if IsValid(rag) then
            ent = rag
        end 
        if ent.pk_pill_ent then
            if ent.pk_pill_ent.GetPuppet then
                ent = ent.pk_pill_ent:GetPuppet()
            else
                ent = ent.pk_pill_ent
            end
        end


        if !IsValid(ent) then return end
        --print(ent:GetNW2Float("IgnoreBall_OM_moduledraw")-CurTime())

        if ent:GetNW2Float("IgnoreBall_OM_moduledraw") > CurTime() then
        else
            if IsValid(ball) then
                ent = ball
            end 
        end

        if !IsValid(ent) then return end

        local scene = render.GetRenderTarget()
        local oldRT = render.GetRenderTarget()
        
        render.SetBlend(1)

        render.CopyRenderTargetToTexture(storeTexture)
        local w = ScrW()
        local h = ScrH()
        render.Clear(0, 0, 0, 0, false, true)
        
        render.SetStencilEnable(true)
        render.SuppressEngineLighting(true)

        render.SetStencilWriteMask(0xFF)
        render.SetStencilTestMask(0xFF)

        render.SetStencilCompareFunction( STENCIL_ALWAYS )
        render.SetStencilPassOperation( STENCIL_REPLACE )
        render.SetStencilFailOperation( STENCIL_KEEP )
        render.SetStencilZFailOperation(STENCIL_ZERO)

        if ply.ignorez then
            cam.Start3D()

                render.OverrideDepthEnable(true, false)

                render.SetStencilCompareFunction(STENCIL_ALWAYS)
                render.SetStencilPassOperation(STENCIL_REPLACE)
                render.SetStencilFailOperation(STENCIL_KEEP)
                render.SetStencilZFailOperation(STENCIL_REPLACE)

                render.SetStencilReferenceValue(playerIndex)

                render.SetColorModulation(0, 0, 0)
                ent:DrawModel()
                render.SetColorModulation(1, 1, 1)

                render.OverrideDepthEnable(false, false)

            cam.End3D()
        else
            cam.Start3D()
                render.SetStencilCompareFunction(STENCIL_ALWAYS)
                render.SetStencilPassOperation(STENCIL_REPLACE)
                render.SetStencilFailOperation(STENCIL_KEEP)
                render.SetStencilZFailOperation(STENCIL_KEEP)
                render.DepthRange(0, 1)
                
                render.SetStencilReferenceValue(playerIndex)

                render.SetColorModulation(0, 0, 0)
                ent:DrawModel()
                render.SetColorModulation(1, 1, 1)
                
                render.DepthRange(0, 0)
            cam.End3D()
        end
        
        cam.Start2D()
        render.SetStencilCompareFunction(STENCIL_EQUAL)
            render.SetStencilReferenceValue(playerIndex)
            local color2 = isfunction(ply.Color) and ply.Color(ent) or ply.Color
            surface.SetDrawColor(color2.r, color2.g, color2.b, color2.a)
            surface.DrawRect(0, 0, w, h)
        cam.End2D()
        
        render.SuppressEngineLighting(false)
        render.SetStencilEnable(false)
        
        render.CopyRenderTargetToTexture(drawTexture)
        render.SetRenderTarget(oldRT)
        
        copyMat:SetTexture("$basetexture", storeTexture)
        render.SetMaterial(copyMat)
        render.DrawScreenQuad()
        
        render.SetStencilEnable(true)
        render.SetStencilWriteMask(0xFF)
        render.SetStencilTestMask(0xFF)
        render.SetStencilReferenceValue(0)
        render.SetStencilCompareFunction(STENCIL_EQUAL)
        
        outlineMat:SetTexture("$basetexture", drawTexture)
        render.SetMaterial(outlineMat)

        local thickness = ply.size

        render.DrawScreenQuadEx(-thickness, -thickness, w, h)
        render.DrawScreenQuadEx(-thickness, 0, w, h)
        render.DrawScreenQuadEx(-thickness, thickness, w, h)
        render.DrawScreenQuadEx(0, -thickness, w, h)
        render.DrawScreenQuadEx(0, thickness, w, h)
        render.DrawScreenQuadEx(thickness, -thickness, w, h)
        render.DrawScreenQuadEx(thickness, 0, w, h)
        render.DrawScreenQuadEx(thickness, thickness, w, h)

        render.SetBlend(1)

        render.SetStencilEnable(false)

        render.SetStencilTestMask( 0 )
        render.SetStencilWriteMask( 0 )
        render.SetStencilReferenceValue( 0 )
    end

    hook.Add("PostDrawEffects", "RenderOutlines_nick_base", function()
        hook.Run( "PreDrawOutlines_nick_base" )
        if #List == 0 then
            render.SetStencilEnable(false)
        else
            for playerIndex, ply in ipairs(List) do
                local ent = ply.Ents
                for i,v in ipairs(ent) do
                    if !IsValid(v) then continue end
                    DrawEntity_effect(v, playerIndex, ply)
                end
            end
        end

        render.SetStencilEnable(false)

        List = {}
    end)
end