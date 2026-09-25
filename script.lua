local player=game.Players.LocalPlayer
local mt=getrawmetatable(game)
local old=mt.__namecall
setreadonly(mt,false)
mt.__namecall=function(self,...)
    local method=getnamecallmethod()
    if method=="FireServer" or method=="InvokeServer" then
        print("["..method.."]",self:GetFullName())
        local args={...}
        for i,v in ipairs(args) do
            print("  arg"..i..":",type(v),tostring(v))
        end
    end
    return old(self,...)
end
setreadonly(mt,true)
print("=== 監視開始 ===")
