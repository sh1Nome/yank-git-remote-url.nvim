-- バックアップファイルとスワップファイルを無効化
vim.opt.backup = false
vim.opt.swapfile = false

-- このファイルから相対的にプラグインディレクトリ(親の親)を解決してランタイムパスに追加
local plugin_dir = vim.fn.fnamemodify(vim.fn.expand("<sfile>"), ":h:h")
vim.opt.rtp:prepend(plugin_dir)

-- プラグインをセットアップ
require("yank-git-remote-url").setup({
	providers = {
		{
			match = function(host)
				return host:find("github") ~= nil
			end,
			build_url = function(host, repo_path, commit, rel_path, start_line, end_line)
				local base = ("https://%s/%s/blob/%s/%s"):format(host, repo_path, commit, rel_path)
				if not start_line then
					return base
				end
				if start_line == end_line then
					return base .. "#L" .. start_line
				end
				return base .. "#L" .. start_line .. "-L" .. end_line
			end,
		},
	},
})
