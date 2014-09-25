/*-------------------------------------------------------------------------------------------------------------------------
	Tab with settings
-------------------------------------------------------------------------------------------------------------------------*/

local TAB = {}
TAB.Title = "Settings"
TAB.Description = "Manage evolution settings and preferences."
TAB.Icon = "page_edit"
TAB.Author = "EntranceJew"
TAB.Width = 520
TAB.Privileges = { "Settings" }

TAB.CatWidth = 166

TAB.Frame = nil
TAB.SearchBox = nil
TAB.SearchButton = nil
TAB.SettingsTree = nil
--[[
  this is mapped:
    global.nodes['category1'].nodes['category2']
]]
TAB.Scroll = nil
TAB.Layout = nil
TAB.GraveYard = nil

TAB.cDepth = 0
TAB.cPathTable = {}

TAB.Categories = {}
--[[
  this is mapped:
    global['category1']['category2'].sets
]]
--[[
  this WILL BE mapped:
    global.nodes['category1'].nodes['category2']
]]
TAB.Controls = {}
--[[
 this is mapped:
    global['num_corns']
]]

-- TAB.Panel == global
local testsettings = {
	category_general = {
		label = 'General',
		desc = 'This is for general evolve settings.',
		stype = 'category',
		icon = 'page_edit',
		value = {
			category_misc = {
				label = 'Misc',
				desc = 'Miscelaneous is hard to spell.',
				stype = 'category',
				icon = 'rainbow',
				value = {
					num_corns = {
					    label = 'No. Corns',
					    desc = 'How many corns? This many.',
					    stype = 'limit',
					    value = 50,
					    min = 25,
					    max = 75,
					    default = 30},
					num_porns = {
					    label = 'No. Porns',
					    desc = 'Remember, we are on a budget.',
					    stype = 'limit',
					    value = 1,
					    min = -3,
					    max = 30,
					    default = 2},
					resync_name = {
					    label = 'Sync Again Label',
					    desc = 'Can you not decide what to call it?',
					    stype = 'string',
					    value = 'reSync',
					    default = 'ReSync'},
					best_name = {
					    label = 'Best Name',
					    desc = 'Who is the best?',
					    stype = 'string',
					    value = 'Bungalo',
					    default = 'EntranceJew'},
					is_gay = {
					    label = 'Is Gay',
					    desc = 'Are you having trouble finding out?',
					    stype = 'bool',
					    value = true,
					    default = false},
				},
			},
		},
	},
}
for i=1,16 do
	local set = {
		label = 'Test Setting #'..i,
    desc = 'Testing out item '..i..', huh?',
    stype = 'bool',
    value = true,
    default = false
	}
	
	testsettings.category_general.value.category_misc.value["test_set"..i]=set
end


evolve:RegisterSettings( testsettings )

function TAB:IsAllowed()
	return LocalPlayer():EV_HasPrivilege( "Settings" )
end
-- functions used by buildsettings
function TAB:CreateLimit( pnl, name, item )
  local elm = vgui.Create( "DNumSlider", pnl )
  pnl:SetTall(32)
  elm:SetTall(32)
  elm:SetText( item.label )
  elm:SetWide( pnl:GetWide() )
  elm:SetTooltip( item.desc )
  elm:SetMin( item.min )
  elm:SetMax( item.max )
  elm:SetDecimals( 0 )
  elm:SetValue( item.value )
  elm.Label:SetDark(true)
  self:SetFocusCallbacks( elm.TextArea )
  pnl.NumSlider = elm
  
  -- boring handler overloading
  local function mousereleased(mousecode)
    evolve:SetSetting(name, math.Round(elm:GetValue())) --@TODO setting the decimals goes here
    evolve:SendSettings()
  end
  
  local scratch_released = elm.Scratch.OnMouseReleased
  local slider_released = elm.Slider.OnMouseReleased
  local knob_released = elm.Slider.Knob.OnMouseReleased

  function elm.Scratch:OnMouseReleased(mousecode)
    mousereleased(mousecode)
    scratch_released(elm.Scratch, mousecode)
  end

  function elm.Slider:OnMouseReleased(mousecode)
    mousereleased(mousecode)
    slider_released(elm.Slider, mousecode)
  end

  function elm.Slider.Knob:OnMouseReleased(mousecode)
    mousereleased(mousecode)
    knob_released(elm.Slider.Knob, mousecode)
  end
  
  return pnl
end

function TAB:CreateString( pnl, name, item )
  -- @TODO: DForm keeps resizing the elements when "DLabel" is passed as the first argument
  local helm = vgui.Create( "DLabel", pnl )
  helm:SetWide(135)
  helm:SetText( item.label )
  helm:SetTooltip( item.label )
  helm:SetDark(true)
  helm:Dock( LEFT )
  
  local elm = vgui.Create( "DTextEntry", pnl )
  --elm:SetSize( 227, 32 )
  elm:SetWide(193)
  elm:SetTooltip( item.desc )
  elm:SetValue( item.value )
  elm:Dock( RIGHT )
  self:SetFocusCallbacks( elm )
  pnl.Label = helm
  pnl.TextEntry = elm
  
  -- boring handler overloading
  elm.OnEnter = function(self)
    evolve:SetSetting(name, elm:GetValue())
    evolve:SendSettings()
  end
  
  return pnl
end

function TAB:CreateBool( pnl, name, item )
  local helm = vgui.Create( "DLabel", pnl )
  helm:SetWide(135)
  helm:SetText( item.label )
  --helm:SetSize( 135, 32 )
  helm:SetTooltip( item.desc )
  helm:SetDark(true)
  helm:Dock( LEFT )
  
  elm = vgui.Create( "DCheckBox", pnl )
  elm:SetTall(16)
  --elm:SetSize( 32, 32 )
  elm:SetTooltip( item.desc )
  elm:SetValue( item.value )
  elm:Dock( LEFT )
  pnl.Label = helm
  pnl.CheckBox = elm
  
  -- boring handler overloading
  elm.OnChange = function(self)
    evolve:SetSetting(name, elm:GetValue())
    evolve:SendSettings()
  end
  
  return pnl
end

--[[TAB:Update()]]
function TAB:BuildCategories( dermadepth, setsdepth, catsdepth, qpath )
  --self:BuildCategories( self.SettingsTree, evolve.settings, self.Categories )
  print("entering buildcategories")
  if qpath~=nil then
    PrintTable(qpath)
  else
    print("qpath was nil!!!")
  end
	if dermadepth.nodes==nil then
		dermadepth.nodes={}
	end
  local bpath = {}
  if qpath ~= nil then
    bpath = table.Copy(qpath)
  end
	for k,v in pairs(setsdepth) do
		if v.stype == 'category' then
      print("spilling category: "..v.label)
			local node = dermadepth:AddNode( v.label )
			node:SetIcon( "icon16/"..v.icon..".png" )
			node:SetTooltip( v.desc )
      
      table.insert(bpath, v.label)
      if bpath~=nil then
        PrintTable(bpath)
      else
        print("bpath was nil???")
      end
			node.DoClick = function()
				-- open the settings for whatever the built path is at present
        print(v.label.." got clicked on!!!")
				self:BuildSettings( bpath )
			end
			dermadepth.nodes[v.label] = node
			if catsdepth[v.label]==nil then
				catsdepth[v.label] = {}
			end
			catsdepth[v.label].sets = v.value
      -- @TODO: do a check here to see if we actually need to go any deeper
			bpath = self:BuildCategories( dermadepth.nodes[v.label], v.value, catsdepth[v.label], bpath )
      print("got back from recursive call")
      if bpath~=nil then
        PrintTable(bpath)
      else
        print("bpath was nil~~~")
      end
		end
	end
  print("returning")
  if qpath~=nil then
    PrintTable(qpath)
  else
    print("qpath was nil@@@")
  end
  return qpath
end

function TAB:BuildCategories2( atree, acat, aset, adepth )
  --[[ Mission:
    1) Create all the "self.SettingsTree" nodes.
    2) Set an event so that when the node is clicked it calls OpenToPath( tblPath )
    3) 
  ]]
  --self:BuildCategories2( self.SettingsTree, evolve.settings, self.Categories )
  --self:BuildCategories( self.SettingsTree, evolve.settings, self.Categories )
  print("DEBUG: BuildCategories2 -- entering")
  
  local tree = atree
  local cat = acat
  local set = aset
  local path = {}
  --[[if type(apath)=="string" then
    path = string.Explode("\\", apath)
    if table.maxn(path) == 1 and path[1]==apath then
      print("DEBUG: BuildCategories2 -- 'apath' was a string but couldn't be exploded: '"..apath.."'")
    end
  elseif apath==nil then
    print("DEBUG: BuildCategories2 -- 'apath' was nil, leaving 'path' as empty table.")
  end]]
  local depth = adepth or 1
  if adepth~= nil then
    print("DEBUG: BuildCategories2 -- 'adepth' wasn't nil, incrementing.")
    depth = adepth+1
  else
    print("DEBUG: BuildCategories2 -- 'adepth' was nil, at entrypoint depth.")
  end
  
  
  assert(tree~=nil, "GOT NIL IN PLACE OF TREE NODE")
  print("DEBUG: BuildCategories2 -- Investigating tree.")
  --PrintTable(tree)
	if tree.nodes==nil then
    print("DEBUG: BuildCategories2 -- 1: Tree @ depth has no nodes, adding node stub.")
		tree.nodes={}
	else
    print("DEBUG: BuildCategories2 -- 2: Tree @ depth has nodes, we must be in an item with multiple children.")
  end
  
  assert(istable(cat), "GOT NON-TABLE CATEGORY NODE")
  print("DEBUG: BuildCategories2 -- Investigating cat shaped like: ")
  PrintTable(cat)
	if cat.nodes==nil then
    print("DEBUG: BuildCategories2 -- 1: Cat @ depth has no nodes, adding node stub.")
		cat.nodes={}
	else
    print("DEBUG: BuildCategories2 -- 2: Cat @ depth has nodes, we must be in an item with multiple children.")
  end
  
  assert(istable(set), "GOT NON-TABLE SETTINGS")
  print("DEBUG: BuildCategories2 -- Beginning settings iteration in table shaped like:")
  PrintTable(set)
	for k,v in pairs(set) do
    if v.stype==nil then
      print("DEBUG: BuildCategories2 -- Ignoring malformed element '"..k.."' ...")
    else
      print("DEBUG: BuildCategories2 -- Inside setting '"..v.label.."' of type '"..v.stype.."'...")
      if v.stype == 'category' then
        local node = tree:AddNode( v.label )
        node:SetIcon( "icon16/"..v.icon..".png" )
        node:SetTooltip( v.desc )
        node.ej_parent = v.label
        
        local parent = self
        node.DoClick = function(self)
          print("doclick: "..v.label.." got clicked on @ depth # "..depth)
          local dpath = {}
          local brk = true
          local work = self
          while brk do
            if work.ej_parent~= nil then
              print("doclick: added '"..work.ej_parent.."' to stack")
              table.insert(dpath, 1, work.ej_parent)
            else
              print("doclick: couldn't find attribute ej_parent, assumed done")
              brk = false
            end
            work = work:GetParentNode()
          end
          parent:BuildSettings( dpath )
        end
        
        -- add tree child
        tree.nodes[v.label] = node
        cat.nodes[v.label] = v.value --assign category as a reference to the position in evolve.settings
        
        print("DEBUG: BuildCategories2 -- Recursing!!!")
        self:BuildCategories2( tree.nodes[v.label], cat.nodes[v.label], v.value, depth )
        print("DEBUG: BuildCategories2 -- Returned from recursion!!!")
      else
        print("DEBUG: BuildCategories2 -- Ignoring non-category '"..v.label.."' of type '"..v.stype.."'.")
      end
    end
	end
  print("DEBUG: BuildCategories2 -- Iterated over all items at current depth of '"..depth.."'")
end


function TAB:BuildSettings( tblPath )
  print("DEBUG: BuildSettings -- entering...")
  for k,v in pairs(self.Controls) do
    if v:IsValid() then
      if v:GetParent() == self.Layout then
        print("DEBUG: BuildSettings -- existing control '"..k.."' moved to grave.")
        v:SetParent(self.GraveYard)
      elseif v:GetParent() == self.GraveYard then
        print("DEBUG: BuildSettings -- control '"..k.."' was already in the grave.")
      else
        assert(false, "RENEGADE CONTROL: "..k)
      end
    else
      --assert(false, "UNDEAD CONTROL ESCAPED GRAVEYARD: "..k)
      v=nil
      print("DEBUG: BuildSettings -- invalid control '"..k.."' erased.")
    end
  end
  -- since we graved all the children, we should refresh the shape of our scrollbar
  self.Layout:SetSize(self.Scroll:GetSize())
  
	local settings = self.Categories
	for _,v in pairs(tblPath) do
		if settings.nodes[v]==nil then
      print("DEBUG: BuildSettings -- "..v.." NON-BREAK ("..table.concat(tblPath, "\\")..")")
		elseif v~='nodes' then
      -- we do not want to step into the 'sets' category by itself
      settings = settings.nodes[v]
    elseif v=='nodes' then
      assert(false, "UH OH, SOMEONE TOLD US TO STEP INTO THE 'nodes' CATEGORY, THEY'RE A BAD MAN.")
    end
		
    print("DEBUG: BuildSettings -- settings=self.Categories."..v.."==nil; BREAK ("..table.concat(tblPath, "\\")..")")
	end
  print("DEBUG: Dumping contents of 'settings'.")
  PrintTable(settings)
	
	for k,v in pairs(settings) do
    if k~='nodes' then
      if self.Controls[k]~=nil then
        print("DEBUG: BuildSettings -- reassigned parent of existing element: '"..k.."'")
        self.Controls[k]:SetParent(self.Layout)
      else
        print("DEBUG: BuildSettings -- created new element stub: '"..k.."'")
        local step = vgui.Create( "DPanel", self.Layout )
        step:SetWide( self.Layout:GetWide() )
        step:SetTall(32)
        
        if v.stype == 'limit' then
          self.Controls[k] = self:CreateLimit( step, k, v )
        elseif v.stype == 'string' then
          self.Controls[k] = self:CreateString( step, k, v )
        elseif v.stype == 'bool' then
          self.Controls[k] = self:CreateBool( step, k, v )
        else
          print("IGNORED ELEMENT OF TYPE '"..v.stype.."', REMOVING STUB")
          step:Remove()
        end
        print("DEBUG: BuildSettings -- finalized element: '"..k.."'")
      end
    end
	end
end

function TAB:SetFocusCallbacks( elm )
  elm.OnGetFocus = function()
    self.Panel:GetParent():GetParent():SetKeyboardInputEnabled(true)
  end
  elm.OnLoseFocus = function()
    self.Panel:GetParent():GetParent():SetKeyboardInputEnabled(false)
  end
end

function TAB:OpenToPath( tblPath )
	local depth = self.SettingsTree.nodes
	for _,v in pairs(tblPath) do
		self.SettingsTree:SetSelectedItem(depth[v])
		if depth[v]==nil then
			break
		end
		depth[v]:SetExpanded(true, true)
		depth = depth[v].nodes
	end
	self:BuildSettings( tblPath )
end


function TAB:Initialize( pnl )
  glb = self
  -- [[ for shorthand reaching for sets via category { "General", "Misc" }
  
  self.SearchPanel = vgui.Create("DPanel", pnl)
  self.SearchPanel:SetSize( self.CatWidth, pnl:GetParent():GetTall() - 58 ) --@MAGIC
  self.SearchPanel:Dock(LEFT)
  --SetSize( 520, 490 )
  
  self.SearchBox = vgui.Create( "DTextEntry", self.SearchPanel )	-- create the form as a child of frame
  self.SearchBox:Dock(TOP)
  self.SearchBox:DockMargin( 4, 2, 4, 2 )
  self.SearchBox:SetTooltip( "Press enter to search settings." )
  self.SearchBox.OnEnter = function( self )
    print( 'SETTINGS SEARCH: '..self:GetValue() )	-- print the form's text as server text
  end
  self:SetFocusCallbacks( self.SearchBox )

  self.SearchButton = self.SearchBox:Add( "DImageButton" )
  self.SearchButton:Dock( RIGHT )
  self.SearchButton:DockMargin( 0, 2, 0, 2 )
  --TAB.SearchButton:SetPos( 2+TAB.SearchBox:GetWide()-16, glob.constantHeight+2 )
  self.SearchButton:SetSize( 16, 16 )
  self.SearchButton:SetImage( "icon16/find.png" )
  self.SearchButton:SetText( "" )
  self.SearchButton:SetTooltip( "Press to search settings." )
  self.SearchButton.DoClick = function(self) 
    self:GetParent().SearchBox:OnEnter()
  end

  self.SettingsTree = vgui.Create( "DTree", self.SearchPanel )
  --self.SettingsTree:SetPos( 0, self.SearchBox:GetTall()+2 )
  self.SettingsTree:Dock(TOP)
  self.SearchButton:DockMargin( 4, 2, 4, 2 )
  self.SettingsTree:SetPadding( 4 )
  --self.SettingsTree:SetTall(430)
  self.SettingsTree:SetSize( self.CatWidth, self.SearchPanel:GetTall()-4)
  --self.SettingsTree:SetSize( self.CatWidth, self.SearchPanel:GetTall()-self.SearchBox:GetTall()-4)
  
  self.Scroll = vgui.Create( "DScrollPanel", self.Panel )
	self.Scroll:Dock(RIGHT)
	self.Scroll:SetSize( self.Width-self.CatWidth-8, self.Panel:GetParent():GetTall()-3) --@MAGIC 3
	
	self.Layout = vgui.Create( "DIconLayout", self.Scroll )
  --self.Layout:SetSize( self.Scroll:GetSize() )
	self.Layout:SetTall(self.Scroll:GetTall())
	self.Layout:SetWide(self.Scroll:GetWide()-18)
	--self.Layout:SetPos(0, 0)
	self.Layout:SetSpaceX(0)
	self.Layout:SetSpaceY(5)
  
  -- REALLY SHITTY WORKAROUND TO PREVENT ELEMENT OVER-DESTRUCTION
  self.GraveYard = vgui.Create( "DPanel" )
  self.GraveYard:SetSize( 0, 0 ) 
  self.GraveYard:SetPos(-1000, -1000)
  
  self:BuildCategories2( self.SettingsTree, self.Categories, evolve.settings )
  self:OpenToPath( {"General", "Misc"} )
end

evolve:RegisterTab( TAB )