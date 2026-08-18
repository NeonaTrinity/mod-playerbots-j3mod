-- Neona custom PlayerBots chatter expansion
-- Safe patch: no DROP TABLE, no probability changes, no stock-file edits.
-- Re-runnable: skips lines that already exist with the same category/name + text.

START TRANSACTION;

CREATE TEMPORARY TABLE IF NOT EXISTS `neona_ai_playerbot_texts_tmp` (
  `name` varchar(255) NOT NULL,
  `text` varchar(1024) NOT NULL
) ENGINE=Memory DEFAULT CHARSET=utf8;
TRUNCATE TABLE `neona_ai_playerbot_texts_tmp`;
INSERT INTO `neona_ai_playerbot_texts_tmp` (`name`, `text`) VALUES
('broadcast_looting_item_poor', 'Another %item_link. My bags are becoming a museum of disappointment.'),
('broadcast_looting_item_poor', 'I picked up %item_link and immediately questioned my choices.'),
('broadcast_looting_item_poor', '%item_link is going straight to the vendor unless it learns to be useful.'),
('broadcast_looting_item_poor', 'My loot luck has a sense of humor: %item_link.'),
('broadcast_looting_item_poor', 'Found %item_link. The adventure continues, apparently downhill.'),
('broadcast_looting_item_poor', '%item_link again. I am being personally targeted by junk.'),
('broadcast_looting_item_poor', 'I am carrying %item_link because hope is a dangerous thing.'),
('broadcast_looting_item_poor', 'One more %item_link for the pile. The pile is winning.'),
('broadcast_looting_item_poor', 'This %item_link better sell for something.'),
('broadcast_looting_item_poor', 'If %item_link had feelings, I would still vendor it.'),
('broadcast_looting_item_normal', 'Picked up %item_link. Not glamorous, but it counts.'),
('broadcast_looting_item_normal', '%item_link acquired. My bags accept your tribute.'),
('broadcast_looting_item_normal', 'A little %item_link never hurt anybody.'),
('broadcast_looting_item_normal', 'Found %item_link. That should come in handy eventually.'),
('broadcast_looting_item_normal', '%item_link is not exciting, but I will take it.'),
('broadcast_looting_item_normal', 'Another %item_link for the road.'),
('broadcast_looting_item_normal', 'I have %item_link now. That feels like progress.'),
('broadcast_looting_item_normal', '%item_link goes in the bag with everything else I forgot about.'),
('broadcast_looting_item_normal', 'Looted %item_link. Tiny victories matter.'),
('broadcast_looting_item_normal', '%item_link secured. Onward.'),
('broadcast_looting_item_uncommon', 'Oh hello, %item_link. You look useful.'),
('broadcast_looting_item_uncommon', 'Not bad at all, %item_link just dropped.'),
('broadcast_looting_item_uncommon', '%item_link? Finally, something with a little sparkle.'),
('broadcast_looting_item_uncommon', 'I might actually keep %item_link.'),
('broadcast_looting_item_uncommon', 'Nice, %item_link is better than the usual pocket lint.'),
('broadcast_looting_item_uncommon', 'That %item_link was worth stopping for.'),
('broadcast_looting_item_uncommon', '%item_link just made this trip better.'),
('broadcast_looting_item_uncommon', 'I call dibs on admiring %item_link first.'),
('broadcast_looting_item_rare', 'Whoa, %item_link. Now we are talking.'),
('broadcast_looting_item_rare', '%item_link just dropped and suddenly I believe in luck again.'),
('broadcast_looting_item_rare', 'Look at %item_link. The loot gods remembered me.'),
('broadcast_looting_item_rare', 'That %item_link is going to make someone jealous.'),
('broadcast_looting_item_rare', 'I was not expecting %item_link today.'),
('broadcast_looting_item_rare', '%item_link? Okay, this run just got interesting.'),
('broadcast_quest_accepted_generic', 'Picked up %quest_link in %zone_name. Time to earn my boots.'),
('broadcast_quest_accepted_generic', 'Accepted %quest_link. I hope the reward is worth the walking.'),
('broadcast_quest_accepted_generic', '%quest_link is on my list now. No turning back.'),
('broadcast_quest_accepted_generic', 'Just grabbed %quest_link. Let us see where this road goes.'),
('broadcast_quest_accepted_generic', 'Taking %quest_link. If I vanish, blame the quest giver.'),
('broadcast_quest_accepted_generic', 'Accepted %quest_link in %zone_name. Adventure paperwork complete.'),
('broadcast_quest_accepted_generic', '%quest_link acquired. Time to pretend I know where I am going.'),
('broadcast_quest_accepted_generic', 'I have %quest_link now. The map better start making sense.'),
('broadcast_quest_accepted_generic', 'Quest accepted: %quest_link. Bags empty, hopes high.'),
('broadcast_quest_accepted_generic', 'Starting %quest_link. I give it ten minutes before I get distracted.'),
('broadcast_quest_turned_in', 'Turned in %quest_link. That one is finally behind me.'),
('broadcast_quest_turned_in', '%quest_link completed and delivered. Feels good.'),
('broadcast_quest_turned_in', 'Just turned in %quest_link in %zone_name. On to the next mess.'),
('broadcast_quest_turned_in', 'Finished %quest_link. My feet deserve a reward too.'),
('broadcast_quest_turned_in', '%quest_link is done. I am officially slightly more heroic.'),
('broadcast_quest_turned_in', 'Turned in %quest_link. The quest log breathes again.'),
('broadcast_quest_turned_in', 'Another one wrapped up: %quest_link.'),
('broadcast_quest_turned_in', '%quest_link completed. I only got lost twice.'),
('broadcast_quest_turned_in', 'Done with %quest_link. Someone better be impressed.'),
('broadcast_quest_turned_in', 'That is %quest_link turned in. Progress tastes nice.'),
('broadcast_quest_update_complete', 'All objectives done for %quest_link. Time to turn this in.'),
('broadcast_quest_update_complete', '%quest_link is ready to turn in. Finally.'),
('broadcast_quest_update_complete', 'Finished the hard part of %quest_link. Now I just need to find the right person.'),
('broadcast_quest_update_complete', 'Objectives complete for %quest_link. My quest log is cheering.'),
('broadcast_quest_update_complete', '%quest_link is done except for the walking back part.'),
('broadcast_quest_update_add_item_objective_progress', 'Got %quest_obj_available/%quest_obj_required %item_link for %quest_link. Slowly but surely.'),
('broadcast_quest_update_add_item_objective_progress', 'Still need %quest_obj_missing more %item_link for %quest_link.'),
('broadcast_quest_update_add_item_objective_progress', '%item_link progress for %quest_link: %quest_obj_available/%quest_obj_required.'),
('broadcast_quest_update_add_item_objective_progress', 'Another %item_link found for %quest_link. The grind continues.'),
('broadcast_quest_update_add_item_objective_progress', 'Working on %quest_link. %quest_obj_missing more %item_link to go.'),
('broadcast_quest_update_add_kill_objective_progress', '%quest_obj_available/%quest_obj_required down for %quest_link. Keep them coming.'),
('broadcast_quest_update_add_kill_objective_progress', 'Still need %quest_obj_missing more for %quest_link.'),
('broadcast_quest_update_add_kill_objective_progress', 'Making progress on %quest_link. The local wildlife may disagree.'),
('broadcast_quest_update_add_kill_objective_progress', 'Another target down for %quest_link. I am getting there.'),
('broadcast_quest_update_add_kill_objective_progress', '%quest_link progress is moving. Slowly, violently, but moving.'),
('broadcast_levelup_generic', 'Level %my_level! I feel taller somehow.'),
('broadcast_levelup_generic', 'Ding! Level %my_level and still carrying too much junk.'),
('broadcast_levelup_generic', 'Level %my_level reached. Someone tell the mobs.'),
('broadcast_levelup_generic', 'I am level %my_level now. Try to act surprised.'),
('broadcast_levelup_generic', 'Level %my_level! Training time soon.'),
('broadcast_levelup_generic', 'Another level, another reason to keep going.'),
('broadcast_levelup_generic', 'Level %my_level. My spellbook better have something nice.'),
('broadcast_levelup_generic', 'Just hit %my_level. That felt good.'),
('broadcast_killed_normal', '%victim_name is down. Moving on.'),
('broadcast_killed_normal', 'Another %victim_name dealt with in %zone_name.'),
('broadcast_killed_normal', '%victim_name should have stayed out of range.'),
('broadcast_killed_normal', 'That %victim_name did not last long.'),
('broadcast_killed_normal', 'One less %victim_name causing trouble.'),
('broadcast_killed_normal', '%victim_name down. The road is a little safer.'),
('broadcast_killed_normal', 'I almost feel bad for %victim_name. Almost.'),
('broadcast_killed_normal', '%victim_name picked the wrong fight.'),
('broadcast_killed_elite', 'Elite %victim_name is down. That one had teeth.'),
('broadcast_killed_elite', 'Took out %victim_name. Not bad for a hard fight.'),
('broadcast_killed_elite', '%victim_name was elite. Was.'),
('broadcast_killed_elite', 'That %victim_name fight woke me up.'),
('broadcast_killed_elite', 'Elite target handled: %victim_name.'),
('suggest_something', 'Anyone else wandering around %zone_name or is it just me?'),
('suggest_something', '%zone_name feels quiet today.'),
('suggest_something', 'I could use a campfire and a better plan.'),
('suggest_something', 'Anyone know a good vendor around %zone_name?'),
('suggest_something', 'My bags are full and my judgment is poor.'),
('suggest_something', 'I keep saying one more quest and then doing five.'),
('suggest_something', 'Anyone want to group before I make a bad decision?'),
('suggest_something', '%my_role looking for trouble in %zone_name.'),
('suggest_something', 'The road through %zone_name feels longer every time.'),
('suggest_something', 'I swear this map moves when I am not looking.'),
('suggest_something', 'Does anyone else talk to their mount or is that just me?'),
('suggest_something', 'I need a repair, a snack, and maybe a nap.'),
('suggest_something', '%zone_name has character. Most of it is trying to kill me.'),
('suggest_something', 'I came here for adventure and stayed because I got lost.'),
('suggest_something', 'Anyone up for a little chaos in %zone_name?'),
('suggest_something', 'I have no plan, but I do have enthusiasm.'),
('suggest_something', 'Looking for company before I become a cautionary tale.'),
('suggest_something', 'The mailbox knows more about me than my guild does.'),
('suggest_something', 'I should sell junk before the junk becomes my identity.'),
('suggest_something', '%my_race reporting from %zone_name: still alive.'),
('suggest_quest', 'Anyone working on %quest_link?'),
('suggest_quest', 'I could use a hand with %quest_link.'),
('suggest_quest', 'Looking for help on %quest_link if anyone is nearby.'),
('suggest_quest', 'Anyone want to knock out %quest_link together?'),
('suggest_quest', 'Doing %quest_link soon. Company welcome.'),
('suggest_quest', 'Need one or two for %quest_link.'),
('suggest_quest', 'Anyone in %zone_name doing %quest_link?'),
('suggest_quest', '%quest_link looks easier with friends.'),
('suggest_quest', 'I am starting %quest_link if anyone wants in.'),
('suggest_quest', 'Who still needs %quest_link?'),
('wait_travel_close', 'Almost there. Try not to start a war before I arrive.'),
('wait_travel_close', 'Close now. I can practically smell the trouble.'),
('wait_travel_close', 'I am nearby. Save me something to hit.'),
('wait_travel_medium', 'On my way. The road is longer than my patience.'),
('wait_travel_medium', 'Traveling now. If I get distracted, blame the herbs.'),
('wait_travel_medium', 'I am coming. Do not make heroic choices without me.'),
('wait_travel_far', 'That is far, but I am moving.'),
('wait_travel_far', 'On the road. This may take a minute.'),
('wait_travel_far', 'Heading out now. Keep the campfire warm.');

INSERT INTO `ai_playerbot_texts` (`name`, `text`, `say_type`, `reply_type`, `text_loc1`, `text_loc2`, `text_loc3`, `text_loc4`, `text_loc5`, `text_loc6`, `text_loc7`, `text_loc8`)
SELECT t.`name`, t.`text`, 0, 0, '', '', '', '', '', '', '', ''
FROM `neona_ai_playerbot_texts_tmp` t
WHERE NOT EXISTS (
  SELECT 1 FROM `ai_playerbot_texts` a
  WHERE a.`name` = t.`name` AND a.`text` = t.`text`
);

CREATE TEMPORARY TABLE IF NOT EXISTS `neona_playerbots_speech_tmp` (
  `name` varchar(255) NOT NULL,
  `text` varchar(1024) NOT NULL,
  `type` varchar(10) NOT NULL
) ENGINE=Memory DEFAULT CHARSET=utf8;
TRUNCATE TABLE `neona_playerbots_speech_tmp`;
INSERT INTO `neona_playerbots_speech_tmp` (`name`, `text`, `type`) VALUES
('taunt', 'Come on, <target>, I have errands tougher than you!', 'say'),
('taunt', '<target>, you brought claws to a spell fight.', 'say'),
('taunt', 'I have seen kobolds with better footwork, <target>!', 'say'),
('taunt', 'Try harder, <target>. I almost noticed that.', 'say'),
('taunt', '<target>, this is why nobody invites you to groups.', 'say'),
('taunt', 'You picked the wrong traveler today, <target>.', 'say'),
('taunt', 'Hold still, <target>. I am trying to look impressive.', 'say'),
('taunt', '<target>, your strategy appears to be losing loudly.', 'say'),
('taunt', 'I hope you brought friends, <target>.', 'say'),
('taunt', 'Bad news, <target>: I still have cooldowns.', 'say'),
('loot', 'My bags are getting full again.', 'say'),
('loot', 'Loot first, questions later.', 'say'),
('loot', 'I hope this sells for more than pocket lint.', 'say'),
('loot', 'Another thing for the vendor pile.', 'say'),
('loot', 'I am going to need a bigger bag.', 'say'),
('loot', 'That was worth bending down for.', 'say'),
('aoe', 'Stack them up!', 'say'),
('aoe', 'Big pull, big regrets!', 'say'),
('aoe', 'Area spells would be lovely right about now.', 'say'),
('aoe', 'Everything is standing too close together. Convenient.', 'say'),
('aoe', 'Careful, this is about to get messy.', 'say'),
('low health', 'I could use a heal soon!', 'say'),
('low health', 'This is starting to hurt a little too much.', 'say'),
('low health', 'My health is not enjoying this plan!', 'say'),
('low health', 'I am fine. Mostly. Not really.', 'say'),
('low health', 'A heal would be very fashionable right now.', 'say'),
('critical health', 'Very bad, very bad, very bad!', 'say'),
('critical health', 'I am one sneeze from the grave here!', 'say'),
('critical health', 'Emergency healing would be appreciated!', 'say'),
('critical health', 'I am about to become a cautionary tale!', 'say'),
('critical health', 'This is the part where someone saves me!', 'say'),
('low mana', 'Mana is getting low.', 'say'),
('low mana', 'I am running dry here.', 'say'),
('low mana', 'Need a drink after this.', 'say'),
('low mana', 'My mana bar is making threats.', 'say'),
('low mana', 'Almost out of mana, make this count.', 'say');

INSERT INTO `playerbots_speech` (`name`, `text`, `type`)
SELECT t.`name`, t.`text`, t.`type`
FROM `neona_playerbots_speech_tmp` t
WHERE NOT EXISTS (
  SELECT 1 FROM `playerbots_speech` s
  WHERE s.`name` = t.`name` AND s.`text` = t.`text` AND s.`type` = t.`type`
);

COMMIT;

-- Verification queries you can run after applying:
-- SELECT COUNT(*) FROM ai_playerbot_texts WHERE text LIKE '%My bags are becoming a museum%';
-- SELECT COUNT(*) FROM playerbots_speech WHERE text LIKE '%errands tougher than you%';