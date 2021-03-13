extends Resource

var _attrs := {
	"chort": {
		"health": 2,
		"attack": 0.5,
	},
	"goblin": {
		"health": 1,
		"attack": 0.5,
	},
	"ice_zombie": {
		"health": 2,
		"attack": 2,
	},
	"imp": {
		"health": 1,
		"attack": 0.5,
	},
	"knight": {
		"health": 3,
		"attack": 1,
	},
	"lizard": {
		"health": 2,
		"attack": 1,
	},
	"muddy": {
		"health": 2,
		"attack": 1,
	},
	"mushroom": {
		"health": 2,
		"attack": 1,
	},
	"necromancer": {
		"health": 2,
		"attack": 1,
	},
	"ogre": {
		"health": 2,
		"attack": 1,
	},
	"orc_masked": {
		"health": 2,
		"attack": 1,
	},
	"orc_shaman": {
		"health": 5,
		"attack": 3,
	},
	"orc_warrior": {
		"health": 4,
		"attack": 2,
	},
	"skeleton": {
		"health": 3,
		"attack": 2,
	},
	"swampy": {
		"health": 2,
		"attack": 1,
	},
	"wizard": {
		"health": 8,
		"attack": 4,
	},
	"zombie": {
		"health": 2,
		"attack": 1,
	},
}

func get(enemy_name: String) -> Dictionary:
	return _attrs.get(enemy_name, {})
