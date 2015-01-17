Tanks to Hiino for his awesome translation

#Advanced quest system
This is a script for creating quests, that aims to be parameterizable and flexible. Thanks to _Zangther_, _Hiino_ and _Altor_ for their help. 

###Licensing
*	Free for any use, commercial or otherwise. Ideally, please credit the author, me (Nuki).

###Installing
This script requires installing the [CustomDatabase](https://github.com/nukiFW/RPGMaker/tree/master/CustomDatabase) to work.
Copy the [script](https://github.com/nukiFW/RPGMaker/blob/master/QuestSystem/scriptUK.rb) in your editor on top of Main, in the Materials category. You can assign it to a reserved spot, and name it however you want. I personally chose the name *QuestSystem* (creative! :P).
I advise you to prepare a script page below this one that will be used to insert the quests (I named it *QuestList*).

###Default views screenshots

####Quest log

![Log](https://raw.githubusercontent.com/nukiFW/RPGMaker/master/QuestSystem/journal.png)

####Quest shop

![Shop](https://raw.githubusercontent.com/nukiFW/RPGMaker/master/QuestSystem/shop.png)

###Using the script

####Creating a quest
As said in the Installing chapter, it is recommended to create an empty page under the main script, for adding quests. When I talk about creating quests, I will assume that you use this quests page.

#####Syntax for quest creation
In order to create a quest, you simply need to add this in the quests page:
```ruby
Quest.create(
  :id => QUEST_NUMBER,
  :name => "Quest name", 
  :desc => "Quest description"
)
```
This is the minimal syntax needed to create a quest. However, there exist a lot of additional parameters.

#####Complementary parameters
Additional parameters allow to specialize a quest in order to define its rewards, trigger conditions, or the quest's cost (since we will later see that quests can be bought).
All parameters must be separated by a comma.

######:gold
It is possible to change the amount of Gold the quest gives you once accomplished. For that, just add the option `:gold => AMOUNT_OF_GOLD_EARNED`.

######:exp
A quest can also earn the team experience once finished thanks to the option `:exp => AMOUNT_OF_EXPERIENCE_EARNED`.

**Example of a quest giving out experience and gold**
```ruby
Quest.create(
  :id => 1,
  :name => "Meet Pierre", 
  :desc => "Go talk to Pierre, north of the Village",
  :gold => 200,
  :exp  => 120
)
```

######:items
As with gold and experience it is possible to parameterize a list of items the team will receive when completing the quest: `:items => [List of item IDs separated by commas]`.
######:weapons
As with items it is possible to parameterize a list of weapons the team will receive when completing the quest: `:weapons => [List of weapon IDs separated by commas]`.
######:armors
As with weapons it is possible to parameterize a list of armors the team will receive when completing the quest: `:armors => [List of armor IDs separated by commas]`.

**Example of a quest giving out experience, gold, and items**
```ruby
Quest.create(
  :id => 1,
  :name => "Meet Pierre", 
  :desc => "Go talk to Pierre, north of the Village",
  :gold => 200,
  :exp  => 120,
  :items => [1,1,2],
  :weapons => [2],
  :armors => [3]
)
```
Here is a quest that gives, when completed, 200 Gold, 120 experience points to the whole team, 2 of the item of ID 1, one of the item of ID 2, the weapon of ID 2, and the armor of ID 3.

######:label

Usually, quests are referenced by their `id`. We will see later how to sart quests, or check if a quest is finished, with their ID. However, IDs being numbers, you can assign a label to them, which is a little word helping to differentiate them. Labels are very useful when you have a large collection of quests to handle. Labels are added like this:
`:label => :label_name`. The default label for a quest is `:quest_` followed by its ID, e.g. `:quest_1`.

######:cost

The cost of a quest will intervene when we tackle the subject of quest shops. For a quest to be available in a shop, it must have a cost, which is how much the player will have to pay to start the quest. Cost can be set with `:cost => QUEST_COST`. If a quest doesn't have a cost, it will not be displayable in shops even if it is contained in its stock.

######:repeatable

By default, a quest that was already started (finished or not, as long as it is displayed in the quest log) cannot be started again. On the other hand, a repeatable quest, upon completion, will be removed from the quest log and will be available again. This option is set like this: `:repeatable => true` (Or `false`. However, it is useless to add the option if its value is supposed to be false anyway).

######:need_confirmation

This attribute is a bit peculiar. In fact, it separates the notions of completing a quest and validating it. For example, if a quest is bought in a shop: once finished, the player will automatically receive the rewards. If it must be validated (via the option: `:need_confirmation => true`), the player will have to go back to a shop (that can sell this quest) to validate it. It is also possible to manually validate a quest (via a script call, which we will talk about later).
Adding a need for confirmation to a quest forces the player to return to the start point of the quest to earn his rewards. In the quest log menu, completed and validated quests are distinguished from each other.

####Internal conditions
Internal conditions are elements that make creating a game easier. Indeed, the example I usually give is the following quest, "kill 3 slimes". The problem is that the quest's success condition is extremely hard to code. We will see that it is possible to automatize the success (or the failure) of a quest in some contexts.

######:success_trigger
The option `:success_trigger => condition_for_a_successful_quest` allows to define a success condition for a quest. We will see how to design trigger conditions a tad later.

######:fail_trigger
The option `:fail_trigger => condition_for_a_failed_quest` allows to define a failure condition for a quest.

#####Creating a condition

######var_check(id, value)
This primitive allows to check the value of a variable. For example, the primitive `var_check(5, 10)` will be considered valid if the variable 5 is equal to 10. It is also possible to specify an operator as a third argument:
*    `var_check(5, 10)` => checks if the variable 5 is equal to 10
*    `var_check(5, 10, :>)` => checks if the variable 5 is strictly greater than 10
*    `var_check(5, 10, :<)` => checks if the variable 5 is strictly less than 10
*    `var_check(5, 10, :>=)` => checks if the variable 5 is greater than or equal to 10
*    `var_check(5, 10, :<=)` => checks if the variable 5 is less than or equal to 10
*    `var_check(5, 10, :!=)` => checks if the variable 5 is different from 10

######switch_check(id, :activated | :deactivated)
This primitive allows to check if a switch is activated or not.
*    `switch_check(2, :activated)` => checks if the switch 2 is activated.
*    `switch_check(2, :deactivated)` => checks if the switch 2 is deactivated.

######Item possession conditions
*    `has_item(id, total)` => checks if the player possesses at least a certain amount (defined by `total`) of the item defined by `id`
*    `has_weapon(id, total)` => checks if the player possesses at least a certain amount (defined by `total`) of the weapon defined by `id`
*    `has_armor(id, total)` => checks if the player possesses at least a certain amount (defined by `total`) of the armor defined by `id`

######monster_killed(id, total)
This primitive forces the player to kill a certain amount (defined by `total`) of the monster defined by `id`.

######Boolean operators between primitives
With the previous primitives, it is not possible to represent as a condition, say, the murder of 5 slimes __AND__ the obtention of the weapon 1. In the same way, it is not possible to represent the disjonction "kill 5 slimes __OR__ obtain 5 slime skins". That is why this script is able to link different primitives with each others through logical connectives, that is, `&` to represent AND, and `|` to represent OU.
For example, let's imagine a quest that is accomplished by killing 5 monsters of ID 1 and by obtaining the weapon of ID 1: `:success_trigger => monster_killed(1, 5) & has_weapon(1, 1)`. We could also think of a quest that is completed when the variable 10 is greater than 7 and the switch 10 is activated, or when the team has obtained three weapons of ID 10: `:success_trigger => (var_check(10, 7, :>) & switch_check(10, :activated)) | has_weapon(10, 13)`.
It is possible to compose really refined patterns in order to not have to code, with _events_, every possible branch of a quest. However, it is still possible to manually complete the quests.

**Examples of quests with automatic success triggers**

```ruby
Quest.create(
  :id => 2,
  :name => "The slime and the potion", 
  :desc => "Kill two slimes and find a potion",
  :gold => 100,
  :exp  => 100,
  :success_trigger => monster_killed(1, 2) & has_item(1, 1)
)
```

This quest will be completed once the player kills two slimes and possesses a potion. There is no need to implement the test, and rewards will be automatically attributed. Another example would be:

```ruby
Quest.create(
  :id => 2,
  :name => "The slime and the potion", 
  :desc => "Kill two slimes and find a potion",
  :gold => 100,
  :exp  => 100,
  :success_trigger => monster_killed(1, 2) & has_item(1, 1),
  :fail_trigger => switch_check(3, :activated)
)
```
This one would fail if the switch number 3 is activated.

######Quest availability conditions
It is also possible to set up a condition to trigger the availability (in shops or elsewhere) of quests. For this section, it is best to have some knowledge in Ruby, or to use the Event Extender in order to gain easier access to some functionalities. Here is the option: `:verify => check{starting condition}`. For example, for a quest to be available only if the level of the first hero is greater than 3: `:verify => check{$game_actors[1].level > 3}`. (The operators && and || can be used too, obviously).

######Triggering an action upon finishing a quest
Once a quest is finished (and validated if needed), it is possible to launch an action, via the option: `:end_action => action{List of actions to execute at the end of the quest}` (The action is launched after the end of the quest, so it is possible to know if the quest was finished or not in the actions).

####Using script calls
In this section, all the `id` arguments can be replaced with quest labels.
*    `Quest.start(id)`: Starts the quest referenced by `id` (even if the availability condition isn't respected)
*    `Quest.finished?(id)`: Returns `true` si the quest is finished, `false` otherwise
*    `Quest.succeeded?(id)`: Returns `true` si the quest was successful, `false` otherwise
*    `Quest.failed?(id)`: Returns `true` si the quest was a failure, `false` otherwise
*    `Quest.ongoing?(id)`: Returns `true` si the quest is ongoing, `false` otherwise
*    `Quest.finish(id)`: Finishes the quest successfully
*    `Quest.fail(id)`: Finishes the quest with failure
*    `Quest.need_confirmation?(id)`: Returns `true` si the quest asks for a validation, `false` otherwise
*    `Quest.confirm(id)`: Validates a quest, gives the rewards
*    `Quest.launchable?(id)`: Returns `true` si the quest's availability condition is respected, `false` otherwise
*    `SceneManager.questShop([list_of_quests_to_be_selled])`: Sets up a quest shop, with the list of quests passed as argument as stock.

####Configuring the script
At the beginning of the script, there is a configuration module that allows to change the script's vocabulary and access to the quest log in the menu.

####Quest log and shops
The script has a quest log, based on the items menu (following its visual structure), resembling the native shop systems. I still encourage you to make your own shop/log script, in order to have something more original.


Have fun!