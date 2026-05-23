extends Node

var recipes = [
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
]

func get_current_recipes():
	return recipes

func add_recipe(data: Dictionary):
	recipes.append(data)

func has_recipe(recipe_name: String) -> bool:
	var list = recipes
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
