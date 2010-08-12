package behaviors
{
	import flash.geom.Point;
	
	import karnold.utils.MathUtil;
	import karnold.utils.Util;
	
	import scripts.TankActor;

	public class AmmoFireSource
	{
		private var _ammoType:AmmoType;
		private var _offsetX:Number;
		private var _offsetY:Number;
		private var _angle:Number;
		
		public function AmmoFireSource(type:AmmoType, x:Number, y:Number, angle:Number = 0)
		{
			_ammoType = type;
			_offsetX = x;
			_offsetY = y;
			angle = angle;
		}

		static private var po_tmp:Point = new Point;
		public function fire(game:IGame, actor:Actor, damageMultiplier:Number = 1):void
		{
			AssetManager.instance.laserSound();
			var ammo:Actor;
			switch(_ammoType) {
				case AmmoType.BULLET:
					ammo = Actor.createBullet(0);
					break;
				case AmmoType.LASER:
				case AmmoType.HIGHLASER:
					ammo = Actor.createLaser(0);
					break;
				case AmmoType.ROCKET:
					ammo = Actor.createRocket();
					break;
				case AmmoType.FUSION:
					ammo = Actor.createFusionBlast();
					break;
			}
			ammo.damage *= damageMultiplier;
			const angle:Number = actor is TankActor ? (TankActor(actor).turretRotation) : actor.displayObject.rotation;

			Util.setPoint(po_tmp, actor.worldPos);
			po_tmp.offset(_offsetX, _offsetY);
			
			MathUtil.rotatePoint(actor.worldPos, po_tmp, angle);
			ammo.launchDegrees(po_tmp, angle);
			if (game.player == actor)
			{
				game.addPlayerAmmo(ammo);
			}
			else
			{
				game.addEnemyAmmo(ammo);
			}
		}
	}
}