local function PortalMenuSettings( pnl )
	
	pnl:AddControl( "CheckBox", { Label = "Portals Cleanings", Command = "portal_cleanportals" } )
	pnl:AddControl( "CheckBox", { Label = "Portals Lights", Command = "portal_dynamic_light" } )

	pnl:AddControl( "ListBox", { Label = "Upgrade (Portal Gun)", Options = list.Get( "list_portalonly" ) } )
	pnl:AddControl( "ListBox", { Label = "Render View", Options = list.Get( "list_portaltexFSB" ) } )
	

	
end

hook.Add( "PopulateToolMenu", "PortalMenus", function()

	spawnmenu.AddToolMenuOption( "Options", "Portal", "Settings", "Settings", "", "", PortalMenuSettings )

end )

list.Set( "list_portalonly", "Two Portal Connect", { portal_portalonly = "0" } )
list.Set( "list_portalonly", "One Portal (Blue)", { portal_portalonly = "1" } )
list.Set( "list_portalonly", "One Portal (Orange)", { portal_portalonly = "2" } )

list.Set( "list_portaltexFSB", "Chell", { portal_texFSB = "0" } )
list.Set( "list_portaltexFSB", "Atlas", { portal_texFSB = "1" } )
list.Set( "list_portaltexFSB", "P-Body", { portal_texFSB = "2" } )