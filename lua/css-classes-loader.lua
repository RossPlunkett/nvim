-- CSS Classes/IDs Loader for Neovim
-- Parses CSS files and provides autocomplete for JS template strings

local M = {}
local css_classes = {}
local last_update = 0
local log_file = vim.fn.stdpath("cache") .. "/css-classes-debug.log"

-- Logging function - only log errors by default
local function log(msg, is_error)
	if is_error then
		local file = io.open(log_file, "a")
		if file then
			file:write(string.format("[%s] ERROR: %s\n", os.date("%H:%M:%S"), msg))
			file:close()
		end
		print("[CSS-Classes ERROR] " .. msg)
	end
end

-- Parse CSS file and extract classes and IDs
local function parse_css_file(filepath)
	local classes = {}
	local file = io.open(filepath, "r")
	if not file then
		log("Failed to open CSS file: " .. filepath, true)
		return classes
	end

	local content = file:read("*a")
	file:close()

	-- Match class selectors (.classname)
	for class in content:gmatch("%.([%w_-]+)") do
		classes[class] = true
	end

	-- Match ID selectors (#idname)
	for id in content:gmatch("#([%w_-]+)") do
		classes[id] = true
	end

	return classes
end

-- Scan all CSS files in directory
local function scan_css_files(directory)
	local classes = {}

	local handle = io.popen("find " .. directory .. ' -name "*.css" -type f 2>/dev/null')
	if not handle then
		log("Failed to open directory: " .. directory, true)
		return classes
	end

	for filepath in handle:lines() do
		local file_classes = parse_css_file(filepath)
		for class, _ in pairs(file_classes) do
			classes[class] = true
		end
	end
	handle:close()

	return classes
end

-- Update CSS classes from project CSS folder
function M.update_classes(css_dir)
	css_dir = css_dir or vim.fn.getcwd() .. "/css"
	css_classes = scan_css_files(css_dir)
	last_update = vim.loop.now()
	return css_classes
end

-- Get all CSS classes as completion items
function M.get_completion_items()
	local items = {}
	for class, _ in pairs(css_classes) do
		table.insert(items, {
			label = class,
			kind = require("cmp").lsp.CompletionItemKind.Class,
			detail = "CSS Class/ID",
			sortText = class,
			filterText = class,
		})
	end
	return items
end

-- Setup autocomplete source for nvim-cmp
function M.setup_cmp_source()
	local cmp = require("cmp")
	cmp.register_source("css_classes", {
		complete = function(self, params, callback)
			local success, items = pcall(M.get_completion_items)
			if not success then
				log("ERROR in get_completion_items: " .. tostring(items), true)
				callback({ items = {} })
				return
			end
			local ok, err = pcall(callback, {
				items = items,
				isIncomplete = false,
			})
			if not ok then
				log("ERROR in callback: " .. tostring(err), true)
			end
		end,
		is_available = function()
			return true
		end,
	})
end

-- Watch CSS files for changes and reload
function M.setup_watcher()
	local css_dir = vim.fn.getcwd() .. "/css"
	vim.api.nvim_create_autocmd("BufWritePost", {
		pattern = css_dir .. "/*.css",
		callback = function()
			M.update_classes(css_dir)
		end,
	})
end

-- Initial load and setup
function M.setup()
	local css_dir = vim.fn.getcwd() .. "/css"

	M.update_classes(css_dir)
	M.setup_cmp_source()
	M.setup_watcher()

	-- Add keymapping to manually reload
	vim.keymap.set("n", "<leader>cr", function()
		M.update_classes(css_dir)
	end, { desc = "Reload CSS classes" })
end

return M
