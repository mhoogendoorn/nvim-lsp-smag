local vim = vim
local api = vim.api

local M = {}

local function get_path(uri)
    local absolute_path = vim.uri_to_fname(uri)
    local working_directory = api.nvim_call_function("getcwd", {}) .. "/"
    -- The string.gsub/find functions do not work with the slashes in the path.
    local maybe_relative_path = api.nvim_call_function("substitute", {absolute_path, working_directory, "", ""})
    return maybe_relative_path
end

local function read_line(uri, line_index)
    local file_path = vim.uri_to_fname(uri)
    local lines = api.nvim_call_function("readfile", {file_path, "", line_index})
    return lines[line_index]
end

function M.lsp_location_to_tag(name, kind, lsp_location)
    local uri = lsp_location.uri or lsp_location.targetUri
    local range = lsp_location.range or lsp_location.targetSelectionRange or lsp_location.targetRange
    local line = range.start.line + 1
    local column = range.start.character + 1
    local cmd = 'normal ' .. line .. 'G' .. column .. '|'

    return {
        name = name,
        cmd = cmd,
        kind = kind .. " ", -- add a gap to the tag name
        filename = get_path(uri),
        user_data = read_line(uri, line)
    }
end

return M
