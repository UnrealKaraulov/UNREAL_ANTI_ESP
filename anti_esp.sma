#include <amxmodx>
#include <reapi>

public plugin_init()
{
	register_plugin("[REAPI] UNREAL ANTI-ESP", "1.6", "Karaulov")
	RegisterHookChain(RH_SV_StartSound, "RH_SV_StartSound_hook",0);
	create_cvar("unreal_no_esp", "1.6", FCVAR_SERVER | FCVAR_SPONLY);
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
	"die2headshot1/535752545155.wav",
	"die2headshot1/555453575755.wav",
	"die2headshot1/565753565655.wav",
	"die2headshot1/575650555448.wav",
	"die2headshot1/495556575349.wav",
	"die2headshot1/485556515557.wav",
	"die2headshot1/485249505057.wav",
	"die2headshot1/494848525353.wav",
	"die2headshot1/495154545050.wav",
	"die2headshot1/525651515253.wav",
	"die2headshot1/575548525649.wav",
	"die2headshot1/565249545552.wav",
	"die2headshot1/545453515353.wav",
	"die2headshot1/485550505650.wav",
	"die2headshot1/525253545757.wav",
	"die2headshot1/545457535152.wav",
	"die2headshot1/565449565448.wav",
	"die2headshot1/515353494853.wav",
	"die2headshot1/544950555155.wav",
	"die2headshot1/515456555752.wav",
	"die2headshot1/545053505749.wav",
	"die2headshot1/524850485257.wav",
	"die2headshot1/524948505651.wav",
	"die2headshot1/555151575756.wav",
	"die2headshot1/545751505054.wav",
	"die2headshot1/534954555052.wav",
	"die2headshot1/524953525448.wav",
	"die2headshot1/505354505150.wav",
	"die2headshot1/544856534854.wav",
	"die2headshot1/485450555348.wav",
	"die2headshot1/565055545351.wav",
	"die2headshot1/515456545555.wav",
	"die2headshot1/565054515451.wav",
	"die2headshot1/495254485350.wav",
	"die2headshot1/564848575454.wav",
	"die2headshot1/495453535452.wav",
	"die2headshot1/515448515754.wav",
	"die2headshot1/514850495555.wav",
	"die2headshot1/485557575349.wav",
	"die2headshot1/525555535652.wav",
	"die2headshot1/505148505249.wav",
	"die2headshot1/495154494848.wav",
	"die2headshot1/505652575552.wav",
	"die2headshot1/575551515756.wav",
	"die2headshot1/545048514857.wav",
	"die2headshot1/555556534853.wav",
	"die2headshot1/534853495751.wav"
}

public plugin_precache()
{
	precache_sound("player/player/pl_step1.wav");
	
	for (new i = 0; i < sizeof(replacedSounds); i++)
	{
		precache_sound(replacedSounds[i]);
	}
}

public PlayBadSound( Float:attenuation, const pitch, ent, const flags, const recipients, const channel )
{
	new Float:fOrig[3];
	get_entvar(ent, var_origin, fOrig);
	fOrig[0] = floatclamp(fOrig[0] + random_float(-200.0,200.0),-8000.0,8000.0);
	fOrig[1] = floatclamp(fOrig[1] + random_float(-200.0,200.0),-8000.0,8000.0);
	fOrig[2] = floatclamp(fOrig[2] + random_float(-30.0,30.0),-8000.0,8000.0);
	
	rh_emit_sound2(ent, 0, channel, "player/player/pl_step1.wav", 1.0, attenuation, flags, pitch, 0, fOrig);
}

public RH_SV_StartSound_hook(const recipients, const entity, const channel, const sample[], const volume, Float:attenuation, const fFlags, const pitch)
{
	for (new i = 0; i < sizeof(replacedSounds); i++)
	{
		if (equal(sample,originalSounds[i]))
		{
			if (random_num(0,500) > 250)
				PlayBadSound(attenuation,pitch,entity,fFlags,recipients,CHAN_BODY);
			SetHookChainArg(4,ATYPE_STRING,replacedSounds[i]);
			SetHookChainArg(6,ATYPE_FLOAT, attenuation * random_float(0.99,0.999));
			break;
		}
	}
	
	if (channel == CHAN_BODY)
		SetHookChainArg(3,ATYPE_INTEGER, CHAN_VOICE);
	else if (channel == CHAN_VOICE)
		SetHookChainArg(3,ATYPE_INTEGER, CHAN_BODY);
		
	return HC_CONTINUE;
}