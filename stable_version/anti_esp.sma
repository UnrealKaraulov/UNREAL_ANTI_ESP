#include <amxmodx>
#include <reapi>

#include <fakemeta>

new g_sPLUGIN_NAME[] = "UNREAL ANTI-ESP";
new g_sPLUGIN_VERSION[] = "2.7";
new g_sPLUGIN_AUTHOR[] = "Karaulov";

new g_sFakePath[] = "player/pl_step1/pl_step1.wav";

new bool:g_bPlayerConnected[MAX_PLAYERS + 1] = {false,...};
new g_iFakeEnt = 0;
new g_iEnts[MAX_PLAYERS + 1] = {0,...};

new Float:g_fFakeTime = 0.0;

new Float:g_fEntTouchTime[MAX_PLAYERS + 1] = {0.0,...};

public plugin_init()
{
	register_plugin(g_sPLUGIN_NAME, g_sPLUGIN_VERSION, g_sPLUGIN_AUTHOR);
	create_cvar("unreal_no_esp", g_sPLUGIN_VERSION, FCVAR_SERVER | FCVAR_SPONLY);
	
	g_iFakeEnt = rg_create_entity("info_target");
	if (!g_iFakeEnt)
	{
		set_fail_state("Can't create fake entity");
		return;
	}
	
	RegisterHookChain(RH_SV_StartSound, "RH_SV_StartSound_hook",0);
}

public client_putinserver(id)
{
	g_bPlayerConnected[id] = true;
}

public client_disconnected(id)
{
	g_bPlayerConnected[id] = false;
}

new precached_sounds[256] = {0,...};

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

public PrecacheSound(const szSound[])
{
	for(new i = 0; i < sizeof(originalSounds); i++)
	{
		if( equali(szSound,originalSounds[i]) )
		{
			if (precached_sounds[i] == 0)
			{
				set_fail_state("No sound/%s found!", replacedSounds[i]);
				return FMRES_IGNORED;
			}
			forward_return(FMV_CELL, precached_sounds[i]);
			return FMRES_SUPERCEDE;
		}
	}

	return FMRES_IGNORED;
}

public plugin_precache()
{
	if (!sound_exists(g_sFakePath))
	{
		set_fail_state("No sound/%s found!",g_sFakePath);
		return;
	}
	
	precache_sound(g_sFakePath);
	
	for(new i = 0; i < sizeof(replacedSounds);i++)
	{
		if (!sound_exists(replacedSounds[i]))
		{
			set_fail_state("No sound/%s found!", replacedSounds[i]);
			return;
		}
		precached_sounds[i] = precache_sound(replacedSounds[i]);
	}
	
	register_forward(FM_PrecacheSound, "PrecacheSound");
}

public bool:sound_exists(path[])
{
	new fullpath[256];
	formatex(fullpath,charsmax(fullpath),"sound/%s",path)
	return file_exists(fullpath,true) > 0;
}

rg_emit_sound_exept_me(const entity, const recipient, const channel, const sample[], Float:vol = VOL_NORM, Float:attn = ATTN_NORM, const flags = 0, const pitch = PITCH_NORM, emitFlags = 0, const Float:origin[3] = {0.0,0.0,0.0})
{
	for(new i = 1; i < MAX_PLAYERS + 1; i++)
	{
		if (g_bPlayerConnected[i] && i != recipient)
		{
			rh_emit_sound2(entity, i, channel, sample, vol, attn, flags, pitch, emitFlags, origin);
		}
	}
}

rg_emit_sound_all(const entity, const channel, const sample[], Float:vol = VOL_NORM, Float:attn = ATTN_NORM, const flags = 0, const pitch = PITCH_NORM, emitFlags = 0, const Float:origin[3] = {0.0,0.0,0.0})
{
	for(new i = 1; i < MAX_PLAYERS + 1; i++)
	{
		if (g_bPlayerConnected[i])
		{
			rh_emit_sound2(entity, i, channel, sample, vol, attn, flags, pitch, emitFlags, origin);
		}
	}
}

emit_fake_sound(Float:origin[3], Float:volume, Float:attenuation, const fFlags, const pitch)
{
	for(new i = 1; i < MAX_PLAYERS + 1; i++)
	{
		if (!g_iEnts[i])
			continue;
		if (get_gametime() - g_fEntTouchTime[i] > 0.5)
		{
			g_fEntTouchTime[i] = get_gametime();
			set_entvar(g_iEnts[i],var_origin,origin);
			rh_emit_sound2(g_iEnts[i], 0, CHAN_AUTO, g_sFakePath, volume, attenuation, fFlags, pitch, 0, origin);
			break;
		}
	}
}

public RH_SV_StartSound_hook(const recipients, const entity, const channel, const sample[], const volume, Float:attenuation, const fFlags, const pitch)
{
	new Float:fOrigin[3];
	new snd = 0;
	new bool:foundSnd = false;
	
	for (snd = 0; snd < sizeof(replacedSounds); snd++)
	{
		if (equal(sample,originalSounds[snd]))
		{	
			SetHookChainArg(4,ATYPE_STRING,replacedSounds[snd])
			
			if (entity > MAX_PLAYERS || entity < 1)
			{
				break;
			}
			
			foundSnd = true;
			
			if (!g_iEnts[entity])
			{
				break;
			}
			
			g_fEntTouchTime[entity] = get_gametime();
			
			get_entvar(entity, var_origin, fOrigin); 
			fOrigin[2] += 1.1;
			set_entvar(g_iEnts[entity],var_origin,fOrigin);
			
			break;
		}
	}
	
	if (!foundSnd)
		return HC_CONTINUE;
	
	if (!g_iEnts[entity])
	{
		g_iEnts[entity] = rg_create_entity( "info_target" );
		set_entvar(g_iEnts[entity],var_effects,EF_NODRAW);
		if (!g_iEnts[entity])
		{
			set_fail_state("Can't create fake player entity!");
			return HC_CONTINUE;
		}
	}
	
	if(recipients == 0)
		rg_emit_sound_all(g_iEnts[entity], CHAN_AUTO, replacedSounds[snd], float(volume) / 255.0, attenuation, fFlags, pitch, 0, fOrigin);
	else 
		rg_emit_sound_exept_me(g_iEnts[entity], entity, CHAN_AUTO, replacedSounds[snd], float(volume) / 255.0, attenuation, fFlags, pitch, 0, fOrigin);
	
	if (get_gametime() - g_fFakeTime > 0.1)
	{
		g_fFakeTime = get_gametime();
		
		fOrigin[0] = floatclamp(fOrigin[0] + random_float(200.0,700.0),-8190.0,8190.0);
		fOrigin[1] = floatclamp(fOrigin[1] - random_float(200.0,700.0),-8190.0,8190.0);
		fOrigin[2] = floatclamp(fOrigin[2] + random_float(-100.0,100.0),-8190.0,8190.0);
		emit_fake_sound(fOrigin,float(volume) / 255.0, attenuation,fFlags, pitch);
	}
	
	return HC_BREAK;
}