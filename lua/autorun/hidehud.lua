local tohide = {
    ["CHudHealth"] = true,
    ["CHudBattery"] = true,
} 

local portalmaps = {
    "testchmb_a_00",
    "testchmb_a_01",
    "testchmb_a_02",
    "testchmb_a_03",
    "testchmb_a_04",
    "testchmb_a_05",
    "testchmb_a_06",
    "testchmb_a_07",
    "testchmb_a_08",
    "testchmb_a_09",
    "testchmb_a_10",
    "testchmb_a_11",
    "testchmb_a_13",
    "testchmb_a_14",
    "testchmb_a_15",
    "escape_00",
    "escape_01",
    "escape_02",
}

GM = {}

hook.Add( "HUDShouldDraw", "HideHUD", function( name )
    for _,v in pairs(portalmaps) do
        if (game.GetMap() == v) then
            if ( tohide[name] ) then
                return false
            end
        end
    end

    -- Don't return anything here, it may break other addons that rely on this hook.
end )

for _,v in pairs(portalmaps) do
    if (game.GetMap() == v) then
		for k, ply in pairs(player.GetAll()) do
			if IsValid(ply) then
				ply:SetWalkSpeed(150)
				ply:SetRunSpeed(150)
				break
			end
		end
	end
end

game.AddParticles( "particles/environment.pcf" )
game.AddParticles( "particles/finale_fx.pcf" )
//game.AddParticles( "particles/fire_01.pcf" )
game.AddParticles( "particles/glados.pcf" )
game.AddParticles( "particles/neurotoxins.pcf" )
game.AddParticles( "particles/tubes.pcf" )