/*
 * Copyright (c) 2010-2021 Tormentor667, Ozymandias81, AFADoomer
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
**/

// BoA Torches converted to ZScript; original DECORATE was from Demonic Uprising
class BoAWallTorchBase : EffectSpawner
{
	class<Actor> flame;
	int frameoffset;

	Property Flame:flame;
	Property FrameOffset:frameoffset;

	Default
	{
		//$Category Lights (BoA)/ACS Switchable
		//$Color 11
		Radius 10;
		Scale 0.50;
		+FIXMAPTHINGPOS
		+NOBLOCKMAP
		+NOGRAVITY
		-SOLID
		EffectSpawner.SwitchVar "boa_torchtype";
		+EffectSpawner.DONTCULL
		+EffectSpawner.ALLOWTICKDELAY
	}

	States
	{
		Spawn:
			WLTR Y 0;
		Active:
			WLTR # 3 BRIGHT Light("WALLTORCH") SpawnEffect();
			Loop;
		Inactive:
			WLTR Y -1;
			Stop;
	}

	override void SpawnEffect()
	{
		Super.SpawnEffect();

		if (!CheckSightOrRange(boa_sfxlod / 4, true))
		{
			A_SpawnItemEx(flame, FRandom[Torch](-2.0, 2.0), FRandom[Torch](-2.0, 2.0), FRandom[Torch](34.0, 36.0), 0.001 * FRandom[Torch](10.0, 200.0), 0.001 * FRandom[Torch](10.0, 200.0), 0.001 * FRandom[Torch](500.0, 1000.0), 0, SXF_SETMASTER | SXF_CLIENTSIDE);

			frame = 24; // Y Frame
		}
		else // Use sprite-based flame if out of range
		{
			frame = frameoffset + ++frame % 8; // Rotate through 8 frames, starting with frameoffset (0 = A)
			tics = 4;
		}
	}

	override void Activate(Actor activator)
	{
		A_StartSound("Ignite");

		bDormant = false;
		SetStateLabel("Active");
	}

	override void Deactivate(Actor activator)
	{
		A_RemoveChildren(TRUE, RMVF_MISC);

		Super.Deactivate(activator);
	}
}

class BoAWallTorch1 : BoAWallTorchBase
{
	Default
	{
		//$Title 2d Wall Torch (SWITCHABLE)
		BoaWallTorchBase.Flame "RedFire";
		BoaWallTorchBase.FrameOffset 0; // What sprite does the sprite version start on? (0 = A, 1 = B, etc.)
	}
}

class BoAWallTorch2 : BoAWallTorchBase
{
	Default
	{
		//$Title 2d Wall Torch, Zyklon (SWITCHABLE)
		BoaWallTorchBase.Flame "ZykFire";
		BoaWallTorchBase.FrameOffset 8;
	}

	States
	{
		Active:
			WLTR # 3 BRIGHT Light("WALLTORC2") SpawnEffect();
			Loop;
	}
}

class BoAWallTorch3 : BoAWallTorchBase
{
	Default
	{
		//$Title 2d Wall Torch, Mutant (SWITCHABLE)
		BoaWallTorchBase.Flame "MutFire";
		BoaWallTorchBase.FrameOffset 16;
	}

	States
	{
		Active:
			WLTR # 3 BRIGHT Light("WALLTORC3") SpawnEffect();
			Loop;
	}
}

class TorchFireBase : ParticleBase
{
	Default
	{
		DistanceCheck "boa_sfxlod";
		RenderStyle "Add";
		Alpha 0.0;
		Scale 0.175;
		+BRIGHT
		+FORCEXYBILLBOARD
		+NOGRAVITY
		+NOINTERACTION
	}

	States
	{
		Spawn:
			"####" AAABBB 1 A_FadeIn(0.16);
			"####" BCDEFG 3;
			"####" HIJKL 2 A_FadeOut(0.15);
			Stop;
		Frames:
			FIR1 A 0;
			FIR2 A 0;
			FIR3 A 0;
			FIR4 A 0;
			FIR5 A 0;
			FIR6 A 0;
	}
}

class RedFire : TorchFireBase
{
	override void PostBeginPlay()
	{
		Super.PostBeginPlay();

		int spr = GetSpriteIndex("FIR" .. Random[Torch](1, 2));
		if (spr != -1) { sprite = spr; }
	}
}

class ZykFire : TorchFireBase
{
	override void PostBeginPlay()
	{
		Super.PostBeginPlay();

		int spr = GetSpriteIndex("FIR" .. Random[Torch](3, 4));
		if (spr != -1) { sprite = spr; }
	}
}

class MutFire : TorchFireBase
{
	override void PostBeginPlay()
	{
		Super.PostBeginPlay();

		int spr = GetSpriteIndex("FIR" .. Random[Torch](5, 6));
		if (spr != -1) { sprite = spr; }
	}
}