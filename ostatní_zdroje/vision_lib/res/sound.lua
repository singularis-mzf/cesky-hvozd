
visionLib.Sound={}

function visionLib.Sound.Metal()
	return {footstep={name="vlib_metal_footsteps", gain=1.1}, place={name="vlib_plastic_thud", gain=1.3}, dig={name="vlib_solid_hit", gain=0.1}, dug={name="vlib_metal_dug", gain=0.4}}
end

function visionLib.Sound.Glass()
	return {footstep={name="vlib_glass_footsteps", gain=1.1}, place={name="vlib_glass_thud", gain=1.0}, dig={name="vlib_solid_hit", gain=0.1}, dug={name="vlib_glass_dug", gain=1.0}}
end

function visionLib.Sound.Sand()
	return {footstep={name="vlib_sand_footsteps", gain=1.0}, dig={name="vlib_sand_dig", gain=0.7}, place={name="vlib_sand_footsteps", gain=0.2}}
end

function visionLib.Sound.Plastic()
	return {footstep={name="vlib_plastic_thud", gain=1.0}, dig={name="vlib_plastic_dig", gain=0.7}, place={name="vlib_plastic_thud", gain=0.5}, dug={name="vlib_plastic_dug", gain=1.0}}
end

function visionLib.Sound.Slime()
	return {footstep={name="vlib_slime_dig", gain=0.5}, dig={name="vlib_slime_dig", gain=0.7}, place={name="vlib_slime_dig", gain=0.5}, dug={name="vlib_slime_dug", gain=1.0}}
end
