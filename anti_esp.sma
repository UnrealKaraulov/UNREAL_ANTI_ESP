#include <amxmodx>
#include <fakemeta>
#include <reapi>
#include <engine>
#include <hamsandwich>
#include <xs>

public plugin_init()
{
	register_plugin("[REAPI] UNREAL MINI ANTI-ESP", "1.0.-1", "Karaulov")
	RegisterHookChain(RH_SV_StartSound, "RH_SV_StartSound_hook",0);
}

new originalSounds[][] = 
{
	"player/pl_step1.wav",
	"player/pl_step2.wav",
	"player/pl_step3.wav",
	"player/pl_step4.wav",
	"player/pl_dirt1.wav",
	"player/pl_dirt2.wav",
	"player/pl_dirt3.wav",
	"player/pl_dirt4.wav",
	"player/pl_duct1.wav",
	"player/pl_duct2.wav",
	"player/pl_duct3.wav",
	"player/pl_duct4.wav",
	"player/pl_grate1.wav",
	"player/pl_grate2.wav",
	"player/pl_grate3.wav",
	"player/pl_grate4.wav",
	"player/pl_metal1.wav",
	"player/pl_metal2.wav",
	"player/pl_metal3.wav",
	"player/pl_metal4.wav",
	"player/pl_ladder1.wav",
	"player/pl_ladder2.wav",
	"player/pl_ladder3.wav",
	"player/pl_ladder4.wav",
	"player/pl_slosh1.wav",
	"player/pl_slosh2.wav",
	"player/pl_slosh3.wav",
	"player/pl_slosh4.wav",
	"player/pl_snow1.wav",
	"player/pl_snow2.wav",
	"player/pl_snow3.wav",
	"player/pl_snow4.wav",
	"player/pl_snow5.wav",
	"player/pl_snow6.wav",
	"player/pl_swim1.wav",
	"player/pl_swim2.wav",
	"player/pl_swim3.wav",
	"player/pl_swim4.wav",
	"player/pl_tile1.wav",
	"player/pl_tile2.wav",
	"player/pl_tile3.wav",
	"player/pl_tile4.wav",
	"player/pl_tile5.wav",
	"player/pl_wade1.wav",
	"player/pl_wade2.wav",
	"player/pl_wade3.wav",
	"player/pl_wade4.wav"
}

new replacedSounds[][] = 
{
	"diegovno/00000001.wav",
	"diegovno/00000002.wav",
	"diegovno/00000003.wav",
	"diegovno/00000004.wav",
	
	"diegovno/20000001.wav",
	"diegovno/20000002.wav",
	"diegovno/20000003.wav",
	"diegovno/20000004.wav",
	
	"diegovno/30000001.wav",
	"diegovno/30000002.wav",
	"diegovno/30000003.wav",
	"diegovno/30000004.wav",
	
	"diegovno/40000001.wav",
	"diegovno/40000002.wav",
	"diegovno/40000003.wav",
	"diegovno/40000004.wav",
	
	"diegovno/50000001.wav",
	"diegovno/50000002.wav",
	"diegovno/50000003.wav",
	"diegovno/50000004.wav",
	
	"diegovno/60000001.wav",
	"diegovno/60000002.wav",
	"diegovno/60000003.wav",
	"diegovno/60000004.wav",
	
	"diegovno/70000001.wav",
	"diegovno/70000002.wav",
	"diegovno/70000003.wav",
	"diegovno/70000004.wav",
	
	"diegovno/80000001.wav",
	"diegovno/80000002.wav",
	"diegovno/80000003.wav",
	"diegovno/80000004.wav",
	"diegovno/80000005.wav",
	"diegovno/80000006.wav",
	
	"diegovno/90000001.wav",
	"diegovno/90000002.wav",
	"diegovno/90000003.wav",
	"diegovno/90000004.wav",
	
	"diegovno/11000001.wav",
	"diegovno/11000002.wav",
	"diegovno/11000003.wav",
	"diegovno/11000004.wav",
	"diegovno/11000005.wav",

	"diegovno/12000001.wav",
	"diegovno/12000002.wav",
	"diegovno/12000003.wav",
	"diegovno/12000004.wav"
}

public plugin_precache()
{
	precache_sound("player/pl_step7.wav")
	for (new i = 0; i < 47; i++)
	{
		precache_sound(replacedSounds[i])
	}
	for (new i = 0; i < 47; i++)
	{
		precache_sound(originalSounds[i])
	}
}

public PlayBadSound( Float:attenuation, const pitch, ent, const flags, const recipients, const channel )
{
	new Float:orig[3]
	entity_get_vector(ent, EV_VEC_origin, orig);
	
	new Float:rnd = random_float(250.0,1000.0)
	orig[0] += rnd
	orig[1] += rnd
	if (orig[0] > 8000.0)
	{
		orig[0] = 8000.0
	}
	if (orig[1] > 8000.0)
	{
		orig[1] = 8000.0
	}
	if (orig[2] > 8000.0)
	{
		orig[2] = 8000.0
	}
	rh_emit_sound2(ent, 0, channel, "player/pl_step7.wav", 1.0, attenuation, flags, pitch, 0, orig)
}

public RH_SV_StartSound_hook(const recipients, const entity, const channel, const sample[], const volume, Float:attenuation, const fFlags, const pitch)
{
	for (new i = 0; i < sizeof(replacedSounds); i++)
	{
		if (equal(sample,originalSounds[i]))
		{
			PlayBadSound(attenuation,pitch,entity,fFlags,recipients,CHAN_VOICE)
			SetHookChainArg(4,ATYPE_STRING,replacedSounds[i])
			SetHookChainArg(6,ATYPE_FLOAT, attenuation * 0.99)
			break;
		}
	}
	return HC_CONTINUE;
}