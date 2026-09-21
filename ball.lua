local mt=getrawmetatable(game)
local old=mt.__namecall
setreadonly(mt,false)
mt.__namecall=function(self,...)
    if getnamecallmethod()=="FireServer" then
        print("Fire:",self:GetFullName())
    end
    return old(self,...)
end
setreadonly(mt,true)
