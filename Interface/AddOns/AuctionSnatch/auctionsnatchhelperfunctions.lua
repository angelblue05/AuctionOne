
--[[

    HELPER FUNCTIONS

    Anything that needs repetitive actions or calculations
    Tips: 
        -- Multiplication are faster than division
        -- Local is faster than global. Re-assign global as a new local if used a lot

]]

local ASprintstack = -1
local messagestring = ""

function ASprint(message, level)

    if ASdebug or (level == 1) then

        if ASprintstack == -1 then
            messagestring = MSG_C.DEFAULT.."AuctionSnatch|r: "
        end

        if not message then
            DEFAULT_CHAT_FRAME:AddMessage(messagestring..tostring(message))
            return false 
        end

        ASprintstack = ASprintstack + 1

        if (type(message) == "table") then
            local filler=string.rep(". . ", ASprintstack)

            DEFAULT_CHAT_FRAME:AddMessage(messagestring.."{table} --> ")
            for k, v in pairs(message) do
                messagestring = filler.."["..k.."] = "
                ASprint(v)
            end
        
        elseif (type(message) == "userdata") then

        elseif (type(message) == "function") then
            DEFAULT_CHAT_FRAME:AddMessage(messagestring.." A function(self)")
        elseif (type(message) == "boolean") then
            DEFAULT_CHAT_FRAME:AddMessage(messagestring..tostring(message))
        else
            DEFAULT_CHAT_FRAME:AddMessage(messagestring..tostring(message))
        end
        
        ASprintstack = ASprintstack - 1
   end
end








ASGetGSC = function (money)
          if (money == nil) then money = 0 end
          local g = math.floor(money / 10000)
          local s = math.floor((money - (g*10000)) / 100)
          local c = math.ceil(money - (g*10000) - (s*100))
          return g,s,c
       end

-- formats money text by color for gold, silver, copper
function ASGSC(money, exact, dontUseColorCodes)
    -------------- THANK YOU BOTTOMSCANNER ----------------
   --if not (exact) then exact = true end;
   if (type(money) ~= "number") then return end
   
   local TEXT_NONE = "0"
   
   local GSC_GOLD="ffd100"
   local GSC_SILVER="e6e6e6"
   local GSC_COPPER="c8602c"
   local GSC_START="|cff%s%d%s|r"
   local GSC_PART=".|cff%s%02d%s|r"
   local GSC_NONE="|cffa0a0a0"..TEXT_NONE.."|r"
   
   if (not money) then money = 0 end
   if (not exact) and (money >= 10000) then money = math.floor(money / 100 + 0.5) * 100 end
   local g, s, c = ASGetGSC(money)
   
   local gsc = ""
   local fmt = GSC_START
   if (g > 0) then gsc = gsc..string.format(fmt, GSC_GOLD, g, 'g') fmt = GSC_PART end
   if (s > 0) or (c > 0) then gsc = gsc..string.format(fmt, GSC_SILVER, s, 's') fmt = GSC_PART end
   if (c > 0) then gsc = gsc..string.format(fmt, GSC_COPPER, c, 'c') end
   if (gsc == "") then gsc = GSC_NONE end
   
   return gsc
end


-- tcopy: recursively copy contents of one table to another.  from wowwiki
function AS_tcopy(to, from)
    -- "to" must be a table (possibly empty)
    for k, v in pairs(from) do

        if type(v) == "table" then
            to[k] = {}
            AS_tcopy(to[k], v)
        else
            to[k] = v
        end
    end
end

-- tcount: count table members even if they're not indexed by numbers
function AS_tcount(tab)
    local n = 0
    
    for _ in pairs(tab) do
        n = n + 1
    end
    return n
end


function AS_template(name)

    ASprint(MSG_C.EVENT.."Generating template: "..name)
    AS.item = {}
    ASautostart = true
    ASautoopen = true
    ASnodoorbell = true
    ASignorebid = false
    ASignorenobuyout = false

    ACTIVE_TABLE = name
    AS_SavedVariables()
end

function AS_LoadTable(name)

    ACTIVE_TABLE = name
    AS.item = {}
    AS_tcopy(AS.item, ASsavedtable[name])

    if ASsavedtable[name]["test"] then
        ASprint("test = "..ASsavedtable[name]["test"])
    end

    if ASsavedtable[name].ASautostart ~= nil then
        ASautostart = ASsavedtable[name].ASautostart
        --ASprint("Auto start = "..MSG_C.BOOL..""..tostring(ASautostart))
    end
    if ASsavedtable[name].ASautoopen ~= nil then
        ASautoopen = ASsavedtable[name].ASautoopen
        --ASprint("Auto open = "..MSG_C.BOOL..""..tostring(ASautoopen))
    end
    if ASsavedtable[name].ASnodoorbell ~= nil then
        ASnodoorbell = ASsavedtable[name].ASnodoorbell
        --ASprint("Doorbell sound = "..MSG_C.BOOL..""..tostring(ASnodoorbell))
    end
    if ASsavedtable[name].ASignorebid ~= nil then
        ASignorebid = ASsavedtable[name].ASignorebid
        --ASprint("Ignore bid = "..MSG_C.BOOL..""..tostring(ASignorebid))
    end
    if ASsavedtable[name].ASignorenobuyout ~= nil then
        ASignorenobuyout = ASsavedtable[name].ASignorenobuyout
        --ASprint("Ignore no buyout = "..MSG_C.BOOL..""..tostring(ASignorenobuyout))
    end

    AS_ScrollbarUpdate()
end




function ASshowtooltip(frame, notes)
    
    if frame then
        
        if frame:GetRight() >= (GetScreenWidth() * 0.5) then
            GameTooltip:SetOwner(frame, "ANCHOR_LEFT")
        else
            GameTooltip:SetOwner(frame, "ANCHOR_RIGHT")
        end
        
        if notes then
            GameTooltip:SetText(notes, 0, 1, 1, 1, 1)
            GameTooltip:Show()
        end
   end
end

function AShidetooltip()
    GameTooltip:Hide()
end





function ASrowsthatcanfit()  --i dunno.  i don't see anything wrong with this
--so, mainframe is 420, right?  header is 120.  300 is the listframe height.  25 is button height  300/25 = 12 - crap, only 11 show?!  why?!
--lolol on debugging, ourheight is 299.9999999999999552965            thats messed up
   if(AS) then
      if AS.mainframe then
         if AS.mainframe.listframe then
            local ourheight = math.ceil(AS.mainframe.listframe:GetHeight()) - AS_FRAMEWHITESPACE
        --  ASprint("Listframe height = "..ourheight)
--          ASprint("AS_BUTTON_HEIGHT = "..AS_BUTTON_HEIGHT)
            --ASprint("math.floor(ourheight / AS_BUTTON_HEIGHT) = "..math.floor(ourheight / AS_BUTTON_HEIGHT))
            
--          math.floor(ourheight / AS_BUTTON_HEIGHT)
            return math.floor(ourheight / AS_BUTTON_HEIGHT)
        end
      end
   end
   return 10--default
end




--------------
function ASbringtotop()
   if(AuctionFrameBrowse) then
      --this just isnt working
      --      AS.mainframe:SetFrameLevel(AuctionFrameBrowse:GetFrameLevel()+4)
      AS.mainframe:SetFrameStrata("HIGH")
      --3 because theres the main frame, then the edit box, then the dropdown buttons - gotta cover them all
   end
   --AS.mainframe.headerframe.editbox:SetFocus()
end

function GetCursorScaledPosition()
   local scale, x, y = UIParent:GetScale(), GetCursorPosition()
   return x / scale, y / scale
end




function ASsanitize(str)

    str = string.lower(str)
    str = string.gsub(str,'|c........',"")
    str = string.gsub(str,'|r',"")
    --str = string.gsub(str,'[^a-z:%p]',"")
    return str
end







--this function will move one button to another spot

function AScolortest()

            if not redcolor then
                redcolor=0x00
                greencolor=0x00
                bluecolor=0x00

    --positive or negative
                bluemod=0x1
                redmod=0x1
                greenmod=0x1

                docolor = "blue"
            end

            ASprint(docolor)

            if (docolor == "red") then
                redcolor=redcolor+redmod
                if (redcolor == 0xff or redcolor == 0x00) then
                    docolor="green"
                    redmod = redmod * -1
                end
            elseif (docolor == "green") then
                greencolor=greencolor+greenmod
                if (greencolor == 0xff or greencolor == 0x00) then
                    greenmod = greenmod * -1
                    docolor="blue"
                end
            elseif (docolor == "blue") then
                bluecolor=bluecolor+bluemod
                if (bluecolor == 0xff or bluecolor == 0x00) then
                    bluemod = bluemod * -1
                    docolor="red"
                end
            end






            redcolorstring=string.format("%x",redcolor)
            greencolorstring=string.format("%x",greencolor)
            bluecolorstring=string.format("%x",bluecolor)



            len=string.len(redcolorstring)
            redcolorstring=string.rep("0",2-len)..redcolorstring
            len=string.len(bluecolorstring)
            bluecolorstring=string.rep("0",2-len)..bluecolorstring
            len=string.len(greencolorstring)
            greencolorstring=string.rep("0",2-len)..greencolorstring

            colorstring=redcolorstring..greencolorstring..bluecolorstring

            ASprint(colorstring)
            ASprint("|c00"..colorstring.."hexadecimal|r")

end

function ASbuttontolistnum(button)
    if AS.item.LastListButtonClicked then
        ASprint(MSG_C.INFO.."Activated button:|r "..AS.item.LastListButtonClicked)
        return AS.item.LastListButtonClicked
    end
end

function ASremoveduplicates(ASlist)

    local newlist = {}
    local ASexists = false

    for i = 1,#ASlist do
        ASexists = false
        if not (newlist[1]) then
            ASprint("Newlist is empty.")
        end
        
        for j = 1,#newlist do
            ASprint("Does ASlist["..i.."] ("..ASlist[i].." = newlist["..j.."] ("..newlist[j].." ? ")    
            if (ASlist[i] == newlist[j]) then --it exists in the new list already
                ASexists  = true
                break
            end
        end
        if(ASexists == false) then
            ASprint("Inserting: "..ASlist[i])
            tinsert(newlist,ASlist[i])
        else
            ASprint("NOT Inserting: "..ASlist[i])
        end
    end

    return newlist
end


function ASvisibility(compared_to)
    local x,y = GetCursorScaledPosition()
    --ASprint("Cursor x,y="..x..","..y.."  Left, right, bottom, top="..compared_to:GetLeft()..","..compared_to:GetRight()..","..compared_to:GetBottom()..","..compared_to:GetTop())
    
    if(x < compared_to:GetLeft() or x > compared_to:GetRight() or y < compared_to:GetBottom() or y > compared_to:GetTop()) then
        return false
    end
    return true
end
