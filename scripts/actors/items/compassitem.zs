/*
 * Copyright (c) 2018-2020 AFADoomer
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

class CompassItem : PuzzleItem
{
	String iconName;
	int specialclue, savetime;
	class<Inventory> alternate0, alternate1;

	Property SpecialClue:specialclue;
	Property Alternates: alternate0, alternate1; // Items that get removed if they are already in the inventory when this item is given (e.g., remove halves of an egyptian artifact when you are given the whole artifact)

	Default
	{
		//$Category Pickups (BoA)
		//$Color 13
		-NOGRAVITY
		+INVENTORY.ALWAYSPICKUP
		+INVENTORY.UNDROPPABLE
		-INVENTORY.INVBAR
		Inventory.MaxAmount 1;
		Inventory.PickupSound "misc/gadget_pickup"; // Default to sounding like a generic item pickup
		Scale 0.5;
	}

	override void PostBeginPlay()
	{
		iconName = "";

		// Try to use the inventory icon as the compass icon
		iconName = TexMan.GetName(icon);

		// Otherwise fall back to using the spawn sprite
		if (iconName == "")
		{
			TextureID iconTex = CurState.GetSpriteTexture(0);
			iconName = TexMan.GetName(iconTex);
		}

		BoACompass.Add(self, iconName);

		Super.PostBeginPlay();
	}

	override bool TryPickup(in out Actor toucher)
	{
		let current = toucher.FindInventory(GetClass()); // Check if it's already in player inventory...

		// Handling so that items properly check the max amount before giving items to the player
		// and taking money or items - but always pick up specialclue items or script-running items.
		if (specialclue || special) { bAlwaysPickup = true; }
		else if (current)
		{
			// Don't force pickup in excess of MaxAmount
			if (maxamount <= 1 || (maxamount > 0 && current.Amount + Amount > maxamount))
			{
				bAlwaysPickup = false; // This flag is checked in the internal Inventory pickup logic, regardless of the return value here.
				return false;
			}
		}

		bool pickup = PickupChecks(toucher);

		if (pickup && specialclue == 3)
		{
			TextureID tex = SpawnState.GetSpriteTexture(0);
			String texName = TexMan.GetName(tex);

			// If it belongs to this chapter and gets added, autosave on pickup so we don't have to deal with clearing the entries if we die.
			if (MapStatsHandler.AddSpecialPickup(texName, specialclue)) { savetime = level.maptime + 1; }
		}

		return pickup;
	}

	bool PickupChecks(in out Actor toucher)
	{
		Actor p =  players[consoleplayer].mo;
		bool pickup = false;

		if (toucher.player && multiplayer && !deathmatch && toucher != p)
		{
			bAutoActivate = false;
			pickup = Inventory.TryPickup(p);
			String msg = ZScriptTools.OwnedMessage(toucher, PickupMessage());
			PrintPickupMessage(p.CheckLocalView(), msg);
		}
		else
		{
			pickup = Inventory.TryPickup(toucher);
		}

		return pickup;
	}

	override bool HandlePickup(Inventory item)
	{
		return Inventory.HandlePickup(item);
	}

	override void Tick()
	{
		Super.Tick();

		if (owner) { RemoveAlternates(); }
		if (savetime > 0 && savetime == level.maptime) { level.MakeAutoSave(); }
	}

	void RemoveAlternates()
	{
		if (owner)
		{
			Inventory item;

			item = owner.FindInventory(alternate0);
			if (item) { item.Destroy(); }

			item = owner.FindInventory(alternate1);
			if (item) { item.Destroy(); }
		}
	}

	override bool ShouldStay ()
	{
		return false;
	}
}