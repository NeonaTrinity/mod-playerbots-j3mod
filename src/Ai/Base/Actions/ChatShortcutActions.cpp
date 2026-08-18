/*
 * Copyright (C) 2016+ AzerothCore <www.azerothcore.org>, released under GNU AGPL v3 license, you may redistribute it
 * and/or modify it under version 3 of the License, or (at your option), any later version.
 */

#include "ChatShortcutActions.h"

#include "CharmInfo.h"
#include "Event.h"
#include "Formations.h"
#include "PlayerbotTextMgr.h"
#include "Playerbots.h"
#include "PositionValue.h"
#include "Pet.h"
#include "SpellInfo.h"
#include "SpellMgr.h"

void PositionsResetAction::ResetReturnPosition()
{
    PositionMap& posMap = context->GetValue<PositionMap&>("position")->Get();
    PositionInfo pos = posMap["return"];
    pos.Reset();
    posMap["return"] = pos;
}

void PositionsResetAction::SetReturnPosition(float x, float y, float z)
{
    PositionMap& posMap = context->GetValue<PositionMap&>("position")->Get();
    PositionInfo pos = posMap["return"];
    pos.Set(x, y, z, botAI->GetBot()->GetMapId());
    posMap["return"] = pos;
}

void PositionsResetAction::ResetStayPosition()
{
    PositionMap& posMap = context->GetValue<PositionMap&>("position")->Get();
    PositionInfo pos = posMap["stay"];
    pos.Reset();
    posMap["stay"] = pos;
}

void PositionsResetAction::SetStayPosition(float x, float y, float z)
{
    PositionMap& posMap = context->GetValue<PositionMap&>("position")->Get();
    PositionInfo pos = posMap["stay"];
    pos.Set(x, y, z, botAI->GetBot()->GetMapId());
    posMap["stay"] = pos;
}

bool FollowChatShortcutAction::Execute(Event /*event*/)
{
    Player* master = GetMaster();
    if (!master)
        return false;

    // botAI->Reset();
    botAI->ChangeStrategy("+follow,-passive,-grind,-move from group", BOT_STATE_NON_COMBAT);
    botAI->ChangeStrategy("-stay,-follow,-passive,-grind,-move from group", BOT_STATE_COMBAT);
    botAI->GetAiObjectContext()->GetValue<GuidVector>("prioritized targets")->Reset();

    PositionMap& posMap = context->GetValue<PositionMap&>("position")->Get();
    PositionInfo pos = posMap["return"];
    pos.Reset();
    posMap["return"] = pos;

    pos = posMap["stay"];
    pos.Reset();
    posMap["stay"] = pos;

    if (bot->IsInCombat())
    {
        Formation* formation = AI_VALUE(Formation*, "formation");
        std::string const target = formation->GetTargetName();
        bool moved = false;
        if (!target.empty())
            moved = Follow(AI_VALUE(Unit*, target));
        else
        {
            WorldLocation loc = formation->GetLocation();
            if (Formation::IsNullLocation(loc) || loc.GetMapId() == -1)
                return false;

            MovementPriority priority = botAI->GetState() == BOT_STATE_COMBAT ? MovementPriority::MOVEMENT_COMBAT : MovementPriority::MOVEMENT_NORMAL;
            moved = MoveTo(loc.GetMapId(), loc.GetPositionX(), loc.GetPositionY(), loc.GetPositionZ(), false, false, false,
                        true, priority);
        }

        if (bot->GetPet())
            botAI->PetFollow();

        if (moved)
        {
            botAI->TellMaster(PlayerbotTextMgr::instance().GetBotTextOrDefault(
                "following", "Following", {}));
            return true;
        }
    }

    /* Default mechanics takes care of this now.
    if (bot->GetMapId() != master->GetMapId() || (master && bot->GetDistance(master) >
    sPlayerbotAIConfig.sightDistance))
    {
        if (bot->isDead())
        {
            bot->ResurrectPlayer(1.0f, false);
            botAI->TellMasterNoFacing("Back from the grave!");
        }
        else
            botAI->TellMaster("You are too far away from me! I will there soon.");

        bot->RemoveAurasWithInterruptFlags(AURA_INTERRUPT_FLAG_TELEPORTED | AURA_INTERRUPT_FLAG_CHANGE_MAP);
        bot->TeleportTo(master->GetMapId(), master->GetPositionX(), master->GetPositionY(), master->GetPositionZ(),
    master->GetOrientation()); return true;
    }
    */

    botAI->TellMaster(PlayerbotTextMgr::instance().GetBotTextOrDefault(
        "following", "Following", {}));
    return true;
}

bool StayChatShortcutAction::Execute(Event /*event*/)
{
    Player* master = GetMaster();
    if (!master)
        return false;

    botAI->Reset();
    botAI->ChangeStrategy("+stay,-passive,-move from group", BOT_STATE_NON_COMBAT);
    botAI->ChangeStrategy("+stay,-follow,-passive,-move from group", BOT_STATE_COMBAT);

    SetReturnPosition(bot->GetPositionX(), bot->GetPositionY(), bot->GetPositionZ());
    SetStayPosition(bot->GetPositionX(), bot->GetPositionY(), bot->GetPositionZ());

    botAI->TellMaster(PlayerbotTextMgr::instance().GetBotTextOrDefault(
        "staying", "Staying", {}));
    return true;
}

bool MoveFromGroupChatShortcutAction::Execute(Event /*event*/)
{
    Player* master = GetMaster();
    if (!master)
        return false;

    // dont need to remove stay or follow, move from group takes priority over both
    // (see their isUseful() methods)
    botAI->ChangeStrategy("+move from group", BOT_STATE_NON_COMBAT);
    botAI->ChangeStrategy("+move from group", BOT_STATE_COMBAT);

    botAI->TellMaster(PlayerbotTextMgr::instance().GetBotTextOrDefault(
        "move_from_group", "Moving away from group", {}));
    return true;
}

bool FleeChatShortcutAction::Execute(Event /*event*/)
{
    Player* master = GetMaster();
    if (!master)
        return false;

    botAI->Reset();
    botAI->ChangeStrategy("+follow,-stay,+passive", BOT_STATE_NON_COMBAT);
    botAI->ChangeStrategy("+follow,-stay,+passive", BOT_STATE_COMBAT);

    ResetReturnPosition();
    ResetStayPosition();

    if (bot->GetMapId() != master->GetMapId() || bot->GetDistance(master) > sPlayerbotAIConfig.sightDistance)
    {
        botAI->TellError(PlayerbotTextMgr::instance().GetBotTextOrDefault(
            "fleeing_far", "I will not flee with you - too far away", {}));
        return true;
    }

    botAI->TellMaster(PlayerbotTextMgr::instance().GetBotTextOrDefault(
        "fleeing", "Fleeing", {}));
    return true;
}

bool GoawayChatShortcutAction::Execute(Event /*event*/)
{
    Player* master = GetMaster();
    if (!master)
        return false;

    botAI->Reset();
    botAI->ChangeStrategy("+runaway,-stay", BOT_STATE_NON_COMBAT);
    botAI->ChangeStrategy("+runaway,-stay", BOT_STATE_COMBAT);

    ResetReturnPosition();
    ResetStayPosition();

    botAI->TellMaster(PlayerbotTextMgr::instance().GetBotTextOrDefault(
        "running_away", "Running away", {}));
    return true;
}

bool GrindChatShortcutAction::Execute(Event /*event*/)
{
    Player* master = GetMaster();
    if (!master)
        return false;

    botAI->Reset();
    botAI->ChangeStrategy("+grind,-passive,-stay", BOT_STATE_NON_COMBAT);

    ResetReturnPosition();
    ResetStayPosition();

    botAI->TellMaster(PlayerbotTextMgr::instance().GetBotTextOrDefault(
        "grinding", "Grinding", {}));
    return true;
}

bool TankAttackChatShortcutAction::Execute(Event /*event*/)
{
    Player* master = GetMaster();
    if (!master)
        return false;

    if (!botAI->IsTank(bot))
        return false;

    botAI->Reset();
    botAI->ChangeStrategy("-passive", BOT_STATE_NON_COMBAT);
    botAI->ChangeStrategy("-passive", BOT_STATE_COMBAT);

    ResetReturnPosition();
    ResetStayPosition();

    botAI->TellMaster(PlayerbotTextMgr::instance().GetBotTextOrDefault(
        "attacking", "Attacking", {}));
    return true;
}

bool TakeAggroChatShortcutAction::Execute(Event event)
{
    Player* requester = event.getOwner() ? event.getOwner() : GetMaster();
    if (!requester)
        return false;

    ObjectGuid targetGuid = requester->GetTarget();
    if (!targetGuid)
    {
        botAI->TellError("Select the enemy you want me to take aggro from first.");
        return false;
    }

    Unit* target = botAI->GetUnit(targetGuid);
    if (!target || !target->IsAlive() || bot->IsFriendlyTo(target))
    {
        botAI->TellError("I cannot take aggro from that target.");
        return false;
    }

    // Make the explicit target the bot's combat target as well.
    context->GetValue<Unit*>("current target")->Set(target);
    context->GetValue<GuidVector>("prioritized targets")->Set({targetGuid});

    bool taunted = false;

    // Scoped override: only this immediate command is allowed to taunt a mob off
    // the main tank. Normal AI casts remain protected before and after this block.
    botAI->BeginTakeAggroOverride(target);
    switch (bot->getClass())
    {
        case CLASS_WARRIOR:
            taunted = botAI->CastSpell("taunt", target);
            break;
        case CLASS_PALADIN:
            taunted = botAI->CastSpell("hand of reckoning", target);
            break;
        case CLASS_DEATH_KNIGHT:
            taunted = botAI->CastSpell("dark command", target);
            break;
        case CLASS_DRUID:
            taunted = botAI->CastSpell("growl", target);
            break;
        default:
            break;
    }
    botAI->EndTakeAggroOverride();

    // If the bot itself has no usable taunt, explicitly force one learned pet taunt.
    // PetAI's normal autocast path remains main-tank protected; forced casts are the
    // one-shot escape hatch used by this command.
    if (!taunted)
    {
        if (Pet* pet = bot->GetPet())
        {
            CharmInfo* charmInfo = pet->GetCharmInfo();
            if (charmInfo)
            {
                for (auto const& [spellId, petSpell] : pet->m_spells)
                {
                    (void)petSpell;
                    if (!pet->HasSpell(spellId))
                        continue;

                    SpellInfo const* spellInfo = sSpellMgr->GetSpellInfo(spellId);
                    if (!spellInfo)
                        continue;

                    if (!spellInfo->HasAura(SPELL_AURA_MOD_TAUNT) &&
                        !spellInfo->HasEffect(SPELL_EFFECT_ATTACK_ME))
                        continue;

                    charmInfo->SetForcedSpell(spellId);
                    charmInfo->SetForcedTargetGUID(targetGuid);
                    taunted = true;
                    break;
                }
            }
        }
    }

    if (taunted)
    {
        botAI->TellMasterNoFacing("Taking aggro from " + target->GetName() + ".");
        return true;
    }

    botAI->TellError("I have no usable taunt for that target right now.");
    return false;
}

bool MaxDpsChatShortcutAction::Execute(Event /*event*/)
{
    Player* master = GetMaster();
    if (!master)
        return false;

    if (!botAI->ContainsStrategy(STRATEGY_TYPE_DPS))
        return false;

    botAI->Reset();

    botAI->ChangeStrategy("-threat,-conserve mana,-cast time,+dps debuff,+boost", BOT_STATE_COMBAT);
    botAI->TellMaster("Max DPS!");

    return true;
}

bool NaxxChatShortcutAction::Execute(Event /*event*/)
{
    Player* master = GetMaster();
    if (!master)
        return false;

    botAI->Reset();
    botAI->ChangeStrategy("+naxx", BOT_STATE_NON_COMBAT);
    botAI->ChangeStrategy("+naxx", BOT_STATE_COMBAT);
    botAI->TellMasterNoFacing("Add Naxx Strategies!");
    // bot->Say("Add Naxx Strategies!", LANG_UNIVERSAL);
    return true;
}

bool BwlChatShortcutAction::Execute(Event /*event*/)
{
    Player* master = GetMaster();
    if (!master)
        return false;

    botAI->Reset();
    botAI->ChangeStrategy("+bwl", BOT_STATE_NON_COMBAT);
    botAI->ChangeStrategy("+bwl", BOT_STATE_COMBAT);
    botAI->TellMasterNoFacing("Add Bwl Strategies!");
    return true;
}
