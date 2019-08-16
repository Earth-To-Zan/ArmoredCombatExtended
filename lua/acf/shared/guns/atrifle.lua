--define the class
ACF_defineGunClass("ATR", {
	spread = 0.05,
	name = "Anti-Tank Rifle",
	desc = "Anti Tank rifles fire stupidly fast small bullets to penetrate light armor. Built to fire HVAP out of these. Using placeholder models ATM. Extremely accurate.",
	muzzleflash = "30mm_muzzleflash_noscale",
	rofmod = 10,
	year = 1917,
	sound = "acf_extra/tankfx/gnomefather/7mm1.wav",
	soundDistance = " ",
	soundNormal = " "
} )

--add a gun to the class
ACF_defineGun("7.92mmATR", { --id
	name = "7.92mm Anti Tank Rifle",
	desc = "The 7.92 Anti Tank Rifle is somone's desperate attempt to fend off hordes of tracked beasts in the trenches",
	model = "models/machinegun/machinegun_762mm.mdl",
	gunclass = "ATR",
	canparent = true,
	caliber = 0.792,
	weight = 15,
	year = 1917,
	rofmod = 1.6,
	magsize = 5,
	magreload = 6,
	round = {
		maxlength = 14,
		propweight = 2.2
	}
} )

ACF_defineGun("14.5mmATR", { --id
	name = "14.5mm Anti Tank Rifle",
	desc = "Commonly used by soviets as a budget way to kill tanks, still worthless.",
	model = "models/machinegun/machinegun_145mm.mdl",
	gunclass = "ATR",
	canparent = true,
	caliber = 1.45,
	weight = 30,
	year = 1917,
	rofmod = 1.4,
	magsize = 5,
	magreload = 8,
	round = {
		maxlength = 21,
		propweight = 3.8
	}
} )

ACF_defineGun("20mmATR", { --id
	name = "20mm Anti Tank Rifle",
	desc = "Collosal anti tank rifle, good for putting a hole through side armor at point blank, that is if you can carry it.",
	model = "models/machinegun/machinegun_20mm.mdl",
	gunclass = "ATR",
	canparent = true,
	caliber = 2.0,
	weight = 45,
	year = 1917,
	rofmod = 0.8,
	magsize = 5,
	magreload = 10,
	round = {
		maxlength = 24,
		propweight = 5.5
	}
} )
