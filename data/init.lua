panel = [[
┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃ $title                                       ┃
┃ $sub_title                                   ┃
┣━━━━━━━━━━━━━━━┳━━━━━━┳━━━━━━━┳━━━━━━━━┳━━━━━━┫
┃ $time         ┃ $s   ┃ $sng  ┃ $f     ┃ $fmt ┃
┗━━━━━━━━━━━━━━━┻━━━━━━┻━━━━━━━┻━━━━━━━━┻━━━━━━┛
]]

function psplit(s)
    parts = {}
    for p in string.gmatch(s, '[^/]+') do
        table.insert(parts, p)
    end
    return parts
end

function contains(list, val)
    for _,v in pairs(list) do
        if v == val then
            return true
        end
    end
    return false
end


function copy(src, dest)
    infile = io.open(src, "r")
    instr = infile:read("*a")
    infile:close()
    print(dest)

    outfile = io.open(dest, "w")
    outfile:write(instr)
    outfile:close()
end

function capitalize(txt)
    res = ''
    s = ''
    for p in string.gmatch(txt, '[^%s]+') do
        res = res .. s .. p:sub(1,1):upper()..p:sub(2)
        s = ' '
    end
    return res
end

function get_composer(meta)
    parts = psplit(meta.filename)
    composer = meta.composer
    if composer == '' then
       if #parts > 3 and contains(parts, 'MODLAND') then
           composer = parts[#parts - 1]
           if composer:find('coop-') == 1 then
               composer = parts[#parts - 2] .. ' & ' .. composer:sub(6)
           end
       else
           composer = '???'
       end
    end
    return composer
end

function render(meta)
    title = meta.fixed_title
    composer = meta.composer

    parts = psplit(meta.filename)

    if composer == '' then
       if #parts > 3 and contains(parts, 'MODLAND') then
           title = capitalize(title)
           composer = parts[#parts - 1]
           if composer:find('coop-') == 1 then
               composer = parts[#parts - 2] .. ' & ' .. composer:sub(6)
           end
       else
           composer = '???'
       end
    end

    title = title .. ' / ' .. composer .. ' (' .. (meta.file_size // 1024) .. 'K)'

    draw('title', title, WHITE)

    draw('sub_title', meta.sub_title, 0xa0a0a0ff)
    draw('fmt', meta.format .. ' ' .. meta.list_length, 0xa0a0ff)
    secs = meta.seconds
    len = meta.length
    if len == 0 then
        draw('time', string.format('%02d:%02d', secs // 60, secs % 60), WHITE)
    else
        draw('time', string.format('%02d:%02d / %02d:%02d',
            secs // 60, secs % 60, len // 60, len % 60), WHITE)
    end
    draw('sng', string.format('%02d/%02d', meta.song + 1, meta.songs), WHITE)
end

function init()
    draw("s", "SONG", YELLOW)
    draw("f", "FORMAT", YELLOW)
end

function ext(filename)
    return filename:match("^.+(%..+)$")
end

map(KEY_F3, function()
    meta = get_meta()
    composer = get_composer(meta)
    copy(meta.filename, "/Users/sasq/mods/" .. composer .. " - " .. meta.fixed_title .. ext(meta.filename))
end)


set_theme({
        stretch_x = 46, 
        panel = panel, -- Scaled and parsed
        init_fn = init,
        render_fn = render -- Function that draws
    })


