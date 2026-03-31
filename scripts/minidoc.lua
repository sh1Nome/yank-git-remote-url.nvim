local minidoc = require("mini.doc")

if _G.MiniDoc == nil then
	minidoc.setup()
end

MiniDoc.generate({ "lua/yank-git-remote-url/init.lua" }, "doc/yank-git-remote-url.txt")
