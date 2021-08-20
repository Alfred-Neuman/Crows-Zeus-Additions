/*/////////////////////////////////////////////////
Author: Crowdedlight
			   
File: fn_spawnSupplyDrop.sqf
Parameters: position ASL and unit clicked
Return: none


*///////////////////////////////////////////////

params ["_groupLeader", "_addAmount", "_ammoList"];

private _airdropPos = [];
// if array we got a pos, otherwise we got aircraft
if (typeName _groupLeader == "ARRAY") then {
	_airdropPos = _groupLeader;
} else {
	// get aircraft
	private _aircraft = vehicle _groupLeader; 
	private _pos = ASLToAGL (getPosASL _aircraft);

	// as we should be over drop-position, we spawn crate 0.5m behind us. 
	_airdropPos = _pos getPos [0.5, (getDir _aircraft) - 180];
	_airdropPos set [2, _pos select 2];
};

// spawn container 
private _container = createVehicle ["C_IDAP_supplyCrate_F", _airdropPos,[],0,"CAN_COLLIDE"];
_container setVelocity [0,0,0];

clearWeaponCargo _container;
clearMagazineCargo _container;
clearItemCargo _container;
clearBackpackCargo _container;

// go through all mags, and add them to container based on zeus amount set multiplied with player count
{
	// add to container 
	_container addMagazineCargoGlobal [_x, _addAmount];
} forEach _ammoList;

private _chute = createvehicle ["i_parachute_02_f", _airdropPos,[],0,"CAN_COLLIDE"]; 
_container attachTo [_chute,[0,0,0.5]];

// attach smoke/chemlight grenade to crate and make it smoke. Spawning function to ensure it keeps smoking and lighting up until at least 5min have passed
private _indicatorSpawn = [_container, 300] spawn {
	params ["_box", "_maxTime"];
	private _startTime = time;

	// blue chemlight ends 
	_supplyLight1 = "Chemlight_blue" createVehicle (position _box);
	_supplyLight1 attachTo [_box, [-0.655,0,0.3]];
	_supplyLight2 = "Chemlight_blue" createVehicle (position _box);
	_supplyLight2 attachTo [_box, [0.655,0,0.3]];

	// blue chemlight sides - rotate object
	_supplyLight3 = "Chemlight_blue" createVehicle (position _box);
	_supplyLight3 attachTo [_box, [0,0.39,0.3]];
	_supplyLight3 setDir 90;

	_supplyLight4 = "Chemlight_blue" createVehicle (position _box);
	_supplyLight4 attachTo [_box, [0,-0.39,0.3]];
	_supplyLight4 setDir 90;

	_supplySmoke = "SmokeShellBlue" createVehicle (position _box);
	_supplySmoke attachTo [_box, [0,0,0]];

	// repeat until time is up
	while {(time - _startTime) <= _maxTime} do {
		// chemlights respawn
		if (isNull _supplyLight1) then {
			_supplyLight1 = "Chemlight_blue" createVehicle (position _box);
			_supplyLight1 attachTo [_box, [-0.655,0,0.3]];
		};
		if (isNull _supplyLight2) then {
			_supplyLight2 = "Chemlight_blue" createVehicle (position _box);
			_supplyLight2 attachTo [_box, [0.655,0,0.3]];
		};
		if (isNull _supplyLight3) then {
			_supplyLight3 = "Chemlight_blue" createVehicle (position _box);
			_supplyLight3 attachTo [_box, [0,0.39,0.3]];
			_supplyLight3 setDir 90;
		};
		if (isNull _supplyLight4) then {
			_supplyLight4 = "Chemlight_blue" createVehicle (position _box);
			_supplyLight4 attachTo [_box, [0,-0.39,0.3]];
			_supplyLight4 setDir 90;
		};

		// smoke respawn
		if (isNull _supplySmoke) then {
			_supplySmoke = "SmokeShellBlue" createVehicle (position _box);
			_supplySmoke attachTo [_box, [0,0,0]];
		};
		// don't need to check more than once per second
		sleep 1;
	};
};

// add container to editable
["zen_common_addObjects", [[_container], objNull]] call CBA_fnc_serverEvent;
