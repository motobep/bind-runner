local M = {}

local Path = require('plenary.path')
local data_path = vim.fn.stdpath('data')
local cache_config = string.format('%s/bind_runnner.json', data_path)
local buffer_name = '[runner_output]'
local opts = { noremap = true, silent = true }


local function log(...)
    print('BindRunner:', ...)
end

local function get_output_buffer()
    local bufnr = vim.fn.bufnr(buffer_name)

    if bufnr == -1 then
        -- If buffer doesn't exist, create
        local split_cmd = string.format('vnew %s | setlocal nobuflisted ' ..
            'buftype=nofile bufhidden=wipe noswapfile', buffer_name)
        vim.api.nvim_command(split_cmd)
        bufnr = vim.fn.bufnr(buffer_name)
        log('Buffer created. Number:', bufnr)
    else
        -- Buffer exists
        local window_position = vim.fn.bufwinnr(bufnr)
        if window_position == -1 then
            -- If not in window, show in window split
            log('Buffer exists. Opening in split')
            vim.api.nvim_command(string.format('vs %s', buffer_name))
        end
    end
    return bufnr
end

local function get_runner(command)
    local runner = function()
        local bufnr = get_output_buffer()

        local append_data = function(_, data)
            if data then
                vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, data)
            end
        end

        vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { 'runner output: ' })
        vim.fn.jobstart(command, {
            stdout_buffered = true,
            on_stdout = append_data,
            on_stderr = append_data
        })
    end
    return runner
end

-- Read/write config
local function read_config(path)
    return vim.fn.json_decode(Path:new(path):read())
end

local function write_config(path, table)
    Path:new(path):write(vim.fn.json_encode(table), 'w')
end

-- Load/Save settings
local function load_settings(path)
    local ok, config = pcall(read_config, path)
    if not ok then
        log('Config wasn\'t found!')
        config = {}
    end
    return config
end

local function save_settings(pwd, props)
    local config = load_settings(cache_config)
    config[pwd] = props
    -- print('Saving')
    log('Config:', vim.fn.json_encode(config))
    write_config(cache_config, config)
    return config
end

local function show_settings()
    local config = load_settings(cache_config)
    log('Config:', vim.fn.json_encode(config))
end

-- Binding to command
local function bind_command(settings)
    local pwd = vim.fn.getcwd()
    local command = settings[pwd].cmd
    local key = settings[pwd].key
    if not command then
        -- log('Can\'t bind command. Pwd:', pwd)
        BindRunRunner = function()
            log('Couldn\'t bind')
        end
    else
        BindRunRunner = get_runner(command)
    end

    vim.api.nvim_set_keymap('n', key, ':lua BindRunRunner()<CR>', opts)
end

local function bind()
    local settings = load_settings(cache_config)
    bind_command(settings)
end


-- Creating commands
vim.api.nvim_create_user_command('BindRunner', function()
    print('BindRunner prompt')
    local command = vim.split(vim.fn.input 'Command: ', ' ')
    local key = vim.fn.input 'Key: '
    print(' ')
    if key == '' then
        key = '<F5>'
        print('Default key is used:', key)
    end
    local pwd = vim.fn.getcwd()
    local settings = save_settings(pwd, { cmd = command, key = key })
    bind_command(settings)
end, {})

vim.api.nvim_create_user_command('RefreshRunner', function()
    bind()
end, {})

vim.api.nvim_create_user_command('ShowRunnerConfig', function()
    show_settings()
end, {})

-- Autocommand
vim.api.nvim_create_autocmd('DirChanged', {
    group = vim.api.nvim_create_augroup('BindRunner', { clear = true }),
    pattern = 'global',
    callback = function ()
        -- log('Directory has changed')
        bind()
    end
})

-- Auto bind on sourcing the file
bind()

return M
