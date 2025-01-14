local ut = require("jb_utils")
local flypy_table = require("flypy")
local M = {}

-- parse的时候英文不要分开，也许可以接近原生体验,或者前后两个parse出来

local flypy = function(str)
	if flypy_table[str] ~= nil then
		return string.sub(flypy_table[str], 1, 2) -- 暂时只有一个音
	else
		return str
	end
end

local function reverse(x)
	local rev = {}
	for i = #x, 1, -1 do
		rev[#rev + 1] = x[i]
	end
	return rev
end

local parse_line = function(str, line)
	local cum_l = 1
	local parsed = {}
	local tokens = ut.split_char(str)
	for _, tok in ipairs(tokens) do
		local i = cum_l
		local t = flypy(tok)
		cum_l = cum_l + #tok
		parsed[#parsed + 1] = { row = line, col = i, t = t }
	end
	return parsed
end

local parse = function()
	local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
	local parsed = {}
	for i, line in ipairs(lines) do
		local parsed_line = parse_line(line, i)
		for _, tok in ipairs(parsed_line) do
			parsed[#parsed + 1] = tok
		end
	end
	return parsed
end

-- local parse_jieba = function()
-- 	local cum_l = 1
-- 	local parsed = {}
-- 	local str = vim.api.nvim_get_current_line()
-- 	local row = vim.api.nvim_win_get_cursor(0)[1]
-- 	local col = vim.api.nvim_win_get_cursor(0)[2]
-- 	local tokens = jieba.lcut(str, false, true)
-- 	for _, tok in ipairs(tokens) do
-- 		local i = cum_l
-- 		cum_l = cum_l + #tok
-- 		if #tok >= 6 and i > col then
-- 			parsed[#parsed + 1] = { pos = { row, i } }
-- 		end
-- 	end
-- 	return parsed
-- end

local function get_char()
	local i = 1
	local tmp = ""
	while i < 3 do
		local a = vim.fn.getcharstr()
		tmp = tmp .. a
		i = i + 1
	end
	return tmp
end

local find_han = function()
	local str = get_char()
	local parsed = parse()
	local pos = vim.api.nvim_win_get_cursor(0)
	local found = {}
	for _, tok in ipairs(parsed) do
		if tok.t == str and tok.row == pos[1] and tok.col > pos[2] then
			found[#found + 1] = { pos = { tok.row, tok.col } }
		elseif tok.t == str and tok.row > pos[1] then
			found[#found + 1] = { pos = { tok.row, tok.col } }
		end
	end
	return found
end

local find_han_bak = function()
	local str = get_char()
	local parsed = parse()
	local pos = vim.api.nvim_win_get_cursor(0)
	local found = {}
	for _, tok in ipairs(parsed) do
		if tok.t == str and tok.row == pos[1] and tok.col < pos[2] then
			found[#found + 1] = { pos = { tok.row, tok.col } }
		elseif tok.t == str and tok.row < pos[1] then
			found[#found + 1] = { pos = { tok.row, tok.col } }
		end
	end
	return reverse(found)
end

M.leap_zh = function()
	require("leap").leap({
		targets = find_han(),
	})
end

M.leap_zh_bak = function()
	require("leap").leap({
		targets = find_han_bak(),
	})
end

-- M.leap_jieba = function()
-- 	require("leap").leap({
-- 		targets = parse_jieba(),
-- 	})
-- end

return M
