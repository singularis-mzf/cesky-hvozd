--[[
    Round Tree Trunks - Turns cubic tree trunks into cylindrical.
	Copyright © 2018, 2020 Hamlet and contributors.

	Licensed under the EUPL, Version 1.2 or – as soon they will be
	approved by the European Commission – subsequent versions of the
	EUPL (the "Licence");
	You may not use this work except in compliance with the Licence.
	You may obtain a copy of the Licence at:

	https://joinup.ec.europa.eu/software/page/eupl
	https://eur-lex.europa.eu/legal-content/EN/TXT/?uri=CELEX:32017D0863

	Unless required by applicable law or agreed to in writing,
	software distributed under the Licence is distributed on an
	"AS IS" basis,
	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
	implied.
	See the Licence for the specific language governing permissions
	and limitations under the Licence.

--]]


--
-- Global procedures to allow third party mod support.
--

round_trunks.trunks_overrider = function(a_s_nodestring)

	-- Constant
	local t_ROUND_TRUNK = {
		drawtype = 'mesh',
		mesh = 'round_trunks_trunk.obj',
		paramtype = 'light',
		paramtype2 = 'facedir',
		selection_box = {
			type = 'fixed',
			fixed = {-0.4, -0.5, -0.4, 0.4, 0.5, 0.4}
		},
		collision_box = {
			type = 'fixed',
			fixed = {-0.4, -0.5, -0.4, 0.4, 0.5, 0.4}
		}
	}

	minetest.override_item(a_s_nodestring, t_ROUND_TRUNK)
end


-- "X" shaped leaves
round_trunks.leaves_overrider = function(a_s_nodestring)

	-- Constant
	local t_ALTERNATIVE_LEAVES = {
		drawtype = 'plantlike',
		visual_scale = 1.0
	}

	minetest.override_item(a_s_nodestring, t_ALTERNATIVE_LEAVES)
end
