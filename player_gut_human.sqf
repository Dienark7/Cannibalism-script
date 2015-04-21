private ["_Corpse","_hasHarvested","_knifeArray","_PlayerNear","_activeKnife","_dis","_sfx","_sharpnessRemaining","_text","_string"]; // Private scope for used variables (incase a variable of the same name is used in another sub routine)


hint "placeholder"; // Check if script runs.


// Variables
_Corpse = _this select 3; 															// Corpse selected by selfaction script.
_hasHarvested = _Corpse getVariable["meatHarvested",false];							// Create variable for corpse as "Not gutted".


// Empty array used for counting gutting equipment
_knifeArray = [];

// Remove action to guy corpse. 
player removeAction s_player_guthuman;
s_player_guthuman = -1;


_PlayerNear = {isPlayer _x} count ((getPosATL _Corpse) nearEntities ["CAManBase", 10]) > 1; // Is their another player within 10 meters?
if (_PlayerNear) exitWith {cutText [localize "str_pickup_limit_5", "PLAIN DOWN"]};		  // If so exit script and print "Another player is nearby".


																					// Count usable gutting tools // _X = elements in array DayZ_Gutting
{
	if (_x IN items player) then { 													// if *list of knifes* in players gear then ...
		_knifeArray set [count _knifeArray, _x];									// Count how many items in the players inventory are in DayZ_Gutting and add them to "_KnifeArray".
	};
} count Dayz_Gutting;


// If the amount of usables tools for gutting is less than 1, exit the script. 
// If ((count _knifeArray) < 1) exitwith { cutText [localize "str_cannotgut", "PLAIN DOWN"] };      If the player has none, exit script. Print "Missing Knife to gut animal."
if ((count _knifeArray) < 1) exitwith { cutText ["Missing Knife to gut corpse", "PLAIN DOWN"] }; // Script string changed to support action.


/*---------------//

Now that the variables are set and checks initial checks have been complete, execute the actuall script providing further conditions are met. 

//---------------*/


		if ((count _knifeArray > 0) and !_hasHarvested) then { 						// Last check before script begins.
		Private ["_qty"]; 															// All variables strictly used in this statement can be privitized to this statement.

			_activeKnife = _knifeArray call BIS_fnc_selectRandom; 					// Select random Knife from array, not the most optimal system but for now it will do.

				player playActionNow "Medic"; // Play Gutting Animation 

					_dis=10; 		// Distance the Gutting noise can be heard
					_sfx = "gut";	// Sound effect used alongside animation
					[player,_sfx,0,false,_dis] call dayz_zombieSpeak;				// Used to generate random speach to Zombies within 10 meters.
					[player,_dis,true,(getPosATL player)] call player_alertZombies; // Used to alert Zombies in 10 meters of the player.

					["Working",0,[20,40,15,0]] call dayz_NutritionSystem; 			// Cause the action of "Gutting" to affect the players Hunger/Thirst/Energy.

					_Corpse setVariable ["meatHarvested",true,true];				// Set the variable attached to the corpse as "Harvested" so other players cannot perform the same action.

					_qty = 0; 														// Defualt meat count given opon gutting.

						
						// _activeKnife = Current hunting knife condtion & _qty represents the amount of meat the corpse can drop.
						if (_activeKnife == "ItemKnifeBlunt") then { _qty = 2 }; 	// Blunt will onl yeild 2 peices of meat.
						if (_activeKnife ==     "ItemKnife1") then { _qty = 2 }; 	// 2nd to worse will do the same.
						if (_activeKnife ==     "ItemKnife2") then { _qty = 3 }; 	// So on and so forth...
						if (_activeKnife ==     "ItemKnife3") then { _qty = 3 };
						if (_activeKnife ==     "ItemKnife4") then { _qty = 4 };
						if (_activeKnife ==     "ItemKnife5") then { _qty = 5 };
						if (_activeKnife ==      "ItemKnife") then { _qty = 5 }; 

								for "_i" from 1 to _qty do {          				// Repeat loop to the same value as _qty.
									_Corpse addMagazine "HumanMeatRaw";	  				// Each repeat add a Raw Human steak to the corpse.
								};

									// If the player does not have the achievement for gutting something, reward them it.
									// Maybe potential for a seperate achievement when gutting a human, would certainly be a shame not to.
									if (!achievement_Gut) then {
										achievement_Gut = true;
									};


						_sharpnessRemaining = getText (configFile >> "cfgWeapons" >> _activeKnife >> "sharpnessRemaining"); // Get name of knife after the one being used by the player
							
							switch _activeKnife do { // Switch to decide which action to take depending on the users knife.

								case "ItemKnife" : { // If knife is the default knife...
									
									if ([0.2] call fn_chance) then { 							// Give it a 20% chance of degrading to a lower tier or "become dull".
											player removeWeapon _activeKnife; 					// Remove old knife.
											player addWeapon _sharpnessRemaining;				// Replace with new knife.
	
											systemChat (localize "str_info_bluntknife");		// Tell the player in grey chat that his/her knife is becoming dull.

									};	
								};
												case "ItemKnifeBlunt" : { 						// In the case that the knife is already dull, do nothing.
													//do nothing
												};

													default { 									// If the knife has started becoming dull already, bring it down one tier. 
														player removeWeapon _activeKnife;		// Remove old knife.	
														player addWeapon _sharpnessRemaining;	// Add new dull knife.
													};
							};	

						sleep 6; 																// Sleep 6 seconds to allow the script to process and animation to complete. 
						_text = "Human"; 														// Instead of printing an animal name, say that the corpse is "Human".
						_string = format[localize "str_success_gutted_animal",_text,_qty]; 		// Add strings together to infrom player what he/she gutted, and how much meat it yeilded. 
																								


					closedialog 0;																// Clear text that might be in the way.
					sleep 0.02;																	// Pause script for a fraction of a second. 
					cutText [_string, "PLAIN DOWN"];											// Print "Human has been gutted, X meat steaks now on the carcass",
																								// This could be alterd to have its own localized string but for now this will do.


}; // Script Ends.