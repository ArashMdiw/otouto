local utilities = require('otouto.utilities')
local autils = require('otouto.autils')

local P = {}

function P:init(bot)
    self.triggers = utilities.triggers(bot.info.username, bot.config.cmd_pat)
        :t('governor', true):t('gov', true).table
    self.command = 'governor <user>'
    self.doc = 'Set the group\'s governor.'
    self.privilege = 3
    self.administration = true
end

function P:action(bot, msg, group)
    local targets, errors = autils.targets(bot, msg)
    local targets_count = utilities.table_size(targets)
    local output

    if targets_count == 1 then
        local target = next(targets)
        local admin = group.data.admin
        local name = utilities.lookup_name(bot, target)
        autils.promote_admin(msg.chat.id, target, true)

        if target == admin.governor then
            output = name .. ' is already governor.'

        else
            -- Demote the old governor if he's not an admin.
            if autils.rank(bot, admin.governor, msg.chat.id) < 4 then
                autils.demote_admin(msg.chat.id, admin.governor)
            end

            admin.moderators[tostring(target)] = nil
            admin.bans[tostring(target)] = nil
            admin.governor = target
            output = name .. ' is now governor.'
        end

    elseif #errors > 0 then
        output = table.concat(errors, '\n')

    elseif targets_count == 0 then
        output = bot.config.errors.specify_target

    else -- multiple targets
        output = 'Please only specify one new governor.'
    end

    utilities.send_reply(msg, output, 'html')
end

return P