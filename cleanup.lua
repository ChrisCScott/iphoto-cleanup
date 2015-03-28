--[[----------------------------------------------------------------------------

Cleanup.lua
Removes the “[Event Name] > Event Photos” structure from the catalogue’s collections and replaces it with “{Event Name}”, where [Event Name] is a collection set and {Event Name} is a collection.

------------------------------------------------------------------------------]]

-- Import namespaces dealing with the current catalog and its collections

local LrApplication = import 'LrApplication'
local LrDialogs = import 'LrDialogs'
local LrLogger = import 'LrLogger'
local LrTasks = import 'LrTasks'

-- Create the logger and point it to the Console (open the Console app to read)
local logger = LrLogger( 'iphotocleanuplog' )
logger:enable( "print" ) -- Pass either a string or a table of actions.

--[[	function traverseCollectionSets(array)

	Calls traverseCollectionSet for each LrCollectionSet in array
--]]

function traverseCollectionSets(array)

	logger:debug( "\nEntered function: traverseCollectionSets" )
	logger:debug( "\n\tarray = ", array )

	for index, child in ipairs(array) do
		logger:debug( "\n\t\tchild = ", child )
		if child:type() == "LrCollectionSet" then
			traverseCollectionSet(child)
		end
	end
end

--[[	function replaceCollection(old,new)

	Place the new collection in the same location as the old collection,
	with the same name. Delete the old collection. 
--]]

function replaceCollection(old,new)
	logger:debug(	"\nEntered function replaceCollection()",
			"\n\told = ", old,
			"\n\tnew = ", new )
	local name = old:getName()
	logger:debug(	"\n\tname = ", name )
	old:setName("ca.christopherscott.lightroom.iphotocleanup-temp")
	new:setName(name)
	new:setParent(old:getParent())
	old:delete()
end

--[[	function traverseCollectionSet(collectionSet)

	Look for collection sets with a single “Event Photos” child collection.
	We want to "convert" each such collection set to a dumb collection.
	To do this, we move the child collection (which is already dumb) up to its parent's level,
	give it the parent's name (after renaming the parent to avoid conflicts),
	and delete the former parent.
--]]

function traverseCollectionSet(parent)
	logger:debug( "\nEntered function: traverseCollectionSet" )
	logger:debug( "\n\tparent = ", parent )

	local children = parent:getChildren()
	logger:debug( "\n\tchildren = ", children )

	-- We expect each automatically imported iPhoto event to have exactly one child.
	-- The child should be a (dumb) collection, so check for that too:
	if #children == 1 then
		logger:debug( "\n\tExactly one child found" )
		local child = children[1]
		logger:debug( "\n\t\tchild = ", child )

		-- If it's a collection named “Event Photos”, put the child in its parent's place.
		if child:type() == "LrCollection" and child:getName() == "Event Photos" then
			logger:debug( "\n\t\tReplacing parent with child")
			replaceCollection(parent,child)
			logger:debug( "\n\t\tReplacement complete")
			-- No need to recurse; exit function
			logger:debug( "\nExiting function: traverseCollectionSet" )
			return
		end
	end

	logger:debug( "\n\tTail recursion on function: traverseCollectionSet" )
	return traverseCollectionSets( children )

end

--[[	function main()

	Contains program logic, for execution in an asynchronous task.
	(This is required by the :get* methods of LrCatalog, LrCollection, etc.)
--]]

function main()
	-- Get an array of all top-level children
	local catalog = LrApplication.activeCatalog()
	logger:debug( "\n\tcatalog = ", catalog )
	local children = catalog:getChildCollectionSets()
	logger:debug( "\n\tchildren = ", children )

	-- Changing collections requires write access.
	catalog:withWriteAccessDo("iPhoto Cleanup", function()
		traverseCollectionSets(children)
	end )
	logger:debug( "\nProcessing complete. Terminating plugin" )
	LrDialogs.message("Cleanup Complete", "Processing of all collection sets imported from iPhoto is complete.", "info")
end

LrTasks.startAsyncTask(main)
