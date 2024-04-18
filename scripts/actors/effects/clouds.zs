class CloudSpawner : EffectSpawner
{
	static const string cloudsprites[] = { "CLXGA0", "CLXGB0", "CLXTA0", "CLXTB0", "CLXDA0", "CLXDB0" };
	double minspeed, maxspeed, s;
	int i;

	Default
	{
		//$Category Special Effects (BoA)
		//$Title Cloudstorm Spawner (arg1 xRadius, arg2 zRadius, arg3 Chance, arg4 Size, arg5 Color; Renderstyle, Stencilcolor and Scale are taken into account)
		//$Color 12
		//$Arg0 "Radius(x/y)"
		//$Arg0Tooltip "Radius of spawn area in map units"
		//$Arg1 "Height(z)"
		//$Arg1Tooltip "Height of spawn area in map units"
		//$Arg2 "Frequency"
		//$Arg2Tooltip "0 is always, 255 is never at a 30-tic basis"
		//$Arg3 "Size"
		//$Arg3Type 11
		//$Arg3Enum { 0 = "Small"; 1 = "Medium"; 2 = "Large"; }
		//$Arg4 "Color"
		//$Arg4Type 11
		//$Arg4Enum { 0 = "Grey (slow)"; 1 = "Tan (slow)"; 2 = "Dark (fast)"; }

		+CLIENTSIDEONLY
		+NOBLOCKMAP
		+NOCLIP
		+NOGRAVITY
		+NOINTERACTION
		+NOSECTOR
		+EffectSpawner.ALLOWTICKDELAY
	}

	States
	{
		Spawn:
			TNT1 A 0;
		Active:
			TNT1 A 30 SpawnEffect();
			Loop;
		Death:
			"####" "#" 5 A_FadeOut(0.05, FTF_REMOVE);
			Loop;
	}

	override void PostBeginPlay()
	{
		s = 4.0;
		Switch(args[3])
		{
			case 0:
				s = 1.0;
				break;
			case 1:
				s = 2.0;
				break;
			default:
			case 2:
				break;
		}

		i = 0;
		Switch(args[4])
		{
			default:
				minspeed = 5.0;
				maxspeed = 8.0;
				break;
			case 1:
				i = 1;
				minspeed = 5.0;
				maxspeed = 8.0;
				break;
			case 2:
				i = 2;
				minspeed = 40.0;
				maxspeed = 70.0;
				break;
		}
		Super.PostBeginPlay();
	}

	override void SpawnEffect()
	{
		Super.SpawnEffect();
		if (Random[Clouds](0, 255) < Args[2]) { return; }

		TextureID cloud = TexMan.CheckForTexture(cloudsprites[2 * i + Random[Clouds](0, 1)]);

		double spawnAngle = Actor.deltaangle(-angle, FRandom[Clouds](-6, 6));
		Vector2 spawnPos = (FRandom[Clouds](args[0]*2,-args[0]*2), FRandom[Clouds](args[0]*2,-args[0]*2)); // relative
		spawnPos = Actor.RotateVector(spawnPos, spawnAngle); // relative
		double spawnZ = FRandom[Clouds](0, args[1]);
		Vector3 particlePos = Vec3Offset(spawnPos.X, spawnPos.Y, spawnZ); // absolute

		double particleSpeed = FRandom[Clouds](minspeed, maxspeed);
		Vector3 traceDirection;
		traceDirection.XY = Actor.AngleToVector(spawnAngle, 1);
		Vector3 particleVel = traceDirection * particleSpeed;

		Sector spawnSector = Level.PointInSector(particlePos.XY);
		BoASolidSurfaceFinderTracer surfFinder = new("BoASolidSurfaceFinderTracer");
		surfFinder.Trace(particlePos, spawnSector, traceDirection, 10000.0, TRACE_HitSky);
		int lifetime = int(surfFinder.results.Distance / particleSpeed);

		FSpawnParticleParams particleInfo;
		particleInfo.color1 = "FFFFFF";
		particleInfo.texture = cloud;
		particleInfo.style = GetRenderStyle(); // SXF_TRANSFERRENDERSTYLE
		particleInfo.flags = SPF_ROLL;
		particleInfo.lifetime = lifetime;

		particleInfo.size = 384 * s;

		particleInfo.pos = particlePos;
		particleInfo.vel = particleVel;
		particleInfo.accel = (0., 0., 0.);

		particleInfo.startalpha = 0.5;

		particleInfo.rollvel = FRandom[Clouds](1.3, 2.0);

		Level.SpawnParticle(particleInfo);
	}
}

