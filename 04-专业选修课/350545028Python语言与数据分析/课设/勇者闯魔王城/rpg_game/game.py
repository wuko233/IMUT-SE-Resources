import os
import random
import sys
# import time

from entities import Player, Mob, Boss


def clear():
    os.system('clear')


def choose(prompt, valid):
    while True:
        try:
            c = input(prompt).strip()
            if c in valid:
                return c
            print("无效输入")
        except (EOFError, KeyboardInterrupt):
            print("退出")
            sys.exit(0)


def pause():
    try:
        input("\n回车继续...")
    except (EOFError, KeyboardInterrupt):
        print("退出")
        sys.exit(0)


# ---------- 地图 ----------
MAP = ["start", "mob", "chest", "mob", "shop", "mob", "boss"]
SYM = {"start": "S", "mob": "M", "chest": "C", "shop": "$", "boss": "B"}


def draw_map(cleared, cur):
    parts = []
    for i, t in enumerate(MAP):
        s = SYM[t]
        parts.append(f"[{s}]" if i == cur else f" {s.lower() if cleared[i] else s} ")
    return " -> ".join(parts)


# ---------- 事件 ----------
def battle(player, kind, rng):
    enemy = Mob(rng) if kind == "mob" else Boss(rng)
    clear()
    print("=== 战斗 ===")
    print(f"{enemy.name} 出现！")
    pause()

    while player.is_alive() and enemy.is_alive():
        clear()
        print(f"{player.name} HP:{player.hp}/{player.max_hp} ATK:{player.atk}")
        print(f"{enemy.name} HP:{enemy.hp}/{enemy.max_hp}")
        print(f"背包: {player.potions} 瓶药水")
        print("1.攻击 2.逃跑 3.喝药水")
        c = choose("选项: ", {"1", "2", "3"})

        if c == "1":
            dmg = player.attack_target(enemy, rng)
            print(f"你造成 {dmg} 伤害")
            if enemy.is_alive():
                edmg = enemy.attack_target(player, rng)
                print(f"敌人造成 {edmg} 伤害")
        elif c == "2":
            if kind == "boss":
                print("魔王使用了禁锢咒，无法逃跑！")
            elif rng.random() < 0.7:
                print("逃跑成功！")
                pause()
                return "fled"
            else:
                print("逃跑失败！")
                edmg = enemy.attack_target(player, rng)
                print(f"敌人造成 {edmg} 伤害")
        elif c == "3":
            ok, h = player.use_potion()
            if ok:
                print(f"恢复 {h} HP")
            else:
                print("没有药水")
                continue
            if enemy.is_alive():
                edmg = enemy.attack_target(player, rng)
                print(f"敌人造成 {edmg} 伤害")
        pause()

    if not player.is_alive():
        return "loss"
    print("击杀！")
    player.gold += enemy.gold_reward
    print(f"获得 {enemy.gold_reward} 金币")
    pause()
    return "win"

def loss(player, rng):
    print(">>> 你在逃跑途中丢失了一些金币...")
    lost = rng.randint(5, 15) if player.gold >= 5 else player.gold
    player.gold -= lost
    print(f"失去 {lost} 金币")
    pause()

def chest(player, rng):
    clear()
    print("=== 宝箱 ===")
    if rng.random() < 0.7:
        g = rng.randint(15, 35)
        player.gold += g
        print(f"获得 {g} 金币")
    else:
        player.potions += 1
        print("获得 1 瓶药水")
    pause()


def shop(player):
    while True:
        clear()
        print("=== 商店 ===")
        print(f"金币:{player.gold} 药水:{player.potions}")
        print("1.药水(20G) 2.离开")
        c = choose("选项: ", {"1", "2"})
        if c == "1":
            if player.gold >= 20:
                player.gold -= 20
                player.potions += 1
                print("购买成功")
            else:
                print("金币不足")
            pause()
        else:
            break


class Game:
    def __init__(self):
        self.player = None
        self.cleared = []
        self.idx = 0
        self.rng = None

    def run(self):
        clear()
        print("勇者闯魔王城")
        print("=" * 20)
        name = input("名字: ").strip() or "勇者"
        self.player = Player(name)
        s = input("种子(回车随机): ").strip()
        self.rng = random.Random(int(s) if s.isdigit() else None)
        self.cleared = [False] * len(MAP)
        self.cleared[0] = True
        self.idx = 0

        clear()
        print("冒险开始")
        print(self.player.status())
        print(draw_map(self.cleared, self.idx))
        pause()

        while self.player.is_alive() and self.idx < len(MAP):
            room = MAP[self.idx]
            if room == "start":
                self.cleared[self.idx] = True
                self.idx += 1
                continue

            clear()
            print(f"第 {self.idx + 1} 层")
            print(self.player.status())
            print(draw_map(self.cleared, self.idx))
            # time.sleep(2)
            pause()

            if room == "mob":
                print(">>> 你感到有个邪恶的东西在看着你...")
                print("一只怪物出现了！")
                pause()
                res = battle(self.player, "mob", self.rng)
                if res == "fled":
                    loss(self.player, self.rng)
            elif room == "boss":
                print(">>> 踏破了千年死寂...")
                print("魔王就在前方！")
                pause()
                res = battle(self.player, "boss", self.rng)
                if res == "fled":
                    pass
            elif room == "chest":
                print(">>> 发现一个宝箱")
                print("打开宝箱...")
                # time.sleep(1)
                pause()
                chest(self.player, self.rng)
            elif room == "shop":
                print(">>> 旅行商人: ")
                print("我曾经也是个勇者，直到我的膝盖中了一箭...")
                pause()
                shop(self.player)

            self.cleared[self.idx] = True
            self.idx += 1

        self.end()

    def end(self):
        clear()
        if not self.player.is_alive():
            print("游戏结束")
            print(f"{self.player.name} 倒在了第 {self.idx + 1} 层")
            print(f"金币: {self.player.gold}")
        else:
            print("胜利！")
            print("你击败了魔王！")
            print(f"剩余 HP: {self.player.hp}/{self.player.max_hp}")
            print(f"金币: {self.player.gold}")
        print("感谢游玩！")
