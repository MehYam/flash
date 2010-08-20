package behaviors
{
	import flash.geom.Point;
	
	import karnold.utils.MathUtil;
	import karnold.utils.Util;
	
	import scripts.TankActor;

	public class AmmoFireSource
	{
		private var _ammoType:AmmoType;
		private var _damage:Number;
		private var _offsetX:Number;
		private var _offsetY:Number;
		private var _angle:Number;
		private var _level:uint;
		
		public function AmmoFireSource(type:AmmoType, damage:Number, x:Number, y:Number, angle:Number = 0, level:uint = 0)
		{
			_ammoType = type;
			_damage = damage;
			_offsetX = x;
			_offsetY = y;
			_angle = angle;
			_level = level;
		}

		static private var po_tmp:Point = new Point;
		public function fire(game:IGame, actor:Actor, damageMultiplier:Number = 1):Actor
		{
			AssetManager.instance.laserSound();
			var ammo:Actor;
			switch(_ammoType) {
				case AmmoType.BULLET:
					ammo = Actor.createBullet(_level);
					break;
				case AmmoType.LASER:
				case AmmoType.HIGHLASER:
					ammo = Actor.createLaser(_level);
					break;
				case AmmoType.ROCKET:
					ammo = Actor.createRocket(_level);
					break;
				case AmmoType.FUSION:
					ammo = Actor.createFusionBlast();
					break;
				case AmmoType.SHIELD:
					ammo = Actor.createShield();
					break;
			}
			ammo.damage = _damage * damageMultiplier;
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
			return ammo;
		}
	}
}