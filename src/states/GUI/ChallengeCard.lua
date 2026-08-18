ChallengeCard = class {__includes = BaseState}

function ChallengeCard:init()
    self.priority = 15
    self.isGUI = true
    self.text = 'Earn More than ' .. tostring(WIN_CONDITION_MONEY) .. ' in 1 day.'
end

function ChallengeCard:render()
    local card = UI_CARD

    love.graphics.setColor(card.color)
    love.graphics.rectangle('fill', card.x, card.y, card.width, card.height, 6, 6)

    love.graphics.setColor(card.border)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle('line', card.x, card.y, card.width, card.height, 6, 6)

    love.graphics.setColor(gColors['white'])
    love.graphics.setFont(gFonts['large'])
    love.graphics.printf('Challenge', card.x, card.y + 6, card.width, 'center')
    love.graphics.setColor(gColors['white'])

    local line1Y = card.y + 42
    local labelOffset = 20

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf(self.text, card.x + labelOffset, line1Y, card.width - labelOffset, 'left')
    love.graphics.setColor(0.2, 0.8, 0.2, 1)
    love.graphics.printf('0.00/' .. tostring(WIN_CONDITION_MONEY), card.x, line1Y, card.width - labelOffset, 'right')
end