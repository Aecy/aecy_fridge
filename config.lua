Config = Config or {}

Config.KeyInteract = 51 -- [E] https://docs.fivem.net/docs/game-references/controls/
Config.MaximumUsage = 8
Config.DrawMarkerMaxDistance = 5
Config.MaxDistancePutBottleOnTable = 1.0

Config.Tables = {
	vector3(382.4264, -1515.2819, 29.2919),
	vector3(379.2404, -1515.6134, 29.2917),
	vector3(381.4189, -1517.9648, 29.2920),
}

Config.Shops = { -- https://gtahash.ru/?s=bottle
	{
		name = 'LaPicole',
		coords = vector3(380.089, -1509.685, 29.291),
		blip = {
			enabled = true,
			color = 69,
			sprite = 685,
			scale = 0.8,
		},
		items = {
			{ name = 'Tequila', prop = 'prop_tequila_bottle', image = 'images/tequila.png', price = 100, },
			{ name = 'Cognac', prop = 'prop_bottle_cognac', image = 'images/cognac.png', price = 100, },
			{ name = 'Macbeth', prop = 'prop_bottle_macbeth', image = 'images/macbeth.png', price = 100, },
			{ name = 'Vodka', prop = 'prop_vodka_bottle', image = 'images/vodka.png', price = 100, },
			{ name = 'Brandy', prop = 'prop_bottle_brandy', image = 'images/brandy.png', price = 100, },
			{ name = 'Rum', prop = 'prop_rum_bottle', image = 'images/rum.png', price = 100, },
			{ name = 'Whisky', prop = 'prop_whiskey_bottle', image = 'images/whisky.png', price = 100, },
		}
	}
}