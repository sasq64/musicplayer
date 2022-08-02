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

function render(meta)
    title = meta.fixed_title
    composer = meta.composer

    parts = psplit(meta.filename)

    if composer == '' then
       if #parts > 2 and parts[#parts - 2] == 'MODLAND' then
           composer = parts[#parts - 1]
       else
           composer = '???'
       end
    end

    title = title .. ' / ' .. composer

    draw('title', title, WHITE)

    draw('sub_title', meta.filename, 0xa0a0a0ff)
    draw('fmt', meta.format, 0xa0a0ff)
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

set_theme({
        stretch_x = 46, 
        panel = panel, -- Scaled and parsed
        init_fn = init,
        render_fn = render -- Function that draws
    })


