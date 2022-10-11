Config = {} 
Config.NotificationType = {
	client = 'col_notify_new',
	server = 'col_notify_new'
}

-- CAR CONFIG --
Config.Gangs = {
    ['gang1'] = {
		Vehicles = {
			{
				Spawner = vec3(0.0, 0.0,0.0),
				InsideShop = vec3(0.0, 0.0,0.0),
				SpawnPoints = {
					{coords = vec3(0.0, 0.0,0.0), heading = 150.74, radius = 10.0}
					
				}
			},
		},
    },
	['gang2'] = {
		Vehicles = {
			{
				Spawner = vec3(0.0, 0.0,0.0),
				InsideShop = vec3(0.0, 0.0,0.0),
				SpawnPoints = {
					{coords = vec3(0.0, 0.0,0.0), heading = 229.74, radius = 6.0}
					
				}
			},
		},
    },
	['gang3'] = {
		Vehicles = {
			{
				Spawner = vec3(0.0, 0.0,0.0),
				InsideShop = vec3(0.0, 0.0,0.0),
				SpawnPoints = {
					{coords = vec3(0.0, 0.0,0.0), heading = 229.74, radius = 6.0}
					
				}
			},
		},
    },
	['gang4'] = {
		Vehicles = {
			{
				Spawner = vec3(0.0, 0.0,0.0),
				InsideShop = vec3(0.0, 0.0,0.0),
				SpawnPoints = {
					{coords = vec3(0.0, 0.0,0.0), heading = 229.74, radius = 6.0}
					
				}
			},
		},
    },

	['gang5'] = {
		Vehicles = {
			{
				Spawner = vec3(0.0, 0.0,0.0),
				InsideShop = vec3(0.0, 0.0,0.0),
				SpawnPoints = {
					{coords = vec3(0.0, 0.0,0.0), heading = 229.74, radius = 6.0}
					
				}
			},
		},
    }
}

-- GANG CAR VEHICLES --
Config.AuthorizedGangVehicles = {
    ['gang1'] = {
        g1 = {
            {model = `kuruma`, price = 30000}
        },
		g2 = {
			{model = `kuruma`, price = 30000}
		},
		g3 = {
            {model = `kuruma`, price = 30000}
		},
		g4 = {
			{model = `kuruma`, price = 30000}
		},
		boss = {
            {model = `kuruma`, price = 30000}
        }
    },
	['gang2'] = {
        g1 = {
            {model = `kuruma`, price = 30000}
        },
		g2 = {
			{model = `kuruma`, price = 30000}
		},
		g3 = {
            {model = `kuruma`, price = 30000}
		},
		g4 = {
			{model = `kuruma`, price = 30000}
		},
		boss = {
            {model = `kuruma`, price = 30000}
        }
    },
	['gang3'] = {
		g1 = {
            {model = `kuruma`, price = 30000}
        },
		g2 = {
			{model = `kuruma`, price = 30000}
		},
		g3 = {
            {model = `kuruma`, price = 30000}
		},
		g4 = {
			{model = `kuruma`, price = 30000}
		},
		boss = {
            {model = `kuruma`, price = 30000}
        }
    },
	['gang4'] = {
        g1 = {
            {model = `kuruma`, price = 30000}
        },
		g2 = {
			{model = `kuruma`, price = 30000}
		},
		g3 = {
            {model = `kuruma`, price = 30000}
		},
		g4 = {
			{model = `kuruma`, price = 30000}
		},
		boss = {
            {model = `kuruma`, price = 30000}
        }
    },
	['gang5'] = {
		g1 = {
            {model = `kuruma`, price = 30000}
        },
		g2 = {
			{model = `kuruma`, price = 30000}
		},
		g3 = {
            {model = `kuruma`, price = 30000}
		},
		g4 = {
			{model = `kuruma`, price = 30000}
		},
		boss = {
            {model = `kuruma`, price = 30000}
        }
    }
}

-- BOSS ACTION --
Config.GangBossActions = {
	[1] = {Job = 'gang1', SocietyFunds = 'society_gang1', BossActionLocation = vec3(0.0, 0.0,0.0), JobLabel = 'Gang 1'},
	[2] = {Job = 'gang2', SocietyFunds = 'society_gang2', BossActionLocation = vec3(0.0,0.0,0.0), JobLabel = 'Gang 2'},
	[3] = {Job = 'gang3', SocietyFunds = 'society_gang3', BossActionLocation = vec3(0.0,0.0,0.0), JobLabel = 'Gang 3'},
	[4] = {Job = 'gang4', SocietyFunds = 'society_gang4', BossActionLocation = vec3(0.0,0.0,0.0), JobLabel = 'Gang 4'},
	[5] = {Job = 'gang5', SocietyFunds = 'society_gang5', BossActionLocation = vec3(0.0,0.0,0.0), JobLabel = 'Gang 5'}
}

-- STASH CONFIG --
Config.StashZoneLocation = {
	[1] = {text = '[~b~E~w~] Gang 1 Primary Stash', pos = vec3(0.0, 0.0,0.0), targetstash = 'gang1_stash_primary', setjob = 'gang1', AuthorizeRanks = {'all'}},
	[2] = {text = '[~b~E~w~] Gang 2 Primary Stash', pos = vec3(0.0,0.0,0.0), targetstash = 'gang2_stash_primary', setjob = 'gang2', AuthorizeRanks = {'all'}},
	[3] = {text = '[~b~E~w~] Gang 3 Primary Stash', pos = vec3(0.0,0.0,0.0), targetstash = 'gang3_stash_primary', setjob = 'gang3', AuthorizeRanks = {'all'}},
	[4] = {text = '[~b~E~w~] Gang 4 Primary Stash', pos = vec3(0.0,0.0,0.0), targetstash = 'gang4_stash_primary', setjob = 'gang4', AuthorizeRanks = {'all'}},
	[5] = {text = '[~b~E~w~] Gang 5 Primary Stash', pos = vec3(0.0,0.0,0.0), targetstash = 'gang5_stash_primary', setjob = 'gang5', AuthorizeRanks = {'all'}},

	[6] = {text = '[~b~E~w~] Gang 1 Secondary Stash', pos = vec3(0.0, 0.0,0.0), targetstash = 'gang1_stash_secondary', setjob = 'gang1', AuthorizeRanks = {'all'}},
	[7] = {text = '[~b~E~w~] Gang 2 Secondary Stash', pos = vec3(0.0,0.0,0.0), targetstash = 'gang2_stash_secondary', setjob = 'gang2', AuthorizeRanks = {'all'}},
	[8] = {text = '[~b~E~w~] Gang 3 Secondary Stash', pos = vec3(0.0,0.0,0.0), targetstash = 'gang3_stash_secondary', setjob = 'gang3', AuthorizeRanks = {'all'}},
	[9] = {text = '[~b~E~w~] Gang 4 Secondary Stash', pos = vec3(0.0,0.0,0.0), targetstash = 'gang4_stash_secondary', setjob = 'gang4', AuthorizeRanks = {'all'}},
	[10] = {text = '[~b~E~w~] Gang 5 Secondary Stash', pos = vec3(0.0,0.0,0.0), targetstash = 'gang5_stash_secondary', setjob = 'gang5', AuthorizeRanks = {'all'}},

	[11] = {text = '[~b~E~w~] Gang 1 Boss Stash', pos = vec3(0.0, 0.0,0.0), targetstash = 'gang1_stash_boss', setjob = 'gang1', AuthorizeRanks = {'boss'}},
	[12] = {text = '[~b~E~w~] Gang 2 Boss Stash', pos = vec3(0.0,0.0,0.0), targetstash = 'gang2_stash_boss', setjob = 'gang2', AuthorizeRanks = {'boss'}},
	[13] = {text = '[~b~E~w~] Gang 3 Boss Stash', pos = vec3(0.0,0.0,0.0), targetstash = 'gang3_stash_boss', setjob = 'gang3', AuthorizeRanks = {'boss'}},
	[14] = {text = '[~b~E~w~] Gang 4 Boss Stash', pos = vec3(0.0,0.0,0.0), targetstash = 'gang4_stash_boss', setjob = 'gang4', AuthorizeRanks = {'boss'}},
	[15] = {text = '[~b~E~w~] Gang 5 Boss Stash', pos = vec3(0.0,0.0,0.0), targetstash = 'gang5_stash_boss', setjob = 'gang5', AuthorizeRanks = {'boss'}}
}

-- STASH DATA CONFIG --
Config.Stashes = {
	{id = 'gang1_stash_primary', label = 'Gang 1 Primary Stash', slots = 1000, weight = 1000000, owner = false, jobs = 'gang1'},
	{id = 'gang2_stash_primary',label = 'Gang 2 Primary Stash',slots = 1000, weight = 1000000, owner = false, jobs = 'gang2'},
	{id = 'gang3_stash_primary', label = 'Gang 3 Primary Stash', slots = 1000, weight = 1000000, owner = false, jobs = 'gang3' },
	{id = 'gang4_stash_primary', label = 'Gang 4 Primary Stash', slots = 1000, weight = 1000000, owner = false, jobs = 'gang4'},
	{id = 'gang5_stash_primary', label = 'Gang 5 Primary Stash', slots = 1000, weight = 1000000, owner = false, jobs = 'gang5'},

	{id = 'gang1_stash_secondary', label = 'Gang 1 Secondary Stash', slots = 1000, weight = 1000000, owner = false, jobs = 'gang1'},
	{id = 'gang2_stash_secondary',label = 'Gang 2 Secondary Stash',slots = 1000, weight = 1000000, owner = false, jobs = 'gang2'},
	{id = 'gang3_stash_secondary', label = 'Gang 3 Secondary Stash', slots = 1000, weight = 1000000, owner = false, jobs = 'gang3' },
	{id = 'gang4_stash_secondary', label = 'Gang 4 Secondary Stash', slots = 1000, weight = 1000000, owner = false, jobs = 'gang4'},
	{id = 'gang5_stash_secondary', label = 'Gang 5 Secondary Stash', slots = 1000, weight = 1000000, owner = false, jobs = 'gang5'},

	{id = 'gang1_stash_boss', label = 'Gang 1 Boss Stash', slots = 1000, weight = 10000000, owner = false, jobs = 'gang1'},
	{id = 'gang2_stash_boss',label = 'Gang 2 Boss Stash',slots = 1000, weight = 10000000, owner = false, jobs = 'gang2'},
	{id = 'gang3_stash_boss', label = 'Gang 3 Boss Stash', slots = 1000, weight = 10000000, owner = false, jobs = 'gang3' },
	{id = 'gang4_stash_boss', label = 'Gang 4 Boss Stash', slots = 1000, weight = 10000000, owner = false, jobs = 'gang4'},
	{id = 'gang5_stash_boss', label = 'Gang 5 Boss Stash', slots = 1000, weight = 10000000, owner = false, jobs = 'gang5'},
	
}

-- GANG TASKS --
Config.GangTaskMinReward = 2000
Config.GangTaskMaxReward = 4000

Config.GangTasks = {
	['gang1'] = {
		menuPos = vec3(0.0, 0.0,0.0),
		AuthorizeRanks = {
			'boss'
		} 
	},
	['gang2'] = {
		menuPos = vec3(0.0, 0.0, 0.0),
		AuthorizeRanks = {
			'boss'
		}
	},
	['gang3'] = {
		menuPos = vec3(0.0, 0.0, 0.0),
		AuthorizeRanks = {
			'boss'
		}
	},
	['gang4'] = {
		menuPos = vec3(0.0, 0.0, 0.0),
		AuthorizeRanks = {
			'boss'
		}
	},
	['gang5'] = {
		menuPos = vec3(0.0, 0.0, 0.0),
		AuthorizeRanks = {
			'boss'
		}
	},
}
Config.TaskZones = {
	{ GangName = "gang1", taskspawn = vec3(-1530.1637, 88.2576, 56.6751), taskheading = 270.5784 },
	{ GangName = "gang2", taskspawn = vec3(87.06, -1969.65, 20.75), taskheading = 320.97 },
	{ GangName = "gang3", taskspawn = vec3(27.44, -1452.97, 30.14), taskheading = 315.88 },
	{ GangName = "gang4", taskspawn = vec3(11.87, 547.35, 175.94), taskheading = 83.27 },
	{ GangName = "gang5", taskspawn = vec3(-225.86, -1700.24, 34.01), taskheading = 275.00 }
}

Config.TaskDeliveryPoints = {
	{ x = 845.25, y = 2195.61, z = 52.06 },
	{ x = 1546.05, y = 2166.52, z = 78.73 },
	{ x = 341.36, y = 2615.56, z = 44.67 },
	{ x = 247.03, y = 3169.43, z = 42.80 },
	{ x = 189.91, y = 3094.13, z = 43.07 },
	{ x = 1934.42, y = 3724.17, z = 32.81 },
	{ x = 1394.70, y = 3598.45, z = 34.99 },
	{ x = 2553.93, y = 4668.73, z = 33.98 },
	{ x = 3323.18, y = 5167.66, z = 18.41 },
	{ x = 1730.36, y = 6409.55, z = 35.00 },
	{ x = 161.29, y = 6635.62, z = 31.59 },
	{ x = -2194.27, y = 4290.31, z = 49.17 },
	{ x = -3156.66, y = 1094.75, z = 20.85 }
}