--- *yank-git-remote-url*  Copy the remote repository URL of the current file to clipboard
---
--- MIT License Copyright (c) 2026 sh1Nome
---
---@toc

--- This plugin generates a URL to the current file on your remote Git hosting
--- service and copies it to the clipboard. The URL uses commit hashes for
--- permanent links.
---
--- Features:
--- - Permanent URLs using commit hashes (not branch names)
--- - Custom provider support for any Git hosting service
--- - Copy to clipboard and notify via |vim.notify()|
--- - Support for line ranges (visual selection)
---@tag yank-git-remote-url-intro
---@toc_entry Introduction

--- Use your preferred plugin manager.
---@tag yank-git-remote-url-install
---@toc_entry Installation

--- Each provider must implement:
--- - `match(host: string): boolean`
--- - `build_url(host, repo_path, commit, rel_path, start_line?, end_line?): string`
---@tag yank-git-remote-url-provider
---@toc_entry Provider

--- Setup the plugin:
--- >lua
---   require('yank-git-remote-url').setup({
---     providers = {
---       {
---         match = function(host)
---           return host:find("github") ~= nil
---         end,
---         build_url = function(host, repo_path, commit,
---             rel_path, start_line, end_line)
---           local base = (
---             "https://%s/%s/blob/%s/%s"
---           ):format(host, repo_path, commit, rel_path)
---           if not start_line then return base end
---           if start_line == end_line then
---             return base .. "#L" .. start_line
---           end
---           return base .. "#L" .. start_line ..
---             "-L" .. end_line
---         end,
---       },
---     }
---   })
--- <
---
--- Create a user command to copy the current file's remote URL:
--- >lua
---   vim.api.nvim_create_user_command("YankGitRemoteUrl", function(opts)
---       require("yank-git-remote-url").yank(
---         opts.range, opts.line1, opts.line2)
---   end, { range = true, desc = "Copy remote URL to clipboard" })
--- <
---
--- Usage:
--- - `:YankGitRemoteUrl` - Copy the entire file's remote URL
--- - `:10,20YankGitRemoteUrl` - Copy the URL with line range (10-20)
---@tag yank-git-remote-url-usage
---@toc_entry Usage

local M = {}

local providers = {}

--- Setup the plugin with custom providers
---
---@param opts table Configuration options
---   - providers: table[] Array of provider tables.
---     Each provider must have:
---     - match: fun(host: string): boolean
---     - build_url: fun(host, repo_path, commit,
---       rel_path, start_line?, end_line?): string
---@tag yank-git-remote-url-api-setup
---@toc_entry setup()
function M.setup(opts)
	providers = opts.providers or {}
end

--- Copy the current file's remote URL to clipboard
---@param range integer Range indication (0: no range, 2: range selected)
---@param start_line integer Start line number
---@param end_line integer End line number
---@tag yank-git-remote-url-api-yank
---@toc_entry yank()
function M.yank(range, start_line, end_line)
	-- Get remote URL
	local remote_url = vim.system({ "git", "remote", "get-url", "origin" }, { text = true })
		:wait().stdout
		:gsub("%s+$", "")
	if remote_url == "" then
		vim.notify("git remote not found", vim.log.levels.ERROR)
		return
	end

	-- Parse host and repo_path from SSH or HTTPS URL
	local host, repo_path
	local ssh_host, ssh_path = remote_url:match("^git@([^:]+):(.+)$")
	if ssh_host then
		host, repo_path = ssh_host, ssh_path
	else
		host, repo_path = remote_url:match("^https?://([^/]+)/(.+)$")
	end
	if not host or not repo_path then
		vim.notify("failed to parse remote URL: " .. remote_url, vim.log.levels.ERROR)
		return
	end
	repo_path = repo_path:gsub("%.git$", "")

	-- Find matching provider for the host
	local provider
	for _, p in ipairs(providers) do
		if p.match(host) then
			provider = p
			break
		end
	end
	if not provider then
		vim.notify("no matching provider: " .. host, vim.log.levels.ERROR)
		return
	end

	-- Calculate relative path from repository root
	local repo_root = vim.system({ "git", "rev-parse", "--show-toplevel" }, { text = true })
		:wait().stdout
		:gsub("%s+$", "")
	local buf_path = vim.api.nvim_buf_get_name(0)
	local rel_path = buf_path:sub(#repo_root + 2) -- +2 to skip trailing /

	-- Get commit hash
	local commit = vim.system({ "git", "rev-parse", "HEAD" }, { text = true }):wait().stdout:gsub("%s+$", "")

	-- Build URL
	local url
	if range > 0 then
		url = provider.build_url(host, repo_path, commit, rel_path, start_line, end_line)
	else
		url = provider.build_url(host, repo_path, commit, rel_path)
	end

	-- Copy to clipboard
	vim.fn.setreg("+", url)

	-- Notify
	vim.notify(url, vim.log.levels.INFO)
end

return M
