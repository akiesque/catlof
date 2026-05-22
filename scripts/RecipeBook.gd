extends Node

enum Type { COOKING, CRAFTING }
var current_mode = Type.COOKING

var cooking_recipes = [
	{
		"name": "Bloodberry Smoothie",
		"description": 
			"A smoothie you've never seen before.",
		"ingredients": [
			{
				"name": "Bloodberry",
				"quantity": 2,
				"icon": "res://assets/bag/ingredients/bloodberries.png"
				}
			],
		"icon": "res://assets/bag/special/bloodberry_drink.png"
	},
	{
		"name": "Bloodberry Smoothie",
		"description": 
			"A smoothie you've never seen before.",
		"result_path": "res://assets/bag/special/Bloodberry_Smoothie.tres",
		"ingredients": [
			{
				"name": "Bloodberry",
				"quantity": 2,
				"icon": "res://assets/bag/ingredients/bloodberries.png"
				}
			],
		"icon": "res://assets/bag/special/bloodberry_drink.png"
	},
	{
		"name": "Bloodberry Smoothie",
		"description": 
			"A smoothie you've never seen before.",
		"ingredients": [
			{
				"name": "Bloodberry",
				"quantity": 2,
				"icon": "res://assets/bag/ingredients/bloodberries.png"
				}
			],
		"icon": "res://assets/bag/special/bloodberry_drink.png"
	},
	
]

var crafting_recipes = [
	{
		"name": "Bracelet",
		"ingredients": [
			{
				"name": "Bloodberry",
				"quantity": 2,
				"icon": "res://assets/pickables/pickup_bloodberry.png"
				},
			{
				"name": "Bloodberry",
				"quantity": 2,
				"icon": "res://assets/pickables/pickup_bloodberry.png"
				}
			],
		"icon": ""
			},
			{
		"name": "Bracelet",
		"ingredients": [
			{
				"name": "Bloodberry",
				"quantity": 2,
				"icon": "res://assets/pickables/pickup_bloodberry.png"
				},
			{
				"name": "Bloodberry",
				"quantity": 2,
				"icon": "res://assets/pickables/pickup_bloodberry.png"
				}
			],
		"icon": ""
			},
		]

func get_current_recipes():
	return cooking_recipes if current_mode == Type.COOKING else crafting_recipes

func add_recipe(type: Type, data: Dictionary):
	if type == Type.COOKING:
		cooking_recipes.append(data)
	else:
		crafting_recipes.append(data)

func has_recipe(type: Type, recipe_name: String) -> bool:
	var list = cooking_recipes if type == Type.COOKING else crafting_recipes
	return list.any(func(r): return r["name"] == recipe_name)
	
#Usage: 
#RecipeBook.add_recipe(RecipeBook.Type.COOKING, {
	#"name": "Healing Stew",
	#"ingredients": ["Herb", "Water"],
	#"icon": "res://assets/bag/special/healing_stew.png"
#})
#
## Switch to crafting mode
#RecipeBook.current_mode = RecipeBook.Type.CRAFTING
#
## Check before adding to avoid duplicates
#if not RecipeBook.has_recipe(RecipeBook.Type.COOKING, "Healing Stew"):
	#RecipeBook.add_recipe(RecipeBook.Type.COOKING, {...})
