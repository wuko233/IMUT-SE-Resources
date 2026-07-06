"""
游戏实体
"""
import random


class Entity:
    def __init__(self, name, hp, atk):
        self.name = name
        self.max_hp = hp
        self.hp = hp
        self.atk = atk

    def is_alive(self):
        return self.hp > 0

    def take_damage(self, damage):
        actual = max(1, damage)
        self.hp = max(0, self.hp - actual)
        return actual

    def heal(self, amount):
        self.hp = min(self.max_hp, self.hp + amount)

    def attack_target(self, target, rng=None):
        if rng is None:
            dmg = max(1, self.atk + random.randint(-2, 2))
        else:
            dmg = max(1, self.atk + rng.randint(-2, 2))
        return target.take_damage(dmg)


class Player(Entity):
    def __init__(self, name):
        super().__init__(name, hp=100, atk=15)
        self.gold = 0
        self.potions = 2

    def use_potion(self):
        if self.potions > 0:
            self.potions -= 1
            old = self.hp
            self.heal(40)
            return True, self.hp - old
        return False, 0

    def buy_potion(self):
        if self.gold >= 20:
            self.gold -= 20
            self.potions += 1
            return True
        return False

    def status(self):
        return f"{self.name} HP:{self.hp}/{self.max_hp} ATK:{self.atk} 金币:{self.gold} 药水:{self.potions}"


class Mob(Entity):
    def __init__(self, rng):
        names = ["史莱姆", "哥布林", "蝙蝠", "毛玉", "骷髅兵"]
        name = rng.choice(names)
        hp = rng.randint(25, 40)
        atk = rng.randint(6, 12)
        super().__init__(name, hp, atk)
        self.gold_reward = rng.randint(10, 20)


class Boss(Entity):
    def __init__(self, rng):
        super().__init__("魔王·玛欧", rng.randint(80, 120), rng.randint(15, 25))
        self.gold_reward = 200
