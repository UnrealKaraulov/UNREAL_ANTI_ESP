#include <amxmodx>
#include <reapi>
#include <fakemeta>
#include <easy_cfg>

#pragma ctrlchar '\'

new PLUGIN_NAME[] = "UNREAL ANTI-ESP";
new PLUGIN_VERSION[] = "3.0 PRE-ALPHA";
new PLUGIN_AUTHOR[] = "Karaulov";

#define MAX_ENTS_FOR_SOUNDS 15
new g_iEnts[MAX_ENTS_FOR_SOUNDS] = {0,...};

#define MAX_CHANNEL CHAN_STREAM
new g_iChannelReplacement[MAX_PLAYERS + 1][MAX_CHANNEL + 1];

new g_sSoundClassname[64] = "info_target";
new g_sFakePath[64] = "player/pl_step5.wav";

new bool:g_bRepeatChannelMode = false;
new bool:g_bGiveSomeRandom = false;
new bool:g_bPlayerConnected[MAX_PLAYERS + 1] = {false,...};
new bool:g_bReinstallNewSounds = false;

new g_iCurEnt = 0;
new g_iCurChannel = 0;
new g_iFakeEnt = 0;

new g_iReplaceSounds = 0;

new Float:g_fFakeTime = 0.0;


public plugin_init()
{
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);
	create_cvar("unreal_no_esp", PLUGIN_VERSION, FCVAR_SERVER | FCVAR_SPONLY);

	g_iFakeEnt = rg_create_entity("info_target");
	if (!g_iFakeEnt)
	{
		set_fail_state("Can't create fake entity");
		return;
	}
	set_entvar(g_iFakeEnt,var_classname, g_sSoundClassname);

	g_iEnts[0] = rg_create_entity("info_target");
	if (!g_iEnts[0])
	{
		set_fail_state("Can't create sound entity");
		return;
	}
	set_entvar(g_iEnts[0],var_classname, g_sSoundClassname);

	RegisterHookChain(RH_SV_StartSound, "RH_SV_StartSound_hook",0);

	for (new i = 0; i <= MAX_PLAYERS; i++) 
	{
		for (new j = 0; j < MAX_CHANNEL; j++) 
		{
			g_iChannelReplacement[i][j] = 0;
		}
	}
}

new bool:one_time_channel_warn = true;

public fill_entity_and_channel(id, channel)
{
	if (channel > MAX_CHANNEL || channel <= 0)
		return 0;

	if (!g_bRepeatChannelMode)
	{
		if (g_iChannelReplacement[id][channel] != 0)
			return g_iChannelReplacement[id][channel];
	}	
	
	g_iCurChannel++;
	if (g_iCurChannel > MAX_CHANNEL)
	{
		g_iCurChannel = 1;
		g_iCurEnt++;
		if (g_iCurEnt < MAX_ENTS_FOR_SOUNDS)
		{
			g_iEnts[g_iCurEnt] = rg_create_entity("info_target");
			if (!g_iEnts[g_iCurEnt])
			{
				set_fail_state("Can't create sound entity");
				return 0;
			}
			set_entvar(g_iEnts[g_iCurEnt],var_classname, g_sSoundClassname);
		}
		else 
		{
			if (one_time_channel_warn && !g_bRepeatChannelMode)
			{
				one_time_channel_warn = false;
				log_amx("Too many sound entities, please increase MAX_ENTS_FOR_SOUNDS in anti_esp.sma\n");
			}
			g_iCurEnt = 0;
		}
	}

	g_iChannelReplacement[id][channel] = PackChannelEnt(g_iCurChannel,g_iCurEnt);
	return g_iChannelReplacement[id][channel];
}

new precached_sounds[512] = {0,...};

new Array:originalSounds;
new Array:replacedSounds;

public InitDefaultSoundArray()
{
	ArrayPushString(originalSounds, "player/pl_step1.wav");
	ArrayPushString(originalSounds, "player/pl_step2.wav");
	ArrayPushString(originalSounds, "player/pl_step3.wav");
	ArrayPushString(originalSounds, "player/pl_step4.wav");
	ArrayPushString(originalSounds, "player/pl_dirt1.wav");
	ArrayPushString(originalSounds, "player/pl_dirt2.wav");
	ArrayPushString(originalSounds, "player/pl_dirt3.wav");
	ArrayPushString(originalSounds, "player/pl_dirt4.wav");
	ArrayPushString(originalSounds, "player/pl_duct1.wav");
	ArrayPushString(originalSounds, "player/pl_duct2.wav");
	ArrayPushString(originalSounds, "player/pl_duct3.wav");
	ArrayPushString(originalSounds, "player/pl_duct4.wav");
	ArrayPushString(originalSounds, "player/pl_grate1.wav");
	ArrayPushString(originalSounds, "player/pl_grate2.wav");
	ArrayPushString(originalSounds, "player/pl_grate3.wav");
	ArrayPushString(originalSounds, "player/pl_grate4.wav");
	ArrayPushString(originalSounds, "player/pl_metal1.wav");
	ArrayPushString(originalSounds, "player/pl_metal2.wav");
	ArrayPushString(originalSounds, "player/pl_metal3.wav");
	ArrayPushString(originalSounds, "player/pl_metal4.wav");
	ArrayPushString(originalSounds, "player/pl_ladder1.wav");
	ArrayPushString(originalSounds, "player/pl_ladder2.wav");
	ArrayPushString(originalSounds, "player/pl_ladder3.wav");
	ArrayPushString(originalSounds, "player/pl_ladder4.wav");
	ArrayPushString(originalSounds, "player/pl_slosh1.wav");
	ArrayPushString(originalSounds, "player/pl_slosh2.wav");
	ArrayPushString(originalSounds, "player/pl_slosh3.wav");
	ArrayPushString(originalSounds, "player/pl_slosh4.wav");
	ArrayPushString(originalSounds, "player/pl_snow1.wav");
	ArrayPushString(originalSounds, "player/pl_snow2.wav");
	ArrayPushString(originalSounds, "player/pl_snow3.wav");
	ArrayPushString(originalSounds, "player/pl_snow4.wav");
	ArrayPushString(originalSounds, "player/pl_snow5.wav");
	ArrayPushString(originalSounds, "player/pl_snow6.wav");
	ArrayPushString(originalSounds, "player/pl_swim1.wav");
	ArrayPushString(originalSounds, "player/pl_swim2.wav");
	ArrayPushString(originalSounds, "player/pl_swim3.wav");
	ArrayPushString(originalSounds, "player/pl_swim4.wav");
	ArrayPushString(originalSounds, "player/pl_tile1.wav");
	ArrayPushString(originalSounds, "player/pl_tile2.wav");
	ArrayPushString(originalSounds, "player/pl_tile3.wav");
	ArrayPushString(originalSounds, "player/pl_tile4.wav");
	ArrayPushString(originalSounds, "player/pl_tile5.wav");
	ArrayPushString(originalSounds, "player/pl_wade1.wav");
	ArrayPushString(originalSounds, "player/pl_wade2.wav");
	ArrayPushString(originalSounds, "player/pl_wade3.wav");
	ArrayPushString(originalSounds, "player/pl_wade4.wav");

	new rnd_str[64];

	if (g_bReinstallNewSounds)
	{
		for(new i = 0; i < ArraySize(originalSounds); i++)
		{
			RandomSoundPostfix("pl_shell/",rnd_str,charsmax(rnd_str));
			ArrayPushString(replacedSounds, rnd_str);
		}
	}
	else 
	{
		for(new i = 0; i < ArraySize(originalSounds); i++)
		{
			StandSoundPostfix("pl_shell/",rnd_str,charsmax(rnd_str));
			ArrayPushString(replacedSounds, rnd_str);
		}
	}
}

public client_putinserver(id)
{
	if (!is_user_bot(id) && !is_user_hltv(id))
	{
		g_bPlayerConnected[id] = true;
	}
	else 
	{
		g_bPlayerConnected[id] = false;
	}
}

public client_disconnected(id)
{
	g_bPlayerConnected[id] = false;
}

public PrecacheSound(const szSound[])
{
	static tmpstr[64];
	for(new i = 0; i < ArraySize(originalSounds); i++)
	{
		ArrayGetString(originalSounds, i, tmpstr, charsmax(tmpstr));
		if( equali(szSound,tmpstr) )
		{
			ArrayGetString(replacedSounds, i, tmpstr, charsmax(tmpstr));
			if (precached_sounds[i] == 0)
			{
				set_fail_state("No sound/%s found!", tmpstr);
				return FMRES_IGNORED;
			}
			forward_return(FMV_CELL, tmpstr);
			return FMRES_SUPERCEDE;
		}
	}
	return FMRES_IGNORED;
}

public plugin_end()
{
	ArrayDestroy(originalSounds);
	ArrayDestroy(replacedSounds);
}

public plugin_precache()
{
	cfg_set_path("/plugins/anti_esp.cfg");
	
	RandomString(g_sSoundClassname, 15);
	g_sSoundClassname[5] = '_';

	originalSounds = ArrayCreate(64);
	replacedSounds = ArrayCreate(64);

	cfg_read_str("general","fake_path",g_sFakePath,g_sFakePath,charsmax(g_sFakePath));
	cfg_read_str("general","ent_classname",g_sSoundClassname,g_sSoundClassname,charsmax(g_sSoundClassname));
	cfg_read_bool("general","repeat_channel_mode", g_bRepeatChannelMode, g_bRepeatChannelMode);
	cfg_read_bool("general","more_random_mode", g_bGiveSomeRandom, g_bGiveSomeRandom);
	cfg_read_bool("general","reinstall_with_new_sounds", g_bReinstallNewSounds, g_bReinstallNewSounds);
	if (g_bReinstallNewSounds)
		cfg_write_bool("general","reinstall_with_new_sounds",false);
	cfg_read_int("sounds","sounds",g_iReplaceSounds,g_iReplaceSounds);

	new tmp_sound[64];
	new tmp_sound_dest[64];

	if (g_iReplaceSounds == 0 || g_bReinstallNewSounds)
	{
		InitDefaultSoundArray();
		g_iReplaceSounds = ArraySize(originalSounds);
		cfg_write_int("sounds","sounds",g_iReplaceSounds);
		
		if (!dir_exists("sound/pl_shell",true))
			mkdir("sound/pl_shell", _, true, "GAMECONFIG");
	}

	new tmp_arg[64];
	for(new i = 0; i < g_iReplaceSounds; i++)
	{
		if (i < ArraySize(originalSounds))
		{
			ArrayGetString(originalSounds, i, tmp_sound, charsmax(tmp_sound));
			ArrayGetString(replacedSounds, i, tmp_sound_dest, charsmax(tmp_sound_dest));

			formatex(tmp_arg,charsmax(tmp_arg),"sound_%i_default", i + 1);
			cfg_write_str("sounds",tmp_arg,tmp_sound);
			formatex(tmp_arg,charsmax(tmp_arg),"sound_%i_replace", i + 1);
			cfg_write_str("sounds",tmp_arg,tmp_sound_dest);
		}
		else 
		{
			formatex(tmp_arg,charsmax(tmp_arg),"sound_%i_default", i + 1);
			cfg_read_str("sounds",tmp_arg,tmp_sound,tmp_sound,charsmax(tmp_sound));
			formatex(tmp_arg,charsmax(tmp_arg),"sound_%i_replace", i + 1);
			cfg_read_str("sounds",tmp_arg,tmp_sound_dest,tmp_sound_dest,charsmax(tmp_sound_dest));
		}
		ArrayPushString(originalSounds,tmp_sound);
		ArrayPushString(replacedSounds,tmp_sound_dest);

		if (!sound_exists(tmp_sound_dest))
		{
			formatex(tmp_arg,charsmax(tmp_arg),"sound/%s",tmp_sound_dest);

			trim_to_dir(tmp_arg);
			if (!dir_exists(tmp_arg, true))
			{
				mkdir(tmp_arg, _, true, "GAMECONFIG");
			}
			
			formatex(tmp_arg,charsmax(tmp_arg),"sound/%s",tmp_sound);
			formatex(tmp_sound,charsmax(tmp_sound),"sound/%s",tmp_sound_dest);

			MoveSoundWithRandomTail(tmp_arg,tmp_sound);

			if (!sound_exists(tmp_sound_dest))
			{
				set_fail_state("Fail while move %s to %s",tmp_sound,tmp_sound_dest);
				return;
			}
		}
	}

	if (!sound_exists(g_sFakePath))
	{
		formatex(tmp_sound,charsmax(tmp_sound),"sound/%s",g_sFakePath);
		CreateSilentWav(tmp_sound, random_float(0.1,0.25))
	}

	if (!sound_exists(g_sFakePath))
	{
		set_fail_state("No sound/%s found!",g_sFakePath);
		return;
	}
	
	precache_sound(g_sFakePath);
	
	for(new i = 0; i < ArraySize(replacedSounds);i++)
	{
		ArrayGetString(replacedSounds, i, tmp_arg, charsmax(tmp_arg));
		if (!sound_exists(tmp_arg))
		{
			set_fail_state("No sound/%s found!", tmp_arg);
			return;
		}
		precached_sounds[i] = precache_sound(tmp_arg);
	}
	
	log_amx("anti_esp loaded");
	log_amx("Settings:");
	log_amx("  g_sSoundClassname = %s", g_sSoundClassname);
	log_amx("  g_sFakePath = %s", g_sFakePath);
	log_amx("  g_bRepeatChannelMode = %i", g_bRepeatChannelMode);
	log_amx("  g_bGiveSomeRandom = %i", g_bGiveSomeRandom);
	log_amx("  g_iReplaceSounds = %i", g_iReplaceSounds);
	register_forward(FM_PrecacheSound, "PrecacheSound");
}

rg_emit_sound_exept_me(const entity, const recipient, const channel, const sample[], Float:vol = VOL_NORM, Float:attn = ATTN_NORM, const flags = 0, const pitch = PITCH_NORM, emitFlags = 0, const Float:origin[3] = {0.0,0.0,0.0})
{
	set_entvar(entity,var_origin,origin);
	for(new i = 1; i < MAX_PLAYERS + 1; i++)
	{
		if (g_bPlayerConnected[i] && i != recipient)
		{
			if (channel == CHAN_STREAM)
				rh_emit_sound2(entity, i, channel, sample, vol, attn, SND_STOP, pitch, emitFlags, origin);
			rh_emit_sound2(entity, i, channel, sample, vol, attn, flags, pitch, emitFlags, origin);
		}
	}
	new Float:vOrigin_fake[3];
	vOrigin_fake[0] = random_float(-8190.0,8190.0);
	vOrigin_fake[1] = random_float(-8190.0,8190.0);
	vOrigin_fake[2] = random_float(-200.0,200.0);
	set_entvar(entity,var_origin,vOrigin_fake);
}

rg_emit_sound_all(const entity, const channel, const sample[], Float:vol = VOL_NORM, Float:attn = ATTN_NORM, const flags = 0, const pitch = PITCH_NORM, emitFlags = 0, const Float:origin[3] = {0.0,0.0,0.0})
{
	set_entvar(entity,var_origin,origin);
	for(new i = 1; i < MAX_PLAYERS + 1; i++)
	{
		if (g_bPlayerConnected[i])
		{
			if (channel == CHAN_STREAM)
				rh_emit_sound2(entity, i, channel, sample, vol, attn, SND_STOP, pitch, emitFlags, origin);
			rh_emit_sound2(entity, i, channel, sample, vol, attn, flags, pitch, emitFlags, origin);
		}
	}
	new Float:vOrigin_fake[3];
	vOrigin_fake[0] = random_float(-8190.0,8190.0);
	vOrigin_fake[1] = random_float(-8190.0,8190.0);
	vOrigin_fake[2] = random_float(-200.0,200.0);
	set_entvar(entity,var_origin,vOrigin_fake);
}

emit_fake_sound(Float:origin[3], Float:volume, Float:attenuation, const fFlags, const pitch, const channel)
{
	set_entvar(g_iFakeEnt,var_origin,origin);
	for(new i = 1; i < MAX_PLAYERS + 1; i++)
	{
		if (g_bPlayerConnected[i])
		{
			rh_emit_sound2(g_iFakeEnt, i, channel, g_sFakePath, volume, attenuation, fFlags, pitch, 0, origin);
		}
	}
}

public RH_SV_StartSound_hook(const recipients, const entity, const channel, const sample[], const volume, Float:attenuation, const fFlags, const pitch)
{
	new snd = 0;

	if (entity > MAX_PLAYERS || entity < 1)
	{
		return HC_CONTINUE;
	}
	
	new Float:vOrigin[3];
	new Float:vOrigin_fake[3];
	get_entvar(entity,var_origin, vOrigin);

	if (get_gametime() - g_fFakeTime > 0.1)
	{
		g_fFakeTime = get_gametime();
		
		vOrigin_fake[0] = floatclamp(vOrigin[0] + random_float(200.0,700.0),-8190.0,8190.0);
		vOrigin_fake[1] = floatclamp(vOrigin[1] - random_float(200.0,700.0),-8190.0,8190.0);
		vOrigin_fake[2] = floatclamp(vOrigin[2] + random_float(-100.0,100.0),-8190.0,8190.0);
		emit_fake_sound(vOrigin_fake,float(volume) / 255.0, attenuation,fFlags, pitch,channel);
	}
	
	new tmp_sample[64];
	// todo: speedup with hash?
	for (snd = 0; snd < ArraySize(originalSounds); snd++)
	{
		ArrayGetString(originalSounds, snd, tmp_sample, charsmax(tmp_sample));
		if (equal(sample,tmp_sample))
		{	
			ArrayGetString(replacedSounds, snd, tmp_sample, charsmax(tmp_sample));
			SetHookChainArg(4,ATYPE_STRING,tmp_sample)
			break;
		}
		tmp_sample[0] = EOS;
	}
	
	new pack_ent_chan = fill_entity_and_channel(entity, channel);
	if (pack_ent_chan == 0)
	{
		return HC_CONTINUE;
	}

	new new_chan = UnpackChannel(pack_ent_chan);
	new new_ent = g_iEnts[UnpackEntId(pack_ent_chan)];

	if (new_ent <= MAX_PLAYERS)
	{
		set_fail_state("Failed to unpack entity or channel from packed value!");
		return HC_CONTINUE;
	}
	
	new Float:vol_mult = 255.0;
	if (g_bGiveSomeRandom)
	{
		vol_mult = 255.0 + random_float(0.0,0.5);
		attenuation = attenuation + random_float(0.0,0.01);
	}

	if(recipients == 0)
		rg_emit_sound_all(new_ent, new_chan, tmp_sample[0] == EOS ? sample : tmp_sample, float(volume) / vol_mult, attenuation, fFlags, pitch, 0, vOrigin);
	else 
		rg_emit_sound_exept_me(new_ent, entity, new_chan, tmp_sample[0] == EOS ? sample : tmp_sample, float(volume) / vol_mult, attenuation, fFlags, pitch, 0, vOrigin);
	
	return HC_BREAK;
}

#define WAVE_FORMAT_PCM 1
#define BITS_PER_SAMPLE 8
#define NUM_CHANNELS 1
#define SAMPLE_RATE 22050

stock MoveSoundWithRandomTail(const path[], const dest[])
{
	new file = fopen(path, "rb", true, "GAMECONFIG");
	if (!file)
	{
		set_fail_state("Failed to open WAV source %s file.", path);
		return;
	}
	
	new file_dest = fopen(dest, "wb", true, "GAMECONFIG");
	if (!file_dest)
	{
		set_fail_state("Failed to open WAV dest %s file.", dest);
		return;
	}

	static buffer_blocks[512];
	static buffer_byte;

	fseek(file, 0, SEEK_SET);
	fseek(file_dest, 0, SEEK_SET);

	// header
	fread(file, buffer_byte, BLOCK_INT);
	fwrite(file_dest, buffer_byte, BLOCK_INT);

	// size
	new rnd_tail = random(50);
	new fileSize;
	fread(file, fileSize, BLOCK_INT);
	fwrite(file_dest, fileSize + rnd_tail, BLOCK_INT);

	// other data
	new read_bytes = 0;
	while((read_bytes = fread_blocks(file, buffer_blocks, sizeof(buffer_blocks), BLOCK_BYTE)))
	{
		fwrite_blocks(file_dest, buffer_blocks, read_bytes, BLOCK_BYTE );
	}

	fclose(file);
	// tail (unsafe but it works!)
	for(new i = 0; i < rnd_tail; i++)
	{
		fwrite(file_dest, 0, BLOCK_BYTE);
	}
	fclose(file_dest);
}

stock CreateSilentWav(const path[],Float:duration = 1.0)
{
    new dataSize = floatround(duration * SAMPLE_RATE); // Total samples
    new fileSize = 44 + dataSize - 8; 

    new file = fopen(path, "wb", true, "GAMECONFIG");
    if (file)
    {
        // Writing the WAV header
		// 1179011410 = "RIFF"
        fwrite(file, 1179011410, BLOCK_INT);
        fwrite(file, fileSize, BLOCK_INT); // File size - 8
		// 1163280727 = "WAVE"
        fwrite(file, 1163280727, BLOCK_INT);
		// 544501094 == "fmt "
        fwrite(file, 544501094, BLOCK_INT);
        fwrite(file, 16, BLOCK_INT); // Subchunk1Size (16 for PCM)
        fwrite(file, WAVE_FORMAT_PCM, BLOCK_SHORT); // Audio format (1 for PCM)
        fwrite(file, NUM_CHANNELS, BLOCK_SHORT); // NumChannels
        fwrite(file, SAMPLE_RATE, BLOCK_INT); // SampleRate
        fwrite(file, SAMPLE_RATE * NUM_CHANNELS * BITS_PER_SAMPLE / 8, BLOCK_INT); // ByteRate
        fwrite(file, NUM_CHANNELS * BITS_PER_SAMPLE / 8, BLOCK_SHORT); // BlockAlign
        fwrite(file, BITS_PER_SAMPLE, BLOCK_SHORT); // BitsPerSample
		// 1635017060 = "data"
        fwrite(file, 1635017060, BLOCK_INT);
        fwrite(file, dataSize, BLOCK_INT); // Subchunk2Size

        // Writing the silent audio data
        for (new i = 0; i < dataSize; i++)
        {
            fwrite(file, 128, BLOCK_BYTE); // Middle value for 8-bit PCM to represent silence
        }

        fclose(file);
    }
    else
    {
        set_fail_state("Failed to create WAV file.");
    }
}

new const g_CharSet[] = "abcdefghijklmnopqrstuvwxyz";

stock RandomString(dest[], length)
{
    new i, randIndex;
    new charsetLength = strlen(g_CharSet);

    for (i = 0; i < length; i++)
    {
        randIndex = random(charsetLength);
        dest[i] = g_CharSet[randIndex];
    }

    dest[length - 1] = EOS;  // Null-terminate the string
}

RandomSoundPostfix(const prefix[], dest[], length)
{
	static rnd_postfix = 0;
	if (rnd_postfix == 0)
		rnd_postfix = random_num(30100000, 99999999);

	
	formatex(dest,length,"%s%i.wav",prefix,rnd_postfix);

	new hash[64];
	hash_string(dest, Hash_Md5, hash, charsmax(hash));

	formatex(dest,length,"%s%s.wav",prefix,hash);


	rnd_postfix-=random_num(1,10000);
	if (rnd_postfix < 10010000) 
		rnd_postfix = 99999999;
}

StandSoundPostfix(const prefix[], dest[], length)
{
	static stnd_postfix = 59999999;
	formatex(dest,length,"%s%i.wav",prefix,stnd_postfix);

	new hash[64];
	hash_string(dest, Hash_Md5, hash, charsmax(hash));

	formatex(dest,length,"%s%s.wav",prefix,hash);

	stnd_postfix-= 599;
	if (stnd_postfix < 10000599) 
		stnd_postfix = 99999999;
}

stock PackChannelEnt(num1, num2)
{
    return (num1 & 0xFF) | ((num2 & 0xFFFFFF) << 8);
}

stock UnpackChannel(packedNum)
{
    return packedNum & 0xFF;
}

stock UnpackEntId(packedNum)
{
    return (packedNum >> 8) & 0xFFFFFF;
}

stock bool:sound_exists(path[])
{
	new fullpath[256];
	formatex(fullpath,charsmax(fullpath),"sound/%s",path)
	return file_exists(fullpath,true) > 0;
}

stock trim_to_dir(path[])
{
    new len = strlen(path);
    len--;
    for(new i = len; i >= 0; i--)
    {
        if(path[i] == '/' || path[i] == '\\')
        {
            path[i] = EOS;
            break;
        }
    }
}