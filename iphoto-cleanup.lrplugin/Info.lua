--[[----------------------------------------------------------------------------

Info.lua
Summary information for iPhoto Cleanup plug-in.

Removes the “[Event Name] > Event Photos” structure from the catalogue’s collections and replaces it with “{Event Name}”, where [Event Name] is a collection set and {Event Name} is a collection.

------------------------------------------------------------------------------]]

return {
	
	LrSdkVersion = 3.0,
	LrSdkMinimumVersion = 1.3, -- minimum SDK version required by this plug-in

	LrToolkitIdentifier = 'ca.christopherscott.lightroom.iphotocleanup',

	LrPluginName = LOC "$$$/iPhotoCleanup/PluginName=iPhoto Cleanup",

	-- Add the menu item to the File menu.
	
	LrExportMenuItems = {
		title = "iPhoto Cleanup",
		file = "cleanup.lua"
	},

	VERSION = { major=1, minor=0, revision=0, build=5, },

}
